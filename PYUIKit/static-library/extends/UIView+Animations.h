//
//  UIView+Animations.h
//  PYUIKit
//
//  Created by littlepush on 8/16/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^PYViewAnimate)(void);

@interface UIView (Animations)

#pragma FadeInFadeOut
/* Checking property */
@property (nonatomic, readonly)	BOOL	isFadedOut;
/* Fade out current view and fade the specified view */
-(void) animateFadeIn:(UIView *)inView withDuration:(NSTimeInterval)duration;
/* Fade in / out animation with completed call back block */
-(void) animateFadeIn:(UIView *)inView 
	withDuration:(NSTimeInterval)duration 
	completed:(PYViewAnimate)completed;
	
#pragma Flip
/* Checking property */
@property (nonatomic, readonly) BOOL	isFlippedOut;
/* Flip current view to other view */
-(void) animateFlipToView:(UIView *)view withDuration:(NSTimeInterval)duration;
/* animate with completed call back block */
-(void) animateFlipToView:(UIView *)view	
	withDuration:(NSTimeInterval)duration 
	completed:(PYViewAnimate)completed;
	
#pragma Page
/* Page to next or prev view */
-(void) animatePageNextView:(UIView *)view withDuration:(NSTimeInterval)duration;
-(void) animatePagePrevView:(UIView *)view withDuration:(NSTimeInterval)duration;

/* Page with completed call back block */
-(void) animatePageNextView:(UIView *)view 
	withDuration:(NSTimeInterval)duration 
	completed:(PYViewAnimate)completed;
	
-(void) animatePagePrevView:(UIView *)view 
	withDuration:(NSTimeInterval)duration 
	completed:(PYViewAnimate)completed;

@end
