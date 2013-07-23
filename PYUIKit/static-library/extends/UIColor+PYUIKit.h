//
//  UIColor+PYUIKit.h
//  PYUIKit
//
//  Created by Chen Push on 3/11/13.
//  Copyright (c) 2013 Markphone Culture Media Co.Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#define __COLOR_D(c)            (((double)c)/255.f)
#define RGBCOLOR(r, g, b)                                                                   \
    [UIColor colorWithRed:__COLOR_D(r) green:__COLOR_D(g) blue:__COLOR_D(b) alpha:1.f]
#define RGBACOLOR(r, g, b, a)                                                               \
    [UIColor colorWithRed:__COLOR_D(r) green:__COLOR_D(g) blue:__COLOR_D(b) alpha:a]

@interface UIColor (PYUIKit)

// Generate a random color schema
+ (UIColor *)randomColor;

// Generate the color from CSS Color Style string
// like: #FFFFFF means white
//       #000000 means black
+ (UIColor *)colorWithString:(NSString *)clrString;
+ (UIColor *)colorWithString:(NSString *)clrString alpha:(CGFloat)alpha;

// Create a gradient color pattern
+ (UIColor *)colorWithGradientPatternFrom:(NSString *)fromString
                                       to:(NSString *)toString
                               fillHeight:(CGFloat)height;
+ (UIColor *)colorWithGradientColors:(NSArray *)colors
                          fillHeight:(CGFloat)height;
+ (UIColor *)colorWithGradientColors:(NSArray *)colors
                           fillWidth:(CGFloat)width;

@end
