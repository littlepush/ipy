//
//  PYView+Animation.h
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

#import "PYView.h"

@interface PYView (Animation)

+ (void)animateWithDuration:(NSTimeInterval)duration
                      delay:(NSTimeInterval)delay
                    options:(UIViewAnimationOptions)options
   disableImplicitAnimation:(BOOL)disable
                 animations:(void (^)(void))animations
                 completion:(void (^)(BOOL))completion;
+ (void)animateWithDuration:(NSTimeInterval)duration
                      delay:(NSTimeInterval)delay
                    options:(UIViewAnimationOptions)options
                 animations:(void (^)(void))animations
                 completion:(void (^)(BOOL finished))completion;

+ (void)animateWithDuration:(NSTimeInterval)duration
   disableImplicitAnimation:(BOOL)disable
                 animations:(void (^)(void))animations
                 completion:(void (^)(BOOL finished))completion;
+ (void)animateWithDuration:(NSTimeInterval)duration
                 animations:(void (^)(void))animations
                 completion:(void (^)(BOOL finished))completion;

+ (void)animateWithDuration:(NSTimeInterval)duration
   disableImplicitAnimation:(BOOL)disable
                 animations:(void (^)(void))animations;
+ (void)animateWithDuration:(NSTimeInterval)duration
                 animations:(void (^)(void))animations;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
