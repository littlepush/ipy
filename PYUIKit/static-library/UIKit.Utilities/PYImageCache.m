//
//  PYImageCache.m
//  PYUIKit
//
//  Created by Push Chen on 7/29/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

/*
 LISENCE FOR IPY
 COPYRIGHT (c) 2013, Push Chen.
 ALL RIGHTS RESERVED.
 
 REDISTRIBUTION AND USE IN SOURCE AND BINARY
 FORMS, WITH OR WITHOUT MODIFICATION, ARE
 PERMITTED PROVIDED THAT THE FOLLOWING CONDITIONS
 ARE MET:
 
 YOU USE IT, AND YOU JUST USE IT!.
 WHY NOT USE THIS LIBRARY IN YOUR CODE TO MAKE
 THE DEVELOPMENT HAPPIER!
 ENJOY YOUR LIFE AND BE FAR AWAY FROM BUGS.
 */

#import "PYImageCache.h"
#import <CommonCrypto/CommonDigest.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <dirent.h>
#include <unistd.h>
#include <sys/stat.h>
#import "UIImage+UIKit.h"

static PYImageCache                     *_gPYImageCache;

@interface PYImageCache ()

// Cache Path of Images
- (NSString *)_cachePath;

// Reorganize the in-mem cache
- (void)_reorganizeCache;

// Inner Memory Cache Messages
- (UIImage *)_imageCacheForKey:(NSString *)imgKey;
- (void)_setImageCache:(UIImage *)image forKey:(NSString *)imgKey;
- (void)_removeImageFromCacheForKey:(NSString *)imgKey;

// Get the memory alloced for the image
- (size_t)_dataSizeOfImage:(UIImage *)image;

// Get the image type by the data.
+ (PYImageType)contentTypeForImageData:(NSData *)data;

@end

@implementation PYImageCache
@synthesize imageCacheDays;

PYSingletonAllocWithZone(_gPYImageCache);
PYSingletonDefaultImplementation;

+ (PYImageCache *)sharedImageCache
{
    @synchronized(self) {
        if ( _gPYImageCache == nil ) {
            _gPYImageCache = __RETAIN([PYImageCache object]);
        }
    }
    return _gPYImageCache;
}

#pragma mark --
#pragma mark Internal

+ (PYImageType)contentTypeForImageData:(NSData *)data
{
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return PYImageTypeJPEG;
        case 0x89:
            return PYImageTypePNG;
        case 0x47:
            return PYImageTypeGIF;
        case 0x49:
        case 0x4D:
            return PYImageTypeTIFF;
    }
    return PYImageTypePNG;
}

- (NSString *)_cachePath
{
    static NSString *__cacheDir = @"";
    if ( [__cacheDir length] == 0 ) {
        // Need to initialize the cache dir
        __cacheDir = [PYCACHEPATH
                      stringByAppendingPathComponent:
                      @"PYUIKit.ImageCache.Temp"];
    }
    
    return __cacheDir;
}

- (void)_reorganizeCache
{
	while( _currentCacheSize > _maxCacheSize ) {
		NSString *_key = [_keyCache lastObject];
        UIImage *_image = [_coreCache objectForKey:_key];
		_currentCacheSize -= [self _dataSizeOfImage:_image];
		[_coreCache removeObjectForKey:_key];
		[_keyCache removeLastObject];
	}
}

// Inner Memory Cache Messages
- (UIImage *)_imageCacheForKey:(NSString *)imgKey
{
    UIImage *_image = [_coreCache objectForKey:imgKey];
    if ( _image == nil ) return _image;
    
    [_keyCache removeObject:imgKey];
    [_keyCache insertObject:imgKey atIndex:0];
    
    [self _reorganizeCache];
    return _image;
}

- (void)_setImageCache:(UIImage *)image forKey:(NSString *)imgKey
{
    if ( image == nil || [imgKey length] == 0 ) return;
    if ( [_coreCache objectForKey:imgKey] != nil )
        [_keyCache removeObject:imgKey];
    [_coreCache setObject:image forKey:imgKey];
    [_keyCache insertObject:imgKey atIndex:0];
    
    NSUInteger _imageSize = [self _dataSizeOfImage:image];
    
    _currentCacheSize += _imageSize;
    [self _reorganizeCache];
}

