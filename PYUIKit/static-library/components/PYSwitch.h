//
//  PYSwitch.h
//  FootPath
//
//  Created by Push Chen on 3/31/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PYComponentView.h"

/* PYSwitch Delegate Pre-definition */
@protocol PYSwitchDelegate;

/* 
	The Switcher's Selected Mode.
	Usually, the left part of the switcher is ModeOn,
	the right part of the switcher is ModeOff.
 */
typedef enum {
  PYSwitchModeOff = 0,		// Mode Off, selecter button is at right part
  PYSwitchModeOn = 1		// Mode On, selecter button is at left part
} PYSwitchMode;

/* Customized Switch */
/*
	You can change the background image, the switcherButton's image,
	the seleted and unselected fonts of the switcher.
	Also, by the delegate, you can even control the statues of the 
	switcher when the mode will or did change.
 */
@interface PYSwitch : PYComponentView {
	// Subviews of the switcher
	UIImageView					*_backgroundImage;
	UIImageView					*_switcherBtn;
	UILabel						*_modeOnLabel;
	UILabel						*_modeOffLabel;
	
	// Gesture
	UISwipeGestureRecognizer	*_swipeGesture;
	
	// Private variable(s)
	PYSwitchMode				_mode;
	
	// Delegate
	id< PYSwitchDelegate>		_delegate;
}

/* The text of the ModeOn side */
@property (nonatomic, retain)	NSString		*modeOnText;
/* The text of the ModeOff side */
@property (nonatomic, retain)	NSString		*modeOffText;
/* Background Image of the switcher */
@property (nonatomic, retain)	UIImage			*backgroundImage;
/* Image of the switch button */
@property (nonatomic, retain)	UIImage			*buttonImage;
/* Selected Text Font */
@property (nonatomic, retain)	UIFont			*selectedFont;
/* Unselected Text Font */
@property (nonatomic, retain)	UIFont			*unselectedFont;
/* Current Mode */
@property (nonatomic, readonly) PYSwitchMode	currentMode;

// delegate
@property (nonatomic, retain)	IBOutlet id<PYSwitchDelegate> delegate;

/* Switch to a specified mode */
-(void) swithToMode:(PYSwitchMode)mode;

/* Set the enable statue */
-(void) setEnable:(BOOL)enable;

@end

// Protocol for the delegate.
@protocol PYSwitchDelegate <NSObject>

@optional
/* Before the switcher's mode changing, tell the delegate which mode will change to. */
-(void) plswitch:(PYSwitch *)aSwitch willChangeToMode:(PYSwitchMode)aMode;

/* After the switcher's mode changing, tell the delegate the mode has benn changed. */
-(void) plswitch:(PYSwitch *)aSwitch selectedMode:(PYSwitchMode)aMode;

@end
