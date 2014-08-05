//
//  PYApperance.h
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

#import <Foundation/Foundation.h>
#import "PYNavigationController.h"
#import "UIViewController+PopUp.h"

@interface PYApperance : PYKVOObject
{
    NSMutableArray              *_mainViewControllers;
    NSMutableArray              *_leftViewControllers;
    NSMutableArray              *_rightViewControllers;

    // The root container.
    UIViewController __unsafe_unretained        *_rootContainer;
    
    // The display range of menus.
    CGFloat                     _leftMenuDisplayWidth;
    CGFloat                     _rightMenuDisplayWidth;
    PYNavigationController      *_popedController;
}

// Singleton instance.
+ (PYApperance *)sharedApperance;

// The display range.
@property (nonatomic, assign)   CGFloat     leftMenuDisplayWidth;
@property (nonatomic, assign)   CGFloat     rightMenuDisplayWidth;

@property (nonatomic, readonly) NSArray     *leftMenus;
@property (nonatomic, readonly) NSArray     *rightMenus;
@property (nonatomic, readonly) NSArray     *mainViews;

// The root container.
@property (nonatomic, readonly) UIViewController __unsafe_unretained    *rootContainer;

// The global loading method
- (void)loadUIFrameworkWithMainView:(NSArray *)mainViews
                           leftMenu:(NSArray *)leftMenus
                          rightMenu:(NSArray *)rightMenus
                      rootContainer:(UIViewController __unsafe_unretained*)rootContainer;

// Now we support two styles.
// First one is no ex-menu, only one main view in the middle.
// Second one contains one left menu and a main view.
- (void)loadUIFrameworkWithMainView:(UIViewController *)mainView
                      rootContainer:(UIViewController __unsafe_unretained*)rootContainer;
- (void)loadUIFrameworkWithMainView:(UIViewController *)mainView
                           leftMenu:(UIViewController *)leftMenu
                      rootContainer:(UIViewController __unsafe_unretained *)rootContainer;

// Get current visiable view controller.
- (UIViewController *)visiableController;

// Present pop view controller.
- (void)presentPopViewController:(UIViewController *)viewController
                       animation:(PYPopUpAnimationType)type
                          center:(CGPoint)center
                        complete:(PYActionDone)complete;
- (void)presentPopViewController:(UIViewController *)viewController
                        complete:(PYActionDone)complete;
- (void)presentPopViewController:(UIViewController *)viewController
                       animation:(PYPopUpAnimationType)type;
- (void)presentPopViewController:(UIViewController *)viewController;

// Dismiss the poped view controller.
- (void)dismissPopedViewControllerWithAnimationType:(PYPopUpAnimationType)type
                                           complete:(PYActionDone)complete;
- (void)dismissPopedViewControllerWithAnimationType:(PYPopUpAnimationType)type;
- (void)dismissPopedViewController;

@end

// Override to change the state bar style.
// Also, for the root container, may use the following
// method to change the default apperance setting
@interface UIViewController (PYApperance)

// Navigation Controller Class for Specified Main View.
// The class must be PYNavigationController or its subclass.
- (Class)navigationControllerClassForMainViewController:(UIViewController *)viewController;
// Navigation Controller Class for Specified Left View.
// The class must be PYNavigationController or its subclass.
- (Class)navigationControllerClassForLeftViewController:(UIViewController *)viewController;
// Navigation Controller Class for Specified Right View.
// The class must be PYNavigationController or its subclass.
- (Class)navigationControllerClassForRightViewController:(UIViewController *)viewController;
// Navigation Controller Class for Specified Pop View.
// The class must be PYNavigationController or its subclass.
- (Class)navigationControllerClassForPopViewController:(UIViewController *)viewController;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
