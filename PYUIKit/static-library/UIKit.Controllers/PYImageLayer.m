//
//  PYImageLayer.m
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

#import "PYImageLayer.h"
#import "PYUIKitMacro.h"
#import "PYImageCache.h"
#import "UIImage+UIKit.h"

// Image Functions.
UIImage * __flipImageForTiledLayerDrawing( UIImage *_in )
{
	if ( PYIsRetina ) {
		UIGraphicsBeginImageContextWithOptions(_in.size, NO, [UIScreen mainScreen].scale);
	} else {
		UIGraphicsBeginImageContext(_in.size);
	}
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	// core rotate fuction
	CGContextTranslateCTM(ctx, 1.f, _in.size.height);
	CGContextScaleCTM(ctx, 1.f, -1.f);
	// draw new picture
	[_in drawInRect:CGRectMake(0, 0, _in.size.width, _in.size.height)];
	UIImage *_ = UIGraphicsGetImageFromCurrentImageContext();
    CGContextScaleCTM(ctx, 1.f, -1.f);
    CGContextTranslateCTM(ctx, 1.f, -_in.size.height);
	UIGraphicsEndImageContext();
	return _;
}

CGRect __rectOfAspectFillImage( UIImage *image, CGRect displayRect) {
	float _ds = (displayRect.size.width / displayRect.size.height);
	float _ix = image.size.width * image.scale, _iy = image.size.height * image.scale;
	float _ix_ = _ds * _iy, _iy_ = _ix / _ds;
	CGRect _pushRect = ( _ix_ <= _ix ) ?
    CGRectMake((_ix - _ix_) / 2, 0, _ix_, _iy):
    CGRectMake(0, (_iy - _iy_) / 2, _ix, _iy_);
	return _pushRect;
}

CGRect __rectOfAspectFitImage( UIImage *image, CGRect displayRect ) {
    float _ds = (displayRect.size.width / displayRect.size.height);
    float _ix = image.size.width * image.scale, _iy = image.size.height * image.scale;
    float _is = _ix / _iy;
    if ( _ds > _is ) {
        // Height fixed
        CGFloat _dw = _is * displayRect.size.height;
        return  CGRectMake((displayRect.size.width - _dw) / 2, 0, _dw, displayRect.size.height);
    } else {
        // Width fixed
        CGFloat _dh = (1 / _is) * displayRect.size.width;
        return CGRectMake(0, (displayRect.size.height - _dh) / 2, displayRect.size.width, _dh);
    }
}

UIImage *PYUIBlurImage(UIImage *inputImage, CGFloat radius)
{
    if ( isnan(radius) || radius == 0.f ) return inputImage;
    if ( inputImage == nil ) return nil;
    // Get the ci image
    CIImage *_ci = nil;
    if ( inputImage.CIImage != nil ) _ci = inputImage.CIImage;
    else _ci = [CIImage imageWithCGImage:inputImage.CGImage];
    
    // Create the filter
    CIFilter* _ciBlur = [CIFilter filterWithName:@"CIGaussianBlur"];
    [_ciBlur setDefaults];
    [_ciBlur setValue:@(radius) forKey:@"inputRadius"];
    [_ciBlur setValue:_ci forKey:@"inputImage"];
    CIImage* _ciOutput = [_ciBlur outputImage];
    
    CIContext *_ciContext = [CIContext contextWithOptions:nil];
    CGRect _outputRect = [_ciOutput extent];
    
    _outputRect.origin.x += (_outputRect.size.width  - inputImage.size.width * inputImage.scale ) / 2;
    _outputRect.origin.y += (_outputRect.size.height - inputImage.size.height * inputImage.scale ) / 2;
    _outputRect.size = (CGSize){inputImage.size.width * inputImage.scale,
        inputImage.size.height * inputImage.scale};
    
    CGImageRef _cgImage = [_ciContext createCGImage:_ciOutput fromRect:_outputRect];
    UIImage *_resultImage = [UIImage imageWithCGImage:_cgImage];
    CGImageRelease(_cgImage);
    
    return _resultImage;
}

// Implementation of the Image layer
@implementation PYImageLayer

@synthesize image = _image;
@synthesize placeholdImage = _placeholdImage;
@synthesize loadingUrl = _loadingUrl;
@synthesize contentMode;

@synthesize blurRadius = _blurRadius;
- (void)setBlurRadius:(CGFloat)blurRadius
{
    [self willChangeValueForKey:@"blurRadius"];
    _blurRadius = blurRadius;
    [self _setImageToContext];
    [self didChangeValueForKey:@"blurRadius"];
}

