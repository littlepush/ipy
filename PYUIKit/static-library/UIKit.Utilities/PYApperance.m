//
//  PYApperance.m
//  PYUIKit
//
//  Created by Push Chen on 11/25/13.
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

#import "PYApperance.h"
#import <PYUIKit/PYUIKit.h>

NSString *const         kUIViewControllerPopState       = @"popState";

@interface PYNavigationController (Apperance)
// Poped state.
- (void)setPopedUpState:(BOOL)popedUp;
@end
@implementation PYNavigationController (Apperance)
- (void)setPopedUpState:(BOOL)popedUp
{
    _isPopedUp = popedUp;
}
@end

static PYApperance *_gPYApperance = nil;
// KVO Extend
@interface PYApperance (KVOExtend)
// Observer the [popState] of _rootContainer.
PYKVO_CHANGED_RESPONSE(_rootContainer, popState);
@end

@implementation PYApperance

@synthesize rootContainer = _rootContainer;

+ (PYApperance *)sharedApperance
{
    PYSingletonLock
    if ( _gPYApperance == nil ) {
        _gPYApperance = [PYApperance object];
    }
    return _gPYApperance;
    PYSingletonUnLock
}
PYSingletonAllocWithZone(_gPYApperance);
PYSingletonDefaultImplementation;

- (id)init
{
    self = [super init];
    if ( self ) {
        _leftViewControllers = [NSMutableArray array];
        _rightViewControllers = [NSMutableArray array];
        _mainViewControllers = [NSMutableArray array];
        
        _leftMenuDisplayWidth = 0.f;
        _rightMenuDisplayWidth = 0.f;
    }
    return self;
}

@synthesize leftMenuDisplayWidth = _leftMenuDisplayWidth;
- (void)setLeftMenuDisplayWidth:(CGFloat)width
{
    @synchronized( self ) {
        for ( PYNavigationController *_mv in _mainViewControllers ) {
            [_mv setMaxToRightMovingSpace:width];
        }
        for ( PYNavigationController *_rv in _rightViewControllers ) {
            [_rv setMaxToRightMovingSpace:width];
        }
        _leftMenuDisplayWidth = width;
    }
}
@synthesize rightMenuDisplayWidth = _rightMenuDisplayWidth;
- (void)setRightMenuDisplayWidth:(CGFloat)width
{
    @synchronized( self ) {
        for ( PYNavigationController *_mv in _mainViewControllers ) {
            [_mv setMaxToLeftMovingSpace:width];
        }
        for ( PYNavigationController *_lv in _leftViewControllers ) {
            [_lv setMaxToLeftMovingSpace:width];
        }
        _rightMenuDisplayWidth = width;
    }
}

