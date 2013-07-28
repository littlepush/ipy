//
//  PYImageView.h
//  PYUIKit
//
//  Created by Push Chen on 7/29/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import "PYResponderView.h"
#import "PYImageLayer.h"

@interface PYImageView : PYView

@property (nonatomic, readonly) PYImageLayer        *layer;

// create the layer with the placehold image.
- (PYImageView *)initWithPlaceholdImage:(UIImage *)image;
+ (PYImageView *)viewWithPlaceholdImage:(UIImage *)image;

// The image to draw on the layer
@property (nonatomic, strong)	UIImage             *image;

// Placehold image.
@property (nonatomic, strong)   UIImage             *placeholdImage;

// Loading URL
@property (nonatomic, readonly) NSString            *loadingUrl;

// Start to load the image from the URL
- (void)setImageUrl:(NSString *)imageUrl;

@end
