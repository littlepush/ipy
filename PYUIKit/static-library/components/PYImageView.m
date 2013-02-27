//
//  PYImageView.m
//  PYUIKit
//
//  Created by littlepush on 9/5/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "PYImageView.h"
#import <QuartzCore/QuartzCore.h>

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

/* The Async Drawing Layer */
@implementation PYAsyncImageLayer
@synthesize imageToDraw;

+(CFTimeInterval)fadeDuration
{
	return 0.f;
}

-(void) checkAndSetTileSize
{
	if ( PYIsRetina ) {
		self.contentsScale = [UIScreen mainScreen].scale;
		self.tileSize = CGSizeMake(1280, 1280);
	} else {
		self.tileSize = CGSizeMake(640, 640);
	}
}

-(id) init {
	self = [super init];
	if ( ! self ) return self;
	[self checkAndSetTileSize];
	return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if ( !self ) return self; 
	[self checkAndSetTileSize];
	return self;
}

-(id) initWithLayer:(id)layer {
	self = [super initWithLayer:layer];
	if ( !self ) return self;
	[self checkAndSetTileSize];
	return self;
}

-(void) dealloc {
	self.contents = nil;
	self.imageToDraw = nil;
	[super dealloc];
}

-(void) drawInContext:(CGContextRef)ctx {
	if ( self.imageToDraw == nil ) return;
	CGContextTranslateCTM(ctx, 0.0, self.bounds.size.height);
	CGContextScaleCTM(ctx, 1.0, -1.0);
	CGRect aspectFillRect = __rectOfAspectFillImage( self.imageToDraw, self.bounds );
	CGImageRef subImageRef = CGImageCreateWithImageInRect(self.imageToDraw.CGImage, aspectFillRect);
	CGContextDrawImage(ctx, self.bounds, subImageRef);
	CFRelease(subImageRef);
}
@end

static BOOL	_loadNetworkImage = YES;

@interface PYImageView (Internal)

-(void) didLoadImage:(UIImage *)image forUrl:(NSString *)urlString;

@end

@implementation PYImageView

@synthesize image, placeholdImage;
@synthesize loadingUrl;
@synthesize delegate = _delegate;

+(Class) layerClass {
	return [CATiledLayer class];
}

+ (void) loadNetworkImage:(BOOL)isLoad {
	_loadNetworkImage = isLoad;
}

-(id<PYImageViewDelegate>)delegate {
	return _delegate;
}
-(void) setDelegate:(id<PYImageViewDelegate>)dele
{
	[_delegate release];
	_delegate = [dele retain];
}

-(void) internalInitial
{
	[super internalInitial];
	[self setOpaque:NO];
	
	CATiledLayer *imageLayer = (CATiledLayer *)self.layer;
	if ( PYIsRetina ) {
		imageLayer.contentsScale = [UIScreen mainScreen].scale;
		imageLayer.tileSize = CGSizeMake(640, 640);
	} else {
		imageLayer.tileSize = CGSizeMake(320, 320);
	}
}

-(void) setPlaceholdImage:(UIImage *)placehold
{
	[placeholdImage release];
	placeholdImage = [placehold retain];
	if ( self.image != nil ) return;
	[self setNeedsDisplay];
}

-(void) setImage:(UIImage *)anImage
{
	[image release];
	image = [anImage retain];
	[self setNeedsDisplay];
}

-(id) initWithPlaceholdImage:(UIImage *)placehold
{
	self = [super init];
	if ( !self ) return self;
	
	self.placeholdImage = placehold;
	return self;
}
-(void) dealloc
{
	self.layer.contents = nil;
	self.image = nil;
	self.placeholdImage = nil;
	self.loadingUrl = nil;
	self.delegate = nil;
	[super dealloc];
}

-(void) drawRect:(CGRect)rect
{	
	UIImage *_drawingImage = [(self.image == nil ? self.placeholdImage : self.image) retain];
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	if ( _drawingImage == nil ) {
		CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.8 alpha:.3f].CGColor);
		CGContextFillRect(ctx, self.bounds);
	} else {
		CGContextTranslateCTM(ctx, 0.0, self.bounds.size.height);
		CGContextScaleCTM(ctx, 1.0, -1.0);	
		CGRect aspectFillRect = __rectOfAspectFillImage( _drawingImage, self.bounds );
		CGImageRef subImageRef = CGImageCreateWithImageInRect(_drawingImage.CGImage, aspectFillRect);
		CGContextDrawImage(ctx, self.bounds, subImageRef);
		CFRelease(subImageRef);
	}
	[_drawingImage release];
}

-(void) setImageUrl:(NSString *)imageUrl
{
	if ( imageUrl == nil ) {
		self.loadingUrl = nil;
		self.image = nil;
		return;
	};
	
	// Loading the same image
	if ( self.loadingUrl != nil && [self.loadingUrl isEqualToString:imageUrl] ) return;
	
	self.loadingUrl = imageUrl;
	// Clear current image cache
	[image release];
	image = nil;
	// Fetch the cache first
	NSData *_imageData = [SHARED_PYFILECACHE dataForKey:imageUrl];
	if ( _imageData != nil ) {
		UIImage *_theImage = [UIImage imageWithData:_imageData];
		[self didLoadImage:_theImage forUrl:self.loadingUrl];
		return;
	}
	
	// Async Block
	PYActionGet _loadingBlock = ^(id url) {
		NSString *imageUrl = (NSString *)url;
		NSData *_imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
		if ( _imageData == nil || [_imageData length] == 0 ) return;
		[SHARED_PYFILECACHE setData:_imageData forKey:imageUrl];
		UIImage *_image = [UIImage imageWithData:_imageData];
		[self didLoadImage:_image forUrl:imageUrl];
	};
	
	// Do not load the network image.
	if ( _loadNetworkImage == NO ) return;
	BEGIN_ASYNC_INVOKE
		_loadingBlock( self.loadingUrl );
	END_ASYNC_INVOKE
}

#pragma Internal
-(void) didLoadImage:(UIImage *)loadedImage forUrl:(NSString *)urlString
{
	if ( ![self.loadingUrl isEqualToString:urlString] ) return;
	//[UIView animateWithDuration:0.3 animations:^{
	[self setImage:loadedImage];
	//}];
	if ( [self.delegate respondsToSelector:@selector(pyImageViewDidLoadImage:)] ) {
		[_delegate pyImageViewDidLoadImage:loadedImage];
	}
}


@end
