//
//  PYView.m
//  PYUIKit
//
//  Created by Chen Push on 3/8/13.
//  Copyright (c) 2013 Markphone Culture Media Co.Ltd. All rights reserved.
//

#import "PYView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PYView

// Corner Radius
@synthesize cornerRadius;
- (void)setCornerRadius:(CGFloat)radius
{
    [self.layer setCornerRadius:radius];
}

// Inner Shadow Setting
@synthesize innerShadowColor;
@synthesize innerShadowRect;

// Inner Glow Setting
@synthesize innerGlowColor;
@synthesize innerGlowRect;

// Border
@synthesize borderWidth;
- (void)setBorderWidth:(CGFloat)width
{
    [self.layer setBorderWidth:width];
}
@synthesize borderColor;
- (void)setBorderColor:(UIColor *)aColor
{
    [self.layer setBorderColor:aColor.CGColor];
}

// Drop Shadow
@synthesize dropShadowColor;
@synthesize dropShadowRadius;
@synthesize dropShadowOpacity;
@synthesize dropShadowOffset;
@synthesize dropShadowRect;

@synthesize gradientType;
@synthesize gradientColors;
@synthesize gradientLocations;

#pragma mark -
#pragma mark Gradient Colors
// if set gradient color, the background color or image will be ignore
- (void)setGradientBackgroundColorFrom:(UIColor *)fromColor to:(UIColor *)toColor
{
    if ( fromColor == nil || toColor == nil ) {
        return;
    }
    self.gradientColors = [NSArray arrayWithObjects:fromColor, toColor, nil];
}
// A serious of colors and locations
- (void)setGradientColors:(NSArray *)colors locations:(NSArray *)locations
{
    self.gradientColors = [NSArray arrayWithArray:colors];
    self.gradientLocations = [NSArray arrayWithArray:locations];
}


#pragma mark -
#pragma mark Override Messages
- (void)viewJustBeenCreated
{
    [self setClipsToBounds:YES];
    // Do nothing
}

#pragma mark -
#pragma mark Override UIView Messages
- (id)init
{
    self = [super init];
    if ( self ) {
        [self viewJustBeenCreated];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self ) {
        [self viewJustBeenCreated];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self ) {
        [self viewJustBeenCreated];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    if ( CGRectEqualToRect(self.frame, frame) ) return;
    [super setFrame:frame];
    if ( _dropShadowLayer != nil ) {
        [_dropShadowLayer setFrame:frame];
    }
    if ( _innerShadowLayer != nil ) {
        [_innerShadowLayer setFrame:self.bounds];
    }
    if ( _innerGlowLayer != nil ) {
        [_innerGlowLayer setFrame:self.bounds];
    }
    if ( _gradientLayer != nil ) {
        [_gradientLayer setFrame:self.bounds];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    // Check Drop Shadow
    if ( self.dropShadowColor != nil && _dropShadowLayer == nil ) {
        _dropShadowLayer = [CALayer layer];
        [_dropShadowLayer setBackgroundColor:[UIColor blackColor].CGColor];
        [_dropShadowLayer setFrame:self.frame];
        [self.superview.layer insertSublayer:_dropShadowLayer below:self.layer];
    }
    if ( _dropShadowLayer != nil ) {
        [_dropShadowLayer setShadowColor:self.dropShadowColor.CGColor];
        [_dropShadowLayer setShadowOpacity:self.dropShadowOpacity];
        [_dropShadowLayer setShadowOffset:self.dropShadowOffset];
        [_dropShadowLayer setShadowPath:
         [UIBezierPath bezierPathWithRoundedRect:self.dropShadowRect
                                    cornerRadius:self.layer.cornerRadius].CGPath];
        [_dropShadowLayer setShadowRadius:self.dropShadowRadius];
        [_dropShadowLayer setNeedsDisplay];
    }
    
    // Check Gradient Background
    if ( [self.gradientColors count] > 2 && _gradientLayer == nil ) {
        _gradientLayer = [CAGradientLayer layer];
        // set the gradient layer to the bottom of the layer
        [self.layer insertSublayer:_gradientLayer atIndex:0];
        [_gradientLayer setFrame:self.bounds];        
    }
    if ( _gradientLayer != nil ) {
        // If anything has been changed...
        if ( [self.layer.sublayers objectAtIndex:0] != _gradientLayer ) {
            [_gradientLayer removeFromSuperlayer];
            [self.layer insertSublayer:_gradientLayer atIndex:0];
        }
        
        NSMutableArray *_gradientColors = [NSMutableArray array];
        for ( id _color in self.gradientColors ) {
            if ( ![_color isKindOfClass:[UIColor class]] ) continue;
            [_gradientColors addObject:(id)(((UIColor *)_color).CGColor)];
        }
        [_gradientLayer setColors:_gradientColors];
        if ( [self.gradientLocations count] > 0 )
            [_gradientLayer setLocations:self.gradientLocations];        
    }
    
    // Inner Shadow
    if ( self.innerShadowColor != nil && _innerShadowLayer == nil ) {
        // Create the inner shadow layer
        _innerShadowLayer = [[PYInnerShadowLayer alloc] init];
        // Set the _innerShadowLayer as the top sub layer
        [_innerShadowLayer setFrame:self.bounds];
        [self.layer addSublayer:_innerShadowLayer];
    }
    if ( _innerShadowLayer != nil ) {
        // Set the properties.
        [_innerShadowLayer setInnerShadowColor:self.innerShadowColor];
        [_innerShadowLayer setShadowRect:self.innerShadowRect];
        [_innerShadowLayer setOutCornerRadius:self.layer.cornerRadius];

        // Set frame and draw the layer
        [_innerShadowLayer setNeedsDisplay];
    }
    
    if ( self.innerGlowColor != nil && _innerGlowLayer == nil ) {
        _innerGlowLayer = [[PYInnerGlowLayer alloc] init];
        [self.layer addSublayer:_innerGlowLayer];
        [_innerGlowLayer setFrame:self.bounds];
    }
    if ( _innerGlowLayer != nil ) {
        // Set the properties.
        [_innerGlowLayer setInnerGlowColor:self.innerGlowColor];
        [_innerGlowLayer setGlowRect:self.innerGlowRect];
        [_innerGlowLayer setOutCornerRadius:self.layer.cornerRadius];
        
        // Set frame and draw the layer
        [_innerGlowLayer setNeedsDisplay];
    }
}

@end
