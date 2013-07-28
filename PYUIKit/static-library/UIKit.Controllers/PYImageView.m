//
//  PYImageView.m
//  PYUIKit
//
//  Created by Push Chen on 7/29/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

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

@end
