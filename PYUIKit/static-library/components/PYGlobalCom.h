//
//  PYGlobalCom.h
//  FootPath
//
//  Created by Push Chen on 3/2/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#ifndef FootPath_PYGlobalCom_h
#define FootPath_PYGlobalCom_h

#import <UIKit/UIKit.h>

#define kRootNavController	@"kRootNavController"


#define PYSetRootNavigationController										\
	UINavigationController *navController =									\
		[[[UINavigationController alloc] init ] autorelease];				\
	GlobalCacheSetObjectValueOfKey(kRootNavController, navController);		\
	[navController pushViewController:self.viewController animated:YES];	\
	[self.window addSubview:navController.view];

#define PYSetRootNavigationControllerWithView( rootViewController )			\
	UINavigationController *navController =									\
		[[[UINavigationController alloc] init ] autorelease];				\
	GlobalCacheSetObjectValueOfKey(kRootNavController, navController);		\
	[navController pushViewController:rootViewController animated:YES];	\
	[self.window addSubview:navController.view];

#define PYRootNavController													\
	((UINavigationController *)GlobalCacheGetObjectOfKey(kRootNavController))

@interface UIViewController(BindController)
@property ( nonatomic, assign ) UIViewController * bindController;
@end

// check if the view is the first time been shown.
// the key point is to check the value set in the layer
BOOL __isViewFirstShown( UIViewController *view );

// set the view shown statues to SHOWN.
void __viewHasBeenShown( UIViewController *view );

// reset the viewcontroller's shown statues.
void __viewShowStatuesReset( UIViewController *view );

#define __ISVIEWFIRSTSHOWN		__isViewFirstShown( self )
#define __VIEWHASBEENSHOWN		__viewHasBeenShown( self )
#define __VIEWSHOWRESET			__viewShowStatuesReset( self )

#endif
