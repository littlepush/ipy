//
//  PYInnerGlowLayer.m
//  PYUIKit
//
//  Created by Chen Push on 3/14/13.
//  Copyright (c) 2013 Markphone Culture Media Co.Ltd. All rights reserved.
//

#import "PYInnerGlowLayer.h"

@implementation PYInnerGlowLayer

@synthesize outCornerRadius, innerGlowColor, glowRect;

- (id)init
{
    self = [super init];
    if ( self ) {
        self.contentsScale = [UIScreen mainScreen].scale;
    }
    return self;
}

- (void)drawInContext:(CGContextRef)ctx
{
    // min no shadow rect size
    CGRect _noShadowRect = self.bounds;
    
    // resize the min space with shadow rect
    _noShadowRect.origin.x = self.glowRect.left;
    _noShadowRect.origin.y = self.glowRect.top;
    _noShadowRect.size.width = self.bounds.size.width - (self.glowRect.left + self.glowRect.right);
    _noShadowRect.size.height = self.bounds.size.height - (self.glowRect.top + self.glowRect.bottom);
    
    // Create the no shadow path
    CGPathRef _noShadowPath =
    [UIBezierPath bezierPathWithRoundedRect:_noShadowRect
                               cornerRadius:self.outCornerRadius].CGPath;
    
    CGPathRef _outterBorderPath =
        [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, -5.f, -5.f)
                                   cornerRadius:self.outCornerRadius].CGPath;
    
    CGContextAddPath(ctx, _outterBorderPath);
    CGContextAddPath(ctx, _noShadowPath);
    
    CGContextSetFillColorWithColor(ctx, self.innerGlowColor.CGColor);
    CGContextEOFillPath(ctx);
}

@end
