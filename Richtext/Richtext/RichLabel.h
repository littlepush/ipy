//
//  RichLabel.h
//  QTRadio
//
//  Created by Chen Push on 1/30/13.
//  Copyright (c) 2013 markradio. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	RichTextLinkNormal,
	RichTextLinkHover,
	RichTextLinkSelected
} RichTextLinkStatue;

/* Rich text of a word */
@interface RichText : NSObject< NSCoding >
{
	RichTextLinkStatue									_linkStatue;
	CGSize												_wordSize;
	CGRect												_drawingRect;
	unsigned int										_length;
}

@property (nonatomic, copy)		NSString 				*text;
@property (nonatomic, retain)	UIImage					*image;
@property (nonatomic, readonly)	NSUInteger				length;
@property (nonatomic, retain)	UIFont					*font;
@property (nonatomic, retain)	UIColor 				*textColor;
@property (nonatomic, assign)	CGSize					shadowOffset;
@property (nonatomic, retain)	UIColor 				*shadowColor;
@property (nonatomic, assign)	CGFloat					shadowOpacity;
@property (nonatomic, retain)	UIColor					*glowColor;
@property (nonatomic, assign)	CGFloat					glowSize;

// URL/LINK/USERNAME support
@property (nonatomic, copy)		NSString 				*address;

// If the user specified the [address] property, then the following
// three properties will work and replace the origin textColor.
@property (nonatomic, retain)	UIColor					*linkNormalColor;
@property (nonatomic, retain)	UIColor					*linkSelectedColor;
@property (nonatomic, retain)	UIColor					*linkHoverColor;

// Initialize
+ (RichText *) textWithString:(NSString *)string;
+ (RichText *) textWithFormat:(NSString *)format, ...;

//+ (const RichText *) endOfLine;

// String Operations
- (RichText *) subTextToIndex:(int)index;
- (RichText *) subTextFromIndex:(int)index;
//- (RichText *) subTextWithRange:(NSRange)range;

- (CGSize) sizeWithFont:(UIFont *)tFont;
- (CGSize) sizeWithSelfFont;

@end

@interface RichText ()

@property (nonatomic, readonly)	BOOL 					isLink;
@property (nonatomic, readonly)	RichTextLinkStatue		linkStatue;

// Copy the settings
- (void) copyRichSettingFromAnotherRichText:(RichText *)anotherRichText;

@end

typedef void (^RichLabelLinkClick)( NSString * text, NSString *link );

/* Richtext Label */
@interface RichLabel : UIView
{
	NSMutableArray				*_wordList;
	NSString 					*_pureText;
	
	NSMutableArray				*_linkTexts;
	BOOL						_tapLink;	
}

@property (nonatomic, readonly)		NSString 			*text;
// Use default style for all text set.
- (void) setText:(NSString *)aText;

// Default text style
@property (nonatomic, retain)		UIFont				*font;
@property (nonatomic, retain)		UIColor				*textColor;
@property (nonatomic, retain)		UIColor				*glowColor;
@property (nonatomic, assign)		CGFloat				glowSize;
@property (nonatomic, retain)		UIColor 			*shadowColor;
@property (nonatomic, assign)		CGFloat				shadowOpacity;
@property (nonatomic, assign)		CGSize				shadowOffset;
@property (nonatomic, assign)		NSTextAlignment		textAlignment;
@property (nonatomic, assign)		BOOL 				multipleLine;

-(void) appendWord:(NSString *)pureWord;
-(void) appendRichText:(RichText *)richText;

// Click block
@property (nonatomic, copy)			RichLabelLinkClick	linkClickBlock;

@end
