//
//  UIImage+UIKit.h
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

#import <UIKit/UIKit.h>

@interface UIImage (UIKit)

// Remain the canvas size and fill the cut part with transplant data.
- (UIImage *)cropToSizeRemainCanvasSize:(CGSize)size;

// Crop the image to a fit size
- (UIImage *)cropToSize:(CGSize)size;

// Crop the image in rect.
- (UIImage *)cropInRect:(CGRect)cropRect;

// Scale canvas to specifed rect
- (UIImage *)scalCanvasFitRect:(CGRect)fitRect;

// Resize the image to fit size.
- (UIImage *)scaledToSize:(CGSize)size;

// Consider the data is a gif image, try to parse the data and fetch
// each frame in the file.
+ (UIImage *)PYImageWithData:(NSData *)theData;

// The string is in the following format:
// Single color: #COLOR
// Gradient two colors: #COLOR1:#COLOR2
// More gradient colors: #COLOR1(L1):#COLOR2(L2):...
// Gradient direction:  v(40)$#COLOR1/L1:#COLOR2/L1... // from top to bottom
//                      h(80)$#COLOR1:#COLOR2... // from left to right
// Must specified the flag to use gradient color.
// the number after flag is the size of the gradient range.
// The location is optional
// This method will create a gradient image with specified color.
+ (UIImage *)imageWithOptionString:(NSString *)optionString;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
