//
//  UIColor+Random.m
//  pyutility-uitest
//
//  Created by Push Chen on 6/5/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "UIColor+Random.h"
#include <stdlib.h>
#include <time.h>

#define _D(c)	(((double)c)/255.f)

@implementation UIColor (Random)

+(void) __srandomInit {
	static BOOL _srandomSetted = NO;
	if (_srandomSetted) return;
	_srandomSetted = YES;
	srandom(time(NULL));
}

+(UIColor *)randomColor
{
	[UIColor __srandomInit];
	CGFloat _red = (CGFloat)( random() % 255 ) / 255;
	CGFloat _green = (CGFloat)( random() % 255 ) / 255;
	CGFloat _blue = (CGFloat)( random() % 255 ) / 255;
	
	UIColor *_randomColor = [UIColor colorWithRed:_red green:_green blue:_blue alpha:1.0];
	return _randomColor;
}

+(UIColor *)colorWithString:(NSString *)clrString
{
	NSString *_c = clrString;
	if ( [clrString length] == 7 ) {
		_c = [clrString substringFromIndex:1];
	}
	if ( [_c length] != 6 ) {
		return [UIColor clearColor];
	}
	
	int r, g, b;
	sscanf(_c.UTF8String, "%02x%02x%02x", &r, &g, &b);
	UIColor *_cc = [UIColor colorWithRed:_D(r) green:_D(g) blue:_D(b) alpha:1.f];
	return _cc;
}

@end
