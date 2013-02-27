//
//  PYImageView.h
//  PYUIKit
//
//  Created by littlepush on 9/5/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PYComponentView.h"

UIImage *__flipImageForTiledLayerDrawing(UIImage *_in);
#define _R	__flipImageForTiledLayerDrawing

/* The async image layer */
@interface PYAsyncImageLayer : CATiledLayer

@property (nonatomic, retain)	UIImage		*imageToDraw;

@end

/*
	The Async Image Loader's Delegate, when did receive
	the image from network, happen to this callback.
*/
@protocol PYImageViewDelegate <NSObject>

@optional
- (void)pyImageViewDidLoadImage:(UIImage *)image;

@end

/*
	The Async Image Loader. Default to load a placehold(if any),
	then set the image url and start to async load.
*/
@interface PYImageView : PYComponentView
{
	id							_delegate;
}

+ (void) loadNetworkImage:(BOOL)isLoad;

/* The really display image */
@property (nonatomic, retain) UIImage					*image;
/* Placehold Image */
@property (nonatomic, retain) UIImage					*placeholdImage;
/* Current Loading Image's URL */
@property (nonatomic, retain) NSString					*loadingUrl;
/* The Delegate */
@property (nonatomic, assign) id<PYImageViewDelegate>	delegate;

/* Init the image loader with the placehold image */
-(id) initWithPlaceholdImage:(UIImage *)placehold;
/* Start to load the image from the URL */
-(void) setImageUrl:(NSString *)imageUrl;

@end
