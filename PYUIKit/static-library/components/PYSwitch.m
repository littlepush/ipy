//
//  PYSwitch.m
//  FootPath
//
//  Created by Push Chen on 3/31/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "PYSwitch.h"
#import "PYExtend.h"
#import "PYLibImage.h"

@implementation PYSwitch

@synthesize delegate = _delegate;
@dynamic modeOnText;
@dynamic modeOffText;
@dynamic backgroundImage;
@dynamic buttonImage;
@dynamic selectedFont;
@dynamic unselectedFont;
@synthesize currentMode = _mode;

#pragma mark - Internal Private Message Definition.
- (void)__changeMode {
	if ( _mode == PYSwitchModeOn ) {
		[_switcherBtn setFrame:_modeOffLabel.frame];
		[_swipeGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
		_mode = PYSwitchModeOff;
		
		// switch the font.
		UIFont *_selectedFont = [_modeOnLabel font];
		[_modeOnLabel setFont:_modeOffLabel.font];
		[_modeOffLabel setFont:_selectedFont];
	} else {
		[_switcherBtn setFrame:_modeOnLabel.frame];
		[_swipeGesture setDirection:UISwipeGestureRecognizerDirectionRight];
		_mode = PYSwitchModeOn;
		
		// switch the font.
		UIFont *_selectedFont = [_modeOffLabel font];
		[_modeOffLabel setFont:_modeOnLabel.font];
		[_modeOnLabel setFont:_selectedFont];
	}
}

- (void)__swipeGestureAction:(id)sender {
	// check the direction and move the button.
	if ( _delegate != nil && [_delegate
		respondsToSelector:@selector(plswitch:willChangeToMode:)] )
	{
		[_delegate plswitch:self 
			willChangeToMode:(_mode == 
				PYSwitchModeOn ? PYSwitchModeOff : PYSwitchModeOn)];
	}
	[UIView animateWithDuration:0.15 animations:^{
		[self __changeMode];
	} completion:^(BOOL finished) {
		if ( _delegate != nil && [_delegate 
			respondsToSelector:@selector(plswitch:selectedMode:)] )
		{
			[_delegate plswitch:self selectedMode:_mode];
		}
	}];
}

- (void)internalInitial
{
	// Initialize
	[super internalInitial];
	
	[self setBackgroundColor:[UIColor clearColor]];
	[self setBackgroundImage:[PYLibImage imageForKey:PYLibImageIndexSwitchBkg]];
	
	_modeOnLabel = [[[UILabel alloc] init] retain];
	_modeOffLabel = [[[UILabel alloc] init] retain];
	_switcherBtn = [[[UIImageView alloc] init] retain];
	[_switcherBtn setUserInteractionEnabled:YES];
	
	[self setButtonImage:[PYLibImage imageForKey:PYLibImageIndexSwitchBtn]];
	//[_switcherBtn setBackgroundColor:[UIColor blueColor]];

	//[_modeOnLabel setText:@"On"];
	UIFont *_onFont = [UIFont fontWithName:@"CourierNewPS-BoldMT" size:14];
	[_modeOnLabel setFont:_onFont];
	
	//[_modeOffLabel setText:@"Off"];
	UIFont *_offFont = [UIFont fontWithName:@"Courier New" size:14];
	[_modeOffLabel setFont:_offFont];
			
	[_modeOnLabel setTextAlignment:UITextAlignmentCenter];
	[_modeOffLabel setTextAlignment:UITextAlignmentCenter];
	[_modeOnLabel setBackgroundColor:[UIColor clearColor]];
	[_modeOffLabel setBackgroundColor:[UIColor clearColor]];
		
	[self addSubview:_switcherBtn];
	[self addSubview:_modeOnLabel];
	[self addSubview:_modeOffLabel];
	
	_mode = PYSwitchModeOn;
	_swipeGesture = [[[UISwipeGestureRecognizer alloc] 
		initWithTarget:self action:@selector(__swipeGestureAction:)] retain];
	[_swipeGesture setDirection:UISwipeGestureRecognizerDirectionRight];
	// remove all gesture
	while ( [_switcherBtn.gestureRecognizers count] > 0 ) {
		[_switcherBtn removeGestureRecognizer:
			[_switcherBtn.gestureRecognizers lastObject]];
	}
	[_switcherBtn addGestureRecognizer:_swipeGesture];
}

#pragma mark -

#pragma mark - Properties

-(NSString *)modeOnText {
	return [_modeOnLabel text];
}

-(void)setModeOnText:(NSString *)aText {
	[_modeOnLabel setText:aText];
}

-(NSString *)modeOffText {
	return [_modeOffLabel text];
}

-(void)setModeOffText:(NSString *)aText {
	[_modeOffLabel setText:aText];
}

-(UIImage *)backgroundImage {
	if ( _backgroundImage == nil ) return nil;
	return [_backgroundImage image];
}

-(void)setBackgroundImage:(UIImage *)anImage {
	if ( _backgroundImage == nil ) {
		_backgroundImage = [[[UIImageView alloc] 
			initWithFrame:self.frame] retain];
		[self insertSubview:_backgroundImage atIndex:0];
		PYSetCornorRadius(self, 0);
		[self setBackgroundColor:[UIColor clearColor]];
	}
	[_backgroundImage setImage:anImage];
}

-(UIImage *)buttonImage {
	return [_switcherBtn image];
}

-(void) setButtonImage:(UIImage *)anImage {
	[_switcherBtn setImage:anImage];
}

-(UIFont *)selectedFont {
	return [(_mode == PYSwitchModeOn ? _modeOnLabel : _modeOffLabel) font];
}

-(void) setSelectedFont:(UIFont *)aFont {
	[(_mode == PYSwitchModeOn ? _modeOnLabel : _modeOffLabel) setFont:aFont];
}

-(UIFont *)unselectedFont {
	return [(_mode == PYSwitchModeOff ? _modeOnLabel : _modeOffLabel) font];
}
-(void)setUnselectedFont:(UIFont *)aFont {
	[(_mode == PYSwitchModeOff ? _modeOnLabel : _modeOffLabel) setFont:aFont];
}

#pragma mark - 

-(void)dealloc {
	[_modeOnLabel release];
	[_modeOffLabel release];
	[_switcherBtn release];
	[_swipeGesture release];
	[_delegate release];
	
	if ( _backgroundImage != nil ) {
		[_backgroundImage release];
	}
	
	[super dealloc];
}

// Set the layout of all subviews
-(void)layoutSubviews
{
	if ( _initialed ) return;
	_initialed = YES;
	if ( _backgroundImage != nil ) {
		[_backgroundImage setFrame:self.bounds];
	}
	CGRect _bounds = self.bounds;
	_bounds.size.width /= 2;
	[_modeOnLabel setFrame:_bounds];
	_bounds.origin.x += _bounds.size.width;
	[_modeOffLabel setFrame:_bounds];
	
	if ( _mode == PYSwitchModeOn ) {
		[_switcherBtn setFrame:_modeOnLabel.frame];
	} else {
		[_switcherBtn setFrame:_modeOffLabel.frame];
	}
}

-(void)setFrame:(CGRect)aFrame
{
	_initialed = NO;
	[super setFrame:aFrame];
}

-(void) swithToMode:(PYSwitchMode)mode
{
	if ( _mode == mode ) return;
	//[self __swipeGestureAction:_swipeGesture];
	//_mode = mode;
	[self __changeMode];
}

-(void) setEnable:(BOOL)enable
{
	if ( enable ) {
		if ( [self.gestureRecognizers containsObject:_swipeGesture] ) return;
		[self addGestureRecognizer:_swipeGesture];
	} else {
		if ( ![self.gestureRecognizers containsObject:_swipeGesture] ) return;
		[self removeGestureRecognizer:_swipeGesture];		
	}
}

@end
