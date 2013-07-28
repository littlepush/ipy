//
//  PYImageCache.h
//  PYUIKit
//
//  Created by Push Chen on 7/29/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define SHARED_IMAGECACHE               ([PYImageCache sharedImageCache])

typedef enum {
    PYImageTypePNG          = 0,        // Default
    PYImageTypeJPEG         = 1,
    PYImageTypeGIF          = 2,
    PYImageTypeTIFF         = 3
} PYImageType;

typedef void (^PYImageCacheLoadedImage)(UIImage *image, NSString *name);

@interface PYImageCache : NSObject
{
	long					_currentCacheSize;
	long					_maxCacheSize;
	
	NSMutableDictionary		*_coreCache;
	NSMutableArray			*_keyCache;
    
    NSOperationQueue        *_imageLoadingQueue;
    NSMutableDictionary     *_pendingList;
}

// How many days the cacher cache the image, default is 10 days
@property (nonatomic, assign)   int         imageCacheDays;

// Singleton Cache Instance
+ (PYImageCache *)sharedImageCache;

// Instance messages

// load an image direct from the file and not store into the cache.
// when try to load an image from web and maybe very large, use
// this method to avoid out-of-memory warning.
- (UIImage *)imageByNameWithNoCache:(NSString *)imageName;

// get an image by the name(or url), return nil on File-Not-Found
// this message will use [imageFromData] and cache the image object
// in the memory.
- (UIImage *)imageByName:(NSString *)imageName;

// save an image as specified image name.
// the image will be save in the cache and file both.
- (UIImage *)setImage:(NSData *)imageData forName:(NSString *)imageName;
//- (void)setImage:(UIImage *)image forName:(NSString *)imageName;

// save an image directly to the disk.
// the image will not be put in the cache.
- (void)saveImage:(NSData *)imageData forName:(NSString *)imageName;
//- (void)saveImage:(UIImage *)image forName:(NSString *)imageName;

// delete the image from both cache and file
- (void)removeImageByName:(NSString *)imageName;

// Load the image from bundle or network
- (void)loadImageNamed:(NSString *)imageName get:(PYImageCacheLoadedImage)get;

@end
