//
//  PYHUDView.m
//  PYUIKit
//
//  Created by littlepush on 8/2/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PYHUDView.h"
#import "UIView+Mask.h"
#import <QuartzCore/QuartzCore.h>

@interface PYHUDView (Private)

-(void) autoHideTimerHandler:(NSTimer *)timer;

-(void) initMessageLabel;
-(void) initDetailsLabel;

@end

@interface PYHUDView ()

// The Window
@property(nonatomic, strong) UIWindow *window;

@end

@implementation PYHUDView

@synthesize delegate = _delegate;
@synthesize margin = _margin;
@synthesize window;

@dynamic autoHiddenDuration;
-(CGFloat) autoHiddenDuration { return _autoDismissedDuration; }
-(void) setAutoHiddenDuration:(CGFloat)duration {
	_autoDismissedDuration = duration;
	if ( duration <= 0.f ) {
		if ( _autoHideTimer == nil ) return;
		[_autoHideTimer invalidate];
		[_autoHideTimer release];
		_autoHideTimer = nil;
		return;
	} 
	
	_autoHideTimer = [[NSTimer 
		scheduledTimerWithTimeInterval:duration 
		target:self 
		selector:@selector(autoHideTimerHandler:) 
		userInfo:nil 
		repeats:NO] retain];
}

@synthesize removeFromSuperviewAfterHidden = _removeFromSuperviewAfterHidden;
@dynamic disableBackgroundAction;
-(BOOL) disableBackgroundAction { return _disableBackgroundAction; }
-(void) setDisableBackgroundAction:(BOOL)disable
{
	if ( _disableBackgroundAction == disable ) return;
	_disableBackgroundAction = disable;
	if ( disable ) {
		// load mask view
		if ( _maskView != nil ) return;
		_maskView = [[UIView object] retain];
		[_maskView setMaskColor:[UIColor grayColor]];
		[_maskView setTransparency:0.1];
		[_maskView setTapGestureDismiss:NO];
		
		if ( self.superview != nil ) {
			[_maskView setFrame:self.superview.bounds];
			[self.superview insertSubview:_maskView belowSubview:self];
			[_maskView setMaskVisible:YES];
		}
	} else {
		if ( _maskView == nil ) return;
		[_maskView removeFromSuperview];
		[_maskView release];
		_maskView = nil;
	}
}

@dynamic contentView;
-(UIView *)contentView { return _contentView; }
-(void) setContentView:(UIView *)ctntView
{
	if ( ctntView == nil ) {
		_type &= 0xFFFFFFFE;
		[_contentView removeFromSuperview];
		_contentView = nil;
		return;
	}
	_type |= PYHUDViewTypeCustomized;
	if ( _contentView != nil ) {
		[_contentView removeFromSuperview];
		[_contentView release];
		_contentView = nil;
	}
	_contentView = [ctntView retain];
	[self addSubview:_contentView];
}


@dynamic message;
-(NSString *)message { return [_messageLabel text]; }
-(void) setMessage:(NSString *)msg {
	[self initMessageLabel];
	[_messageLabel setText:msg];
}

@dynamic details;
-(NSString *) details { return [_detailsLabel text]; }
-(void) setDetails:(NSString *)dt {
	[self initDetailsLabel];
	[_detailsLabel setText:dt];
}

@dynamic messageFont;
-(UIFont *)messageFont { return [_messageLabel font]; }
-(void) setMessageFont:(UIFont *)font {
	[self initMessageLabel];
	[_messageLabel setFont:font];
}

@dynamic detailsFont;
-(UIFont *)detailsFont { return [_detailsLabel font]; }
-(void) setDetailsFont:(UIFont *)font {
	[self initDetailsLabel];
	[_detailsLabel setFont:font];
}

+(PYHUDView *) hudView:(PYHUDViewType)type 
{
	PYHUDView *_hv = [PYHUDView object];
	[_hv setHUDViewType:type];
	return _hv;
}
+(PYHUDView *) hudView:(PYHUDViewType)type frame:(CGRect)frame
{
	PYHUDView *_hv = [PYHUDView object];
	[_hv setHUDViewType:type];
	[_hv setFrame:frame];
	return _hv;
}
+(PYHUDView *) hudView:(PYHUDViewType)type message:(NSString *)message
{
	PYHUDView *_hv = [PYHUDView object];
	[_hv setHUDViewType:type];
	[_hv setMessage:message];
	return _hv;
}
+(PYHUDView *) hudView:(PYHUDViewType)type 
	message:(NSString *)message hideAfter:(CGFloat)duration
{
	PYHUDView *_hv = [PYHUDView object];
	[_hv setHUDViewType:type];
	[_hv setMessage:message];
	[_hv setAutoHiddenDuration:duration];
	return _hv;
}
	
