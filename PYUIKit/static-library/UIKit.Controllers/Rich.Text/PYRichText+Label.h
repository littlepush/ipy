//
//  PYRichText+Label.h
//  PYUIKit
//
//  Created by Push Chen on 7/30/13.
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

#import "PYRichText.h"

@interface PYRichText (Label)

@property (nonatomic, readonly)	CGSize		wordSize;
- (void) setWordSize:(CGSize)wsize;

@property (nonatomic, readonly)	CGRect		drawingRect;
- (void) setDrawingRect:(CGRect)rect;

// Calculate the text length
- (void) _calculateTextLength;

@property (nonatomic, readonly)	UIColor		*displayColor;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
