//
//  PYImageLayer.h
//  PYUIKit
//
//  Created by Push Chen on 7/29/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import "PYStaticLayer.h"
#import <QuartzCore/QuartzCore.h>

// Predefine
@class PYTiledLayer;

@interface PYImageLayer : PYLayer
{
    PYTiledLayer                    *_contentLayer;
    // Inner Image Data
    UIImage                         *_image;
    UIImage                         *_placeholdImage;
    UIImage                         *_aspectImage;
    CGFloat                         _frameRate;
    NSString                        *_loadingUrl;
    PYMutex                         *_mutex;
}

// create the layer with the placehold image.
- (PYImageLayer *)initWithPlaceholdImage:(UIImage *)image;
+ (PYImageLayer *)layerWithPlaceholdImage:(UIImage *)image;

// The image to draw on the layer
@property (nonatomic, strong)	UIImage             *image;

// Placehold image.
@property (nonatomic, strong)   UIImage             *placeholdImage;

// Loading URL
@property (nonatomic, readonly) NSString            *loadingUrl;

// The content mode.
@property (nonatomic, assign)   UIViewContentMode   contentMode;

// Start to load the image from the URL
- (void)setImageUrl:(NSString *)imageUrl;

// Refresh the content after reset the frame.
- (void)refreshContent;

@end
