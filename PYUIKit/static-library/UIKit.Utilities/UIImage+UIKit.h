//
//  UIImage+UIKit.h
//  PYUIKit
//
//  Created by Push Chen on 7/29/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UIKit)

// Remain the canvas size and fill the cut part with transplant data.
- (UIImage *)cropToSizeRemainCanvasSize:(CGSize)size;

// Crop the image to a fit size
- (UIImage *)cropToSize:(CGSize)size;

// Resize the image to fit size.
- (UIImage *)scaledToSize:(CGSize)size;

// Consider the data is a gif image, try to parse the data and fetch
// each frame in the file.
+ (UIImage *)PYImageWithData:(NSData *)theData;

@end
