//
//  PYTouchSwitcher.h
//  PYUIKit
//
//  Created by Push Chen on 7/27/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "PYComponentView.h"

@protocol PYTouchSwitcherDelegate;

/* Direction to put the switch button on */
typedef enum {
	PYTouchSwitcherDirectionLeftToRight,
	PYTouchSwitcherDirectionRightToLeft	
} PYTouchSwitcherDirection;

/* Touch Button And Slide Switcher Control */
@interface PYTouchSwitcher : PYComponentView
{
	UIImageView									*_backgroundImage;
	UIButton									*_switchButton;
	UILabel										*_textLabel;
	
	BOOL										_isSwiping;
	PYTouchSwitcherDirection					_direction;
	BOOL										_isHideText;
	BOOL										_isAlwaysShowBackground;
	
	BOOL										_firstDraging;
	
	NSTimer										*_touchTimer;
	
	id<PYTouchSwitcherDelegate>					_delegate;
}

/* The Background Image of the component */
@property (nonatomic, retain)	UIImage		*backgroundImage;
/* The Switch Button */
@property (nonatomic, readonly) UIButton	*touchButton;
/* The Switch Button's current image */
@property (nonatomic, readonly) UIImage		*buttonImage;
/* The text to be shown when sliding */
@property (nonatomic, retain)	UILabel		*textLabel;
/* The direction to slide */
@property (nonatomic, assign, setter = setDirection:) 
	PYTouchSwitcherDirection touchDirection;
/* If hide text when sliding */
@property (nonatomic, assign, setter = setHideTextWhenSwipe:) 
	BOOL isHideText;
/* If always show the background image */
@property (nonatomic, assign, setter = setAlwaysShowBackground:)
	BOOL isAlwaysShowBackground;
/* The delegate */
@property (nonatomic, retain) IBOutlet 
	id<PYTouchSwitcherDelegate> delegate;

/* Change the button's image */
-(void) setButtonImage:(UIImage *)anImage forState:(UIControlState)state;

/* Restore the control's state to default */
-(void) restore;

@end

/*
	Delegate of the TouchSwicther Control
	All message is optional
 */
@protocol PYTouchSwitcherDelegate <NSObject>

@optional
/* Touch up inside the switch button */
-(void) touchSwitcherClick:(PYTouchSwitcher *)tswitcher;
/* Slide the switch button to the end peer */
-(void) touchSwitcherSlideToEnd:(PYTouchSwitcher *)tswitcher;
/* Begin to drag the touch button */
-(void) touchSwitcherBeginToDrag:(PYTouchSwitcher *)tswitcher;
@end