// The global loading method
- (void)loadUIFrameworkWithMainView:(NSArray *)mainViews
                           leftMenu:(NSArray *)leftMenus
                          rightMenu:(NSArray *)rightMenus
                      rootContainer:(UIViewController __unsafe_unretained*)rootContainer
{
    @synchronized( self ) {
        PYASSERT(rootContainer != nil, @"root container cannot be nil");
        if ( _rootContainer != nil ) {
            PYRemoveObserve(_rootContainer, kUIViewControllerPopState);
        }
        _rootContainer = rootContainer;
        PYObserve(_rootContainer, kUIViewControllerPopState);
        for ( UIViewController *_uc in leftMenus ) {
            Class _navClass = [rootContainer navigationControllerClassForLeftViewController:_uc];
            PYNavigationController *_nc = [[_navClass alloc] initWithRootViewController:_uc];
            PYASSERT([_nc isKindOfClass:[PYNavigationController class]],
                     @"The navigation class for left view is not a PYNavigationController.");
            [_leftViewControllers addObject:_nc];
            [_nc setViewControllerType:UINavigationControllerTypeLeftMenu];
            [_nc setMaxToLeftMovingSpace:_rightMenuDisplayWidth];
            [_nc setMaxToRightMovingSpace:0.f];
            
            [_rootContainer addChildViewController:_nc];
            [_rootContainer.view addSubview:_nc.view];
        }
        for ( UIViewController *_uc in rightMenus ) {
            Class _navClass = [rootContainer navigationControllerClassForRightViewController:_uc];
            PYNavigationController *_nc = [[_navClass alloc] initWithRootViewController:_uc];
            PYASSERT([_nc isKindOfClass:[PYNavigationController class]],
                     @"The navigation class for right view is not a PYNavigationController.");
            [_rightViewControllers addObject:_nc];
            [_nc setViewControllerType:UINavigationControllerTypeRightMenu];
            [_nc setMaxToRightMovingSpace:_leftMenuDisplayWidth];
            [_nc setMaxToLeftMovingSpace:0.f];

            [_rootContainer addChildViewController:_nc];
            [_rootContainer.view addSubview:_nc.view];
        }
        for ( UIViewController *_uc in mainViews ) {
            Class _navClass = [rootContainer navigationControllerClassForMainViewController:_uc];
            PYNavigationController *_nc = [[_navClass alloc] initWithRootViewController:_uc];
            PYASSERT([_nc isKindOfClass:[PYNavigationController class]],
                     @"The navigation class for main view is not a PYNavigationController.");
            [_mainViewControllers addObject:_nc];
            [_nc setViewControllerType:UINavigationControllerTypeMainView];
            [_nc setMaxToLeftMovingSpace:_rightMenuDisplayWidth];
            [_nc setMaxToRightMovingSpace:_leftMenuDisplayWidth];
        
            [_rootContainer addChildViewController:_nc];
            [_rootContainer.view addSubview:_nc.view];
        }
        
        PYNavigationController *_lastMainView = [_mainViewControllers lastObject];
        if ( _lastMainView == nil ) return;
        for ( PYNavigationController *_nc in _leftViewControllers ) {
            _nc.mainNavController = _lastMainView;
        }
        for ( PYNavigationController *_nc in _rightViewControllers ) {
            _nc.mainNavController = _lastMainView;
        }
        for ( UIViewController *_vc in _mainViewControllers ) {
            if ( [_vc isKindOfClass:[PYNavigationController class]] ) {
                PYNavigationController *_nc = (PYNavigationController *)_vc;
                _nc.mainNavController = _lastMainView;
            }
        }
    }
}

- (void)loadUIFrameworkWithMainView:(UIViewController *)mainView
                      rootContainer:(UIViewController __unsafe_unretained*)rootContainer
{
    if ( mainView == nil ) return;
    [self loadUIFrameworkWithMainView:@[mainView]
                             leftMenu:nil
                            rightMenu:nil
                        rootContainer:rootContainer];
}
- (void)loadUIFrameworkWithMainView:(UIViewController *)mainView
                           leftMenu:(UIViewController *)leftMenu
                      rootContainer:(UIViewController *__unsafe_unretained)rootContainer
{
    if ( mainView == nil || leftMenu == nil ) return;
    [self loadUIFrameworkWithMainView:@[mainView]
                             leftMenu:@[leftMenu]
                            rightMenu:nil
                        rootContainer:rootContainer];
}

- (UIViewController *)visiableController
{
    @synchronized( self ) {
        if ( _popedController != nil ) {
            return [_popedController visibleViewController];
        }
        if ( [_mainViewControllers count] == 0 ) return nil;
        PYNavigationController *_mainNC = [_mainViewControllers lastObject];
        return _mainNC.visibleViewController;
    }
}

