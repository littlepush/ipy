//
//  PYImageLayer.h
//  PYUIKit
//
//  Created by Push Chen on 7/29/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import "PYLayer.h"
#import <QuartzCore/QuartzCore.h>

@interface PYImageLayer : PYLayer
{
    CATiledLayer                    *_contentLayer;
    // Inner Image Data
    UIImage                         *_image;
    UIImage                         *_placeholdImage;
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

@end
