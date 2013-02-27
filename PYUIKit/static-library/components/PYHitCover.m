//
//  PYHitCover.m
//  FootPath
//
//  Created by Push Chen on 3/21/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "PYHitCover.h"
#import "PYExtend.h"

@implementation PYHitCover

@synthesize coverView = _coverView;

- (void) internalInitial
{
	[super internalInitial];
	self.backgroundColor = [UIColor clearColor];
}

// Return the cover view when touch happened.
-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	if ( _coverView == nil ) return [super hitTest:point withEvent:event];
	if ( CGRectContainsPoint(
			CGRectMake(0, 0, self.frame.size.width, 
			self.frame.size.height), point) )
		return _coverView;
	return [super hitTest:point withEvent:event];
}

@end
