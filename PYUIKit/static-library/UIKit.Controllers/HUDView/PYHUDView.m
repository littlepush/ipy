//
//  PYHUDView.m
//  PYUIKit
//
//  Created by Push Chen on 3/11/13.
//  Copyright (c) 2013 PushLab. All rights reserved.
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

#import "PYHUDView.h"
#import "PYHUDView+Singleton.h"

@implementation PYHUDView

// Initialize
- (void)viewJustBeenCreated
{
    [super viewJustBeenCreated];
    _isEnableUserInactive = NO;
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    _contentView = [[PYView alloc] init];
    [_contentView setBackgroundColor:[UIColor blackColor]];
    [_contentView setAlpha:.5f];
    [_contentView setCornerRadius:7.5f];
    [_contentView setAutoresizingMask:
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [_contentView setFrame:self.bounds];
    [self addSubview:_contentView];
}
// Settings
+ (CGFloat)displayAnimationDuration
{
    // Singleton setting
    return .35f;
}

+ (void)setIsEnableUserInactive:(BOOL)isEnable
{
    @synchronized(self) {
        ((PYHUDView *)[PYHUDView sharedHUDView])->_isEnableUserInactive = isEnable;
    }
}

// UI
+ (void)setBackgroundAlpha:(CGFloat)alpha
{
    @synchronized(self) {
        [((PYHUDView *)[PYHUDView sharedHUDView])->_contentView setAlpha:alpha];
    }
}

+ (void)setCornerRadius:(CGFloat)radius
{
    @synchronized(self) {
        [((PYHUDView *)[PYHUDView sharedHUDView])->_contentView setCornerRadius:radius];
    }
}

+ (void)setEnableDropShadow:(BOOL)isEnable
{
    @synchronized(self) {
        if ( isEnable ) {
            [((PYHUDView *)[PYHUDView sharedHUDView])->_contentView setDropShadowColor:[UIColor blackColor]];
            [((PYHUDView *)[PYHUDView sharedHUDView])->_contentView setDropShadowOffset:CGSizeMake(1, 1)];
            [((PYHUDView *)[PYHUDView sharedHUDView])->_contentView setDropShadowOpacity:5.f];
        } else {
            [((PYHUDView *)[PYHUDView sharedHUDView])->_contentView setDropShadowColor:nil];
            [((PYHUDView *)[PYHUDView sharedHUDView])->_contentView setDropShadowOffset:CGSizeZero];
            [((PYHUDView *)[PYHUDView sharedHUDView])->_contentView setDropShadowOpacity:0.f];
        }
    }
}

// Actions
+ (void)hideHUDView
{
    [[PYHUDView sharedHUDView] _cleanAutoHidingTimer];
    
    // Hide the hud view
    dispatch_async( dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:[PYHUDView displayAnimationDuration] animations:^{
            [[PYHUDView sharedHUDView] setAlpha:0];
        } completion:^(BOOL finished) {
            if ( ! finished ) return;
            @synchronized(self) {
                [[PYHUDView sharedHUDView] _clearAllData];
            }
        }];
    });
}

+ (void)hideHUDViewAfter:(CGFloat)seconds
{
    @synchronized(self) {
        [[PYHUDView sharedHUDView] _cleanAutoHidingTimer];
        [[PYHUDView sharedHUDView] _startAutoHidingTimer:seconds];
    }
}

+ (void)displayMessage:(NSString *)message
{
    @synchronized(self) {
        [[PYHUDView sharedHUDView] _cleanAutoHidingTimer];
        [[PYHUDView sharedHUDView] _clearAllData];
        [PYHUDView sharedHUDView]->_message = message;
        [[PYHUDView sharedHUDView] _showHUDView];
    }
}

+ (void)displayMessage:(NSString *)message duration:(CGFloat)duration
{
    @synchronized(self) {
        [[PYHUDView sharedHUDView] _cleanAutoHidingTimer];
        [[PYHUDView sharedHUDView] _clearAllData];
        [PYHUDView sharedHUDView]->_message = message;
        [[PYHUDView sharedHUDView] _showHUDView];
        [[PYHUDView sharedHUDView] _startAutoHidingTimer:duration];
    }
}

+ (void)displayCustomizedInfo:(UIView *)customizedView
{
    @synchronized(self) {
        [[PYHUDView sharedHUDView] _cleanAutoHidingTimer];
        [[PYHUDView sharedHUDView] _clearAllData];
        [PYHUDView sharedHUDView]->_customizedView = customizedView;
        [[PYHUDView sharedHUDView] _showHUDView];
    }
}

+ (void)displayCustomizedInfo:(UIView *)customizedView duration:(CGFloat)duration
{
    @synchronized(self) {
        [[PYHUDView sharedHUDView] _cleanAutoHidingTimer];
        [[PYHUDView sharedHUDView] _clearAllData];
        [PYHUDView sharedHUDView]->_customizedView = customizedView;
        [[PYHUDView sharedHUDView] _showHUDView];
        [[PYHUDView sharedHUDView] _startAutoHidingTimer:duration];
    }
}

+ (void)displayIndicateWithMessage:(NSString *)message
{
    @synchronized(self) {
        [[PYHUDView sharedHUDView] _cleanAutoHidingTimer];
        [[PYHUDView sharedHUDView] _clearAllData];
        [PYHUDView sharedHUDView]->_isShowIndicator = YES;
        [PYHUDView sharedHUDView]->_message  = message;
        [[PYHUDView sharedHUDView] _showHUDView];
    }
}

+ (void)displayIndicateWithMessage:(NSString *)message duration:(CGFloat)duration
{
    @synchronized(self) {
        [[PYHUDView sharedHUDView] _cleanAutoHidingTimer];
        [[PYHUDView sharedHUDView] _clearAllData];
        [PYHUDView sharedHUDView]->_isShowIndicator = YES;
        [PYHUDView sharedHUDView]->_message  = message;
        [[PYHUDView sharedHUDView] _showHUDView];
        [[PYHUDView sharedHUDView] _startAutoHidingTimer:duration];
    }
}

+ (void)displayTitle:(NSString *)title withDetail:(NSString *)details
{
    @synchronized(self) {
        [[PYHUDView sharedHUDView] _cleanAutoHidingTimer];
        [[PYHUDView sharedHUDView] _clearAllData];
        [PYHUDView sharedHUDView]->_title = title;
        [PYHUDView sharedHUDView]->_message = details;
        [[PYHUDView sharedHUDView] _showHUDView];
    }
}

+ (void)displayTitle:(NSString *)title withDetail:(NSString *)details duration:(CGFloat)duration
{
    @synchronized(self) {
        [[PYHUDView sharedHUDView] _cleanAutoHidingTimer];
        [[PYHUDView sharedHUDView] _clearAllData];
        [PYHUDView sharedHUDView]->_title = title;
        [PYHUDView sharedHUDView]->_message = details;
        [[PYHUDView sharedHUDView] _showHUDView];
        [[PYHUDView sharedHUDView] _startAutoHidingTimer:duration];
    }
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
