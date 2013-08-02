//
//  PYRichLabel.h
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

#import "PYView.h"
#import "PYRichText.h"

typedef void (^PYRichLabelLinkClick)( id object, CGRect rect);

@interface PYRichLabel : PYView
{
	NSMutableArray				*_wordList;
	NSMutableString             *_pureText;
	
	NSMutableArray				*_linkTexts;
	BOOL						_tapLink;
}

@property (nonatomic, readonly)		NSString                *text;
// Use default style for all text set.
- (void)setText:(NSString *)aText;
- (void)setRichTexts:(NSArray *)richTexts;

// Default text style
@property (nonatomic, strong)       UIFont                  *font;
@property (nonatomic, strong)       UIColor                 *textColor;
@property (nonatomic, strong)       UIColor                 *shadowColor;
@property (nonatomic, assign)       CGFloat                 shadowOpacity;
@property (nonatomic, assign)       CGSize                  shadowOffset;
@property (nonatomic, assign)       NSTextAlignment         textAlignment;
@property (nonatomic, assign)       CGFloat                 borderWidth;
@property (nonatomic, strong)       UIColor                 *borderColor;
@property (nonatomic, assign)       BOOL                    multipleLine;

// Reset all rich texts in current label.
- (void)resetLabel;

// Append new word into this label.
- (void)appendWord:(NSString *)pureWord;
- (void)appendRichText:(PYRichText *)richText;

// Click block
@property (nonatomic, copy)			PYRichLabelLinkClick	linkClickBlock;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
