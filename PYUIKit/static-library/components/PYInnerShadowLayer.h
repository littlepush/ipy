//
//  PYInnerShadowLayer.h
//  PYUIKit
//
//  Created by Chen Push on 3/8/13.
//  Copyright (c) 2013 Markphone Culture Media Co.Ltd. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

// Inner Shadow Size Structure;
// For the inner shadow of each side in the view.
typedef struct {
    CGFloat                 left;
    CGFloat                 right;
    CGFloat                 top;
    CGFloat                 bottom;
} PYShadowRect;

// Create a shadow rect
static inline
PYShadowRect PYShadowRectMake(CGFloat l, CGFloat r, CGFloat t, CGFloat b)
{
    return (PYShadowRect){l, r, t, b};
}

// Create a shadow rect with all same padding size
static inline
PYShadowRect PYShadowRectWithPadding(CGFloat p)
{
    return (PYShadowRect){p, p, p, p};
}

// Create a shadow rect with only top
static inline
PYShadowRect PYShadowRectTop(CGFloat t)
{
    return (PYShadowRect){0, 0, t, 0};
}

// Compare two shadow rect
BOOL PYShadowRectCompare(PYShadowRect r1, PYShadowRect r2);

// Check if the shadow rect is zero
BOOL PYShadowRectIsZero(PYShadowRect rect);

@interface PYInnerShadowLayer : CALayer

@property (nonatomic, assign)   CGFloat         outCornerRadius;
@property (nonatomic, assign)   PYShadowRect    shadowRect;
@property (nonatomic, strong)   UIColor         *innerShadowColor;

@end
