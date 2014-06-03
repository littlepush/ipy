//
//  PYNavigationController.m
//  PYUIKit
//
//  Created by Push Chen on 11/25/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import "PYNavigationController.h"

@interface PYNavigationController ()

@end

@implementation PYNavigationController

@synthesize viewControllerType = _viewControllerType;
- (void)setViewControllerType:(UINavigationControllerType)type
{
    _viewControllerType = type;
    if ( type == UINavigationControllerTypeMainView ) {
        // Add Pan gesture...
        if ( _panGesture == nil ) {
            _panGesture = [[UIPanGestureRecognizer alloc]
                           initWithTarget:self
                           action:@selector(_gesturePanHandler:)];
        }
        [self.view addGestureRecognizer:_panGesture];
    } else {
        if ( _panGesture != nil ) {
            [self.view removeGestureRecognizer:_panGesture];
        }
    }
}
@synthesize mainNavController;
@synthesize maxToLeftMovingSpace = _maxToLeftMovingSpace;
@synthesize maxToRightMovingSpace = _maxToRightMovingSpace;
@dynamic isMainViewController;
- (BOOL)isMainViewController
{
    return _viewControllerType == UINavigationControllerTypeMainView;
}

@dynamic stuckWhenMainViewMoveToLeft;
- (BOOL)stuckWhenMainViewMoveToLeft
{
    return _maxToLeftMovingSpace == 0;
}
@dynamic stuckWhenMainViewMoveToRight;
- (BOOL)stuckWhenMainViewMoveToRight
{
    return _maxToRightMovingSpace == 0;
}

// Pop statue.
@synthesize isPopedUp = _isPopedUp;

- (void)mainViewIsMovingToLeftWithPercentage:(CGFloat)percentage
{
    if ( _maxToLeftMovingSpace == 0.f ) return;
    CGFloat _movingDistance = _maxToLeftMovingSpace * percentage;
    self.view.transform = CGAffineTransformMakeTranslation(-_movingDistance, 0);
}

- (void)mainViewIsMovingToRightWithPercentage:(CGFloat)percentage
{
    if ( _maxToRightMovingSpace == 0.f ) return;
    CGFloat _movingDistance = _maxToRightMovingSpace * percentage;
    self.view.transform = CGAffineTransformMakeTranslation(_movingDistance, 0);
}

- (void)moveToLeftWithDistance:(CGFloat)distance animated:(BOOL)animated
{
    if ( animated ) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.175];
    }
    
    CGFloat _currentTransform = self.view.transform.tx;
    _currentTransform -= PYABSF(distance);
    if ( _currentTransform < -_maxToLeftMovingSpace ) {
        _currentTransform = -_maxToLeftMovingSpace;
    }
    self.view.transform = CGAffineTransformMakeTranslation(_currentTransform, 0);
    // Tell the container...
    
    if ( animated ) {
        [UIView commitAnimations];
    }
}

- (void)moveToRightWithDistance:(CGFloat)distance animated:(BOOL)animated
{
    if ( animated ) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.175];
    }
    
    CGFloat _currentTransform = self.view.transform.tx;
    _currentTransform += PYABSF(distance);
    if ( _currentTransform > _maxToRightMovingSpace ) {
        _currentTransform = _maxToRightMovingSpace;
    }
    self.view.transform = CGAffineTransformMakeTranslation(_currentTransform, 0);
    // Tell the container...

    if ( animated ) {
        [UIView commitAnimations];
    }
}

