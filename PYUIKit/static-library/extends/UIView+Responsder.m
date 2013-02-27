//
//  UIView+Responsder.m
//  PYUIKit
//
//  Created by littlepush on 9/2/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "UIView+Responsder.h"

@implementation UIView (Responsder)

-(UIView *) findFirstResponsder
{
	if ( [self isFirstResponder] ) return self;
	for ( UIView *_subView in self.subviews )
	{
		UIView *_first = [_subView findFirstResponsder];
		if ( _first != nil ) return _first;
	}
	return nil;
}

-(CGPoint) originInSuperview:(UIView *)specifiedSuperview
{
	if ( self.superview == specifiedSuperview ) return self.frame.origin;
	CGPoint origin = self.frame.origin;
	CGPoint superOrigin = [self.superview originInSuperview:specifiedSuperview];
	origin.x += superOrigin.x;
	origin.y += superOrigin.y;
	return origin;
}

@end
