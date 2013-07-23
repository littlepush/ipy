//
//  PYView+Animation.m
//  PYUIKit
//
//  Created by Chen Push on 3/15/13.
//  Copyright (c) 2013 Markphone Culture Media Co.Ltd. All rights reserved.
//

#import "PYView+Animation.h"

@implementation PYView (Animation)

+ (void)animateWithDuration:(NSTimeInterval)duration
                      delay:(NSTimeInterval)delay
                    options:(UIViewAnimationOptions)options
                 animations:(void (^)(void))animations
                 completion:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:duration delay:delay options:options animations:^{
        [CATransaction begin];
        [CATransaction setAnimationDuration:duration];
        [CATransaction
         setAnimationTimingFunction:
            [CAMediaTimingFunction
             functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        // Do the animation.
        animations();
        
        [CATransaction commit];
    } completion:completion];
}

+ (void)animateWithDuration:(NSTimeInterval)duration
                 animations:(void (^)(void))animations
                 completion:(void (^)(BOOL finished))completion
{
    [PYView animateWithDuration:duration delay:0.f options:0 animations:animations completion:completion];
}

+ (void)animateWithDuration:(NSTimeInterval)duration
                 animations:(void (^)(void))animations
{
    [PYView animateWithDuration:duration delay:0.f options:0 animations:animations completion:NULL];
}

@end
