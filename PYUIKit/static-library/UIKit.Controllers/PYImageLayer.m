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

@interface PYTiledLayer : CATiledLayer
//@property (nonatomic, assign)   CGSize          tileSize;
@end
@implementation PYTiledLayer
//@synthesize tileSize;
+ (CFTimeInterval)fadeDuration
{
    return 0.15f;
}
- (id<CAAction>)actionForKey:(NSString *)event
{
    if ( [event isEqualToString:kCAOnOrderIn] ) {
        CGFloat _scale = [UIScreen mainScreen].scale;
        CGSize _superSize = self.superlayer.bounds.size;
        _superSize.width *= _scale;
        _superSize.height *= _scale;
        [self setTileSize:_superSize];
        self.contentsScale = _scale;
    }
    return [super actionForKey:event];
}
@end

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

// Implementation of the Image layer
@implementation PYImageLayer

@synthesize image = _image;
@synthesize placeholdImage = _placeholdImage;
@synthesize loadingUrl = _loadingUrl;
@synthesize contentMode;

- (void)_setImageToContext
{
    UIImage *_imageToDraw = (_image != nil) ? _image : _placeholdImage;
    if ( _imageToDraw == nil ) {
        _aspectImage = nil;
    } else {
        if ( self.contentMode == UIViewContentModeScaleAspectFit ) {
            // Nothing to do...
            //_aspectImage = [_imageToDraw scalCanvasFitRect:self.bounds];
        } else {
            CGRect aspectFillRect = __rectOfAspectFillImage(_imageToDraw, self.bounds);
            _aspectImage = [_imageToDraw cropInRect:aspectFillRect];
        }
    }
    //self.contents = nil;
    [self setContents:nil];
    [_contentLayer setHidden:NO];
    [_contentLayer setFrame:self.bounds];
    [_contentLayer setNeedsDisplay];
}

- (void)layerJustBeenCreated
{
    _mutex = [PYMutex object];
    
    CGFloat _scale = [UIScreen mainScreen].scale;
    self.contentsScale = _scale;
    
    //_mutex.enableDebug = YES;
    _contentLayer = [PYTiledLayer layer];
    _contentLayer.actions = @{
                              kCAOnOrderIn:[NSNull null],
                              kCAOnOrderOut:[NSNull null],
                              @"contents":[NSNull null]
                              };
    _contentLayer.delegate = self;
    _contentLayer.opaque = NO;
    [_contentLayer setBackgroundColor:[UIColor clearColor].CGColor];
    [self addSublayer:_contentLayer];
    self.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)layerJustBeenCopied
{
    _mutex = [PYMutex object];
    
    CGFloat _scale = [UIScreen mainScreen].scale;
    self.contentsScale = _scale;
    
    //_mutex.enableDebug = YES;
    for ( CALayer *_subLayer in self.sublayers ) {
        if ( [_subLayer isKindOfClass:[PYTiledLayer class]] ) {
            _contentLayer = (PYTiledLayer *)_subLayer;
            _contentLayer.delegate = self;
            _contentLayer.actions = @{
                                      kCAOnOrderIn:[NSNull null],
                                      kCAOnOrderOut:[NSNull null],
                                      @"contents":[NSNull null]
                                      };
            break;
        }
    }
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
        _contentLayer.contents = nil;
        [self _setImageToContext];
        return nil;
    }];
    //}
}

- (void)setImageUrl:(NSString *)imageUrl
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
        
        _contentLayer.contents = nil;
        _loadingUrl = [imageUrl copy];
        // Fetch the cache.
        _image = [SHARED_IMAGECACHE imageByName:_loadingUrl];
        if ( _image != nil ) {
            [self _setImageToContext];
            return nil;
        }
        
        __block PYImageLayer *_bss = self;
        [SHARED_IMAGECACHE
         loadImageNamed:_loadingUrl
         get:^(UIImage *loadedImage, NSString *imageName){
             // Did loaded the image...
             if ( ![imageName isEqualToString:_bss->_loadingUrl] ) return;
             _bss->_image = loadedImage;
             [_bss _setImageToContext];
         }];
        return nil;
    }];
    //}
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    // First time...Nothing
    if ( self.contentMode == UIViewContentModeScaleAspectFit ) {
        if ( _contentLayer.contents != nil ) {
            self.contents = _contentLayer.contents;
        }
    } else {
        self.contents = (id)_aspectImage.CGImage;
    }
    _contentLayer.contents = nil;
    [_contentLayer setHidden:YES];
}

- (void)refreshContent
{
    CGFloat _scale = [UIScreen mainScreen].scale;
    self.contentsScale = _scale;
    _contentLayer.contents = nil;
    _contentLayer.contentsScale = _scale;
    _contentLayer.tileSize = CGSizeMake(self.bounds.size.width * _scale,
                                        self.bounds.size.height * _scale);
    [self _setImageToContext];
}

- (void)willMoveToSuperLayer:(CALayer *)layer
{
    if ( layer == nil ) return;
    [self _setImageToContext];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    if ( layer != _contentLayer ) return;
    //@synchronized( self ) {
    UIImage *_imageToDraw = (_image != nil) ? _image : _placeholdImage;
    
    if ( _imageToDraw == nil ) {
        //layer.contents = nil;
        return;
    }
    
    UIGraphicsPushContext(ctx);
    if ( self.contentMode == UIViewContentModeScaleAspectFit ) {
        //CGRect __rectOfAspectFitImage( UIImage *image, CGRect displayRect ) {
        CGRect _aspectFit = __rectOfAspectFitImage(_imageToDraw, self.bounds);
        [_imageToDraw drawInRect:_aspectFit];
    } else {
        [_aspectImage drawInRect:self.bounds];
    }
    UIGraphicsPopContext();
    //}
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
