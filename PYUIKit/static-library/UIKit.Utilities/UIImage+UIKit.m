//
//  UIImage+UIKit.m
//  PYUIKit
//
//  Created by Push Chen on 7/29/13.
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

#import "UIImage+UIKit.h"
#import "PYUIKitMacro.h"
#import <ImageIO/ImageIO.h>
#import <CoreImage/CoreImage.h>
#import "UIColor+PYUIKit.h"

#if __has_feature(objc_arc)
#define CastToCFType(d)         ((__bridge CFTypeRef)(d))
#define CastFromCFType(d)       ((__bridge id)(d))
#else
#define CastToCFType(d)         ((CFTypeRef)(d))
#define CastFromCFType(d)       ((id)(d))
#endif

@implementation UIImage (UIKit)

- (UIImage *)cropToSizeRemainCanvasSize:(CGSize)size
{
    if ( self == nil ) return nil;
	CGRect _imageRect = CGRectMake(0, 0, size.width * self.scale, size.height * self.scale);
	CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], _imageRect);
    
    if ( PYIsRetina ) {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [UIScreen mainScreen].scale);
    } else {
        UIGraphicsBeginImageContext(self.size);
    }
    
    CGContextRef _imgCtx = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(_imgCtx, 0.0, self.size.height);
    CGContextScaleCTM(_imgCtx, 1.0, -1.0);
    
    CGRect _drawRect = CGRectMake(0, 0, size.width, size.height);
    CGContextDrawImage(_imgCtx, _drawRect, imageRef);
    UIImage *_newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    CGContextScaleCTM(_imgCtx, 1.0, -1.0);
    CGContextTranslateCTM(_imgCtx, 0.0, -self.size.height);
    
    UIGraphicsEndImageContext();
    CGImageRelease(imageRef);
    return _newImage;
}

- (UIImage *)cropToSize:(CGSize)size
{
    if ( self == nil ) return nil;
	CGRect _imageRect = CGRectMake(0, 0, size.width * self.scale, size.height * self.scale);
	CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], _imageRect);
	UIImage *newImage = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	
	return newImage;
}

- (UIImage *)cropInRect:(CGRect)cropRect
{
    CGImageRef subImageRef = CGImageCreateWithImageInRect(self.CGImage, cropRect);
    UIImage *_newImage = [UIImage imageWithCGImage:subImageRef];
    CGImageRelease(subImageRef);
    return _newImage;
}

- (UIImage *)scalCanvasFitRect:(CGRect)fitRect
{
    float _ds = (fitRect.size.width / fitRect.size.height);
    float _ix = self.size.width * self.scale, _iy = self.size.height * self.scale;
    float _is = _ix / _iy;
    CGRect _canvasRect = CGRectZero;
    if ( _ds > _is ) {
        // Height fixed
        _canvasRect.size.height = _iy;
        _canvasRect.size.width = _iy * _ds;
        _canvasRect.origin.y = 0;
        _canvasRect.origin.x = (_canvasRect.size.width - _ix) / 2;
    } else {
        // Width fixed
        _canvasRect.size.width = _ix;
        _canvasRect.size.height = _ix / _ds;
        _canvasRect.origin.x = 0;
        _canvasRect.origin.y = (_canvasRect.size.height - _iy) / 2;
    }

    PYStopWatch *sw = [PYStopWatch object];
    [sw start];
    // Create the context as canvas.
    if ( PYIsRetina ) {
        UIGraphicsBeginImageContextWithOptions(_canvasRect.size, NO, [UIScreen mainScreen].scale);
    } else {
        UIGraphicsBeginImageContext(_canvasRect.size);
    }
    DUMPFloat([sw tick]);
    CGRect _imgRect = _canvasRect;
    _imgRect.size.width = _ix;
    _imgRect.size.height = _iy;
    [self drawInRect:_imgRect];
    DUMPFloat([sw tick]);
    UIImage *_newImage = UIGraphicsGetImageFromCurrentImageContext();
    DUMPFloat([sw tick]);
    
    UIGraphicsEndImageContext();
    DUMPFloat([sw tick]);
    return _newImage;
}

