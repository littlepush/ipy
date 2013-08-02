//
//  UIColor+PYUIKit.m
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

#import "UIColor+PYUIKit.h"
#include <stdlib.h>
#include <time.h>

@implementation UIColor (PYUIKit)

+ (void)initialize
{
    // Set the random sand
    srandom(time(NULL));
}

+ (UIColor *)randomColor
{
    CGFloat _red = (CGFloat)(random() % 255) / 255.f;
    CGFloat _green = (CGFloat)(random() % 255) / 255.f;
    CGFloat _blue = (CGFloat)(random() % 255) / 255.f;
    
    UIColor *_randomColor = [UIColor colorWithRed:_red green:_green blue:_blue alpha:1.f];
    return _randomColor;
}

+ (UIColor *)colorWithString:(NSString *)clrString
{
    return [UIColor colorWithString:clrString alpha:1.f];
}

+ (UIColor *)colorWithString:(NSString *)clrString alpha:(CGFloat)alpha
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
    return RGBACOLOR(r, g, b, alpha);
}

+ (UIColor *)colorWithGradientPatternFrom:(NSString *)fromString to:(NSString *)toString fillHeight:(CGFloat)height
{
    CGFloat _width = 2.f;
    
    // Create a new bitmap image context and make it to be the current context
    UIGraphicsBeginImageContext(CGSizeMake(_width, height));
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(ctx);
    
    // Get from string
    NSString *_c = fromString;
    if ( [fromString length] == 7 ) {
        _c = [fromString substringFromIndex:1];
    }
    if ( [_c length] != 6 ) {
        return [UIColor clearColor];
    }
    
    int fr, fg, fb;
    sscanf(_c.UTF8String, "%02x%02x%02x", &fr, &fg, &fb);
    
    // Get to string
    _c = toString;
    if ( [toString length] == 7 ) {
        _c = [toString substringFromIndex:1];
    }
    if ( [_c length] != 6 ) {
        return [UIColor clearColor];
    }
    int tr, tg, tb;
    sscanf(_c.UTF8String, "%02x%02x%02x", &tr, &tg, &tb);
        
    // Draw gradient
    size_t _locationsCount = 2;
    CGFloat locations[2] = {0.0, 1.0};
    CGFloat components[8] = {
        __COLOR_D(fr), __COLOR_D(fg), __COLOR_D(fb), 1.f,
        __COLOR_D(tr), __COLOR_D(tg), __COLOR_D(tb), 1.f
    };
    CGColorSpaceRef rgbColorspace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef glossGradient =
        CGGradientCreateWithColorComponents
            (rgbColorspace, components, locations, _locationsCount);
    CGPoint topCenter = CGPointMake(0, 0);
    CGPoint bottomCenter = CGPointMake(0, height);
    CGContextDrawLinearGradient(ctx, glossGradient, topCenter, bottomCenter, 0);
    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace);
    
    // pop context
    UIGraphicsPopContext();
    
    // Get the image
    UIImage *_gradientImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // clean up drawing environment
    UIGraphicsEndImageContext();
    
    // Get the image color
    return [UIColor colorWithPatternImage:_gradientImage];
}

+ (UIColor *)colorWithGradientColors:(NSArray *)colors fillHeight:(CGFloat)height
{
    CGFloat _width = 2.f;
    
    // Create a new bitmap image context and make it to be the current context
    UIGraphicsBeginImageContext(CGSizeMake(_width, height));
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(ctx);
    
    // Get from string
    CGFloat *_components = (CGFloat *)(malloc(sizeof(CGFloat) * 4 * [colors count]));
    
    for ( int l = 0; l < [colors count]; ++l ){
        UIColor *_color = [colors objectAtIndex:l];
        CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0, white = 0.0;
        
        // This is a non-RGB color
        if(CGColorGetNumberOfComponents(_color.CGColor) == 2) {
            [_color getWhite:&white alpha:&alpha];
            red = white;
            green = white;
            blue = white;
        }
        else {
            // iOS 5
            if ([_color respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
                [_color getRed:&red green:&green blue:&blue alpha:&alpha];
            } else {
                // < iOS 5
                const CGFloat *components = CGColorGetComponents(_color.CGColor);
                red = components[0];
                green = components[1];
                blue = components[2];
                alpha = components[3];
            }
        }
        
        *(_components + l * 4 + 0) = red;
        *(_components + l * 4 + 1) = green;
        *(_components + l * 4 + 2) = blue;
        *(_components + l * 4 + 3) = alpha;
    }
    size_t _locationsCount = 2;
    CGFloat locations[2] = {0.0, 1.0};

    CGColorSpaceRef rgbColorspace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef glossGradient =
    CGGradientCreateWithColorComponents
    (rgbColorspace, _components, locations, _locationsCount);
    CGPoint topCenter = CGPointMake(0, 0);
    CGPoint bottomCenter = CGPointMake(0, height);
    CGContextDrawLinearGradient(ctx, glossGradient, topCenter, bottomCenter, 0);
    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace);

    free(_components);
    
    
    // pop context
    UIGraphicsPopContext();
    
    // Get the image
    UIImage *_gradientImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // clean up drawing environment
    UIGraphicsEndImageContext();
    
    // Get the image color
    return [UIColor colorWithPatternImage:_gradientImage];    
}

+ (UIColor *)colorWithGradientColors:(NSArray *)colors fillWidth:(CGFloat)width
{
    CGFloat _height = 2.f;
    
    // Create a new bitmap image context and make it to be the current context
    UIGraphicsBeginImageContext(CGSizeMake(width, _height));
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(ctx);
    
    // Get from string
    CGFloat *_components = (CGFloat *)(malloc(sizeof(CGFloat) * 4 * [colors count]));
    
    for ( int l = 0; l < [colors count]; ++l ){
        UIColor *_color = [colors objectAtIndex:l];
        [_color getRed:(_components + l * 4 + 0)
                 green:(_components + l * 4 + 1)
                  blue:(_components + l * 4 + 2)
                 alpha:(_components + l * 4 + 3)];
    }
    size_t _locationsCount = 2;
    CGFloat locations[2] = {0.0, 1.0};
    
    CGColorSpaceRef rgbColorspace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef glossGradient =
    CGGradientCreateWithColorComponents
    (rgbColorspace, _components, locations, _locationsCount);
    CGPoint topCenter = CGPointMake(0, 0);
    CGPoint bottomCenter = CGPointMake(width, 0);
    CGContextDrawLinearGradient(ctx, glossGradient, topCenter, bottomCenter, 0);
    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace);
    
    free(_components);
    
    
    // pop context
    UIGraphicsPopContext();
    
    // Get the image
    UIImage *_gradientImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // clean up drawing environment
    UIGraphicsEndImageContext();
    
    // Get the image color
    return [UIColor colorWithPatternImage:_gradientImage];    
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
