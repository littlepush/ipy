//
//  PYMultiSwitch.m
//  pyutility-uitest
//
//  Created by Push Chen on 5/11/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "PYMultiSwitch.h"
#import "PYLibImage.h"

#define __PY_MS_CREATELABEL(_lbvar)							\
	UILabel *_lbvar = [[[UILabel alloc] init] autorelease];	\
	[_lbvar setBackgroundColor:[UIColor clearColor]];		\
	[_lbvar setTextAlignment:UITextAlignmentCenter];		\
	[self addSubview:_lbvar]

@implementation PYMultiSwitch

@synthesize switchStatues = _switchStatues;
@synthesize delegate = _delegate;
@synthesize selectedFont = _selectedFont;
@synthesize unselectedFont = _unselectedFont;

@dynamic backgroundImage;
@dynamic switchButtonImage;
@dynamic statuesCount;

-(void) __swipeLeftAction:(id)sender
{	
	if ( _selectedIndex == 0 || [_switchStatues count] == 1 ) return;
	if ( [_delegate respondsToSelector:@selector(pyMultiSwitch:willSwitchToStatuesAtIndex:)] ) {
		[_delegate pyMultiSwitch:self willSwitchToStatuesAtIndex:_selectedIndex - 1];
	}	
	[UIView animateWithDuration:0.3
	 animations:^{
		 CGRect _buttonFrame = _switchButton.frame;
		 _buttonFrame.origin.x -= _buttonFrame.size.width;
		 if ( _buttonFrame.origin.x < 0 ) _buttonFrame.origin.x = 0;
		 [_switchButton setFrame:_buttonFrame];
	 } completion:^(BOOL finished) {
		 _selectedIndex -= 1;
		 if ( [_delegate respondsToSelector:@selector(pyMultiSwitch:selectedStatuesAtIndex:)] ) {
			[_delegate pyMultiSwitch:self selectedStatuesAtIndex:_selectedIndex];
		 }
	 }];
}

-(void) __swipeRightAction:(id)sender
{
	if ( _selectedIndex == [_switchStatues count] - 1
		|| [_switchStatues count] == 1 ) {
		PYLog(@"already the last one...");
		return;
	}
	if ( [_delegate respondsToSelector:@selector(pyMultiSwitch:willSwitchToStatuesAtIndex:)] ) {
		[_delegate pyMultiSwitch:self willSwitchToStatuesAtIndex:_selectedIndex + 1];
	}	
	[UIView animateWithDuration:0.3
	 animations:^{
		 CGRect _buttonFrame = _switchButton.frame;
		 _buttonFrame.origin.x += _buttonFrame.size.width;
		 //if ( _buttonFrame.origin.x < 0 ) _buttonFrame.origin.x = 0;
		 [_switchButton setFrame:_buttonFrame];
	 } completion:^(BOOL finished) {
		 _selectedIndex += 1;
		 if ( [_delegate respondsToSelector:@selector(pyMultiSwitch:selectedStatuesAtIndex:)] ) {
			[_delegate pyMultiSwitch:self selectedStatuesAtIndex:_selectedIndex];
		 }
	 }];
}

