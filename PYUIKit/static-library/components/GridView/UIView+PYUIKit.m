//
//  UIView+PYUIKit.m
//  PYUIKit
//
//  Created by Chen Push on 3/11/13.
//  Copyright (c) 2013 Markphone Culture Media Co.Ltd. All rights reserved.
//

#import "UIView+PYUIKit.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (PYUIKit)

- (UIView *)findFirstResponsder
{
    if ( [self isFirstResponder] ) return self;
	for ( UIView *_subView in self.subviews )
	{
		UIView *_first = [_subView findFirstResponsder];
		if ( _first != nil ) return _first;
	}
	return nil;
}

- (CGPoint)originInSuperview:(UIView *)specifiedSuperview
{
    if ( self.superview == specifiedSuperview ) return self.frame.origin;
	CGPoint origin = self.frame.origin;
	CGPoint superOrigin = [self.superview originInSuperview:specifiedSuperview];
	origin.x += superOrigin.x;
	origin.y += superOrigin.y;
	return origin;
}

+ (UIImage *)captureScreen
{
    CGSize _windowSize = [UIScreen mainScreen].applicationFrame.size;
    UIGraphicsBeginImageContextWithOptions(_windowSize, NO, [UIScreen mainScreen].scale);
    [[UIApplication sharedApplication].keyWindow.rootViewController.view.layer
        renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *_screenImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return _screenImage;
}

@end
