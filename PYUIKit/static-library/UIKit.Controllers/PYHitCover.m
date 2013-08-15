//
//  PYHitCover.m
//  PYUIKit
//
//  Created by Push Chen on 8/15/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

/*
 LISENCE FOR IPY
 COPYRIGHT (c) 2013, Push Chen.
 ALL RIGHTS RESERVED.
 
 REDISTRIBUTION AND USE IN SOURCE AND BINARY
 FORMS, WITH OR WITHOUT MODIFICATION, ARE
 PERMITTED PROVIDED THAT THE FOLLOWING CONDITIONS
 ARE MET:
 
 YOU USE IT, AND YOU JUST USE IT!.
 WHY NOT USE THIS LIBRARY IN YOUR CODE TO MAKE
 THE DEVELOPMENT HAPPIER!
 ENJOY YOUR LIFE AND BE FAR AWAY FROM BUGS.
 */

#import "PYHitCover.h"

@implementation PYHitCover

@synthesize coverView = _coverView;

- (void)viewJustBeenCreated
{
	[super viewJustBeenCreated];
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

// @littlepush
// littlepush@gmail.com
// PYLab