- (UIImage *)scaledToSize:(CGSize)size
{
    if ( self == nil ) return nil;
    if ( PYIsRetina ) {
        UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    } else {
        UIGraphicsBeginImageContext(size);
    }
	[self drawInRect:CGRectMake(0, 0, size.width, size.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
	return newImage;
}

+ (UIImage *)PYImageWithData:(NSData *)theData
{
    // Check if the image is gif.
    if ( theData == nil ) return nil;
    uint8_t c;
    [theData getBytes:&c length:1];
    if ( c != 0x47 ) {
        //CIImage *_ciImage = [CIImage imageWithData:theData];
        //return [UIImage imageWithCIImage:_ciImage];
        return [UIImage imageWithData:theData];
    }
    
    // try to get all frame.
    CGImageSourceRef _imgSource = CGImageSourceCreateWithData(CastToCFType(theData), NULL);
    size_t _frameCount = CGImageSourceGetCount(_imgSource);
    int _totalDuration = 0;
    NSMutableArray *_frames = [NSMutableArray array];
    
    for ( size_t i = 0; i < _frameCount; ++i ) {
        CGImageRef _frameRef = CGImageSourceCreateImageAtIndex(_imgSource, i, NULL);
        UIImage *_frameImage = [UIImage imageWithCGImage:_frameRef];
        [_frames addObject:_frameImage];
        CFRelease(_frameRef);
        
        // Get the frame time info.
        int _frameDuration = 1;
        _totalDuration += 1;
        
        CFDictionaryRef _frameProperties = CGImageSourceCopyPropertiesAtIndex(_imgSource, i, NULL);
        if ( _frameProperties == NULL ) continue;
        CFDictionaryRef _gifProperties = CFDictionaryGetValue(_frameProperties, kCGImagePropertyGIFDictionary);
        if ( _gifProperties == NULL ) {
            CFRelease(_frameProperties);
            continue;
        }
        CFIndex _count = CFDictionaryGetCount(_gifProperties);
        if ( _count == 0 ) {
            CFRelease(_frameProperties);
            continue;
        }
        if ( !CFDictionaryContainsKey(_gifProperties, kCGImagePropertyGIFDelayTime) ) {
            CFRelease(_frameProperties);
            continue;
        }
        CFNumberRef _second = CFDictionaryGetValue(_gifProperties, kCGImagePropertyGIFDelayTime);
        _frameDuration = (int)lrint([CastFromCFType(_second) doubleValue] * 100);
        
        CFRelease(_frameProperties);
        
        _totalDuration -= 1;
        _totalDuration += _frameDuration;
    }
    
    CFRelease(_imgSource);
    return [UIImage animatedImageWithImages:_frames duration:(_totalDuration / 100)];
}

+ (UIImage *)imageWithGradientColors:(NSArray *)colors
                           locations:(NSArray *)locations
                          fillHeight:(CGFloat)height
{
    CGFloat _width = 1.f;
    if ( [locations count] == 0 ) {
        locations = [NSArray arrayWithObjects:PYDoubleToObject(0.f), PYDoubleToObject(1.f), nil];
    }
    
    // Create a new bitmap image context and make it to be the current context
    UIGraphicsBeginImageContext(CGSizeMake(_width, height));
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(ctx);
    
    // Get from string
    CGFloat *_components = (CGFloat *)(malloc(sizeof(CGFloat) * 4 * [colors count]));
    
    for ( int l = 0; l < [colors count]; ++l ){
        UIColor *_color = [colors objectAtIndex:l];
        PYColorInfo _colorInfo = _color.colorInfo;
        *(_components + l * 4 + 0) = _colorInfo.red;
        *(_components + l * 4 + 1) = _colorInfo.green;
        *(_components + l * 4 + 2) = _colorInfo.blue;
        *(_components + l * 4 + 3) = _colorInfo.alpha;
    }
    size_t _locationsCount = (size_t)[locations count];
    CGFloat *_locations = (CGFloat*)malloc(sizeof(CGFloat) * _locationsCount);
    for ( NSUInteger i = 0; i < [locations count]; ++i ) {
        _locations[i] = [[locations objectAtIndex:i] floatValue];
    }
    
    CGColorSpaceRef rgbColorspace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef glossGradient =
    CGGradientCreateWithColorComponents
    (rgbColorspace, _components, _locations, _locationsCount);
    CGPoint topCenter = CGPointMake(0, 0);
    CGPoint bottomCenter = CGPointMake(0, height);
    CGContextDrawLinearGradient(ctx, glossGradient, topCenter, bottomCenter, 0);
    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace);
    
    free(_components);
    free(_locations);
    
    // pop context
    UIGraphicsPopContext();
    
    // Get the image
    UIImage *_gradientImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // clean up drawing environment
    UIGraphicsEndImageContext();
    
    return _gradientImage;
}

+ (UIImage *)imageWithGradientColors:(NSArray *)colors
                           locations:(NSArray *)locations
                           fillWidth:(CGFloat)width
{
    CGFloat _height = 1.f;
    if ( [locations count] == 0 ) {
        locations = [NSArray arrayWithObjects:PYDoubleToObject(0.f), PYDoubleToObject(1.f), nil];
    }
    
    // Create a new bitmap image context and make it to be the current context
    UIGraphicsBeginImageContext(CGSizeMake(width, _height));
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(ctx);
    
    // Get from string
    CGFloat *_components = (CGFloat *)(malloc(sizeof(CGFloat) * 4 * [colors count]));
    
    for ( int l = 0; l < [colors count]; ++l ){
        UIColor *_color = [colors objectAtIndex:l];
        PYColorInfo _colorInfo = _color.colorInfo;
        *(_components + l * 4 + 0) = _colorInfo.red;
        *(_components + l * 4 + 1) = _colorInfo.green;
        *(_components + l * 4 + 2) = _colorInfo.blue;
        *(_components + l * 4 + 3) = _colorInfo.alpha;
    }
    size_t _locationsCount = (size_t)[locations count];
    CGFloat *_locations = (CGFloat*)malloc(sizeof(CGFloat) * _locationsCount);
    for ( NSUInteger i = 0; i < [locations count]; ++i ) {
        _locations[i] = [[locations objectAtIndex:i] floatValue];
    }
    
    CGColorSpaceRef rgbColorspace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef glossGradient =
    CGGradientCreateWithColorComponents
    (rgbColorspace, _components, _locations, _locationsCount);
    CGPoint topCenter = CGPointMake(0, 0);
    CGPoint bottomCenter = CGPointMake(width, 0);
    CGContextDrawLinearGradient(ctx, glossGradient, topCenter, bottomCenter, 0);
    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace);
    
    free(_components);
    free(_locations);
    
    // pop context
    UIGraphicsPopContext();
    
    // Get the image
    UIImage *_gradientImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // clean up drawing environment
    UIGraphicsEndImageContext();
    
    return _gradientImage;
}

