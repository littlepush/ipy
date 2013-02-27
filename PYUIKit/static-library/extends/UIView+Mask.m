//
//  UIView+Mask.m
//  FootPath
//
//  Created by Push Chen on 3/28/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "UIView+Mask.h"
#import "PYExtend.h"

#define kUIViewMaskTransparency	@"kUIViewMaskTransparency"
#define kUIViewMaskColor		@"kUIViewMaskColor"
#define kUIViewTapGesture		@"kUIViewTapGesture"
#define kUIViewBlurImage		@"kUIViewBlurImage"

@implementation UIView(Mask)

@dynamic transparency;
@dynamic maskColor;
//@dynamic _tapGesture;

-(void)_tapToDismissMaskView:(id)sender {
	//[self removeFromSuperview];
	//[self setTapGestureDismiss:NO];
	[self setMaskVisible:NO];
}

-(CGFloat)transparency {
	NSNumber *_transparency = [self.layer valueForKey:kUIViewMaskTransparency];
	if ( _transparency == nil ) {
		return 0.45;
	}
	return [_transparency floatValue];
}

-(void)setTransparency:(CGFloat)aTransparency {
	if ( aTransparency > 1.0 ) {
		float _integerPart = (float)(int)aTransparency;
		aTransparency = aTransparency - _integerPart;
	}
	NSNumber *_transparency = [NSNumber numberWithFloat:aTransparency];
	[self.layer setValue:_transparency forKey:kUIViewMaskTransparency];
}

-(UIColor *)maskColor {
	UIColor *_maskColor = [self.layer valueForKey:kUIViewMaskColor];
	if ( _maskColor == nil ) {
		return [UIColor blackColor];
	}
	return _maskColor;
}

-(void)setMaskColor:(UIColor *)aColor {
	[self.layer setValue:aColor forKey:kUIViewMaskColor];
}

-(UITapGestureRecognizer *)tapGesture {
	UITapGestureRecognizer *tap = [self.layer valueForKey:kUIViewTapGesture];
	return tap;
}

-(void)setTapGesture:(UITapGestureRecognizer *)aTapGesture {
	[self.layer setValue:aTapGesture forKey:kUIViewTapGesture];
}

-(void) setMaskVisible:(BOOL)aVisible
{
	if ( aVisible == YES && self.alpha == 1.0 ) {
		[self setAlpha:0.];
	}
	if ( aVisible == NO && self.alpha == 0.0 ) {
		[self setAlpha:self.transparency];
	}
	
	if ( aVisible ) {
		/*
		UIImage *_screenCapture =__CaptureScreen();
		UIImageView *_blurView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
		[_blurView setImage:[_screenCapture imageByApplyingBoxBlur3x3]];
		[self addSubview:_blurView];
		[self.layer setValue:_blurView forKey:kUIViewBlurImage];
		*/
		[self setBackgroundColor:[self maskColor]];
		[UIView 
			animateWithDuration:0.45 
			animations:^(void){
				[self setAlpha:[self transparency]];
			}
		];
	} else {
		/*
		UIImageView *_blurView = [self.layer valueForKey:kUIViewBlurImage];
		[_blurView removeFromSuperview];
		[self.layer setValue:nil forKey:kUIViewBlurImage];
		*/
		[self setAlpha:0.0];
	}
}

-(void) setTapGestureDismiss:(BOOL)enabled
{
	if ( enabled == NO ) {
		UITapGestureRecognizer *_tapGesture = [self tapGesture];
		if ( _tapGesture == nil ) return;
		[self removeGestureRecognizer:_tapGesture];
	} else {
		UITapGestureRecognizer *_tapGesture = [self tapGesture];
		if ( _tapGesture == nil ) {
			_tapGesture = [[[UITapGestureRecognizer alloc] 
							initWithTarget:self 
							action:@selector(_tapToDismissMaskView:)] autorelease];
			[self setTapGesture:_tapGesture];
			//[_tapGesture release];
		}
		[self addGestureRecognizer:_tapGesture];
	}
}

@end