- (void)resetViewPosition
{
    if ( self.view.transform.tx == 0.f ) return;
    [UIView animateWithDuration:.175 animations:^{
        self.view.transform = CGAffineTransformIdentity;
        // Tell the container...
    }];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    if ( [PYLayer isDebugEnabled] ) {
        __formatLogLine(__FILE__, __FUNCTION__, __LINE__,
                        [NSString stringWithFormat:@"***[%@:%p] Dealloced***",
                         NSStringFromClass([self class]), self]);
    }
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

#pragma mark --
#pragma mark Content Size
@dynamic contentFrame;
- (CGRect)contentFrame
{
    return _containerView.frame;
}
@dynamic contentSize;
- (CGSize)contentSize
{
    return _containerView.frame.size;
}

#pragma mark --
#pragma mark Bottom Bar
@synthesize bottomBarHidden = _isBottomBarHidden;
@synthesize bottomBar = _bottomBarView;
@synthesize bottomBarHeight = _bottomBarHeight;
- (void)__notifyChildrenForContentSizeChangedCausedByBottomBar
{
    // Tell all child viewcontrollers
    for ( UIViewController *_vc in self.viewControllers ) {
        CGRect _vcFrame = _vc.view.frame;
        _vcFrame.size.height = (_containerView.bounds.size.height -
                                _vc.view.frame.origin.y);
        [_vc.view setFrame:_vcFrame];
        [_vc contentSizeDidChanged];
    }
}
- (void)setBottomBarHeight:(CGFloat)height
{
    CGFloat _oldHeight = _bottomBarHeight;
    _bottomBarHeight = height;
    // Not show, return.
    if ( _isBottomBarHidden ) return;
    
    // Change the container frame.
    CGRect _containerFrame = _containerView.frame;
    _containerFrame.size.height += (_oldHeight - height);
    [_containerView setFrame:_containerFrame];
    
    // Change the bottom view frame.
    CGRect _bottomFrame = _bottomBarView.frame;
    _bottomFrame.size.height = height;
    _bottomFrame.origin.y -= (_oldHeight - height);
    [_bottomBarView setFrame:_bottomFrame];
    [self __notifyChildrenForContentSizeChangedCausedByBottomBar];
}

- (void)__changeBottomBarHidden:(BOOL)hidden
{
    // Change container frame.
    CGRect _containerFrame = _containerView.frame;
    if ( hidden == NO ) {
        _containerFrame.size.height -= _bottomBarHeight;
        
        // Check if bottom bar height has been changed since last show
        if ( _bottomBarView.frame.size.height != _bottomBarHeight ) {
            // chagne the frame
            CGRect _bottomFrame = self.view.bounds;
            _bottomFrame.origin.y = _containerFrame.size.height;
            _bottomFrame.size.height = _bottomBarHeight;
            [_bottomBarView setFrame:_bottomFrame];
        }
    } else {
        _containerFrame.size.height += _bottomBarHeight;
    }
    [_containerView setFrame:_containerFrame];
    [_bottomBarView setAlpha:(hidden ? 0.f : 1.f)];
}

- (void)setBottomBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    if ( _isBottomBarHidden == hidden ) return;
    _isBottomBarHidden = hidden;
    
    if ( animated ) {
        [UIView animateWithDuration:.175 animations:^{
            [self __changeBottomBarHidden:hidden];
        } completion:^(BOOL finished) {
            [self __notifyChildrenForContentSizeChangedCausedByBottomBar];
        }];
    } else {
        [self __changeBottomBarHidden:hidden];
        [self __notifyChildrenForContentSizeChangedCausedByBottomBar];
    }
}

// Override the [loadView] to initialize the bottom bar.
- (void)loadView
{
    // Copy the old container.
    [super loadView];
    _containerView = self.view;
    self.view = [UIView object];
    [self.view setFrame:_containerView.frame];
    
    _bottomBarHeight = 44.f;
    _bottomBarView = [PYView object];
    [_bottomBarView setAlpha:0.f];
    [_bottomBarView
     setFrame:CGRectMake(0, _containerView.frame.size.height - _bottomBarHeight,
                         _containerView.frame.size.width, _bottomBarHeight)];
    // [_bottomBarView setTransform:CGAffineTransformMakeTranslation(0, _bottomBarHeight)];
    [self.view addSubview:_containerView];
    [self.view addSubview:_bottomBarView];
    _isBottomBarHidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --
#pragma mark Pan Action.

- (void)_gesturePanHandler:(id)sender
{
    CGPoint _touchPoint = [_panGesture locationInView:[UIApplication sharedApplication].keyWindow];
    
    if ( _panGesture.state == UIGestureRecognizerStateBegan ) {
        // Store the first point.
        _lastTouchPoint = _touchPoint;
    } else if ( _panGesture.state == UIGestureRecognizerStateChanged ) {
        CGFloat _deltaHor = _touchPoint.x - _lastTouchPoint.x;
        if ( _deltaHor > 0 ) {
            [self moveToRightWithDistance:_deltaHor animated:NO];
        } else {
            [self moveToLeftWithDistance:-_deltaHor animated:NO];
        }
        _lastTouchPoint = _touchPoint;
        _lastDelta = _deltaHor;
    } else if ( _panGesture.state == UIGestureRecognizerStateRecognized ) {
        // Release current object...
        if ( _lastDelta > 0 ) {
            // Move to right stage if current transform is zero.
            if ( self.view.transform.tx < 0.f ) {
                [self moveToRightWithDistance:self.view.transform.tx animated:YES];
            } else {
                [self moveToRightWithDistance:_maxToRightMovingSpace animated:YES];
            }
        } else {
            if ( self.view.transform.tx > 0.f ) {
                [self moveToLeftWithDistance:self.view.transform.tx animated:YES];
            } else {
                [self moveToLeftWithDistance:_maxToLeftMovingSpace animated:YES];
            }
        }
    }
}

#pragma mark --
#pragma mark Override

// When push viewcontroller, reset view position first.
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self resetViewPosition];
    [super pushViewController:viewController animated:animated];
}

@end

@implementation UIViewController (PYNavigationController)

- (void)contentSizeDidChanged
{
    // When the bottom bar show/hide, this method will be invoked.
}

@end