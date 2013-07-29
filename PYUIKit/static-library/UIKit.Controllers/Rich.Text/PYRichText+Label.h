//
//  PYRichText+Label.h
//  PYUIKit
//
//  Created by Push Chen on 7/30/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

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