+ (UIImage *)imageWithOptionString:(NSString *)optionString
{
    NSArray *_gradientInfo = [optionString componentsSeparatedByString:@"$"];
    UIImage *_image = nil;
    if ( [_gradientInfo count] > 1 ) {
        NSString *_gradientFlag = [_gradientInfo safeObjectAtIndex:0];
        float _gradientSize = 0.f;
        char _direction = 0;
        sscanf(_gradientFlag.UTF8String, "%c(%f)", &_direction, &_gradientSize);
        
        NSString *_colorGroup = [_gradientInfo safeObjectAtIndex:1];
        NSArray *_colors = [_colorGroup componentsSeparatedByString:@":"];
        
        NSMutableArray *_clrs = [NSMutableArray array];
        NSMutableArray *_locs = [NSMutableArray array];
        for ( NSString *_clrString in _colors ) {
            NSArray *_com = [_clrString componentsSeparatedByString:@"/"];
            if ( [_com count] == 2 ) {
                CGFloat _loc = [[_com lastObject] floatValue];
                if ( !isnan(_loc) ) {
                    [_locs addObject:PYDoubleToObject(_loc)];
                }
            }
            [_clrs addObject:[UIColor colorWithString:[_com objectAtIndex:0]]];
        }
        
        if ( _direction == 'v' ) {
            _image = [UIImage imageWithGradientColors:_clrs locations:_locs fillHeight:_gradientSize];
        } else {
            _image = [UIImage imageWithGradientColors:_clrs locations:_locs fillWidth:_gradientSize];
        }
    }
    return _image;
}

