//
//  PYSlider.m
//  pyutility-uitest
//
//  Created by Push Chen on 6/1/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "PYSlider.h"
#import "PYLibImage.h"

#define __PY_SLIDE_OFFSET			\
	(_slideButton.frame.size.width / 2)
#define __PY_SLIDE_REALLENGTH		\
	(self.frame.size.width - _slideButton.frame.size.width)
#define __PY_SLIDE_CURRENTPOINT		\
	(_slideButton.center.x - __PY_SLIDE_OFFSET)
#define __PY_SLIDE_REALRANGE		\
	(_maximum - _minimum)

@implementation PYSlider

@dynamic backgroundImage;
@dynamic slideButtonImage;
@dynamic slideButtonColor;
@dynamic minTrackTintImage;
@dynamic maxTrackTintImage;
@dynamic minTrackTintColor;
@dynamic maxTrackTintColor;
@dynamic currentValue;

@synthesize minimum = _minimum;
@synthesize maximum = _maximum;
@synthesize delegate = _delegate;

/* Functional Methods */
-(UIImage *)imageWithImage:(UIImage *)sourceImage cropToSize:(CGSize)size
{
	CGRect _imageRect = CGRectMake(0, 0, size.width, size.height);
	CGImageRef imageRef = CGImageCreateWithImageInRect([sourceImage CGImage], _imageRect);
	UIImage *newImage = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	
	return newImage;
}

