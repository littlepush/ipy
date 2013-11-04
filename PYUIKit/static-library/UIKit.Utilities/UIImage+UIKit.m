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
        int _count = CFDictionaryGetCount(_gifProperties);
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

@end

// @littlepush
// littlepush@gmail.com
// PYLab
