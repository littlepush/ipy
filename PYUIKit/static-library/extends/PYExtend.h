//
//  PYAnimation.h
//  PYAnimation
//
//  Created by Push Chen on 12/1/11.
//  Copyright (c) 2011 Push Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UIView+Mask.h"
#import "UIView+Animations.h"
#import "UIView+Responsder.h"
#import "UIViewController+PopUp.h"
#import "UIColor+PYUIKit.h"
#import "UIScrollView+KeyboardExtended.h"

#import <QuartzCore/QuartzCore.h>

// Set the view's cornor radius
#define PYNoNavgationBar	self.navigationController.navigationBarHidden = YES
#define PYHasNavgationBar	self.navigationController.navigationBarHidden = NO

#define PYIsNavgationBarHidden	\
	self.navigationController.navigationBarHidden

#define PYStatusBarHidden	[[UIApplication sharedApplication] setStatusBarHidden:YES];
#define PYStatusBarShown	[[UIApplication sharedApplication] setStatusBarHidden:NO];

#define CGRectCompare( _rect1, _rect2 )				\
	(_rect1).origin.x == (_rect2).origin.x &&		\
	(_rect1).origin.y == (_rect2).origin.y &&		\
	(_rect1).size.width == (_rect2).size.width &&	\
	(_rect1).size.height == (_rect2).size.height
	
#ifndef CGRectEmpty
#define CGRectEmpty		CGRectMake(0, 0, 0, 0)
#endif

#define __ALERT_VAR__							CHAR_CONNECT(_alert_, __LINE__)
#define __EXP_VAR__								CHAR_CONNECT(_e_, __LINE__)
#define MESSAGEBOX( title, text )											\
	UIAlertView *__ALERT_VAR__ = [[UIAlertView alloc]						\
		initWithTitle:title message:text									\
		delegate:nil cancelButtonTitle:@"OK"								\
		otherButtonTitles:nil];                                             \
	[__ALERT_VAR__ show]

/* View Controller Creater */
/* 
	Get a multiple platform UIviewController according to the name
	And also, the viewcontroller will be added to global cache
	automatically.
	The viewcontroller's xib name must be end with _iPhone or _iPad
 */
UIViewController *_pyviewController_multiplatform( NSString *_name );

/* 
	Get a uiviewcontroller according to the name
	And also, the viewcontroller will be added to global cache
	automatically.
 */
UIViewController * _pyviewController( NSString *_name );

/*
	Just create a multiple platform viewcontroller, not add to the global cache.
 */
#define _pyviewController_multiplatform_nocache _pyviewController_multiplatform

/*
	Just create a viewcontroller, not add to the global cache.
 */
#define _pyviewController_nocache               _pyviewController

/* You should not invoke the methods defined upside. Instead, use the following macros */
#define PYViewControllerMultiPlatformGetter( vcName )						\
	(vcName *)_pyviewController_multiplatform( @#vcName )
	
#define PYViewControllerGetter( vcName )									\
	(vcName *)_pyviewController( @#vcName )
	
#define PYViewControllerMultiPlatformNoCache( vcName )						\
	(vcName *)_pyviewController_multiplatform_nocache( @#vcName )

#define PYViewControllerNoCache( vcName )									\
	(vcName *)_pyviewController_nocache( @#vcName )
	
/*
	Load a view from a nib file.
 */
UIView * _pyloadView( NSString *_nibname, Class _class );

/*
	Load a multiplatform view
 */
UIView * _pyloadView_multiplatform( NSString *_nibname, Class _class );

/*  */
#define PYViewGetter( viewName )											\
	(viewName *)_pyloadView( @#viewName, NSClassFromString( @#viewName ) )
#define PYViewMultiplatformGetter( viewName )								\
	(viewName *)_pyloadView_multiplatform( @#viewName,						\
		NSClassFromString( @#viewName ) )

	