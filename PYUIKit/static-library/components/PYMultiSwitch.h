//
//  PYMultiSwitch.h
//  pyutility-uitest
//
//  Created by Push Chen on 5/11/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PYComponentView.h"

/* PYMultiple Switcher Pre-Definition Delegate */
@protocol PYMultiSwitchDelegate;

/*
	multiple switcher, an upgraded version of PYSwitch
 */
@interface PYMultiSwitch : PYComponentView
{
	/* the background image view */
	UIImageView					*_backgroundImage;
	/* the button user touched */
	UIImageView					*_switchButton;
	
	/* the statues data */
	NSMutableArray				*_switchStatues;
	/* the label controls */
	NSMutableArray				*_switchLabel;

	/* current selected index */
	NSUInteger					_selectedIndex;
	
	/* statues fonts */
	UIFont						*_selectedFont;
	UIFont						*_unselectedFont;
	
	id< PYMultiSwitchDelegate >	_delegate;
}

/* set the image of the background */
@property (nonatomic, retain) UIImage						*backgroundImage;
/* set the button's image */
@property (nonatomic, retain) UIImage						*switchButtonImage;

/* get the statues list */
@property (nonatomic, readonly) NSArray						*switchStatues;

/* Selected Text Font */
@property (nonatomic, retain)	UIFont						*selectedFont;
/* Unselected Text Font */
@property (nonatomic, retain)	UIFont						*unselectedFont;

/* count of the statues */
@property (assign, readonly)	NSUInteger					statuesCount;

@property (nonatomic, retain) IBOutlet id< PYMultiSwitchDelegate >	delegate;

// Methods
/* add a new statues to the end */
-(void) addMultiSwitchStatues:(NSString *)statues;
/* delete one statues */
-(void) deleteMultiSwitchStatues:(NSString *)statues;
/* insert a statues */
-(void) insertMultiSwitchStatues:(NSString *)statues atIndex:(NSUInteger)index;
/* delete statues at specified index */
-(void) deleteMultiSwitchStatuesAtIndex:(NSUInteger)index;
/* change a statues' text */
-(void) setStatues:(NSString *)statues atIndex:(NSUInteger)index;
/* get the statues */
-(NSString *)statuesAtIndex:(NSUInteger)index;

/* Init */
-(id)initWithStatues:(NSArray *)statues;
-(id)initWithStatuesCount:(NSUInteger)count;

@end


/* Callback Delegate for Multi Switcher */
@protocol PYMultiSwitchDelegate <NSObject>

/* before the statues change */
-(void) pyMultiSwitch:(PYMultiSwitch *)switcher willSwitchToStatuesAtIndex:(NSUInteger)index;
/* after the statues changed */
-(void) pyMultiSwitch:(PYMultiSwitch *)switcher selectedStatuesAtIndex:(NSUInteger)index;

@end

