//
//  QTImageView.h
//  QTUIKit
//
//  Created by Chen Push on 3/8/13.
//  Copyright (c) 2013 Markphone Culture Media Co.Ltd. All rights reserved.
//

#import "QTView.h"

UIImage *__flipImageForTiledLayerDrawing(UIImage *_in);
#define _R	__flipImageForTiledLayerDrawing

/* The async image layer */
@interface QTAsyncImageLayer : CALayer

@property (nonatomic, strong)	UIImage             *imageToDraw;

@property (nonatomic, assign)   UIViewContentMode   contentMode;

@end

@protocol QTImageViewDelegate;

/*
 QTImageView Setting
 */
@interface QTImageViewManager : NSObject
{
    BOOL                    _isLoadNetworkImage;
    NSOperationQueue        *_loadingQueue;
}
// If the image view should load network image.
+ (BOOL)isLoadNetworkImage;
+ (void)setIsLoadNetworkImage:(BOOL)isLoad;

// The image loading queue.
+ (NSOperationQueue *)imageLoadingQueue;

@end

/*
 The Async Image Loader. Default to load a placehold(if any),
 then set the image url and start to async load.
 */
@interface QTImageView : QTView

/* The really display image */
@property (nonatomic, strong)   UIImage                     *image;
/* Placehold Image */
@property (nonatomic, strong)   UIImage                     *placeholdImage;
/* Current Loading Image's URL */
@property (nonatomic, copy)     NSString                    *loadingUrl;
/* The Delegate */
@property (nonatomic, assign)   id<QTImageViewDelegate>     delegate;

/* Init the image loader with the placehold image */
- (id)initWithPlaceholdImage:(UIImage *)placehold;
/* Start to load the image from the URL */
- (void)setImageUrl:(NSString *)imageUrl;

@end

/*
 The Async Image Loader's Delegate, when did receive
 the image from network, happen to this callback.
 */
@protocol QTImageViewDelegate <NSObject>

@optional
- (void)imageView:(QTImageView *)imageView didLoadImage:(UIImage *)image forUrl:(NSString *)url;

@end