-(void) internalInitial
{
	[self setBackgroundColor:[UIColor clearColor]];
	_backgroundImage = [[[UIImageView alloc] initWithFrame:self.bounds] retain];
	[_backgroundImage setImage:[PYLibImage imageForKey:PYLibImageIndexSwitchBkg]];
	
	_switchButton = [[[UIImageView alloc] initWithFrame:self.bounds] retain];
	[_switchButton setImage:[PYLibImage imageForKey:PYLibImageIndexSwitchBtn]];
	[_switchButton setUserInteractionEnabled:YES];
	
	[self addSubview:_backgroundImage];
	[self addSubview:_switchButton];
	
	UISwipeGestureRecognizer * _swipeLeftGesture = 
		[[[UISwipeGestureRecognizer alloc] 
			initWithTarget:self action:@selector(__swipeLeftAction:)] autorelease];
	[_swipeLeftGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
	[_switchButton addGestureRecognizer:_swipeLeftGesture];
	
	UISwipeGestureRecognizer * _swipeRightGesture = 
		[[[UISwipeGestureRecognizer alloc]
			initWithTarget:self action:@selector(__swipeRightAction:)] autorelease];
	[_swipeRightGesture setDirection:UISwipeGestureRecognizerDirectionRight];
	[_switchButton addGestureRecognizer:_swipeRightGesture];
	
	_selectedIndex = 0;
	
	if ( _switchStatues == nil ) {
		_switchStatues = [[NSMutableArray array] retain];
	}
	if ( _switchLabel == nil ) {
		_switchLabel = [[NSMutableArray array] retain];
	}
}

-(void) __resetStatuesLabelWithSize:(CGSize)size
{
	for ( int i = 0; i < [_switchLabel count]; ++i ) {
		CGRect _labelFrame = CGRectMake(i * size.width, 0, size.width, size.height);
		UILabel *_label = [_switchLabel objectAtIndex:i];
		[_label setFrame:_labelFrame];
	}
}

-(void) __resetSwitchButtonFrameOfStatuesCount:(NSUInteger)count animated:(BOOL)animated
{
	if ( count == 0 ) count = 1;
	CGRect _buttonFrame = self.frame;
		
	_buttonFrame.size.width /= count;
	_buttonFrame.origin.y = 0;
	_buttonFrame.origin.x = (_buttonFrame.size.width * _selectedIndex);
	
	if ( animated ) {
		[UIView animateWithDuration:0.3
		 animations:^{
			[_switchButton setFrame:_buttonFrame];
			[self __resetStatuesLabelWithSize:_switchButton.frame.size];
		}];
	} else {
		[_switchButton setFrame:_buttonFrame];
		[self __resetStatuesLabelWithSize:_switchButton.frame.size];
	}
}

/* Property */

// Background Image
-(UIImage *)backgroundImage 
{
	//if ( _backgroundImage )
	return [_backgroundImage image];
}

-(void)setBackgroundImage:(UIImage *)anImage
{
	[_backgroundImage setImage:anImage];
}

// Switch Button Image
-(UIImage *)switchButtonImage
{
	return _switchButton.image;
	//return [[_switchButton imageView] image];
}

-(void) setSwitchButtonImage:(UIImage *)anImage
{
	[_switchButton setImage:anImage];
	//[_switchButton setImage:anImage forState:UIControlStateNormal];
}

// Statues Count

/* Init And Dealloc */

-(id)initWithStatues:(NSArray *)statues
{
	self = [super init];
	if (self) {
		_switchStatues = [[NSMutableArray arrayWithArray:statues] retain];
		for ( NSUInteger i = 0; i < [statues count]; ++i ) {
			//UILabel *_label = [[[UILabel alloc] init] autorelease];
			__PY_MS_CREATELABEL( _label );
			[_label setText:(NSString *)[statues objectAtIndex:i]];
			[_switchLabel addObject:_label];
		}
		[self __resetSwitchButtonFrameOfStatuesCount:[_switchStatues count] animated:NO];
	}
	return self;
}

-(id)initWithStatuesCount:(NSUInteger)count
{
	self = [super init];
	if ( self ) {
		for ( NSUInteger i = 0; i < count; ++i ) {
			//UILabel *_label = [[[UILabel alloc] init] autorelease];
			__PY_MS_CREATELABEL( _label );
			[_label setText:@""];
			[_switchStatues addObject:@""];
			[_switchLabel addObject:_label];
		}
		[self __resetSwitchButtonFrameOfStatuesCount:count animated:NO];
	}
	return self;
}


-(void)dealloc
{
	// do something
	[_backgroundImage release];
	[_switchButton release];
	[_switchStatues release];
	[_switchLabel release];
	_delegate = nil;
	
	[super dealloc];
}

/* Change the switcher's layout, redraw the switcher. */
-(void)layoutSubviews
{
	if ( _initialed ) return;
	_initialed = YES;
	[_backgroundImage setFrame:self.bounds];
	[self __resetSwitchButtonFrameOfStatuesCount:
		[_switchStatues count] animated:NO];
}

-(void)setFrame:(CGRect)aFrame
{
	_initialed = NO;
	[super setFrame:aFrame];
}

/* Statues */
-(void) addMultiSwitchStatues:(NSString *)statues
{
	[_switchStatues addObject:statues];
	//UILabel *statueLabel = [[[UILabel alloc] initWithFrame:[_switchButton frame]] autorelease];
	__PY_MS_CREATELABEL( statueLabel );
	[statueLabel setText:statues];
	[_switchLabel addObject:statueLabel];
	
	[self __resetSwitchButtonFrameOfStatuesCount:[_switchStatues count] animated:YES];
}
-(void) deleteMultiSwitchStatues:(NSString *)statues
{
	NSUInteger _index = [_switchStatues indexOfObject:statues];
	[_switchStatues removeObject:statues];
	UILabel *_statuesLabel = [_switchLabel objectAtIndex:_index];
	[_statuesLabel removeFromSuperview];
	[_switchLabel removeObjectAtIndex:_index];
	
	[self __resetSwitchButtonFrameOfStatuesCount:[_switchStatues count] animated:YES];
}
-(void) insertMultiSwitchStatues:(NSString *)statues atIndex:(NSUInteger)index
{
	[_switchStatues insertObject:statues atIndex:index];
	//UILabel *statueLabel = [[[UILabel alloc] initWithFrame:[_switchButton frame]] autorelease];
	__PY_MS_CREATELABEL( statueLabel );
	[statueLabel setText:statues];
	[self insertSubview:statueLabel aboveSubview:_backgroundImage];

	[self __resetSwitchButtonFrameOfStatuesCount:[_switchStatues count] animated:YES];
}
-(void) deleteMultiSwitchStatuesAtIndex:(NSUInteger)index
{
	[_switchStatues removeObjectAtIndex:index];
	UILabel *_statueLabel = [_switchLabel objectAtIndex:index];
	[_statueLabel removeFromSuperview];
	[_switchLabel removeObjectAtIndex:index];
	[self __resetSwitchButtonFrameOfStatuesCount:[_switchStatues count] animated:YES];
}
-(void) setStatues:(NSString *)statues atIndex:(NSUInteger)index
{
	NSString *_statues = [_switchStatues objectAtIndex:index];
	[_statues copy:statues];
	UILabel *_statuesLabel = [_switchLabel objectAtIndex:index];
	[_statuesLabel setText:statues];
}
-(NSString *)statuesAtIndex:(NSUInteger)index
{
	return [_switchStatues objectAtIndex:index];
}

@end
