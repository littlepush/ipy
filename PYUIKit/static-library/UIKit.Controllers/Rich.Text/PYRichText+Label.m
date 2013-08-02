//
//  PYRichText+Label.m
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

#import "PYRichText+Label.h"

@implementation PYRichText (Label)

@dynamic wordSize;
- (CGSize)wordSize
{
    return _wordSize;
}
- (void)setWordSize:(CGSize)wsize
{
	_wordSize = wsize;
}

@dynamic drawingRect;
- (CGRect)drawingRect
{
    return _drawingRect;
}
- (void)setDrawingRect:(CGRect)rect
{
	_drawingRect = rect;
}


@dynamic displayColor;
- (UIColor *)displayColor
{
	if ( self.isLink ) {
		switch (_linkStatue) {
            case PYRichTextLinkNormal: {
                return self.linkNormalColor == nil ?
                [UIColor blueColor] : self.linkNormalColor;
            }
			case PYRichTextLinkHover: {
                return self.linkHoverColor == nil ?
                [UIColor lightGrayColor] : self.linkHoverColor;
            }
			case PYRichTextLinkSelected: {
                return self.linkSelectedColor == nil ?
                [UIColor redColor] : self.linkSelectedColor;
            }
		};
	}
	return self.textColor;
}

- (void)_calculateTextLength
{
	__block unsigned int l = 0;
	[self.text
     enumerateSubstringsInRange:NSMakeRange(0, [self.text length])
     options:NSStringEnumerationByComposedCharacterSequences
     usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         ++l;
     }];
	_length = l;
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
