//
//  PYTouchSwitcher.m
//  PYUIKit
//
//  Created by Push Chen on 7/27/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "PYTouchSwitcher.h"
#import "PYLibImage.h"

@implementation PYTouchSwitcher

@dynamic backgroundImage;
-(UIImage *)backgroundImage {
	return [_backgroundImage image];
}
-(void) setBackgroundImage:(UIImage *)anImage {
	[_backgroundImage setImage:anImage];
}

@synthesize touchButton = _switchButton;

@dynamic buttonImage;
-(UIImage *)buttonImage {
	return [[_switchButton imageView] image];
}
-(void) setButtonImage:(UIImage *)anImage forState:(UIControlState)state {
	[_switchButton setImage:anImage forState:state];
}

@synthesize textLabel = _textLabel;

@synthesize touchDirection = _direction;
-(void) setDirection:(PYTouchSwitcherDirection)aDirection {
	_direction = aDirection;
	[self setNeedsLayout];
}

@synthesize isHideText = _isHideText;
-(void) setHideTextWhenSwipe:(BOOL)hidden {
	_isHideText = hidden;
	[self setNeedsLayout];
}

@synthesize isAlwaysShowBackground = _isAlwaysShowBackground;
-(void) setAlwaysShowBackground:(BOOL)show {
	_isAlwaysShowBackground = show;
	[self setNeedsLayout];
}

@synthesize delegate = _delegate;

-(void) dealloc {
	[_backgroundImage release];
	_backgroundImage = nil;
	
	[_switchButton release];
	_switchButton = nil;
	
	[_textLabel release];
	_textLabel = nil;
	
	_delegate = nil;
	_touchTimer = nil;
	
	[super dealloc];
}

// Internal
-(void) switchTimerAction:(NSTimer *)timer
{
	if ( _isSwiping == NO ) {
		[UIView animateWithDuration:0.15 animations:^{
			[_backgroundImage setAlpha:1];
			[_textLabel setAlpha:1];
		} completion:^(BOOL finished) {
			_isSwiping = YES;
		}];
	}
}

-(void) switchButtonDragInside:(id)sender withEvent:(UIEvent *)event
{
	[self switchTimerAction:nil];
	//_isSwiping = YES;
	
#define __PY_SLIDE_OFFSET			\
	(_switchButton.frame.size.width / 2)
#define __PY_SLIDE_REALLENGTH		\
	(self.frame.size.width - _switchButton.frame.size.width)
#define __PY_SLIDE_CURRENTPOINT		\
	(_switchButton.center.x - __PY_SLIDE_OFFSET)
	
	if ( _firstDraging == YES ) {
		if ( [_delegate respondsToSelector:@selector(touchSwitcherBeginToDrag:)] ) {
			[_delegate touchSwitcherBeginToDrag:self];
		}
		_firstDraging = NO;
	}
	
	if ( _switchButton.isSelected ) {
		[_switchButton setSelected:NO];
		_switchButton.transform = CGAffineTransformIdentity;
	}

	CGPoint movePoint =	[[[event allTouches] anyObject] locationInView:self];
	CGPoint currentPoint = _switchButton.center;
	movePoint.y = currentPoint.y;
	//PYLog(@"pan gesture move to point: %f, %f", movePoint.x, movePoint.y);
	//CGSize buttonSize = _movableButton.frame.size;
	if ( movePoint.x <= __PY_SLIDE_OFFSET ) {
		if ( _switchButton.center.x > __PY_SLIDE_OFFSET )
			movePoint.x = __PY_SLIDE_OFFSET;
		else return;
	}
	if ( movePoint.x >= (__PY_SLIDE_REALLENGTH + __PY_SLIDE_OFFSET) ) {
		if ( _switchButton.center.x < (__PY_SLIDE_REALLENGTH + __PY_SLIDE_OFFSET) )
			movePoint.x = (__PY_SLIDE_REALLENGTH + __PY_SLIDE_OFFSET);
		else return;
	}
	//draggingGesture 
	[_switchButton setCenter:movePoint];
	
	if ( _isHideText ) {
		CGFloat _percentage = __PY_SLIDE_CURRENTPOINT / __PY_SLIDE_REALLENGTH;
		CGFloat _alpha = (_direction == PYTouchSwitcherDirectionLeftToRight) ?
			1 - _percentage : _percentage;
		[_textLabel setAlpha:_alpha];
	}
	
	if ( _direction == PYTouchSwitcherDirectionLeftToRight ) {
		if ( movePoint.x == __PY_SLIDE_OFFSET + __PY_SLIDE_REALLENGTH )	// to right
		{
			if ( [_delegate respondsToSelector:@selector(touchSwitcherSlideToEnd:)] )
			{
				[_delegate touchSwitcherSlideToEnd:self];
			}
		}
	} else {
		if ( movePoint.x == __PY_SLIDE_OFFSET ) 
		{
			if ( [_delegate respondsToSelector:@selector(touchSwitcherSlideToEnd:)] )
			{
				[_delegate touchSwitcherSlideToEnd:self];
			}
		}
	}
}