// Draw a check icon(√) within specified size, default background color is clear, icon color is black
+ (UIImage *)checkIconWithSize:(CGSize)imgSize
{
    return [UIImage checkIconWithSize:imgSize
                      backgroundColor:[UIColor clearColor]
                            iconColor:[UIColor blackColor]
                            lineWidth:1.f
                              padding:1.f];
}
+ (UIImage *)checkIconWithSize:(CGSize)imgSize
               backgroundColor:(UIColor *)bkgClr
                     iconColor:(UIColor *)icnClr
                     lineWidth:(CGFloat)lineWidth
                       padding:(CGFloat)padding
{
    if ( lineWidth == 0 ) lineWidth = 1.f;
    if ( bkgClr == nil ) bkgClr = [UIColor clearColor];
    if ( icnClr == nil ) icnClr = [UIColor blackColor];
    
    if ( PYIsRetina ) {
        UIGraphicsBeginImageContextWithOptions(imgSize, NO, [UIScreen mainScreen].scale);
    } else {
        UIGraphicsBeginImageContext(imgSize);
    }
    
    // Create image context
    CGContextRef _imgCtx = UIGraphicsGetCurrentContext();
    
    CGRect _drawRect = CGRectMake(0, 0, imgSize.width, imgSize.height);
    
    // Fill the background
    CGContextSetFillColorWithColor(_imgCtx, bkgClr.CGColor);
    CGContextFillRect(_imgCtx, _drawRect);
    
    CGRect _chkImgRect = CGRectZero;
    CGFloat _l = 0.f;
    if ( imgSize.width > imgSize.height ) {
        _chkImgRect.origin.x = (imgSize.width - imgSize.height) / 2 + padding;
        _chkImgRect.origin.y = padding;
        _chkImgRect.size.width = imgSize.height - 2 * padding;
        _chkImgRect.size.height = imgSize.height - 2 * padding;
        _l = imgSize.height - 2 * padding;
    } else {
        _chkImgRect.origin.x = padding;
        _chkImgRect.origin.y = (imgSize.height - imgSize.width) / 2 + padding;
        _chkImgRect.size.width = imgSize.width - 2 * padding;
        _chkImgRect.size.height = imgSize.width - 2 * padding;
        _l = imgSize.width - 2 * padding;
    }
    
    // Draw the check image
    CGContextSetLineWidth(_imgCtx, lineWidth);
    CGContextSetLineCap(_imgCtx, kCGLineCapRound);
    CGContextSetStrokeColorWithColor(_imgCtx, icnClr.CGColor);
    
    CGMutablePathRef _chkPath = CGPathCreateMutable();
    CGPathMoveToPoint(_chkPath, NULL, _chkImgRect.origin.x + _l / 8.f, _chkImgRect.origin.y + _l / 2);
    CGPathAddLineToPoint(_chkPath, NULL, _chkImgRect.origin.x + 3.f * _l / 8.f, _chkImgRect.origin.y + 3.f * _l / 4.f);
    CGPathAddLineToPoint(_chkPath, NULL, _chkImgRect.origin.x + 7.f * _l / 8.f, _chkImgRect.origin.y + _l / 4.f);
    
    CGContextAddPath(_imgCtx, _chkPath);
    CGContextStrokePath(_imgCtx);
    
    // Get the check image
    UIImage *_checkImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();

    return _checkImage;
}

