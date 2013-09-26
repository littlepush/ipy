//
//  PYView.m
//  PYUIKit
//
//  Created by Push Chen on 7/24/13.
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

#import "PYView.h"
#import "UIColor+PYUIKit.h"
#import "PYLayer.h"

@implementation PYView

// Make PYView to support debug
+ (void)setDebugEnabled:(BOOL)enableDebug
{
    [PYLayer setDebugEnabled:enableDebug];
}

@dynamic coreLayer;
- (PYLayer *)coreLayer
{
    return (PYLayer *)self.layer;
}

@dynamic layer;
- (PYLayer *)layer
{
    return (PYLayer *)[super layer];
}

// We use PYLayer as the default layer
+ (Class)layerClass
{
    return [PYLayer class];
}

- (void)viewJustBeenCreated
{
    // Default message
}

- (id)init
{
    self = [super init];
    if ( self ) {
        if ( _hasInvokeInit == NO ) {
            [self viewJustBeenCreated];
        }
        _hasInvokeInit = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self ) {
        if ( _hasInvokeInit == NO ) {
            [self viewJustBeenCreated];
        }
        _hasInvokeInit = YES;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self ) {
        if ( _hasInvokeInit == NO ) {
            [self viewJustBeenCreated];
        }
        _hasInvokeInit = YES;
    }
    return self;
}

- (void)dealloc
{
    if ( [PYLayer isDebugEnabled] ) {
        __formatLogLine(__FILE__, __FUNCTION__, __LINE__,
                        [NSString stringWithFormat:@"***[%@:%p] Dealloced [Layer: %p]***",
                         NSStringFromClass([self class]), self, self.layer]);
    }
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

// Add sub layer or sub view.
- (void)addChild:(id)child
{
    if ( [child isKindOfClass:[CALayer class]] ) {
        [self.layer addSublayer:child];
    } else if ( [child isKindOfClass:[UIView class]] ) {
        [self addSubview:child];
    }
}

// Properties
@dynamic cornerRadius;
- (CGFloat)cornerRadius
{
    return self.layer.cornerRadius;
}
- (void)setCornerRadius:(CGFloat)radius
{
    [self setClipsToBounds:(radius > 0.f)];
    [self.layer setCornerRadius:radius];
    if ( _shadowLayer == nil ) return;
    [_shadowLayer setFrame:self.bounds];
}

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
@dynamic dropShadowColor;
- (void)setDropShadowColor:(UIColor *)shadowColor
{
    self.layer.shadowColor = shadowColor.CGColor;
}
- (UIColor *)dropShadowColor
{
    return [UIColor colorWithCGColor:self.layer.shadowColor];
}
@dynamic dropShadowRadius;
- (void)setDropShadowRadius:(CGFloat)radius
{
    self.layer.shadowRadius = radius;
}
- (CGFloat)dropShadowRadius
{
    return self.layer.shadowRadius;
}
@dynamic dropShadowOpacity;
- (void)setDropShadowOpacity:(CGFloat)opacity
{
    self.layer.shadowOpacity = opacity;
}
- (CGFloat)dropShadowOpacity
{
    return self.layer.shadowOpacity;
}
@dynamic dropShadowOffset;
- (void)setDropShadowOffset:(CGSize)offset
{
    self.layer.shadowOffset = offset;
}
- (CGSize)dropShadowOffset
{
    return self.layer.shadowOffset;
}
@dynamic dropShadowPath;
- (UIBezierPath *)dropShadowPath
{
    return [UIBezierPath bezierPathWithCGPath:self.layer.shadowPath];
}
- (void)setDropShadowPath:(UIBezierPath *)shadowPath
{
    [self.layer setShadowPath:shadowPath.CGPath];
}

// Inner Shadow
@dynamic innerShadowRect;
- (PYPadding)innerShadowRect
{
    if ( _shadowLayer == nil ) return PYPaddingZero;
    return _shadowLayer.shadowPadding;
}
- (void)setInnerShadowRect:(PYPadding)innerShadowRect
{
    if ( _shadowLayer == nil ) {
        _shadowLayer = [PYInnerShadowLayer layer];
        _shadowLayer.zPosition = MAXFLOAT;
        [_shadowLayer setFrame:self.bounds];
        [self.layer addSublayer:_shadowLayer];
    }
    [_shadowLayer setShadowPadding:innerShadowRect];
    [_shadowLayer setNeedsDisplay];
}

@dynamic innerShadowColor;
- (UIColor *)innerShadowColor
{
    if ( _shadowLayer == nil ) return [UIColor clearColor];
    return _shadowLayer.innerShadowColor;
}
- (void)setInnerShadowColor:(UIColor *)aColor
{
    if ( _shadowLayer == nil ) {
        _shadowLayer = [PYInnerShadowLayer layer];
        _shadowLayer.zPosition = MAXFLOAT;
        [_shadowLayer setFrame:self.bounds];
        [self.layer addSublayer:_shadowLayer];
    }
    [_shadowLayer setInnerShadowColor:aColor];
    [_shadowLayer setNeedsDisplay];
}

// Override
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if ( _shadowLayer == nil ) return;
    [_shadowLayer setFrame:self.bounds];
    [_shadowLayer setNeedsDisplay];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if ( newSuperview == nil ) {
        if ( _shadowLayer != nil ) {
            [_shadowLayer removeFromSuperlayer];
            _shadowLayer = nil;
        }
    } else {
        if ( _shadowLayer != nil ) {
            //[_shadowLayer setFrame:self.bounds];
            [_shadowLayer setNeedsDisplay];
        }
    }
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