- (void)_removeImageFromCacheForKey:(NSString *)imgKey
{
    [_keyCache removeObject:imgKey];
    [_coreCache removeObjectForKey:imgKey];
}

- (size_t)_dataSizeOfImage:(UIImage *)image
{
    int _height = image.size.height;
    int _width = image.size.width;
    int _rowBytes = 4 * _width;
    if ( _rowBytes % 16 ) _rowBytes = ((_rowBytes / 16) + 1) * 16;
    return _height * _rowBytes;
}

#pragma mark --
#pragma mark Instance Message

- (id)init
{
    self = [super init];
    if ( self ) {
        // Init the mutex.
        _mutex = [PYMutex object];
        //_mutex.enableDebug = YES;
        
        _currentCacheSize = 0;
        _maxCacheSize = 5 * PYMegaByte;		// 5MB
        self.imageCacheDays = 7;
        
        _coreCache = [NSMutableDictionary dictionary];
        _keyCache = [NSMutableArray array];
        
        // check the cache directory
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL dir = NO;
        BOOL exist = [fm fileExistsAtPath:[self _cachePath] isDirectory:&dir];
        
        if ( !exist ) {
            NSError *_error = nil;
            [fm createDirectoryAtPath:[self _cachePath] withIntermediateDirectories:YES
                           attributes:nil error:&_error];
            if ( _error != nil ) {
                @throw [_error localizedDescription];
            }
        } else if ( exist && (dir == NO) ) {
            @throw @"Failed to create the file cache directory";
        }
        
        _imageLoadingQueue = [[NSOperationQueue alloc] init];
        _pendingList = [NSMutableDictionary dictionary];
    }
    return self;
}

// load an image direct from the file and not store into the cache.
// when try to load an image from web and maybe very large, use
// this method to avoid out-of-memory warning.
- (UIImage *)imageByNameWithNoCache:(NSString *)imageName
{
    NSData *_imgData = [NSData
                        dataWithContentsOfFile:
                        [[self _cachePath] stringByAppendingPathComponent:
                         [imageName md5sum]]];
    if ( _imgData == nil ) return nil;
    return [UIImage PYImageWithData:_imgData];
}

// get an image by the name(or url), return nil on File-Not-Found
// this message will use [imageFromData] and cache the image object
// in the memory.
- (UIImage *)imageByName:(NSString *)imageName
{
    // Try to check the keys
	NSString *_innerFileKey = [imageName md5sum];
    NSString *_filePath = [[self _cachePath] stringByAppendingPathComponent:_innerFileKey];
    //@synchronized(self) {
    return [_mutex lockAndDo:^id{
        // Check in-men cache first
        UIImage *_image = [self _imageCacheForKey:_innerFileKey];
        if ( _image != nil ) return _image;
        
        // Check file's date
        if ( self.imageCacheDays != 0 ) {
            struct stat st;
            time_t _createDate = -1;
            if ( 0 == stat(_filePath.UTF8String, &st) )
                _createDate = st.st_ctimespec.tv_sec;
            time_t _nowSec = time(NULL);
            
            // Release the file if expired
            if ( (_nowSec - _createDate) >= (self.imageCacheDays * 86400) ) {
                remove( _filePath.UTF8String );
                // The image should be fetch again from the source URL;
                return nil;
            }
        }
        
        NSData *_fdata = [NSData dataWithContentsOfFile:_filePath];
        // no such image file in disk
        if ( _fdata == nil ) return nil;
        _image = [UIImage PYImageWithData:_fdata];
        if ( _image == nil ) return nil;
        
        // put the image into cache
        [self _setImageCache:_image forKey:_innerFileKey];
        return _image;
    }];
    //}
}

// save an image as specified image name.
// the image will be save in the cache and file both.
- (UIImage *)setImage:(NSData *)imageData forName:(NSString *)imageName
{
    if ( imageData == nil || [imageName length] == 0 ) return nil;
    NSString *_innerKey = [imageName md5sum];
    NSString *_filePath = [[self _cachePath] stringByAppendingPathComponent:_innerKey];
    //@synchronized(self) {
    return [_mutex lockAndDo:^id{
        UIImage *_image = [UIImage PYImageWithData:imageData];
        if ( _image == nil ) return nil;
        if ( [imageData writeToFile:_filePath atomically:YES] ) {
            [self _setImageCache:_image forKey:_innerKey];
        }
        return _image;
    }];
    //}
}