+ (UIImage *)menuIconWithSize:(CGSize)imgSize
{
    return [UIImage menuIconWithSize:imgSize
                     backgroundColor:[UIColor clearColor]
                           iconColor:[UIColor colorWithString:@"#135AFF"]
                           lineWidth:1.f
                             padding:4.f];
}
+ (UIImage *)menuIconWithSize:(CGSize)imgSize
              backgroundColor:(UIColor *)bkgClr
                    iconColor:(UIColor *)icnClr
                    lineWidth:(CGFloat)lineWidth
                      padding:(CGFloat)padding
{
    if ( lineWidth == 0 ) lineWidth = 1.f;
    if ( bkgClr == nil ) bkgClr = [UIColor clearColor];
    if ( icnClr == nil ) icnClr = [UIColor colorWithString:@"#135AFF"];
    
    if ( PYIsRetina ) {
        UIGraphicsBeginImageContextWithOptions(imgSize, NO, [UIScreen mainScreen].scale);
    } else {
        UIGraphicsBeginImageContext(imgSize);
    }
    
    // Create image context
    CGContextRef _imgCtx = UIGraphicsGetCurrentContext();
    
    CGRect _drawRect = CGRectMake(0, 0, imgSize.width, imgSize.height);
    
    // Fill the background
    CGContextSetFillColorWithColor(_imgCtx, bkgClr.CGColor);
    CGContextFillRect(_imgCtx, _drawRect);
    
    CGRect _menuImgRect = CGRectInset(_drawRect, padding, padding);
    if ( (_menuImgRect.size.width / _menuImgRect.size.height) > (4.f / 3.f) ) {
        CGFloat _d = _menuImgRect.size.height / 3;
        CGFloat _w = _d * 4;
        _menuImgRect.origin.x += (_menuImgRect.size.width - _w) / 2;
        _menuImgRect.size.width = _w;
    } else {
        CGFloat _d = _menuImgRect.size.width / 4;
        CGFloat _h = _d * 3;
        _menuImgRect.origin.y += (_menuImgRect.size.height - _h) / 2;
        _menuImgRect.size.height = _h;
    }

    // Draw the menu image
    CGContextSetLineWidth(_imgCtx, lineWidth);
    CGContextSetLineCap(_imgCtx, kCGLineCapRound);
    CGContextSetStrokeColorWithColor(_imgCtx, icnClr.CGColor);
    
    CGContextMoveToPoint(_imgCtx,
                         _menuImgRect.origin.x,
                         _menuImgRect.origin.y);
    CGContextAddLineToPoint(_imgCtx,
                            _menuImgRect.origin.x + _menuImgRect.size.width,
                            _menuImgRect.origin.y);
    CGContextMoveToPoint(_imgCtx,
                         _menuImgRect.origin.x,
                         _menuImgRect.origin.y + _menuImgRect.size.height / 2);
    CGContextAddLineToPoint(_imgCtx,
                            _menuImgRect.origin.x + _menuImgRect.size.width,
                            _menuImgRect.origin.y + _menuImgRect.size.height / 2);
    CGContextMoveToPoint(_imgCtx,
                         _menuImgRect.origin.x,
                         _menuImgRect.origin.y + _menuImgRect.size.height);
    CGContextAddLineToPoint(_imgCtx,
                            _menuImgRect.origin.x + _menuImgRect.size.width,
                            _menuImgRect.origin.y + _menuImgRect.size.height);
    
    CGContextStrokePath(_imgCtx);
    
    // Get the check image
    UIImage *_menuImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return _menuImage;
}

- (UIImage *)imageWithCornerRadius:(CGFloat)cornerRadius
{
    if ( PYIsRetina ) {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    } else {
        UIGraphicsBeginImageContext(self.size);
    }
    
    const CGRect _imageRect = CGRectMake(0, 0, self.size.width, self.size.height);
    [[UIBezierPath bezierPathWithRoundedRect:_imageRect cornerRadius:cornerRadius] addClip];
    [self drawInRect:_imageRect];
    
    UIImage *_cornerImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return _cornerImage;
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
