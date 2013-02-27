//
// Global Component

#include "PYGlobalCom.h"

#define __VIEW_KEY_DEF__	@"kViewShownStatuesKey"
#define __VIEW_KEY_BIND__	@"kViewBindControllerKey"

@implementation UIViewController(BindController)

@dynamic bindController;

-(UIViewController *) bindController
{
	return [self.view.layer valueForKey:__VIEW_KEY_BIND__];
}

-(void) setBindController:(UIViewController *)bctrl
{
	[self.view.layer setValue:bctrl forKey:__VIEW_KEY_BIND__];
}

@end

// check if the view is the first time been shown.
// the key point is to check the value set in the layer
BOOL __isViewFirstShown( UIViewController *view )
{
	NSNumber *statuesNumber = [view.view.layer valueForKey:__VIEW_KEY_DEF__];
	if ( statuesNumber == nil ) return YES;
	return [statuesNumber boolValue];
}

// set the view shown statues to SHOWN.
void __viewHasBeenShown( UIViewController *view )
{
	NSNumber *statuesNumber = [NSNumber numberWithBool:NO];
	[view.view.layer setValue:statuesNumber forKey:__VIEW_KEY_DEF__];
}

// reset the viewcontroller's shown statues.
void __viewShowStatuesReset( UIViewController *view )
{
	NSNumber *statuesNumber = [NSNumber numberWithBool:YES];
	[view.view.layer setValue:statuesNumber forKey:__VIEW_KEY_DEF__];
	
	if ( view.bindController != nil ) {
		__viewShowStatuesReset( view.bindController );
	}
}

