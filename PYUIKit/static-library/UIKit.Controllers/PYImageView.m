//
//  PYImageView.m
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

#import "PYImageView.h"
#import "PYImageLayer.h"

@implementation PYImageView

+ (Class)layerClass
{
    return [PYImageLayer class];
}

@dynamic layer;
- (PYImageLayer *)layer
{
    return (PYImageLayer *)[super layer];
}

- (PYImageView *)initWithPlaceholdImage:(UIImage *)image
{
    self = [super init];
    if ( self ) {
        self.layer.placeholdImage = image;
    }
    return self;
}

+ (PYImageView *)viewWithPlaceholdImage:(UIImage *)image
{
    return [[PYImageView alloc] initWithPlaceholdImage:image];
}

@dynamic image;
- (UIImage *)image
{
    return self.layer.image;
}

- (void)setImage:(UIImage *)anImage
{
    [self.layer setImage:anImage];
}

@dynamic placeholdImage;
- (UIImage *)placeholdImage
{
    return self.layer.placeholdImage;
}
- (void)setPlaceholdImage:(UIImage *)anImage
{
    [self.layer setPlaceholdImage:anImage];
}

@dynamic loadingUrl;
- (NSString *)loadingUrl
{
    return self.layer.loadingUrl;
}

- (void)setImageUrl:(NSString *)imageUrl
{
    [self.layer setImageUrl:imageUrl];
}

- (void)setContentMode:(UIViewContentMode)contentMode
{
    [super setContentMode:contentMode];
    [self.layer setContentMode:contentMode];
}

- (void)refreshContent
{
    [self.layer refreshContent];
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
