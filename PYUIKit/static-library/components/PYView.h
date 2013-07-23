//
//  PYView.h
//  PYUIKit
//
//  Created by Chen Push on 3/8/13.
//  Copyright (c) 2013 Markphone Culture Media Co.Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PYInnerShadowLayer.h"
#import "PYInnerGlowLayer.h"

typedef enum {
    PYViewGradientTopBottom     = 0,
    PYViewGradientLeftRight     = 1
} PYViewGradientType;

@interface PYView : UIView
{
    PYInnerShadowLayer                              *_innerShadowLayer;
    CALayer                                         *_dropShadowLayer;
    CAGradientLayer                                 *_gradientLayer;
    PYInnerGlowLayer                                *_innerGlowLayer;
}

// Corner Radius
@property (nonatomic, assign)   CGFloat             cornerRadius;

// Inner Shadow Setting
@property (nonatomic, strong)   UIColor             *innerShadowColor;
@property (nonatomic, assign)   PYShadowRect        innerShadowRect;

// Inner Glow Setting
@property (nonatomic, strong)   UIColor             *innerGlowColor;
@property (nonatomic, assign)   PYShadowRect        innerGlowRect;

// Border
@property (nonatomic, assign)   CGFloat             borderWidth;
@property (nonatomic, strong)   UIColor             *borderColor;

// Drop Shadow
@property (nonatomic, strong)   UIColor             *dropShadowColor;
@property (nonatomic, assign)   CGFloat             dropShadowRadius;
@property (nonatomic, assign)   CGFloat             dropShadowOpacity;
@property (nonatomic, assign)   CGSize              dropShadowOffset;
@property (nonatomic, assign)   CGRect              dropShadowRect;

// Gradient Color
// Set the gradient direction
@property (nonatomic, assign)   PYViewGradientType  gradientType;
@property (nonatomic, strong)   NSArray             *gradientColors;
@property (nonatomic, strong)   NSArray             *gradientLocations;

// if set gradient color, the background color or image will be ignore
- (void)setGradientBackgroundColorFrom:(UIColor *)fromColor to:(UIColor *)toColor;
// A serious of colors and locations
- (void)setGradientColors:(NSArray *)colors locations:(NSArray *)locations;

// Default Messages
- (void)viewJustBeenCreated;

@end
