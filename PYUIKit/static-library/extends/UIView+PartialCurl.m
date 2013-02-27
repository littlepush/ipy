//
//  UIView+PartialCurl.m
//  TuitaAnimation
//
//  Created by Push Chen on 1/10/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "UIView+PartialCurl.h"
#import <QuartzCore/QuartzCore.h>


#define kUIViewPartialCurlDuration		@"kUIViewPartialCurlDuration"
#define kUIViewPartialCurlPercent		@"kUIViewPartialCurlPercent"
#define kUIViewPartialCurlDelegate		@"kUIViewPartialCurlDelegate"
#define kUIViewPartialCurlStatue		@"kUIViewPartialCurlStatue"

@implementation UIView(PartialCurl)

@dynamic partialCurlDuration;
@dynamic partialCurlPercent;
@dynamic curlDelegate;

-(double)partialCurlDuration
{
	NSNumber *duration = [self.layer valueForKey:kUIViewPartialCurlDuration];
	if ( duration == nil ) return .4f;
	else return [duration doubleValue];
}

-(void)setPartialCurlDuration:(double)partialDuration
{
	NSNumber *duration = [NSNumber numberWithDouble:partialDuration];
	[self.layer setValue:duration forKey:kUIViewPartialCurlDuration];
}

-(double)partialCurlPercent
{
	NSNumber *percent = [self.layer valueForKey:kUIViewPartialCurlPercent];
	if ( percent == nil ) return .65f;
	else return [percent doubleValue];
}

-(void)setPartialCurlPercent:(double)percent
{
	NSNumber *curlPercent = [NSNumber numberWithDouble:percent];
	[self.layer setValue:curlPercent forKey:kUIViewPartialCurlPercent];	
}

-(id<UIViewPartialCurlDelegate>)curlDelegate
{
	return [self.layer valueForKey:kUIViewPartialCurlDelegate];
}

-(void)setCurlDelegate:(id<UIViewPartialCurlDelegate>)delg
{
	[self.layer setValue:delg forKey:kUIViewPartialCurlDelegate];
}

-(void)animationPartialCurlUp
{
	NSNumber *curledStatue = [self.layer valueForKey:kUIViewPartialCurlStatue];
	if ( curledStatue != nil ) {
		BOOL _curledStatue = [curledStatue boolValue];
		if ( _curledStatue ) return;
	}
	[self setAlpha:0];
	[UIView beginAnimations:@"partialPageCurlUp" context:nil];
	[UIView setAnimationDuration:[self partialCurlDuration]];
	[UIView setAnimationsEnabled:NO];
	[UIView setAnimationDelegate:self];
	[UIView 
	 setAnimationWillStartSelector:
	 @selector(animationPartialCurlWillStart:context:)];
	[UIView setAnimationsEnabled:YES];
	[UIView
	 setAnimationTransition:UIViewAnimationTransitionCurlUp
	 forView:self cache:YES];
	[UIView commitAnimations];
	
	[self performSelector:@selector(animationPartialCurlJustStarted)
			   withObject:nil
			   afterDelay:[self partialCurlPercent] * [self partialCurlDuration] ];
	
	curledStatue = [NSNumber numberWithBool:YES];
	[self.layer setValue:curledStatue forKey:kUIViewPartialCurlStatue];
}

-(void)animationPartialCurlDown
{
	NSNumber *curledStatue = [self.layer valueForKey:kUIViewPartialCurlStatue];
	if ( curledStatue == nil ) return;
	BOOL _curledStatue = [curledStatue boolValue];
	if ( _curledStatue == NO ) return;
	
	[self.layer removeAllAnimations];
	self.layer.speed = 1.0;
	self.alpha = 1;
	[UIView beginAnimations:@"partialPageCurlDown" context:nil];
	[UIView setAnimationDuration:[self partialCurlDuration]];
	[UIView setAnimationsEnabled:NO];
	[UIView setAnimationDelegate:self];
	[UIView 
	 setAnimationWillStartSelector:
	 @selector(animationPartialCurlWillStart:context:)];
	[UIView
	 setAnimationDidStopSelector:
	 @selector(animationDidStop:finished:context:)];
	[UIView setAnimationsEnabled:YES];
	[UIView 
	 setAnimationTransition:UIViewAnimationTransitionCurlDown 
	 forView:self
	 cache:YES];
	[UIView commitAnimations];
	

	curledStatue = [NSNumber numberWithBool:NO];
	[self.layer setValue:curledStatue forKey:kUIViewPartialCurlStatue];
}

-(void)animationDidStop:(NSString *)animationID 
			   finished:(NSNumber *)finished 
				context:(void *)context
{
	if ( self.curlDelegate != nil ) {
		if ( [self.curlDelegate
			  respondsToSelector:
			  @selector(partialCurlAnimationDidFinish:animation:)] )
		{
			[self.curlDelegate
			 partialCurlAnimationDidFinish:self
			 animation:kAnimationPartialCurlDown];
		}
	}
}

-(void)animationPartialCurlJustStarted
{
	CFTimeInterval pausedTime = [self.layer 
								 convertTime:CACurrentMediaTime() 
								 fromLayer:nil];
    self.layer.speed = 0.0;
    self.layer.timeOffset = pausedTime + 0.01;
	
	if ( self.curlDelegate != nil ) {
		if ([self.curlDelegate 
			 respondsToSelector:
			 @selector(partialCurlAnimationDidFinish:animation:)])
		{
			[self.curlDelegate 
			 partialCurlAnimationDidFinish:self
			 animation:kAnimationPartialCurlUp];
		}
	}
}

-(void)animationPartialCurlWillStart:(NSString *)animationId context:(void *)context
{
	if ( [animationId isEqualToString:@"partialPageCurlUp"] ) {
		if ( self.curlDelegate != nil ) {
			if ( [self.curlDelegate 
				  respondsToSelector:
				  @selector(partialCurlAnimationWillStart:animation:)]) 
			{
				[self.curlDelegate 
				 partialCurlAnimationWillStart:self 
				 animation:kAnimationPartialCurlUp];
			}
		}
	} else {
		if ( self.curlDelegate != nil ) {
			if ( [self.curlDelegate 
				  respondsToSelector:
				  @selector(partialCurlAnimationWillStart:animation:)]) 
			{
				[self.curlDelegate 
				 partialCurlAnimationWillStart:self 
				 animation:kAnimationPartialCurlDown];
			}
		}
		self.layer.timeOffset += (1 - [self partialCurlPercent]) * 
									[self partialCurlDuration];
	}
}

@end
