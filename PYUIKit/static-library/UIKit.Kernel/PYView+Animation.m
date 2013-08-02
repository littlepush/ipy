//
//  PYView+Animation.m
//  PYUIKit
//
//  Created by Push Chen on 7/30/13.
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

#import "PYView+Animation.h"

@implementation PYView (Animation)

+ (void)animateWithDuration:(NSTimeInterval)duration
                      delay:(NSTimeInterval)delay
                    options:(UIViewAnimationOptions)options
   disableImplicitAnimation:(BOOL)disable
                 animations:(void (^)(void))animations
                 completion:(void (^)(BOOL))completion
{
    [UIView animateWithDuration:duration delay:delay options:options animations:^{
        [CATransaction begin];
        if ( disable ) {
            [CATransaction setDisableActions:YES];
        }
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
   disableImplicitAnimation:(BOOL)disable
                 animations:(void (^)(void))animations
                 completion:(void (^)(BOOL finished))completion
{
    [PYView animateWithDuration:duration
                          delay:0.f
                        options:0
       disableImplicitAnimation:disable
                     animations:animations
                     completion:completion];
}

+ (void)animateWithDuration:(NSTimeInterval)duration
                 animations:(void (^)(void))animations
{
    [PYView animateWithDuration:duration delay:0.f options:0 animations:animations completion:NULL];
}
+ (void)animateWithDuration:(NSTimeInterval)duration
   disableImplicitAnimation:(BOOL)disable
                 animations:(void (^)(void))animations
{
    [PYView animateWithDuration:duration
                          delay:0.f
                        options:0
       disableImplicitAnimation:disable
                     animations:animations
                     completion:NULL];
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
