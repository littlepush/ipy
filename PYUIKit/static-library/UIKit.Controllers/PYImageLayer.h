//
//  PYImageLayer.h
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

// force to update content image, without re-draw, just set the content.
- (void)forceUpdateContentWithImage:(UIImage *)image;

// Refresh the content after reset the frame.
- (void)refreshContent;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
