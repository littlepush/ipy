//
//  PYImageCache.m
//  PYUIKit
//
//  Created by Push Chen on 3/9/13.
//  Copyright (c) 2013 Markphone Culture Media Co.Ltd. All rights reserved.
//

#import "PYImageCache.h"
#import <CommonCrypto/CommonDigest.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <dirent.h>
#include <unistd.h>
#include <sys/stat.h>
#import "UIImage+animatedGIF.h"

static PYImageCache                     *gImageCache;

@interface PYImageCache ()

// Store the cache path
- (NSString *)_cachePath;

// Md5 the file name of each image
- (NSString *)_md5sumForFileName:(NSString *)originFileName;

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

// Singleton
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if ( gImageCache == nil ) {
            gImageCache = [super allocWithZone:zone];
        }
    }
    return gImageCache;
}

+ (PYImageCache *)sharedImageCache
{
    @synchronized(self) {
        if ( gImageCache == nil ) {
            gImageCache = [[PYImageCache alloc] init];
        }
    }
    return gImageCache;
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
        NSArray *paths = NSSearchPathForDirectoriesInDomains
            (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        __cacheDir =
            [documentDirectory stringByAppendingPathComponent:@"PYUIKit.ImageCache.Temp"];
    }
    
    return __cacheDir;
}
- (NSString *)_md5sumForFileName:(NSString *)originFileName
{
    const char *cStr = [originFileName UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (void)_reorganizeCache
{
	if ( _currentCacheSize <= _maxCacheSize ) return;
	do {
		NSString *_key = [_keyCache lastObject];
        UIImage *_image = [_coreCache objectForKey:_key];
		_currentCacheSize -= [self _dataSizeOfImage:_image];
		[_coreCache removeObjectForKey:_key];
		[_keyCache removeLastObject];
	} while( _currentCacheSize > _maxCacheSize );
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
    if ( image == nil || [imgKey length] ==0 ) return;
    if ( [_coreCache objectForKey:imgKey] != nil )
        [_keyCache removeObject:imgKey];
    [_coreCache setObject:image forKey:imgKey];
    [_keyCache insertObject:imgKey atIndex:0];
    
    int _imageSize = [self _dataSizeOfImage:image];
    
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
        _currentCacheSize = 0;
        _maxCacheSize = 10 * 1024 * 1024;		// 10MB
        self.imageCacheDays = 10;
        
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
                         [self _md5sumForFileName:imageName]]];
    if ( _imgData == nil ) return nil;
    PYImageType _type = [PYImageCache contentTypeForImageData:_imgData];
    if ( _type == PYImageTypeGIF ) {
        return [UIImage animatedImageWithAnimatedGIFData:_imgData];
    } else {
        return [UIImage imageWithData:_imgData];
    }
}

// get an image by the name(or url), return nil on File-Not-Found
// this message will use [imageFromData] and cache the image object
// in the memory.
- (UIImage *)imageByName:(NSString *)imageName
{
    // Try to check the keys
	NSString *_innerFileKey = [self _md5sumForFileName:imageName];
    NSString *_filePath = [[self _cachePath] stringByAppendingPathComponent:_innerFileKey];
    @synchronized(self) {
        
        // Check in-men cache first
        UIImage *_image = [self _imageCacheForKey:_innerFileKey];
        if ( _image != nil ) return _image;
        
        // Check file's date
        if ( self.imageCacheDays != 0 ) {
            struct stat st;
            time_t _createDate;
            if ( 0 != stat(_filePath.UTF8String, &st) )
                _createDate = -1;
            else _createDate = st.st_ctimespec.tv_sec;
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
        PYImageType _imgType = [PYImageCache contentTypeForImageData:_fdata];
        if ( _imgType == PYImageTypeGIF ) {
            _image = [UIImage animatedImageWithAnimatedGIFData:_fdata];
        }
        if ( _image == nil ) {
            _image = [UIImage imageWithData:_fdata];
        }
        if ( _image == nil ) return _image;
        // put the image into cache
        [self _setImageCache:_image forKey:_innerFileKey];
        return _image;
    }
}

// save an image as specified image name.
// the image will be save in the cache and file both.
- (void)setImage:(NSData *)imageData forName:(NSString *)imageName
{
    if ( imageData == nil || [imageName length] == 0 ) return;
    NSString *_innerKey = [self _md5sumForFileName:imageName];
    NSString *_filePath = [[self _cachePath] stringByAppendingPathComponent:_innerKey];
    @synchronized(self) {
        if ( [imageData writeToFile:_filePath atomically:YES] ) {
            PYImageType _imgType = [PYImageCache contentTypeForImageData:imageData];
            UIImage *_image = nil;
            if ( _imgType == PYImageTypeGIF ) {
                _image = [UIImage animatedImageWithAnimatedGIFData:imageData];
            }
            if ( _image == nil ) {
                _image = [UIImage imageWithData:imageData];
            }
            if (_image == nil ) return;
            [self _setImageCache:_image forKey:_innerKey];
        }
    }
}

// save an image directly to the disk.
// the image will not be put in the cache.
- (void)saveImage:(NSData *)imageData forName:(NSString *)imageName
{
    NSString *_innerKey = [self _md5sumForFileName:imageName];
    NSString *_filePath = [[self _cachePath] stringByAppendingPathComponent:_innerKey];
    @synchronized(self) {
        [imageData writeToFile:_filePath atomically:YES];
    }
}

// delete the image from both cache and file
- (void)removeImageByName:(NSString *)imageName
{
    NSString *_innerKey = [self _md5sumForFileName:imageName];
    NSString *_filePath = [[self _cachePath] stringByAppendingPathComponent:_innerKey];
    @synchronized(self) {
        [self _removeImageFromCacheForKey:_innerKey];
        NSFileManager *_fm = [NSFileManager defaultManager];
        if ( [_fm fileExistsAtPath:_filePath] ) {
            NSError *_error;
            [_fm removeItemAtPath:_filePath error:&_error];
            if ( !_error ) {
                @throw [_error localizedDescription];
            }
        }
    }
}

@end
