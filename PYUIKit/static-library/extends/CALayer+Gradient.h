//
//  CALayer+Gradient.h
//  PYUIKit
//
//  Created by littlepush on 8/17/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface CALayer (Gradient)

/* Set the gradient color(2) */
-(void) setGradientColorFrom:(UIColor *)startColor to:(UIColor *)endColor;

/* Set gradient color set */
-(void) setGradientColors:(NSArray *)colorSet;

@end
