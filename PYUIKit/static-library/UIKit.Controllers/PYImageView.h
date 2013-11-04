//
//  PYImageView.h
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

#import "PYResponderView.h"
#import <PYCore/PYMutex.h>

@interface PYImageView : UIImageView<PYView>
{
    PYInnerShadowLayer              *_shadowLayer;
    BOOL                            _hasInvokeInit;
    UIImage                         *_placeholdImage;
    NSString                        *_loadingUrl;
    PYMutex                         *_mutex;
}

//@property (nonatomic, readonly) PYImageLayer        *layer;

// create the layer with the placehold image.
- (PYImageView *)initWithPlaceholdImage:(UIImage *)image;
+ (PYImageView *)viewWithPlaceholdImage:(UIImage *)image;

// Placehold image.
@property (nonatomic, strong)   UIImage             *placeholdImage;

// Loading URL
@property (nonatomic, readonly) NSString            *loadingUrl;

// Start to load the image from the URL
- (void)setImageUrl:(NSString *)imageUrl;

// Refresh the content after reset the frame.
- (void)refreshContent;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
