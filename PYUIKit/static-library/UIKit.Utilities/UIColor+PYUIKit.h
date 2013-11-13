//
//  UIColor+PYUIKit.h
//  PYUIKit
//
//  Created by Chen Push on 3/11/13.
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

#import <UIKit/UIKit.h>

#define __COLOR_D(c)            (((double)c)/255.f)
#define RGBCOLOR(r, g, b)                                                                   \
    [UIColor colorWithRed:__COLOR_D(r) green:__COLOR_D(g) blue:__COLOR_D(b) alpha:1.f]
#define RGBACOLOR(r, g, b, a)                                                               \
    [UIColor colorWithRed:__COLOR_D(r) green:__COLOR_D(g) blue:__COLOR_D(b) alpha:a]

// Color Info of a UIColor
typedef struct tagColorInfo {
    float       red;
    float       green;
    float       blue;
    float       alpha;
} PYColorInfo;

@interface UIColor (PYUIKit)

// Generate a random color schema
+ (UIColor *)randomColor;

// Generate the color from CSS Color Style string
// like: #FFFFFF means white
//       #000000 means black
+ (UIColor *)colorWithString:(NSString *)clrString;
+ (UIColor *)colorWithString:(NSString *)clrString alpha:(CGFloat)alpha;

// Get the color info
@property (nonatomic, readonly) PYColorInfo         colorInfo;

// Create a gradient color pattern
+ (UIColor *)colorWithGradientPatternFrom:(NSString *)fromString
                                       to:(NSString *)toString
                               fillHeight:(CGFloat)height;
+ (UIColor *)colorWithGradientColors:(NSArray *)colors
                          fillHeight:(CGFloat)height;
+ (UIColor *)colorWithGradientColors:(NSArray *)colors
                           fillWidth:(CGFloat)width;

// The color is in the following format:
// Single color: #COLOR
// Gradient two colors: #COLOR1:#COLOR2
// More gradient colors: #COLOR1:#COLOR2:...
// Gradient direction:  @v(40)$#COLOR1:#COLOR2... // from top to bottom
//                      @h(80)$#COLOR1:#COLOR2... // from left to right
// Must specified the flag to use gradient color.
// the number after flag is the size of the gradient range.
+ (UIColor *)colorWithOptionString:(NSString *)colorString;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
