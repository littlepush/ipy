//
//  PYRichText.h
//  PYUIKit
//
//  Created by Push Chen on 7/30/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define RICHLB_DEFAULT_FONT_SIZE            14

typedef enum {
	PYRichTextLinkNormal,
	PYRichTextLinkHover,
	PYRichTextLinkSelected
} PYRichTextLinkStatue;

@interface PYRichText : NSObject
{
    NSString                                    *_text;
    PYRichTextLinkStatue                        _linkStatue;
	CGSize                                      _wordSize;
	CGRect                                      _drawingRect;
	unsigned int                                _length;
}

@property (nonatomic, copy)		NSString 				*text;
@property (nonatomic, strong)	UIImage					*image;
@property (nonatomic, readonly)	NSUInteger				length;
@property (nonatomic, strong)	UIFont					*font;
@property (nonatomic, strong)	UIColor 				*textColor;
@property (nonatomic, assign)	CGSize					shadowOffset;
@property (nonatomic, strong)	UIColor 				*shadowColor;
@property (nonatomic, assign)	CGFloat					shadowOpacity;
@property (nonatomic, assign)   CGFloat                 borderWidth;
@property (nonatomic, strong)   UIColor                 *borderColor;

// URL/LINK/USERNAME support
@property (nonatomic, copy)		NSString 				*address;

// If the user specified the [address] property, then the following
// three properties will work and replace the origin textColor.
@property (nonatomic, strong)	UIColor					*linkNormalColor;
@property (nonatomic, strong)	UIColor					*linkSelectedColor;
@property (nonatomic, strong)	UIColor					*linkHoverColor;

// Initialize
+ (PYRichText *)textWithString:(NSString *)string;
+ (PYRichText *)textWithFormat:(NSString *)format, ...;

//+ (const RichText *) endOfLine;

// String Operations
- (PYRichText *)subTextToIndex:(int)index;
- (PYRichText *)subTextFromIndex:(int)index;
//- (RichText *) subTextWithRange:(NSRange)range;

- (CGSize)sizeWithFont:(UIFont *)tFont;
- (CGSize)sizeWithSelfFont;

@end

@interface PYRichText ()

@property (nonatomic, readonly)	BOOL 					isLink;
@property (nonatomic, readonly)	PYRichTextLinkStatue	linkStatue;

// Copy the settings
- (void) copyRichSettingFromAnotherRichText:(PYRichText *)anotherRichText;

@end
