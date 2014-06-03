//
//  PYNavigationController.h
//  PYUIKit
//
//  Created by Push Chen on 11/25/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PYView.h"

typedef NS_OPTIONS(NSUInteger, UINavigationControllerType) {
    UINavigationControllerTypeMainView      = 0,
    UINavigationControllerTypeLeftMenu      = 1 << 0,
    UINavigationControllerTypeRightMenu     = 1 << 1,
    UINavigationControllerTypePopView       = 1 << 2
};

@interface PYNavigationController : UINavigationController
{
    // Current view controller type.
    UINavigationControllerType              _viewControllerType;
    
    // The max spacing means max distance current view controller can move to one side.
    // for example, if current view is a left menu, then the [_maxToLeftMovingSpace]
    // should be 0, which means the controller cannot be moved towards left.
    // And also, the [_maxToRightMovingSpace] is also 0.
    // When the view controller is a main view,
    CGFloat                                 _maxToLeftMovingSpace;
    CGFloat                                 _maxToRightMovingSpace;
    
    // Pan gesture info
    CGPoint                                 _lastTouchPoint;
    UIPanGestureRecognizer                  *_panGesture;
    CGFloat                                 _lastDelta;
    
    // Old Container View.
    UIView                                  *_containerView;
    // The bottom bar.
    PYView                                  *_bottomBarView;
    // The top bar.
    PYView                                  *_topBarView;
    // Size..
    CGFloat                                 _topBarHeight;
    CGFloat                                 _bottomBarHeight;
    
    // If current navigation controller is poped up.
    BOOL                                    _isPopedUp;
    BOOL                                    _isBottomBarHidden;
    BOOL                                    _isTopBarHidden;
}

// Set the view controller type.
@property (nonatomic, assign)   UINavigationControllerType  viewControllerType;

// The main view controller which always show on top.
@property (nonatomic, assign)   PYNavigationController      *mainNavController;
// If current view controller is main view controlle.
@property (nonatomic, readonly) BOOL                        isMainViewController;
// If current view controller should remine the origin position when main view controller
// is moving to right side. In other words, if current view controller is a left
// menu view.
@property (nonatomic, readonly) BOOL                        stuckWhenMainViewMoveToRight;
// If current view controller should remine the origin position when main view controller
// is moving to left side. In other words, if current view controller is a right
// menu view.
@property (nonatomic, readonly) BOOL                        stuckWhenMainViewMoveToLeft;

// Max towards side moving space.
@property (nonatomic, assign)   CGFloat                     maxToLeftMovingSpace;
@property (nonatomic, assign)   CGFloat                     maxToRightMovingSpace;

// Pop Navigation Controller Properties
@property (nonatomic, readonly) BOOL                        isPopedUp;

// BottomBar.
@property (nonatomic, readonly) PYView                      *bottomBar;
@property (nonatomic, assign)   BOOL                        bottomBarHidden;
@property (nonatomic, assign)   CGFloat                     bottomBarHeight;
// Change the bottom bar hidden with animation.
- (void)setBottomBarHidden:(BOOL)hidden animated:(BOOL)animated;

// Get the notification when main view is moving.
- (void)mainViewIsMovingToRightWithPercentage:(CGFloat)percentage;
- (void)mainViewIsMovingToLeftWithPercentage:(CGFloat)percentage;

// Manually move current view
- (void)moveToLeftWithDistance:(CGFloat)distance animated:(BOOL)animated;
- (void)moveToRightWithDistance:(CGFloat)distance animated:(BOOL)animated;

// Reset current view's state
- (void)resetViewPosition;

// Content Size
@property (nonatomic, readonly) CGRect                      contentFrame;
@property (nonatomic, readonly) CGSize                      contentSize;

@end

// Extend for UIController.
@interface UIViewController (PYNavigationController)

// The content size did changed.
- (void)contentSizeDidChanged;

@end