-(id) initWithType:(PYHUDViewType)type {
	self = [super init];
	if ( self ) {
		[self setHUDViewType:type];
	}
	return self;
}
-(id) initWithType:(PYHUDViewType)type message:(NSString *)message {
	self = [super init];
	if ( self ) {
		[self setHUDViewType:type];
		[self setMessage:message];
	}
	return self;
}

-(void) showHUDViewOn:(UIView *)superview 
{
	if ( self.window != nil ) return;
	
	self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
	self.window.windowLevel = UIWindowLevelAlert;
	self.window.backgroundColor = [UIColor clearColor];
	[self.window addSubview:self];
	
	[self.window makeKeyAndVisible];
	
//	if ( superview == nil && self.superview == nil ) {
//		superview = [[(UIWindow *)[[[UIApplication sharedApplication] 
//			windows] objectAtIndex:0] rootViewController] view];
//	} else if ( superview == nil && self.superview != nil ) {
//		superview = self.superview;
//		[self setAlpha:PYHUDViewDefaultAlpha];
//	} else {
//		[superview addSubview:self];
//	}
	if ([_delegate respondsToSelector:@selector(pyHUDView:appearOnView:)]) {
		[_delegate pyHUDView:self appearOnView:superview];
	}
}
-(void) hideHUDView
{
//	if ( _maskView != nil ) {
//		[_maskView removeFromSuperview];
//	}
//	if ( _removeFromSuperviewAfterHidden ) {
//		[self removeFromSuperview];
//	} else {
//		[self setAlpha:0.0];
//	}

	self.window.hidden = YES;
	self.window = nil;

	PYSingletonLock
	if (_autoHideTimer != nil) {
		[_autoHideTimer invalidate];
		[_autoHideTimer release];
		_autoHideTimer = nil;
	}
	PYSingletonUnLock
}

-(void) setHUDViewType:(PYHUDViewType)type
{
	if ( _type == type ) return;
	
	_type = type;
    
	// Reset _contentView
    if (( _contentView != nil ) && (_contentView.superview != nil)) {
        [_contentView removeFromSuperview];
        [_contentView release];
        _contentView = nil;
    }
    
	if ( _type & PYHUDViewTypeCustomized ) {
		if ( _type & PYHUDViewTypeIndicate ) {
			UIActivityIndicatorView *indicator = 
				[UIActivityIndicatorView object];
			[indicator setActivityIndicatorViewStyle:
				UIActivityIndicatorViewStyleWhiteLarge];
			[indicator startAnimating];
			[self addSubview:indicator];
			_contentView = [indicator retain];
		} else {
		}
	}
    
	if ( _type & PYHUDViewTypeMessage ) {
		[self initMessageLabel];
	} else {
		[_messageLabel removeFromSuperview];
		[_messageLabel release];
		_messageLabel = nil;
	}
	
	if ( _type & PYHUDViewTypeDetailsMsg ) {
		[self initDetailsLabel];
	} else {
		[_messageLabel removeFromSuperview];
		[_messageLabel release];
		_messageLabel = nil;
	}
	
	[self setNeedsLayout];
}

-(void) initMessageLabel
{
	_type |= PYHUDViewTypeMessage;
	if ( _messageLabel == nil ) {
		_messageLabel = [[UILabel object] retain];
		[_messageLabel setBackgroundColor:[UIColor clearColor]];
		[_messageLabel setFont:[UIFont boldSystemFontOfSize:17.f]];
		[_messageLabel setTextAlignment:UITextAlignmentCenter];
		[_messageLabel setTextColor:[UIColor whiteColor]];
		[self addSubview:_messageLabel];
	}
}

-(void) initDetailsLabel
{
	_type |= PYHUDViewTypeDetailsMsg;
	if ( _detailsLabel == nil ) {
		_detailsLabel = [[UILabel object] retain];
		[_detailsLabel setBackgroundColor:[UIColor clearColor]];
		[_detailsLabel setFont:[UIFont boldSystemFontOfSize:13.f]];
		[_detailsLabel setTextAlignment:UITextAlignmentCenter];
		[_detailsLabel setTextColor:[UIColor whiteColor]];
		[_detailsLabel setNumberOfLines:3];
		[self addSubview:_detailsLabel];
	}
}