// save an image directly to the disk.
// the image will not be put in the cache.
- (void)saveImage:(NSData *)imageData forName:(NSString *)imageName
{
    if ( imageData == nil || [imageName length] == 0 ) return;
    NSString *_innerKey = [imageName md5sum];
    NSString *_filePath = [[self _cachePath] stringByAppendingPathComponent:_innerKey];
    //@synchronized(self) {
    [_mutex lockAndDo:^id{
        [imageData writeToFile:_filePath atomically:YES];
        return nil;
    }];
    //}
}

// delete the image from both cache and file
- (void)removeImageByName:(NSString *)imageName
{
    NSString *_innerKey = [imageName md5sum];
    NSString *_filePath = [[self _cachePath] stringByAppendingPathComponent:_innerKey];
    //@synchronized(self) {
    [_mutex lockAndDo:^id{
        [self _removeImageFromCacheForKey:_innerKey];
        NSFileManager *_fm = [NSFileManager defaultManager];
        if ( [_fm fileExistsAtPath:_filePath] ) {
            NSError *_error;
            [_fm removeItemAtPath:_filePath error:&_error];
            if ( !_error ) {
                @throw [_error localizedDescription];
            }
        }
        return nil;
    }];
    //}
}

// Load the image from bundle or network
- (void)loadImageNamed:(NSString *)imageName get:(PYImageCacheLoadedImage)get
{
    if ( get == nil ) return;
    //@synchronized( self ) {
    UIImage *_image = [self imageByName:imageName];
    if ( _image != nil ) {
        get( _image, imageName );
        return;
    }
    [_mutex lockAndDo:^id{
        NSMutableArray *_pendingObserverList = [_pendingList objectForKey:imageName];
        if ( _pendingObserverList == nil ) {
            // Add new operation
            __weak PYImageCache *_wss = self;
            _pendingObserverList = [NSMutableArray array];
            [_pendingObserverList addObject:get];
            [_pendingList setObject:_pendingObserverList forKey:imageName];
            
            // Start the loading queue.
            [_imageLoadingQueue addOperationWithBlock:^{
                NSURL *_url = [NSURL URLWithString:imageName];
                NSURLRequest *_request = [NSURLRequest requestWithURL:_url];
                NSURLResponse *_response;
                NSError *_error;
                NSData *_data = [NSURLConnection
                                 sendSynchronousRequest:_request
                                 returningResponse:&_response
                                 error:&_error];
                if ( _error != nil ) {
                    NSLog(@"failed to load the image: %@", _error.localizedDescription);
                    return;
                }
                if ( _data == nil || [_data length] == 0 ) {
                    NSLog(@"the image is invalidate.");
                    return;
                }
                //@synchronized ( _bss ) {
                dispatch_async( dispatch_get_main_queue(), ^{
                    __strong PYImageCache *_bss = _wss;
                    UIImage *_netImage = [_bss setImage:_data forName:imageName];
                    NSMutableArray *_loadingObservers = [_bss->_pendingList objectForKey:imageName];
                    if ( _loadingObservers == nil ) return;
                    for ( PYImageCacheLoadedImage _get in _loadingObservers ) {
                        // Push the main thread...
                        _get(_netImage, imageName);
                    }
                    [_bss->_pendingList removeObjectForKey:imageName];
                });
                //}
            }];
        } else {
            // Add getter to the list
            [_pendingObserverList addObject:get];
        }
        return nil;
    }];
    //}
}

- (void)eraseAllCachedImages:(PYActionDone)done failed:(PYActionFailed)failed
{
    [_imageLoadingQueue addOperationWithBlock:^{
        [_mutex lockAndDo:^id{
            NSFileManager *fm = [NSFileManager defaultManager];
            NSError *_error = nil;
            // Remove the cache folder
            [fm removeItemAtPath:[self _cachePath] error:&_error];
            if ( _error != nil ) {
                if ( failed ) failed(_error);
                return nil;
            }
            
            // Recreate the folder
            [fm createDirectoryAtPath:[self _cachePath] withIntermediateDirectories:YES
                           attributes:nil error:&_error];
            if ( _error != nil ) {
                if ( failed ) failed(_error);
            }
 
            if ( done ) {
                BEGIN_MAINTHREAD_INVOKE
                done();
                END_MAINTHREAD_INVOKE
            }
            
            return nil;
        }];
    }];
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
