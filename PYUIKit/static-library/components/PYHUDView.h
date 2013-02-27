//
//  PYHUDView.h
//  PYUIKit
//
//  Created by littlepush on 8/2/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "PYComponentView.h"

typedef enum {
	PYHUDViewTypeInvalidate			= 0,
	PYHUDViewTypeCustomized			= 0x00000001,
	PYHUDViewTypeMessage			= 0x00000002,
	PYHUDViewTypeDetailsMsg			= 0x00000004,
	//PYHUDViewTypeProgress			= 0x01000001,
	PYHUDViewTypeIndicate			= 0x02000001
} PYHUDViewType;

@protocol PYHUDViewDelegate;

#define PYHUDViewDefaultFrame		(CGRect){100, 192, 120, 120}
#define PYHUDViewDefaultAlpha		0.7f
#define PYHUDViewDefaultColor		[UIColor blackColor]

@interface PYHUDView : PYComponentView
{
	PYHUDViewType			_type;
	UIView					*_backgroundView;
	UIView					*_maskView;
	UIView					*_contentView;
	UILabel					*_messageLabel;
	UILabel					*_detailsLabel;
	
	CGFloat					_autoDismissedDuration;
	NSTimer					*_autoHideTimer;
	BOOL					_removeFromSuperviewAfterHidden;
	BOOL					_disableBackgroundAction;
	
	CGFloat					_margin;
	id<PYHUDViewDelegate>	_delegate;
}

+(PYHUDView *) hudView:(PYHUDViewType)type;
+(PYHUDView *) hudView:(PYHUDViewType)type frame:(CGRect)frame;
+(PYHUDView *) hudView:(PYHUDViewType)type message:(NSString *)message;
+(PYHUDView *) hudView:(PYHUDViewType)type 
	message:(NSString *)message hideAfter:(CGFloat)duration;
	
-(id) initWithType:(PYHUDViewType)type;
-(id) initWithType:(PYHUDViewType)type message:(NSString *)message;

@property (nonatomic, retain)	id< PYHUDViewDelegate > delegate;
@property (nonatomic, assign)	CGFloat		autoHiddenDuration;
@property (nonatomic, assign)	BOOL		removeFromSuperviewAfterHidden;
@property (nonatomic, assign)	BOOL		disableBackgroundAction;

@property (nonatomic, retain)	UIView		*contentView;
@property (nonatomic, copy)		NSString	*message;
@property (nonatomic, retain)	UIFont		*messageFont;
@property (nonatomic, copy)		NSString	*details;
@property (nonatomic, retain)	UIFont		*detailsFont;

@property (nonatomic, assign)	CGFloat		margin;

-(void) setHUDViewType:(PYHUDViewType)type;
-(void) showHUDViewOn:(UIView *)superview;
-(void) hideHUDView;

@end

@protocol PYHUDViewDelegate <NSObject>

-(void) pyHUDView:(PYHUDView *)hudview appearOnView:(UIView *)superview;
-(void) pyHUDViewDidHidden:(PYHUDView *)hudview;

@end
