//
//  UIBarButtonItem+CustomizedImage.m
//  TuitaAnimation
//
//  Created by Push Chen on 1/30/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "UIBarButtonItem+CustomizedImage.h"

@implementation UIBarButtonItem(CustomizedImage)

-(UIBarButtonItem *)initWithImage:(UIImage *)image 
						   target:(id)target 
						   action:(SEL)selector
{
	UIButton *customizedButtonView = [[[UIButton alloc]
									   init]
									  autorelease];
	CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
	[customizedButtonView setFrame:frame];

	[customizedButtonView setBackgroundImage:image forState:UIControlStateNormal];
	[customizedButtonView 
	 addTarget:target 
	 action:selector 
	 forControlEvents:UIControlEventTouchUpInside];
	
	self = (UIBarButtonItem *)[super init];
	if ( self != nil )
		[self initWithCustomView:customizedButtonView];
	return self;
}

-(UIBarButtonItem *)initWithImage:(UIImage *)image 
						scaleRate:(CGFloat)rate 
						   target:(id)target 
						   action:(SEL)selector
{
	UIButton *customizedButtonView = [[[UIButton alloc]
									   init]
									  autorelease];
	CGRect frame = CGRectMake(0, 0, image.size.width * rate, image.size.height * rate);
	[customizedButtonView setFrame:frame];

	[customizedButtonView setBackgroundImage:image forState:UIControlStateNormal];
	[customizedButtonView 
	 addTarget:target 
	 action:selector 
	 forControlEvents:UIControlEventTouchUpInside];
	
	self = (UIBarButtonItem *)[super init];
	if ( self != nil )
		[self initWithCustomView:customizedButtonView];
	self.width = frame.size.width;
	return self;
}

-(UIBarButtonItem *)initWithImage:(UIImage *)image
						scaleRate:(CGFloat)rate 
						title:(NSString*)title
						target:(id)target 
						action:(SEL)selector
{
	UIButton *customizedButtonView = [[[UIButton alloc]
									   init]
									  autorelease];
	CGRect frame = CGRectMake(0, 0, image.size.width * rate, image.size.height * rate);
	[customizedButtonView setFrame:frame];
	
	[customizedButtonView setTitle:title forState:UIControlStateNormal];
	// add text format...
	[customizedButtonView setBackgroundImage:image forState:UIControlStateNormal];
	[customizedButtonView 
	 addTarget:target 
	 action:selector 
	 forControlEvents:UIControlEventTouchUpInside];
	
	self = (UIBarButtonItem *)[super init];
	if ( self != nil )
		[self initWithCustomView:customizedButtonView];
	self.width = frame.size.width;
	return self;
}

@end
