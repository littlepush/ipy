//
//  CALayer+Gradient.m
//  PYUIKit
//
//  Created by littlepush on 8/17/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "CALayer+Gradient.h"

@implementation CALayer (Gradient)

-(void) setGradientColorFrom:(UIColor *)startColor to:(UIColor *)endColor
{
	[self setGradientColors:[NSArray 
		arrayWithObjects:startColor, endColor, nil]];
}

-(void) setGradientColors:(NSArray *)colorSet
{
	CALayer *lastLayer = [self.sublayers objectAtIndex:0];
	CAGradientLayer *gradientLayer;
	
	// get the gradientLayer
	if ( [lastLayer isKindOfClass:[CAGradientLayer class]] )
		gradientLayer = (CAGradientLayer *)lastLayer;
	else {
		gradientLayer = [CAGradientLayer layer];
		[self insertSublayer:gradientLayer atIndex:0];
	}
	
	[gradientLayer setFrame:self.bounds];
	NSMutableArray *colorArray = [NSMutableArray array];
	for ( UIColor *color in colorSet ) {
		[colorArray addObject:((id)color.CGColor)];
	}
	[gradientLayer setColors:colorArray];	
}

@end