-(void) autoHideTimerHandler:(NSTimer *)timer
{
	[self hideHUDView];
}

-(void) internalInitial
{
	[super internalInitial];
	
	// do something
	
	_type = PYHUDViewTypeMessage;
	
	[self setFrame:PYHUDViewDefaultFrame];
	[self setBackgroundColor:[UIColor clearColor]];
	_backgroundView = [[UIView object] retain];
	[_backgroundView setBackgroundColor:PYHUDViewDefaultColor];
	[_backgroundView setAlpha:PYHUDViewDefaultAlpha];
	[self insertSubview:_backgroundView atIndex:0];
	//[self addSubview:_backgroundView];
	//[self setBackgroundColor:PYHUDViewDefaultColor];
	//[self setAlpha:PYHUDViewDefaultAlpha];
	[self.layer setCornerRadius:10];
	[self.layer setMasksToBounds:YES];

	
	_autoDismissedDuration = 0.f;
	_removeFromSuperviewAfterHidden = YES;
	_disableBackgroundAction = NO;
	
	[self initMessageLabel];
	
	_margin = 10.f;
}

-(void) layoutSubviews
{
	PYComponentViewInitChecking;
	if ( self.superview == nil ) return;
	CGRect _bounds = self.bounds;
	if ( _bounds.size.width == 0 || _bounds.size.height == 0 ) return;
	
	if ( _contentView == nil && _messageLabel == nil && _detailsLabel == nil )
		return;
		
	[_backgroundView setFrame:_bounds];
	if ( _disableBackgroundAction && _maskView != nil ) {
		if ( _maskView.superview == nil ) {
			[self.superview insertSubview:_maskView belowSubview:self];
		}
		[_maskView setFrame:self.superview.bounds];
		[_maskView setMaskVisible:YES];
	} 
	CGFloat _fromBottom = _margin;
	CGFloat _width = _bounds.size.width - 2 * _margin;
	
	if ( _detailsLabel != nil ) {
		if ( _messageLabel == nil && _contentView == nil ) {
			[_detailsLabel setFrame:self.bounds];
			[_detailsLabel setCenter:CGPointMake(
				_bounds.size.width / 2, _bounds.size.height / 2)];
			return;
		}
	
		CGSize _detailSize = [_detailsLabel.text sizeWithFont:_detailsLabel.font 
			constrainedToSize:CGSizeMake(_width, 40.f)];
		_fromBottom += _detailSize.height;
		
		CGRect _df = CGRectMake(_margin, 
			_bounds.size.height - _fromBottom, _width, _detailSize.height);
		[_detailsLabel setFrame:_df];
		
		_fromBottom += _margin;
	}
	
	if ( _messageLabel != nil ) {
		if ( _detailsLabel == nil && _contentView == nil ) {
			[_messageLabel setFrame:self.bounds];
			[_messageLabel setCenter:CGPointMake(
				_bounds.size.width / 2, _bounds.size.height / 2)];
			return;
		}
		
		if ( _contentView == nil ) {
			CGFloat _h = _bounds.size.height - _margin - _fromBottom;
			[_messageLabel setFrame:CGRectMake(_margin, _margin, _width, _h)];
			return;
		}
		
		CGSize _msgSize = [_messageLabel.text sizeWithFont:_messageLabel.font
			constrainedToSize:CGSizeMake(_width, 20.f)];
		_fromBottom += _msgSize.height;
		
		CGRect _mf = CGRectMake(_margin, _bounds.size.height - _fromBottom, 
			_width, _msgSize.height);
		[_messageLabel setFrame:_mf];
	}
	
	if ( _contentView != nil ) {
		if ( _messageLabel == nil && _detailsLabel == nil ) {
			[_contentView setFrame:self.bounds];
			[_contentView setCenter:CGPointMake(
				_bounds.size.width / 2, _bounds.size.height / 2)];
			return;
		}
		
		CGFloat _h = _bounds.size.height - _margin - _fromBottom;
		[_contentView setFrame:CGRectMake(_margin, _margin, _width, _h)];
	}
}

-(void) dealloc 
{
	_backgroundView = nil;
	_maskView = nil;
	_contentView = nil;
	
	_messageLabel = nil;
	_detailsLabel = nil;
	[_autoHideTimer invalidate];
	_autoHideTimer = nil;
	
	_delegate = nil;

	[super dealloc];
}

@end
