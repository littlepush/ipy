//
//  UIView+Animations.m
//  PYUIKit
//
//  Created by littlepush on 8/16/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "UIView+Animations.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (Animations)

#pragma FadeInFadeOut
@dynamic isFadedOut;
-(BOOL) isFadedOut { return (self.alpha == 0.f || self.superview == nil); };

-(void) animateFadeIn:(UIView *)inView withDuration:(NSTimeInterval)duration
{
	[self animateFadeIn:inView withDuration:duration completed:nil];
}

-(void) animateFadeIn:(UIView *)inView 
	withDuration:(NSTimeInterval)duration 
	completed:(PYViewAnimate)completed
{
	[inView setAlpha:0.f];
	if ( inView.superview == nil ) {
		[inView setFrame:self.frame];
		[self.superview insertSubview:inView belowSubview:self];
		//[self.superview addSubview:inView];
	}
	
	[UIView animateWithDuration:duration animations:^(void){
		[self setAlpha:0.f];
		[inView setAlpha:1.f];
	} completion:^(BOOL finished) {
		if ( completed ) completed();
	}];
}

#pragma Flip
@dynamic isFlippedOut;
-(BOOL) isFlippedOut {
	return self.superview == nil;
}

#define kFlipMarkSuperView		@"kFlipMarkSuperView"

-(void) animateFlipToView:(UIView *)view withDuration:(NSTimeInterval)duration
{
	[self animateFlipToView:view withDuration:duration completed:nil];
}

-(void) animateFlipToView:(UIView *)view 
	withDuration:(NSTimeInterval)duration 
	completed:(PYViewAnimate)completed
{
	CATransform3D defaultTransform = CATransform3DIdentity;
	defaultTransform.m34 = -0.0005;

	if ( view.superview != self.superview ) {
		if ( view.superview != nil ) [view removeFromSuperview];
	}
	// init view's statue
	[view setFrame:self.frame];
	[self.superview insertSubview:view belowSubview:self];
	[view.layer setTransform:CATransform3DRotate(defaultTransform, M_PI_2, 0, 1, 0)];
	
	[UIView animateWithDuration:duration / 2 animations:^{
		[self.layer setTransform:CATransform3DRotate(defaultTransform, M_PI_2, 0, -1, 0)];
	} completion:^(BOOL finished) {
		[self removeFromSuperview];
		[UIView animateWithDuration:duration / 2 animations:^{
			[view.layer setTransform:CATransform3DRotate(defaultTransform, 0, 0, -1, 0)];
		} completion:^(BOOL finished) {
			if ( completed ) completed();
		}];
	}];
}

#pragma Page
/* internal */
-(void) pageTo:(UIView *)view duration:(NSTimeInterval)duration 
	toPrev:(BOOL)toPrev completed:(PYViewAnimate)completed
{
	CATransform3D defaultTransform = CATransform3DIdentity;
	defaultTransform.m34 = -0.001;

	if ( toPrev ) {
		[self.superview insertSubview:view aboveSubview:self];
		[view.layer setAnchorPoint:CGPointMake(0.0, 0.5)];
		[view.layer setTransform:CATransform3DRotate(defaultTransform, M_PI, 0, -1, 0)];
	} else {
		[self.layer setAnchorPoint:CGPointMake(0.0, 0.5)];
		[self.superview insertSubview:view belowSubview:self];
	}
	[view setFrame:self.frame];
	
	[UIView animateWithDuration:duration animations:^{
		if ( toPrev ) {
			[view.layer setTransform:CATransform3DRotate(defaultTransform, 0, 0, 1, 0)];
		} else {
			[self.layer setTransform:CATransform3DRotate(defaultTransform, M_PI, 0, -1, 0)];
		}
	} completion:^(BOOL finished) {
		[self removeFromSuperview];
		if ( completed ) completed();
	}];
}
/* Page to next or prev view */
-(void) animatePageNextView:(UIView *)view withDuration:(NSTimeInterval)duration
{
	[self pageTo:view duration:duration toPrev:NO completed:NULL];
}
-(void) animatePagePrevView:(UIView *)view withDuration:(NSTimeInterval)duration
{
	[self pageTo:view duration:duration toPrev:YES completed:NULL];
}

/* Page with completed call back block */
-(void) animatePageNextView:(UIView *)view 
	withDuration:(NSTimeInterval)duration 
	completed:(PYViewAnimate)completed
{
	[self pageTo:view duration:duration toPrev:NO completed:completed];
}
	
-(void) animatePagePrevView:(UIView *)view 
	withDuration:(NSTimeInterval)duration 
	completed:(PYViewAnimate)completed
{
	[self pageTo:view duration:duration toPrev:YES completed:completed];
}

@end