-(UIImage *)imageWithImage:(UIImage *)sourceImage scaledToSize:(CGSize)size
{
	UIGraphicsBeginImageContext(size);
	[sourceImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

	UIGraphicsEndImageContext();

	return newImage;
}

/* Properties */

-(UIImage *) backgroundImage
{
	return [_backgroundView image];
}

-(void) setBackgroundImage:(UIImage *)anImage
{
	[_backgroundView setImage:anImage];
}

-(UIImage *) slideButtonImage
{
	return [_slideButton image];
}

-(void) setSlideButtonImage:(UIImage *)anImage
{
	[_slideButton setImage:anImage];
}

-(UIColor *) slideButtonColor
{
	return [_slideButton backgroundColor];
}

-(void) setSlideButtonColor:(UIColor *)aColor
{
	[_slideButton setBackgroundColor:aColor];
}

-(UIImage *) minTrackTintImage
{
	return _minTrackTintImage;
	//return [_minTrackTint image];
}

-(void) setMinTrackTintImage:(UIImage *)anImage
{
	_minTrackTintImage = [self imageWithImage:anImage scaledToSize:self.bounds.size];

	[_maxTrackTint setImage:
		[self imageWithImage:_minTrackTintImage 
			cropToSize:_minTrackTint.frame.size]];
}

-(UIImage *) maxTrackTintImage
{
	return [_maxTrackTint image];
} 

-(void) setMaxTrackTintImage:(UIImage *)anImage
{
	[_maxTrackTint setImage:anImage];
}

-(UIColor *)minTrackTintColor
{
	return [_minTrackTint backgroundColor];
}

-(void) setMinTrackTintColor:(UIColor *)aColor
{
	[_minTrackTint setBackgroundColor:aColor];
}

-(UIColor *)maxTrackTintColor
{
	return [_maxTrackTint backgroundColor];
}

-(void) setMaxTrackTintColor:(UIColor *)aColor
{
	[_maxTrackTint setBackgroundColor:aColor];
}

-(CGFloat)currentValue
{
	// percentage * allrange + minimum;
	return __PY_SLIDE_CURRENTPOINT / __PY_SLIDE_REALLENGTH * 
		__PY_SLIDE_REALRANGE + _minimum;
}

-(void) _setCurrentValue:(CGFloat)aValue
{
	CGFloat _Xposition = ((( aValue - _minimum ) / __PY_SLIDE_REALRANGE) * 
		__PY_SLIDE_REALLENGTH ) +  __PY_SLIDE_OFFSET;
	CGPoint _center = CGPointMake(_Xposition, _slideButton.center.y );
	CGRect _minFrame = _minTrackTint.frame;
	_minFrame.size.width = _Xposition;
	[_slideButton setCenter:_center];
	[_minTrackTint setFrame:_minFrame];
	[_minTrackTint setImage:
		[self imageWithImage:_minTrackTintImage 
		 cropToSize:_minTrackTint.frame.size]];
	if ( [_delegate respondsToSelector:@selector(pySlider:valueChangedTo:)] ) {
		[_delegate pySlider:self valueChangedTo:self.currentValue];
	}
}

#define _SLIDE_ANIMATION_SPLITE		3500

-(void) _animatedSetValue:(CGFloat)aValue step:(CGFloat)step
{
	if ( ABS(self.currentValue - aValue) < ABS(step) ) {
		[self _setCurrentValue:aValue];
		return;
	}
	
	[UIView animateWithDuration:0.35 / _SLIDE_ANIMATION_SPLITE
	 animations:^{
		 [self _setCurrentValue:(self.currentValue - step)];
	 } completion:^(BOOL finished) {
		 [self _animatedSetValue:aValue step:step];
	 }];
}

-(void) setCurrentValue:(CGFloat)aValue animated:(BOOL)animated
{
	//static CGFloat _animationTime = 0.35f;
	CGFloat _currentValue = self.currentValue;
	CGFloat _delta = (_currentValue - aValue) / _SLIDE_ANIMATION_SPLITE;
	if ( animated ) {
		[self _animatedSetValue:aValue step:_delta];
	} else {
		[self _setCurrentValue:aValue];
	}
}

/* Internal Methods of the Slide View */
-(void) __gestureRecognizerCallback:(id)sender
{
	UIPanGestureRecognizer *_slideRecognizer = (UIPanGestureRecognizer *)sender;
	CGPoint movePoint = [_slideRecognizer locationInView:self];
	CGPoint currentPoint = _slideButton.center;
	movePoint.y = currentPoint.y;
	//PYLog(@"pan gesture move to point: %f, %f", movePoint.x, movePoint.y);
	//CGSize buttonSize = _movableButton.frame.size;
	if ( movePoint.x <= __PY_SLIDE_OFFSET ) {
		if ( _slideButton.center.x > __PY_SLIDE_OFFSET )
			movePoint.x = __PY_SLIDE_OFFSET;
		else return;
	}
	if ( movePoint.x >= (__PY_SLIDE_REALLENGTH + __PY_SLIDE_OFFSET) ) {
		if ( _slideButton.center.x < (__PY_SLIDE_REALLENGTH + __PY_SLIDE_OFFSET) )
			movePoint.x = (__PY_SLIDE_REALLENGTH + __PY_SLIDE_OFFSET);
		else return;
	}
	//draggingGesture 
	[_slideButton setCenter:movePoint];

	// cut the image of min track tint
	CGRect _minFrame = _minTrackTint.frame;
	_minFrame.size.width = movePoint.x;
	[_minTrackTint setFrame:_minFrame];
	[_minTrackTint setImage:
		[self imageWithImage:_minTrackTintImage 
		 cropToSize:_minTrackTint.frame.size]];
		
	if ( [_delegate respondsToSelector:@selector(pySlider:valueChangedTo:)] ) {
		[_delegate pySlider:self valueChangedTo:self.currentValue];
	}
}

-(void) internalInitial
{
	_backgroundView = [[[UIImageView alloc] 
		initWithImage:[PYLibImage imageForKey:PYLibImageIndexSlideBkg]]
			retain];
	_slideButton = [[[UIImageView alloc]
		initWithImage:[PYLibImage imageForKey:PYLibImageIndexSlideBtn]]
			retain];
	_minTrackTint = [[[UIImageView alloc]
		initWithImage:[PYLibImage imageForKey:PYLibImageIndexSlideMin]]
			retain];
	_maxTrackTint = [[[UIImageView alloc]
		initWithImage:[PYLibImage imageForKey:PYLibImageIndexSlideMax]]
			retain];

	//_minTrackTintImage = [[PYLibImage imageForKey:PYLibImageIndexSlideMin] retain];

	UIPanGestureRecognizer *_slideRecognizer = [[[UIPanGestureRecognizer alloc] 
		initWithTarget:self action:@selector(__gestureRecognizerCallback:)] autorelease];
	[_slideRecognizer setMinimumNumberOfTouches:1];
	[_slideButton addGestureRecognizer:_slideRecognizer];

	[_slideButton setUserInteractionEnabled:YES];
	[self addSubview:_backgroundView];
	[self addSubview:_maxTrackTint];
	[self addSubview:_minTrackTint];
	[self addSubview:_slideButton];

	_minimum = 0.0;
	_maximum = 1.0;
}

/* Init the Slide View Interface */

-(id) initWithMinimum:(CGFloat)min Maximum:(CGFloat)max Current:(CGFloat)val
{
	self = [super init];
	if ( self ) {
		_minimum = min;
		_maximum = max;
		//self.currentValue = val;
		[self setCurrentValue:val animated:NO];
	}
	return self;
}

/* Dealloc the Slide View */
-(void) dealloc 
{
	_backgroundView = nil;
	_slideButton = nil;
	_minTrackTint = nil;
	_maxTrackTint = nil;
	_minTrackTintImage = nil;

	[super dealloc];
}

-(void) layoutSubviews
{
	// to draw the components
	if ( _initialed ) return;
	_initialed = YES;
	CGRect _theFrame = self.bounds;
	[_backgroundView setFrame:_theFrame];
	[_maxTrackTint setFrame:_theFrame];

	CGRect _buttonFrame = CGRectMake(0, 0, 
		_theFrame.size.height, _theFrame.size.height);
	[_slideButton setFrame:_buttonFrame];
	
	_minTrackTintImage = [[self imageWithImage:
			[PYLibImage imageForKey:PYLibImageIndexSlideMin]
		scaledToSize:_theFrame.size] retain];

	_theFrame.size.width = _slideButton.center.x + __PY_SLIDE_OFFSET;
	[_minTrackTint setFrame:_theFrame];
	[_minTrackTint setImage:
		[self imageWithImage:_minTrackTintImage 
		 cropToSize:_minTrackTint.frame.size]];
	
}

-(void)setFrame:(CGRect)aFrame
{
	_initialed = NO;
	CGFloat _currentValue = [self currentValue];
	[super setFrame:aFrame];
	[self setCurrentValue:_currentValue animated:NO];
}

@end
