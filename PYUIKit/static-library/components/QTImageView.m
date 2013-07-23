//
//  QTImageView.m
//  QTUIKit
//
//  Created by Chen Push on 3/8/13.
//  Copyright (c) 2013 Markphone Culture Media Co.Ltd. All rights reserved.
//

#import "QTImageView.h"
#import "QTImageCache.h"

UIImage * __flipImageForTiledLayerDrawing( UIImage *_in )
{
	if ( QTIsRetina ) {
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

@implementation QTAsyncImageLayer
@synthesize imageToDraw;
@synthesize contentMode;

+ (CFTimeInterval)fadeDuration
{
    return 0.f;
}

- (void)checkAndSetTileSize
{
    if ( QTIsRetina ) {
        self.contentsScale = [UIScreen mainScreen].scale;
    }
//    self.tileSize = CGSizeMake([UIScreen mainScreen].applicationFrame.size.height,
//                               [UIScreen mainScreen].applicationFrame.size.height);
    [self setBackgroundColor:[UIColor clearColor].CGColor];
}

- (id)init
{
    self = [super init];
    if ( self ) {
        [self checkAndSetTileSize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self ) {
        [self checkAndSetTileSize];
    }
    return self;
}

- (id)initWithLayer:(id)layer
{
    self = [super initWithLayer:layer];
    if ( self ) {
        [self checkAndSetTileSize];
    }
    return self;
}

- (void)drawInContext:(CGContextRef)ctx
{
    if ( self.imageToDraw == nil ) {
        CGContextClearRect(ctx, self.bounds);
        return;
    }
    if ( QTIsRetina ) {
        self.contentsScale = [UIScreen mainScreen].scale;
    }
    CGContextTranslateCTM(ctx, 0.0, self.bounds.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    if ( self.contentMode == UIViewContentModeScaleAspectFit ) {
        CGRect aspectFitRect = __rectOfAspectFitImage(self.imageToDraw, self.bounds);
        CGContextDrawImage(ctx, aspectFitRect, self.imageToDraw.CGImage);
    } else {
        CGRect aspectFillRect = __rectOfAspectFillImage(self.imageToDraw, self.bounds);
        CGImageRef subImageRef = CGImageCreateWithImageInRect(self.imageToDraw.CGImage, aspectFillRect);
        CGContextDrawImage(ctx, self.bounds, subImageRef);
        CFRelease(subImageRef);
    }
    
    CGContextScaleCTM(ctx, 1.0, -1.0);
    CGContextTranslateCTM(ctx, 0.0, -self.bounds.size.height);
}

@end

/*
 * QTImageView Manager, for global setting
 */
static QTImageViewManager *_gQTImgViewMgr;
@interface QTImageViewManager ()

// Singleton
+ (QTImageViewManager *)sharedManager;

@end

@implementation QTImageViewManager

- (id)init
{
    self = [super init];
    if ( self ) {
        // Default load all images
        _isLoadNetworkImage = YES;
        _loadingQueue = [[NSOperationQueue alloc] init];
        [_loadingQueue setMaxConcurrentOperationCount:1];
    }
    return self;
}

// Singleton
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if ( _gQTImgViewMgr == nil ) {
            _gQTImgViewMgr = [super allocWithZone:zone];
        }
    }
    return _gQTImgViewMgr;
}

+ (QTImageViewManager *)sharedManager
{
    @synchronized(self) {
        if ( _gQTImgViewMgr == nil ) {
            _gQTImgViewMgr = [[QTImageViewManager alloc] init];
        }
    }
    return _gQTImgViewMgr;
}

// Peoperties
+ (BOOL)isLoadNetworkImage
{
    @synchronized(self) {
        return [QTImageViewManager sharedManager]->_isLoadNetworkImage;
    }
}

+ (void)setIsLoadNetworkImage:(BOOL)isLoad
{
    @synchronized(self) {
        [QTImageViewManager sharedManager]->_isLoadNetworkImage = isLoad;
    }
}

+ (NSOperationQueue *)imageLoadingQueue
{
    @synchronized(self) {
        return [QTImageViewManager sharedManager]->_loadingQueue;
    }
}

@end

@interface QTImageView ()

- (void)didLoadImage:(UIImage *)netImage forUrl:(NSString *)url;

@end

@implementation QTImageView

@synthesize image, placeholdImage;
@synthesize loadingUrl;
@synthesize delegate;

+ (Class)layerClass
{
    return [QTAsyncImageLayer class];
}

- (void)viewJustBeenCreated
{
    [super viewJustBeenCreated];
    [self setOpaque:NO];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setClearsContextBeforeDrawing:YES];
}

- (id)initWithPlaceholdImage:(UIImage *)placehold
{
    self = [super init];
    if ( self ) {
        self.placeholdImage = placehold;
    }
    return self;
}

- (void)setContentMode:(UIViewContentMode)contentMode
{
    [super setContentMode:contentMode];
    ((QTAsyncImageLayer *)self.layer).contentMode = contentMode;
}

- (void)setImageUrl:(NSString *)imageUrl
{
    @synchronized(self) {
        
        if ( [imageUrl length] == 0 ) {
            // Clean self's status
            self.loadingUrl = imageUrl;
            self.image = nil;
            [self setNeedsLayout];
            return;
        }
        
        // Check if is loading the image.
        if ( [self.loadingUrl length] > 0 && [self.loadingUrl isEqualToString:imageUrl] ) return;
        
        self.loadingUrl = imageUrl;
        // Fetch the cache.
        self.image = [SHARED_IMAGECACHE imageByName:self.loadingUrl];
        if ( self.image != nil ) {
            if ( [self.delegate respondsToSelector:@selector(imageView:didLoadImage:forUrl:)] ) {
                [self.delegate imageView:self didLoadImage:self.image forUrl:self.loadingUrl];
            }
            [self setNeedsLayout];
            return;
        }
        
        // Do not load network url
        if ( ![QTImageViewManager isLoadNetworkImage] ) return;
        
        NSURL *_url = [NSURL URLWithString:self.loadingUrl];
        NSURLRequest *_request = [NSURLRequest requestWithURL:_url];
        [NSURLConnection
         sendAsynchronousRequest:_request
         queue:[QTImageViewManager imageLoadingQueue]
         completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
             if ( error != nil ) {
                 // On error
                 NSLog(@"Load image error: %@", [error localizedDescription]);
                 return;
             }
             if ( data == nil || [data length] == 0 ) return;   // no image data.
             UIImage *_image = [UIImage imageWithData:data];
             [SHARED_IMAGECACHE setImage:_image forName:self.loadingUrl];
             dispatch_async( dispatch_get_main_queue(), ^{
                 [self didLoadImage:_image forUrl:self.loadingUrl];
             });
        }];
    }
}

#pragma mark
#pragma mark Override
- (void)layoutSubviews
{
    [super layoutSubviews];
    // Redraw self.layer
    ((QTAsyncImageLayer *)self.layer).imageToDraw =
        (self.image == nil ? self.placeholdImage : self.image);
    [self.layer setNeedsDisplay];
}

#pragma mark --
#pragma mark Internal

- (void)didLoadImage:(UIImage *)netImage forUrl:(NSString *)url
{
    @synchronized(self) {
        // the request is expired
        if ( ![self.loadingUrl isEqualToString:url] ) return;
        
        self.image = netImage;
        
        if ( [self.delegate respondsToSelector:@selector(imageView:didLoadImage:forUrl:)] ) {
            [self.delegate imageView:self didLoadImage:netImage forUrl:url];
        }
        
        [self setNeedsLayout];
    }
}

@end
