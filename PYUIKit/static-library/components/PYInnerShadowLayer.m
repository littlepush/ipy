//
//  PYInnerShadowLayer.m
//  PYUIKit
//
//  Created by Chen Push on 3/8/13.
//  Copyright (c) 2013 Markphone Culture Media Co.Ltd. All rights reserved.
//

#import "PYInnerShadowLayer.h"

// Compare two shadow rect
BOOL PYShadowRectCompare(PYShadowRect r1, PYShadowRect r2)
{
    return (PYFLOATEQUAL(r1.left, r2.left) &&
            PYFLOATEQUAL(r1.right, r2.right) &&
            PYFLOATEQUAL(r1.top, r2.top) &&
            PYFLOATEQUAL(r1.bottom, r2.bottom));
}

// Check if the shadow rect is zero
BOOL PYShadowRectIsZero(PYShadowRect rect)
{
    return PYShadowRectCompare(rect, (PYShadowRect){0, 0, 0, 0});
}

@implementation PYInnerShadowLayer

@synthesize outCornerRadius, innerShadowColor, shadowRect;

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
    CGFloat _maxPadding = MAX(
                              MAX(self.shadowRect.left, self.shadowRect.right),
                              MAX(self.shadowRect.top, self.shadowRect.bottom)
                              );
    _noShadowRect.origin.x -= ABS(_maxPadding - self.shadowRect.left);
    _noShadowRect.origin.y -= (ABS(_maxPadding - self.shadowRect.top) + 1);
    _noShadowRect.size.width += ABS(_maxPadding - self.shadowRect.left);
    _noShadowRect.size.width += ABS(_maxPadding - self.shadowRect.right);
    _noShadowRect.size.height += ABS(_maxPadding - self.shadowRect.top);
    _noShadowRect.size.height += (ABS(_maxPadding - self.shadowRect.bottom) + 1);
    
    // Create the no shadow path
    CGPathRef _noShadowPath =
    [UIBezierPath bezierPathWithRoundedRect:_noShadowRect
                               cornerRadius:self.outCornerRadius].CGPath;
    
    CGPathRef _outterBorderPath =
        [UIBezierPath bezierPathWithRoundedRect:CGRectInset(_noShadowRect, -_maxPadding, -_maxPadding)
                                   cornerRadius:self.outCornerRadius].CGPath;
    
    CGContextAddPath(ctx, _outterBorderPath);
    CGContextAddPath(ctx, _noShadowPath);
    
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), _maxPadding, self.innerShadowColor.CGColor);
    CGContextEOFillPath(ctx);
}

@end