// Present pop view controller.
- (void)presentPopViewController:(UIViewController *)viewController
                       animation:(PYPopUpAnimationType)type
                          center:(CGPoint)center
                        complete:(PYActionDone)complete
{
    @synchronized ( self  ) {
        if ( _popedController != nil ) return;
        //CGRect _bouds = viewController.view.bounds;
        Class _navClass = [_rootContainer navigationControllerClassForPopViewController:viewController];
        PYNavigationController *_nc = [[_navClass alloc] initWithRootViewController:viewController];
        if ( [_nc isKindOfClass:[PYNavigationController class]] == NO ) {
            ALog(@"The navigation controller for pop is not a PYNavigationController.");
            return;
        }
        //[_nc.view setFrame:_bouds];
        _popedController = _nc;
        [_rootContainer presentPopViewController:_nc animation:type center:center complete:^{
            if ( complete ) complete();
        }];
    }
}
- (void)presentPopViewController:(UIViewController *)viewController
                        complete:(PYActionDone)complete
{
    CGPoint _center = CGPointMake(_rootContainer.view.bounds.size.width / 2,
                                  _rootContainer.view.bounds.size.height / 2);
    [self presentPopViewController:viewController
                         animation:PYPopUpAnimationTypeSlideFromRight
                            center:_center
                          complete:complete];
}
- (void)presentPopViewController:(UIViewController *)viewController
                       animation:(PYPopUpAnimationType)type
{
    CGPoint _center = CGPointMake(_rootContainer.view.bounds.size.width / 2,
                                  _rootContainer.view.bounds.size.height / 2);
    [self presentPopViewController:viewController
                         animation:type
                            center:_center
                          complete:nil];
}
- (void)presentPopViewController:(UIViewController *)viewController
{
    CGPoint _center = CGPointMake(_rootContainer.view.bounds.size.width / 2,
                                  _rootContainer.view.bounds.size.height / 2);
    [self presentPopViewController:viewController
                         animation:PYPopUpAnimationTypeSlideFromRight
                            center:_center
                          complete:nil];
}
- (void)dismissPopedViewControllerWithAnimationType:(PYPopUpAnimationType)type
                                           complete:(PYActionDone)complete
{
    if ( _popedController == nil ) return;
    [_popedController dismissPoppedViewControllerAnimation:type complete:complete];
}
- (void)dismissPopedViewControllerWithAnimationType:(PYPopUpAnimationType)type
{
    [self dismissPopedViewControllerWithAnimationType:type complete:nil];
}
- (void)dismissPopedViewController
{
    [self dismissPopedViewControllerWithAnimationType:PYPopUpAnimationTypeSlideFromLeft
                                             complete:nil];
}

PYKVO_CHANGED_RESPONSE(_rootContainer, popState)
{
    NSInteger _newState = [newValue integerValue];
    if ( _popedController == nil ) return;
    if ( _newState == UIViewControllerPopStatePoppedUp ) {
        [_popedController setPopedUpState:YES];
    }
    if ( _newState == UIViewControllerPopStateDismissed ) {
        [_popedController setPopedUpState:NO];
        [_popedController popToRootViewControllerAnimated:NO];
        _popedController = nil;
    }
}

@end

@implementation UIViewController (PYApperance)

- (UIViewController *)childViewControllerForStatusBarStyle
{
    UIViewController *_vc = [[PYApperance sharedApperance] visiableController];
    if ( [_vc isKindOfClass:[UITabBarController class]] ) {
        UITabBarController *_tbC = (UITabBarController *)_vc;
        _vc = _tbC.selectedViewController;
    }
    if ( _vc == self ) return nil;
    return _vc;
}

// Navigation Controller Class for Specified Main View.
// The class must be PYNavigationController or its subclass.
- (Class)navigationControllerClassForMainViewController:(UIViewController *)viewController
{
    return [PYNavigationController class];
}
// Navigation Controller Class for Specified Left View.
// The class must be PYNavigationController or its subclass.
- (Class)navigationControllerClassForLeftViewController:(UIViewController *)viewController
{
    return [PYNavigationController class];
}
// Navigation Controller Class for Specified Right View.
// The class must be PYNavigationController or its subclass.
- (Class)navigationControllerClassForRightViewController:(UIViewController *)viewController
{
    return [PYNavigationController class];
}
// Navigation Controller Class for Specified Pop View.
// The class must be PYNavigationController or its subclass.
- (Class)navigationControllerClassForPopViewController:(UIViewController *)viewController
{
    return [PYNavigationController class];
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