-(void) switchButtonTouchUpInsideAction:(id)sender
{
	if (_touchTimer != nil) {
		[_touchTimer invalidate];
		[_touchTimer release];
		_touchTimer = nil;
	}
	// do something
	if ( _switchButton.frame.origin.x != (
		(_direction == PYTouchSwitcherDirectionLeftToRight) ?
			0 : self.bounds.size.width - self.bounds.size.height)
	) {
		[UIView animateWithDuration:0.15 animations:^{
			[_backgroundImage setAlpha:(_isAlwaysShowBackground ? 1 : 0)];
			[_textLabel setAlpha:1];
			CGRect _btnFrame = _switchButton.frame;
			_btnFrame.origin.x = (_direction == PYTouchSwitcherDirectionLeftToRight ?
				0 : self.frame.size.width - _btnFrame.size.width);
			[_switchButton setFrame:_btnFrame];
		} completion:^(BOOL finished) {
			_isSwiping = NO;
		}];
	} else {
		if ( [_delegate respondsToSelector:@selector(touchSwitcherClick:)] ) {
			[_delegate touchSwitcherClick:self];
		}
	}
	// last
	_isSwiping = NO;
	_firstDraging = YES;
}

-(void) switchButtonTouchDragExitAction:(id)sender
{
	if ( _backgroundImage.alpha > 0 ) {
		[UIView animateWithDuration:0.15 animations:^{
			[_backgroundImage setAlpha:(_isAlwaysShowBackground ? 1 : 0)];
			[_textLabel setAlpha:1];
			CGRect _btnFrame = _switchButton.frame;
			_btnFrame.origin.x = (_direction == PYTouchSwitcherDirectionLeftToRight ?
				0 : self.frame.size.width - _btnFrame.size.width);
			[_switchButton setFrame:_btnFrame];
		} completion:^(BOOL finished) {
			_isSwiping = NO;
		}];
	} 
	_firstDraging = YES;
}

-(void) switchButtonTouchDownAction:(id)sender
{
	_touchTimer = [[NSTimer scheduledTimerWithTimeInterval:0.3 
		target:self selector:@selector(switchTimerAction:) 
		userInfo:nil repeats:NO] retain];
}

-(void) restore {
	[self switchButtonTouchDragExitAction:nil];
}

// Init
-(void) internalInitial
{
	[super internalInitial];
	
	_backgroundImage = [[[UIImageView alloc] initWithImage:
		[PYLibImage imageForKey:PYLibImageIndexSwitchBkg]] retain];
	[self addSubview:_backgroundImage];
	
	_switchButton = [[[UIButton alloc] init] retain];
	[_switchButton 
		setImage:[PYLibImage imageForKey:PYLibImageIndexSwitchBtn]
		forState:UIControlStateNormal];
	[self addSubview:_switchButton];
	
	[_switchButton addTarget:self 
		action:@selector(switchButtonTouchUpInsideAction:) 
		forControlEvents:UIControlEventTouchUpInside];
	[_switchButton addTarget:self 
		action:@selector(switchButtonTouchDownAction:) 
		forControlEvents:UIControlEventTouchDown];
	[_switchButton addTarget:self 
		action:@selector(switchButtonDragInside:withEvent:) 
		forControlEvents:UIControlEventTouchDragInside];
	[_switchButton addTarget:self
		action:@selector(switchButtonTouchDragExitAction:) 
		forControlEvents:UIControlEventTouchDragExit];
	_textLabel = [[[UILabel alloc] init] retain];
	[_textLabel setBackgroundColor:[UIColor clearColor]];
	[_backgroundImage addSubview:_textLabel];
	
	_direction = PYTouchSwitcherDirectionLeftToRight;
	_isHideText = YES;
	_isSwiping = NO;
	_isAlwaysShowBackground = NO;
	
	[self setBackgroundColor:[UIColor clearColor]];
}

-(void) layoutSubviews
{
	PYComponentViewInitChecking;
	
	CGRect _selfFrame = self.bounds;
	[_backgroundImage setFrame:_selfFrame];

	CGRect _btnFrame = _switchButton.frame;
	_btnFrame.size.height = _selfFrame.size.height;
	_btnFrame.size.width = _selfFrame.size.height;
	_btnFrame.origin.x = (_direction == PYTouchSwitcherDirectionLeftToRight) ?
		0 : _selfFrame.size.width - _selfFrame.size.height;
	_btnFrame.origin.y = 0;
	[_switchButton setFrame:_btnFrame];
	
	CGFloat _halfSize = _selfFrame.size.height / 2;
	CGFloat _textWidth = _selfFrame.size.width - _selfFrame.size.height - _halfSize;
	if ( _textWidth < 0.f ) {
		_textWidth = 0.f;
		_halfSize = 0.f;
	} else if ( _textWidth == 0 ) {
		_textWidth = _halfSize;
		_halfSize = 0.f;
	}
	
	CGFloat _xPos = (_direction == PYTouchSwitcherDirectionLeftToRight) ?
		_selfFrame.size.height : _halfSize;
	CGRect _textFrame = CGRectMake(_xPos, 0, _textWidth, _selfFrame.size.height);
	[_textLabel setFrame:_textFrame];
	
	[_textLabel setTextAlignment:
		((_direction == PYTouchSwitcherDirectionLeftToRight) ?
		UITextAlignmentRight : UITextAlignmentLeft)];
	
	[_textLabel setAlpha:1];
	[_backgroundImage setAlpha:(_isAlwaysShowBackground ? 1 : 0)];
}

@end
