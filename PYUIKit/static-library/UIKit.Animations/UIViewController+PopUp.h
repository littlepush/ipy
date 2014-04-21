//
//  UIViewController+PopUp.h
//  PYUIKit
//
//  Created by Push Chen on 8/26/13.
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

#import <UIKit/UIKit.h>
#import <PYCore/PYCoreMacro.h>

typedef NS_ENUM(NSInteger, PYPopUpAnimationType) {
    PYPopUpAnimationTypeNone            = 0,        // No animation
    PYPopUpAnimationTypeJelly           = 1,        // Jelly Popup
    PYPopUpAnimationTypeSmooth          = 2,        // Smooth Popup
    PYPopUpAnimationTypeFade            = 3,        // Fade In/Out
    PYPopUpAnimationTypeSlideFromLeft   = 4,        // Slide In from left
    PYPopUpAnimationTypeSlideFromRight  = 5,        // Slide In from right
    PYPopUpAnimationTypeSlideFromBottom = 6,        // Slide in from bottom
    PYPopUpAnimationTypeSlideFromTop    = 7         // Slide in from top
};

typedef NS_ENUM(NSInteger, UIViewControllerPopState) {
    UIViewControllerPopStateUnknow      = 0,
    UIViewControllerPopStateWillPop,
    UIViewControllerPopStatePoppedUp,
    UIViewControllerPopStateWillDismiss,
    UIViewControllerPopStateDismissed
};

@interface UIViewController (PopUp)

// Check if current has a pop view and is visiable.
@property (nonatomic, readonly) BOOL        isPopViewVisiable DEPRECATED_ATTRIBUTE;

// Observe this property to get the notification of child viewcontroller
// poping state.
@property (nonatomic, readonly) UIViewControllerPopState        popState;

// Popped Child View Controller
@property (nonatomic, readonly) UIViewController                *poppedViewController;

// Pop up the view controller with specified animation type.
// Default animation type is Jelly.
- (void)presentPopViewController:(UIViewController *)controller;
- (void)presentPopViewController:(UIViewController *)controller
                        complete:(PYActionDone)complete;
- (void)presentPopViewController:(UIViewController *)controller
                       animation:(PYPopUpAnimationType)type
                        complete:(PYActionDone)complete;
- (void)presentPopViewController:(UIViewController *)controller
                       animation:(PYPopUpAnimationType)type
                          center:(CGPoint)center
                        complete:(PYActionDone)complete;

// Dismiss the view controller, and set if need animation.
- (void)dismissPoppedViewController:(BOOL)animated;
- (void)dismissPoppedViewController:(BOOL)animated
                           complete:(PYActionDone)complete;
- (void)dismissPoppedViewControllerAnimation:(PYPopUpAnimationType)type
                                    complete:(PYActionDone)complete;
// For the container, dismiss the popped
- (void)dismissChildPoppedView;

// Message Callback
- (void)willPopViewController:(UIViewController *)controller;
- (void)didPoppedViewController:(UIViewController *)controller;
- (void)willDismissPopViewController:(UIViewController *)controller;
- (void)didDismissedPopViewController:(UIViewController *)controller;

@end

@interface UIViewController (Private)

// Display and hide the pop up background mask view.
- (void)displayMaskViewWithAlpha:(CGFloat)alpha
                       animation:(PYPopUpAnimationType)type
             customizeController:(UIViewController *)controller;
- (void)hideMaskView:(PYPopUpAnimationType)type;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
