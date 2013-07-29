//
//  PYImageLayer.m
//  PYUIKit
//
//  Created by Push Chen on 7/29/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import "PYImageLayer.h"
#import "PYUIKitMacro.h"
#import "PYImageCache.h"

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

- (void)layerJustBeenCreated
{
    _mutex = [PYMutex object];
    //_mutex.enableDebug = YES;
    _contentLayer = [CATiledLayer layer];
    _contentLayer.delegate = self;
    _contentLayer.opaque = NO;
    [_contentLayer setBackgroundColor:[UIColor clearColor].CGColor];
    [self addSublayer:_contentLayer];

    self.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)layerJustBeenCopied
{
    _mutex = [PYMutex object];
    //_mutex.enableDebug = YES;
    //if ( _contentLayer != nil ) return;
    for ( CALayer *_subLayer in self.sublayers ) {
        if ( [_subLayer isKindOfClass:[CATiledLayer class]] ) {
            _contentLayer = (CATiledLayer *)_subLayer;
            _contentLayer.delegate = self;
            break;
        }
    }

    self.contentMode = UIViewContentModeScaleAspectFill;
}

- (id)init
{
    self = [super init];
    if ( self ) {
        [self layerJustBeenCreated];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self ) {
        [self layerJustBeenCreated];
    }
    return self;
}

- (id)initWithLayer:(id)layer
{
    self = [super initWithLayer:layer];
    if ( self ) {
        [self layerJustBeenCopied];
    }
    return self;
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
        // Set new value
        _image = anImage;
        _loadingUrl = [@"" copy];
        _contentLayer.contents = nil;
        [_contentLayer setNeedsDisplay];
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
        
        _loadingUrl = [imageUrl copy];
        // Fetch the cache.
        _image = [SHARED_IMAGECACHE imageByName:_loadingUrl];
        if ( _image != nil ) {
            _contentLayer.contents = nil;
            [_contentLayer setNeedsDisplay];
            return nil;
        }
        
        // Before request the network image, set current image to nil.
        _image = nil;
        _contentLayer.contents = nil;
        [_contentLayer setNeedsDisplay];
        
        __block PYImageLayer *_bss = self;
        [SHARED_IMAGECACHE
         loadImageNamed:_loadingUrl
         get:^(UIImage *loadedImage, NSString *imageName){
             // Did loaded the image...
             if ( ![imageName isEqualToString:_bss->_loadingUrl] ) return;
             _bss->_image = loadedImage;
             [_bss->_contentLayer setNeedsDisplay];
         }];
        return nil;
    }];
    //}
}

- (void)layoutSublayers
{
    [super layoutSublayers];
    self.contentsScale = [UIScreen mainScreen].scale;
    _contentLayer.tileSize = CGSizeMake(self.frame.size.width, self.frame.size.width / 2);
    [_contentLayer setNeedsDisplay];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [_contentLayer setFrame:self.bounds];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    if ( layer != _contentLayer ) return;
    //@synchronized( self ) {
    UIImage *_imageToDraw = [_mutex lockAndDo:^id{
        return (_image != nil) ? _image : _placeholdImage;
    }];
    
    if ( _imageToDraw == nil ) {
        //layer.contents = nil;
        return;
    }
    
    CGContextTranslateCTM(ctx, 0.0, self.bounds.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    if ( self.contentMode == UIViewContentModeScaleAspectFit ) {
        CGRect aspectFitRect = __rectOfAspectFitImage(_imageToDraw, self.bounds);
        CGContextDrawImage(ctx, aspectFitRect, _imageToDraw.CGImage);
    } else {
        CGRect aspectFillRect = __rectOfAspectFillImage(_imageToDraw, self.bounds);
        CGImageRef subImageRef = CGImageCreateWithImageInRect(_imageToDraw.CGImage, aspectFillRect);
        CGContextDrawImage(ctx, self.bounds, subImageRef);
        CFRelease(subImageRef);            
    }
    
    CGContextScaleCTM(ctx, 1.0, -1.0);
    CGContextTranslateCTM(ctx, 0.0, -self.bounds.size.height);
    //}
}

@end