- (void)_setImageToContext
{
    UIImage *_imageToDraw = (_image != nil) ? _image : _placeholdImage;
    if ( _imageToDraw == nil ) {
        _aspectImage = nil;
    } else {
        if ( self.contentMode == UIViewContentModeScaleAspectFit ) {
            // Nothing to do...
            //_aspectImage = [_imageToDraw scalCanvasFitRect:self.bounds];
            _aspectImage = _imageToDraw;
        } else {
            CGRect aspectFillRect = __rectOfAspectFillImage(_imageToDraw, self.bounds);
            _aspectImage = [_imageToDraw cropInRect:aspectFillRect];
        }
    }
    _aspectImage = PYUIBlurImage(_aspectImage, _blurRadius);
    [self setNeedsDisplay];
}

- (void)layerJustBeenCreated
{
    _mutex = [PYMutex object];
    
    CGFloat _scale = [UIScreen mainScreen].scale;
    self.contentsScale = _scale;
    [self setBackgroundColor:[UIColor clearColor].CGColor];
    
    self.contentMode = UIViewContentModeScaleAspectFill;
}

- (PYImageLayer *)initWithPlaceholdImage:(UIImage *)image
{
    self = [super init];
    if ( self ) {
        [self layerJustBeenCreated];
        _placeholdImage = image;
    }
    return self;
}

+ (PYImageLayer *)layerWithPlaceholdImage:(UIImage *)image
{
    return [[PYImageLayer alloc] initWithPlaceholdImage:image];
}

- (void)setImage:(UIImage *)anImage
{
    //@synchronized( self ) {
    [_mutex lockAndDo:^id{
        // Clear old image.
        _image = nil;
        _image = anImage;
        _loadingUrl = [@"" copy];
        // Set new value
        [self _setImageToContext];
        return nil;
    }];
}

- (void)forceUpdateContentWithImage:(UIImage *)image
{
    [self setImage:image];
}

- (void)_internalSetImage:(UIImage *)image
{
    _image = image;
    [self _setImageToContext];
}

- (void)setImageUrl:(NSString *)imageUrl
{
    [self setImageUrl:imageUrl done:nil failed:nil];
}

- (void)setImageUrl:(NSString *)imageUrl done:(PYActionDone)done failed:(PYActionFailed)failed
{
    //@synchronized(self) {
    if ( [imageUrl length] == 0 ) {
        // Clean self's status
        self.image = nil;
        return;
    }
    
    [_mutex lockAndDo:^id{
        // Check if is loading the image.
        if ( [_loadingUrl length] > 0 && [_loadingUrl isEqualToString:imageUrl] )
            return nil;
        
        _image = nil;
        
        _loadingUrl = [imageUrl copy];
        // Fetch the cache.
        _image = [SHARED_IMAGECACHE imageByName:_loadingUrl];
        if ( _image != nil ) {
            [self _setImageToContext];
            if ( done ) done();
            return nil;
        }
        
        __weak PYImageLayer *_bss = self;
        [SHARED_IMAGECACHE
         loadImageNamed:_loadingUrl
         get:^(UIImage *loadedImage, NSString *imageName){
             // Did loaded the image...
             if ( ![imageName isEqualToString:_bss.loadingUrl] ) {
                 if ( failed )
                     failed( [self errorWithCode:10002 message:@"image loading has been cancelled"]);
             };
             [_bss _internalSetImage:loadedImage];
             if ( done ) done();
         } failed:^(NSError *error) {
             if ( failed ) failed( error );
         }];
        return nil;
    }];
    //}
}

- (void)refreshContent
{
    [self setNeedsDisplay];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void)willMoveToSuperLayer:(CALayer *)layer
{
    if ( layer == nil ) return;
    [self _setImageToContext];
}

- (void)drawInContext:(CGContextRef)ctx
{
    if ( _aspectImage == nil ) return;
    UIGraphicsPushContext(ctx);
    if ( self.contentMode == UIViewContentModeScaleAspectFit ) {
        //CGRect __rectOfAspectFitImage( UIImage *image, CGRect displayRect ) {
        CGRect _aspectFit = __rectOfAspectFitImage(_aspectImage, self.bounds);
        [_aspectImage drawInRect:_aspectFit];
    } else {
        [_aspectImage drawInRect:self.bounds];
    }
    UIGraphicsPopContext();
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
