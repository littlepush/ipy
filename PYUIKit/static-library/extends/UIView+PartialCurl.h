//
//  UIView+PartialCurl.h
//
//  Created by Push Chen on 1/10/12.
//  Copyright (c) 2012 Push Chen. All rights reserved.
//  Connect me by mail: littlepush@gmail.com
//  Follow me on twitter: @littlepush
//  

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*
 Animation Key
 For the delegate to identify which animation has started or finished.
 This catalog only provide two animation: curl up and curl down.
 */
#define kAnimationPartialCurlUp		@"kAnimationPartialCurlUp"
#define kAnimationPartialCurlDown	@"kAnimationPartialCurlDown"

/*
 Animation Statue Changing Delegate
 */
@protocol UIViewPartialCurlDelegate;

/*
 UIView Partial Curl Catalog.
 This animation is to present the view like UIViewModelTranslat
 */
@interface UIView(PartialCurl)

/* 
 The whole curl animation duration, not the partial curl animation time. 
 The partial curl animation duration is equal to
	partialCurlDuration * partialCurlPercent
 */
@property (nonatomic, assign) double partialCurlDuration;
/* The percent the view will be curled, default is 65%(.65f) */
@property (nonatomic, assign) double partialCurlPercent;
/* Statue change delegate */
@property (nonatomic, retain) id<UIViewPartialCurlDelegate> curlDelegate;

/*
 Curl the view up to the percent specified.
 */
-(void)animationPartialCurlUp;
/*
 Reserve the view to the normal states
 */
-(void)animationPartialCurlDown;

@end

/*
 Curl Animation States change callback.
 */
@protocol UIViewPartialCurlDelegate <NSObject>

@optional
-(void)partialCurlAnimationWillStart:(UIView *)view 
						   animation:(NSString *)animationID;

-(void)partialCurlAnimationDidFinish:(UIView *)view 
						   animation:(NSString *)animationID;

@end