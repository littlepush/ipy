//
//  PYRichText.m
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
#import "PYRichText+Label.h"

@implementation PYRichText

@synthesize text = _text, font, textColor;
@synthesize shadowColor, shadowOffset, shadowOpacity;
@synthesize address;
@synthesize linkHoverColor, linkSelectedColor, linkNormalColor;
@synthesize borderWidth, borderColor;

- (NSUInteger)length
{
	if ( self.image != nil ) return 1;
	return _length;
}

- (void)setText:(NSString *)aText
{
	_text = [aText copy];
	[self _calculateTextLength];
}

// Copy the settings
- (void)copyRichSettingFromAnotherRichText:(PYRichText *)anotherRichText
{
	if ( self == anotherRichText ) return;
	if ( anotherRichText == nil ) return;
	
	self.image = anotherRichText.image;
	self.font = anotherRichText.font;
	self.textColor = anotherRichText.textColor;
	self.shadowOffset = anotherRichText.shadowOffset;
	self.shadowColor = anotherRichText.shadowColor;
	self.shadowOpacity = anotherRichText.shadowOpacity;
	self.address = anotherRichText.address;
	self.linkNormalColor = anotherRichText.linkNormalColor;
	self.linkSelectedColor = anotherRichText.linkSelectedColor;
	self.linkHoverColor = anotherRichText.linkHoverColor;
    self.borderColor = anotherRichText.borderColor;
    self.borderWidth = anotherRichText.borderWidth;
	_linkStatue = PYRichTextLinkNormal;
}

- (id)copy
{
    PYRichText *_newText = [[PYRichText alloc] init];
    [_newText copyRichSettingFromAnotherRichText:self];
    _newText->_text = [_text copy];
    _newText->_length = _length;
    return _newText;
}

@synthesize linkStatue = _linkStatue;
@dynamic isLink;
- (BOOL)isLink { return [self.address length] > 0; }

#pragma mark --
#pragma mark System Override
- (NSString *)description
{
	return self.text;
}

#pragma mark --
#pragma mark Initialize
// Initialize
+ (PYRichText *)textWithString:(NSString *)string
{
	PYRichText *_text = [[PYRichText alloc] init];
	_text.text = string;
	return _text;
}
+ (PYRichText *)textWithFormat:(NSString *)format, ...
{
	PYRichText *_text = [[PYRichText alloc] init];
	va_list _args;
	va_start(_args, format);
	_text.text = [[NSString alloc] initWithFormat:format arguments:_args];
	va_end(_args);
	return _text;
}

- (PYRichText *)subTextToIndex:(NSUInteger)index
{
	__block NSUInteger _charCount = 0;
	__block NSUInteger _cSize = 0;
	PYRichText *_subText = [[PYRichText alloc] init];
	[_subText copyRichSettingFromAnotherRichText:self];
	if ( index == 0 ) {
		_subText.text = @"";
		return _subText;
	}
	[self.text
     enumerateSubstringsInRange:NSMakeRange(0, self.text.length)
     options:NSStringEnumerationByComposedCharacterSequences
     usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         ++_charCount;
         _cSize += substring.length;
         if ( _charCount == index ) {
             *stop = YES;
         }
         if ( _charCount == self.text.length ) {
             *stop = YES;
         }
     }];
	_subText.text = [self.text substringToIndex:_cSize];
	return _subText;
}

- (PYRichText *)subTextFromIndex:(NSUInteger)index
{
	__block NSUInteger _index = 0;
	__block NSUInteger _cSize = 0;
	// 😄😃😄[3], self.text.length = 6, we need the _adjIndex to be 4
	// index = 2
	// 😄 1st substring, substring.length = 2, _adjIndex = 2, ==> _adjIndex += 2 - 1 ==> 3
	// 2nd, add another 1
	// when the enumerate finished, _adjIndex is 4;
	[self.text
     enumerateSubstringsInRange:NSMakeRange(0, self.text.length)
     options:NSStringEnumerationByComposedCharacterSequences
     usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         if ( _index == index ) {
             *stop = YES;
             return;
         }
         ++_index;
         _cSize += substring.length;
     }];
	PYRichText *_subText = [PYRichText textWithString:[self.text substringFromIndex:_cSize]];
	[_subText copyRichSettingFromAnotherRichText:self];
	return _subText;
}

- (CGSize)sizeWithFont:(UIFont *)tFont
{
	if ( self.image != nil ) {
		CGFloat _scale = self.image.scale;
		CGSize _s = CGSizeMake( self.image.size.width / _scale, self.image.size.height / _scale );
		return _s;
	}
	if ( [self.text length] == 0 ) return [self.address sizeWithFont:tFont];
	return [self.text sizeWithFont:tFont];
}

- (CGSize)sizeWithSelfFont
{
	if ( self.image != nil ) {
		CGFloat _scale = self.image.scale;
		CGSize _s = CGSizeMake( self.image.size.width / _scale, self.image.size.height / _scale );
		return _s;
	}
	if ( self.font == nil ) {
		return [self sizeWithFont:[UIFont systemFontOfSize:RICHLB_DEFAULT_FONT_SIZE]];
	}
	return [self sizeWithFont:self.font];
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
