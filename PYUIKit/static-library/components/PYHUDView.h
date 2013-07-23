//
//  PYHUDView.h
//  PYUIKit
//
//  Created by Chen Push on 3/11/13.
//  Copyright (c) 2013 Markphone Culture Media Co.Ltd. All rights reserved.
//

#import "PYView.h"

/*
 Singleton:PYHUDView
 The HUD View is stand for: Head Up Display View.
 The view is used to show some message to the end-user but not to interrupt the user inactive.
 */
@interface PYHUDView : PYView
{
    BOOL                                _isEnableUserInactive;
    
    // Content
    NSString                            *_title;
    NSString                            *_message;
    BOOL                                _isShowIndicator;
    
    // Subviews
    PYView                              *_contentView;
    UIView                              *_customizedView;
    UILabel                             *_titleLabel;
    UILabel                             *_messageLabel;
    UIActivityIndicatorView             *_indicatorView;
    
    // Statues
    NSTimer                             *_autoHidingTimer;
    UIWindow                            *_containerWindow;
}

// Global setting for HUDView
+ (void)setIsEnableUserInactive:(BOOL)isEnable;
/* Style */
+ (void)setBackgroundAlpha:(CGFloat)alpha;
+ (void)setCornerRadius:(CGFloat)radius;
+ (void)setEnableDropShadow:(BOOL)isEnable;
+ (CGFloat)displayAnimationDuration;

// Actions for developers to use
/* Hide the hud view directly */
+ (void)hideHUDView;
/* Hide the hud view after the specified seconds */
+ (void)hideHUDViewAfter:(CGFloat)seconds;

/* Display the specified message until hide manually */
+ (void)displayMessage:(NSString *)message;
/* Display the message for the duration */
+ (void)displayMessage:(NSString *)message duration:(CGFloat)duration;

/* Display a customized view */
+ (void)displayCustomizedInfo:(UIView *)customizedView;
/* Display a customized view for the duration */
+ (void)displayCustomizedInfo:(UIView *)customizedView duration:(CGFloat)duration;

/* Display an indicate view with specified message */
+ (void)displayIndicateWithMessage:(NSString *)message;
/* Display an indicate view with specified message for the duration */
+ (void)displayIndicateWithMessage:(NSString *)message duration:(CGFloat)duration;

/* Display title + detail message */
+ (void)displayTitle:(NSString *)title withDetail:(NSString *)details;
/* Display title + detail message for the duration */
+ (void)displayTitle:(NSString *)title withDetail:(NSString *)details duration:(CGFloat)duration;

@end
