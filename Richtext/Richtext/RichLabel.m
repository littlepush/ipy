//
//  RichLabel.m
//  QTRadio
//
//  Created by Chen Push on 1/30/13.
//  Copyright (c) 2013 markradio. All rights reserved.
//

#import "RichLabel.h"
#import <QuartzCore/QuartzCore.h>

@interface RichText ()

@property (nonatomic, readonly)	CGSize		wordSize;
- (void) setWordSize:(CGSize)wsize;

@property (nonatomic, readonly)	CGRect		drawingRect;
- (void) setDrawingRect:(CGRect)rect;

// Calculate the text length
- (void) _calculateTextLength;

@property (nonatomic, readonly)	UIColor		*displayColor;

@end

@implementation RichText

#define _Encode_( obj, type )										\
	[aCoder encode##type:self.obj forKey:@"kArc" #obj]
#define _EncodeObj( obj )				_Encode_(obj, Object)
#define _EncodeInt(obj)					_Encode_(obj, Int)
#define _EncodeFloat(obj)				_Encode_(obj, Float)
#define _EncodeDouble(obj)				_Encode_(obj, Double)
#define _Decode_( obj, type )										\
	self.obj = [aDecoder decode##type##ForKey:@"kArc" #obj]
#define _DecodeObj( obj )				_Decode_(obj, Object)
#define _DecodeInt( obj )				_Decode_(obj, Int)
#define _DecodeFloat( obj )				_Decode_(obj, Float)
#define _DecodeDouble( obj )			_Decode_(obj, Double)

#define RICHLB_DEFAULT_FONT_SIZE		14

@synthesize text, font, textColor;
@synthesize shadowColor, shadowOffset, shadowOpacity;
@synthesize glowColor, glowSize;
@synthesize address;
@synthesize linkHoverColor, linkSelectedColor, linkNormalColor;
//@synthesize length = _length;

- (NSUInteger) length
{
	if ( self.image != nil ) return 1;
	return _length;
}

@synthesize wordSize = _wordSize;
- (void) setWordSize:(CGSize)wsize
{
	_wordSize = wsize;
}

@synthesize drawingRect = _drawingRect;
- (void) setDrawingRect:(CGRect)rect
{
	_drawingRect = rect;
}

@dynamic displayColor;
- (UIColor *) displayColor
{
	if ( self.isLink ) {
		switch (_linkStatue) {
			case RichTextLinkNormal: return self.linkNormalColor == nil ? [UIColor blueColor] : self.linkNormalColor;
			case RichTextLinkHover: return self.linkHoverColor == nil ? [UIColor lightGrayColor] : self.linkHoverColor;
			case RichTextLinkSelected : return self.linkSelectedColor == nil ? [UIColor redColor] : self.linkSelectedColor;
		};
	}
	return self.textColor;
}

- (void) _calculateTextLength
{
	__block unsigned int l = 0;
	[self.text enumerateSubstringsInRange:NSMakeRange(0, [self.text length])
		options:NSStringEnumerationByComposedCharacterSequences
		usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
		++l;
	}];
	_length = l;
}

- (void) setText:(NSString *)aText
{
	if ( text != nil )
		[text release];
	text = [[aText copy] retain];
	[self _calculateTextLength];
}

// Copy the settings
- (void) copyRichSettingFromAnotherRichText:(RichText *)anotherRichText
{
	if ( self == anotherRichText ) return;
	if ( anotherRichText == nil ) return;
	
	self.image = anotherRichText.image;
	self.font = anotherRichText.font;
	self.textColor = anotherRichText.textColor;
	self.shadowOffset = anotherRichText.shadowOffset;
	self.shadowColor = anotherRichText.shadowColor;
	self.shadowOpacity = anotherRichText.shadowOpacity;
	self.glowColor = anotherRichText.glowColor;
	self.glowSize = anotherRichText.glowSize;
	self.address = anotherRichText.address;
	self.linkNormalColor = anotherRichText.linkNormalColor;
	self.linkSelectedColor = anotherRichText.linkSelectedColor;
	self.linkHoverColor = anotherRichText.linkHoverColor;
	_linkStatue = RichTextLinkNormal;
}

- (void) dealloc
{
	self.text = nil;
	self.image = nil;
	self.font = nil;
	self.textColor = nil;
	self.shadowColor = nil;
	self.glowColor = nil;
	self.address = nil;
	self.linkNormalColor = nil;
	self.linkSelectedColor = nil;
	self.linkHoverColor = nil;
	
	[super dealloc];
}

@synthesize linkStatue = _linkStatue;
@dynamic isLink;
- (BOOL) isLink { return [self.address length] > 0; }


#pragma mark --
#pragma mark Rich Text NSCoding
- (void) encodeWithCoder:(NSCoder *)aCoder
{
	_EncodeObj( text );
	_EncodeObj( image );
	_EncodeObj( font );
	_EncodeObj( textColor );
	_EncodeObj( shadowColor );
	_EncodeObj( glowColor );
	_EncodeObj( address );
	_EncodeObj( linkNormalColor );
	_EncodeObj( linkSelectedColor );
	_EncodeObj( linkHoverColor );
	_EncodeFloat(shadowOpacity);
	_EncodeFloat( glowSize );
	_EncodeInt( linkStatue );
	[aCoder encodeFloat:shadowOffset.width forKey:@"kArcShadowOffsetWidth"];
	[aCoder encodeFloat:shadowOffset.height forKey:@"kArcShaodwOffsetHeight"];
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if ( self ) {
		_DecodeObj(text);
		_DecodeObj(image);
		_DecodeObj(font);
		_DecodeObj(textColor);
		_DecodeObj(shadowColor);
		_DecodeObj(glowColor);
		_DecodeObj(address);
		_DecodeObj(linkNormalColor);
		_DecodeObj(linkSelectedColor);
		_DecodeObj(linkHoverColor);
		_DecodeFloat(shadowOpacity);
		_DecodeFloat(glowSize);
		_linkStatue = (RichTextLinkStatue)[aDecoder decodeIntForKey:@"kArclinkStatue"];
		CGSize _shadowOffset;
		_shadowOffset.width = [aDecoder decodeFloatForKey:@"kArcShadowOffsetWidth"];
		_shadowOffset.height = [aDecoder decodeFloatForKey:@"kArcShaodwOffsetHeight"];
		self.shadowOffset = _shadowOffset;
	}
	return self;
}

- (NSString *)description
{
	return self.text;
}

// Initialize
+ (RichText *) textWithString:(NSString *)string
{
	RichText *_text = [[[RichText alloc] init] autorelease];
	_text.text = string;
	return _text;
}
+ (RichText *) textWithFormat:(NSString *)format, ...
{
	RichText *_text = [[[RichText alloc] init] autorelease];
	va_list _args;
	va_start(_args, format);
	_text.text = [[[NSString alloc] initWithFormat:format arguments:_args] autorelease];
	va_end(_args);
	return _text;
}

- (RichText *) subTextToIndex:(int)index
{
	__block int _charCount = 0;
	__block int _cSize = 0;
	RichText *_subText = [[[RichText alloc] init] autorelease];
	[_subText copyRichSettingFromAnotherRichText:self];
	if ( index == 0 ) {
		_subText.text = @"";
		return _subText;
	}
	[self.text enumerateSubstringsInRange:NSMakeRange(0, self.text.length)
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
- (RichText *) subTextFromIndex:(int)index
{
	__block int _index = 0;
	__block int _cSize = 0;
	// 😄😃😄[3], self.text.length = 6, we need the _adjIndex to be 4
	// index = 2
	// 😄 1st substring, substring.length = 2, _adjIndex = 2, ==> _adjIndex += 2 - 1 ==> 3
	// 2nd, add another 1
	// when the enumerate finished, _adjIndex is 4;
	[self.text enumerateSubstringsInRange:NSMakeRange(0, self.text.length)
		options:NSStringEnumerationByComposedCharacterSequences
		usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
			if ( _index == index ) {
				*stop = YES;
				return;
			}
			++_index;
			_cSize += substring.length;
		}];
	RichText *_subText = [RichText textWithString:[self.text substringFromIndex:_cSize]];
	[_subText copyRichSettingFromAnotherRichText:self];
	return _subText;
}

- (CGSize) sizeWithFont:(UIFont *)tFont
{
	if ( self.image != nil ) {
		CGFloat _scale = self.image.scale;
		CGSize _s = CGSizeMake( self.image.size.width / _scale, self.image.size.height / _scale );
		return _s;
	}
	if ( [self.text length] == 0 ) return [self.address sizeWithFont:tFont];
	return [self.text sizeWithFont:tFont];
}

- (CGSize) sizeWithSelfFont
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


// RichLabel
@interface RichLabel ()

- (int) _checkAndCutTheRichText:(RichText *)richText toFitLineWidth:(CGFloat)lineWidth;

@end

@implementation RichLabel

@synthesize text = _pureText;

@synthesize font, textColor, glowColor, glowSize, shadowColor, shadowOpacity, shadowOffset, textAlignment;

@synthesize linkClickBlock;
@synthesize multipleLine;

- (void) dealloc
{
	[_wordList release];
	[_pureText release];
	[_linkTexts release];
	
	self.linkClickBlock = nil;
	self.font = nil;
	self.textColor = nil;
	self.glowColor = nil;
	self.shadowColor = nil;
	
	[super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		_wordList = [[NSMutableArray array] retain];
		_pureText = [[NSString stringWithFormat:@""] retain];
		[self setBackgroundColor:[UIColor clearColor]];
		[self setUserInteractionEnabled:YES];
		_linkTexts = [[NSMutableArray array] retain];
    }
    return self;
}

- (id) init
{
	self = [super init];
	if (self) {
        // Initialization code
		_wordList = [[NSMutableArray array] retain];
		_pureText = [[NSString stringWithFormat:@""] retain];
		[self setBackgroundColor:[UIColor clearColor]];
		[self setUserInteractionEnabled:YES];
		_linkTexts = [[NSMutableArray array] retain];
	}
	return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		_wordList = [[aDecoder decodeObjectForKey:@"kArcWordList"] retain];
		if ( _wordList == nil ) _wordList = [[NSMutableArray array] retain];
		_pureText = [[NSString stringWithFormat:@""] retain];
		for ( RichText *richText in _wordList ) {
			NSString *_string = [_pureText stringByAppendingString:richText.text];
			[_pureText release];
			_pureText = [_string retain];
		}
		
		_DecodeObj(font);
		_DecodeObj(textColor);
		_DecodeObj(glowColor);
		_DecodeObj(shadowColor);
		
		_DecodeFloat(glowSize);
		_DecodeFloat(shadowOpacity);
		_DecodeInt(textAlignment);
		_Decode_(multipleLine, Bool);
		
		CGSize _offset;
		_offset.width = [aDecoder decodeFloatForKey:@"kArcShadowOffsetWidth"];
		_offset.height = [aDecoder decodeFloatForKey:@"kArcShadowOffsetHeight"];
		
		self.shadowOffset = _offset;
		[self setBackgroundColor:[UIColor clearColor]];
		[self setUserInteractionEnabled:YES];
		_linkTexts = [[NSMutableArray array] retain];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
	[super encodeWithCoder:aCoder];
	
	[aCoder encodeObject:_wordList forKey:@"kArcWordList"];
	_EncodeObj(font);
	_EncodeObj(textColor);
	_EncodeObj(glowColor);
	_EncodeObj(shadowColor);
	
	_EncodeFloat(glowSize);
	_EncodeFloat(shadowOpacity);
	_EncodeInt(textAlignment);
	_Encode_(multipleLine, Bool);
	
	[aCoder encodeFloat:self.shadowOffset.width forKey:@"kArcShadowOffsetWidth"];
	[aCoder encodeFloat:self.shadowOffset.height forKey:@"kArcShadowOffsetHeight"];
}

- (void) setText:(NSString *)aText
{
	[_wordList removeAllObjects];
	[_pureText release];
	_pureText = [[aText copy] retain];

	if ( [aText length] == 0 ) {
		[self setNeedsDisplay];
		return;
	}

	RichText *_defaultText = [[[RichText alloc] init] autorelease];
	
	_defaultText.text = aText;
	_defaultText.font = self.font;
	_defaultText.textColor = self.textColor;
	_defaultText.shadowOffset = self.shadowOffset;
	_defaultText.shadowColor = self.shadowColor;
	_defaultText.shadowOpacity = self.shadowOpacity;
	_defaultText.glowColor = self.glowColor;
	_defaultText.glowSize = self.glowSize;
	
	[_wordList addObject:_defaultText];
	[self setNeedsDisplay];
}

- (void) appendWord:(NSString *)pureWord
{
	if ( [pureWord length] == 0 ) return;
	if ( [_wordList count] == 0 ) {
		[self setText:pureWord];
		return;
	}
	RichText *_lastWord = [_wordList lastObject];
	_lastWord.text = [_lastWord.text stringByAppendingString:pureWord];

	NSString *_temp = [_pureText stringByAppendingString:pureWord];
	[_pureText release];
	_pureText = [_temp retain];
	
	[self setNeedsDisplay];
}

- (void) appendRichText:(RichText *)richText
{
	if ( richText == nil || [richText.text length] == 0 ) return;
	[_wordList addObject:richText];

	NSString *_temp = [_pureText stringByAppendingString:richText.text];
	[_pureText release];
	_pureText = [_temp retain];

	[self setNeedsDisplay];
}

- (int) _checkAndCutTheRichText:(RichText *)richText toFitLineWidth:(CGFloat)lineWidth
{
	BOOL _isTooShort = NO;
	int _shouldSubStringAtIndex = [richText length] / 2;
	if ( _shouldSubStringAtIndex == 0 ) return 0;
	
	int _topLimit = [richText length];
	int _bottomLimit = 0;
	
	UIFont *_font = (richText.font == nil) ?
		[UIFont systemFontOfSize:RICHLB_DEFAULT_FONT_SIZE] : richText.font;

	while (true) {
		RichText *_subString = [richText subTextToIndex:_shouldSubStringAtIndex];
		CGSize _subSize = [_subString sizeWithFont:_font];
		// If fit, then return;
		if ( _subSize.width == lineWidth ) return _shouldSubStringAtIndex;
		
		
		if ( _subSize.width < lineWidth ) _isTooShort = YES;
		else _isTooShort = NO;
		
		int _nextSubIndex = ( _isTooShort ) ?
			( _topLimit - _shouldSubStringAtIndex ) / 2 + _shouldSubStringAtIndex :
			_shouldSubStringAtIndex - ( _shouldSubStringAtIndex - _bottomLimit ) / 2;
		if ( _isTooShort ) _bottomLimit = _shouldSubStringAtIndex;
		else _topLimit = _shouldSubStringAtIndex;
		
		if ( _nextSubIndex == _shouldSubStringAtIndex ) {
			return ( _isTooShort ? _shouldSubStringAtIndex : _shouldSubStringAtIndex - 1);
		}
		_shouldSubStringAtIndex = _nextSubIndex;
		if ( _shouldSubStringAtIndex == 0 ) return 0;
	}
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
// [self _drawLine:_wordsArray topleft:(CGPoint)topleft inContext:ctx];
- (void)_drawLine:(NSArray *)wordsArray topLeft:(CGPoint)topleft
	lineHeight:(CGFloat)lineHeight inContext:(CGContextRef)context
{
	if ( [wordsArray count] == 0 ) return;
	
	CGFloat _x = topleft.x;
	if ( self.textAlignment == NSTextAlignmentCenter && topleft.x == 0 ) {
		CGFloat _allWidth = 0.f;
		for ( RichText *_t in wordsArray ) {
			_allWidth += _t.wordSize.width;
		}
		_x = (self.bounds.size.width - _allWidth) / 2;
	} else if ( self.textAlignment == NSTextAlignmentRight && topleft.x == 0 ) {
		CGFloat _allWidth = 0.f;
		for ( RichText *_t in wordsArray ) {
			_allWidth += _t.wordSize.width;
		}
		_x = (self.bounds.size.width - _allWidth);
	}
	for ( RichText *_t in wordsArray ) {
		UIColor *_textColor = _t.displayColor;
		if ( _textColor == nil ) _textColor = self.textColor;
		
		// All nil, use default black color
		if ( _textColor == nil ) _textColor = [UIColor blackColor];
		CGFloat _y = (_t.wordSize.height < lineHeight) ? lineHeight - _t.wordSize.height + topleft.y : topleft.y;
		
		CGRect _rectToDraw = CGRectMake(_x, _y, _t.wordSize.width, _t.wordSize.height);
		[_t setDrawingRect:_rectToDraw];
		if ( _t.image != nil ) {
			// Draw the image
			CGContextTranslateCTM(context, 0.0, _t.wordSize.height);
			CGContextScaleCTM(context, 1.0, -1.0);
			CGContextDrawImage(
				context,
				_rectToDraw,
				_t.image.CGImage);
			CGContextScaleCTM(context, 1.0, -1.0);
			CGContextTranslateCTM(context, 0.0, -_t.wordSize.height);
		} else {
			// Shadow Checking
			BOOL _shadowed = NO;
			CGColorSpaceRef _colorSpace = NULL;
			CGColorRef _glowColor = NULL;
			// Glow is not supported yet.
			/*
			if ( _t.glowSize > 0 && _t.glowColor != nil ) {
				CGContextSaveGState(context);
				_colorSpace = CGColorSpaceCreateDeviceRGB();
				_glowColor = CGColorCreate(_colorSpace, CGColorGetComponents(_t.glowColor.CGColor));
				
				CGContextSetShadow(context, CGSizeZero, _t.glowSize);
				CGContextSetShadowWithColor(context, CGSizeZero, _t.glowSize, _glowColor);
				_shadowed = YES;
			}
			*/
			if ( _t.shadowOffset.width != 0 && _t.shadowOffset.height != 0
				&& _t.shadowColor != nil && _shadowed == NO ) {
				CGContextSaveGState(context);
				CGContextSetShadowWithColor(context, _t.shadowOffset, _t.shadowOpacity == 0 ? .7
					: _t.shadowOpacity, _t.shadowColor.CGColor);
				_shadowed = YES;
			}
			
			// Draw text
			UIGraphicsPushContext(context);
			CGContextSetFillColorWithColor(context, _textColor.CGColor);
			[_t.text drawInRect:_rectToDraw withFont:_t.font];
			//CGContextStrokePath(UIGraphicsGetCurrentContext());
			UIGraphicsPopContext();
			
			// Restore Shadow GState
			if ( _shadowed ) {
				CGContextRestoreGState(context);
				if ( _colorSpace != NULL ) CGColorSpaceRelease(_colorSpace);
				if ( _glowColor != NULL ) CGColorRelease(_glowColor);
			}
		}
		_x += _t.wordSize.width;
	}
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	NSMutableArray *_wordsArray = [NSMutableArray array];
	CGSize _dotSize = [@"..." sizeWithFont:(self.font == nil ?
		[UIFont systemFontOfSize:RICHLB_DEFAULT_FONT_SIZE] : self.font)];
	CGFloat _lineSizeLimit = (self.multipleLine ?
		self.bounds.size.width : self.bounds.size.width - _dotSize.width);
		
	CGFloat _currentLineLeftSize = _lineSizeLimit;
	CGFloat _allLineHeight = 0;
	CGFloat _lineHeight = 0;
	
	// Create a temp dot text, in anycase we need to draw ...
	RichText *_dotText = [RichText textWithString:@"..."];
	_dotText.font = self.font;
	_dotText.textColor = self.textColor;
	_dotText.shadowColor = self.shadowColor;
	_dotText.shadowOffset = self.shadowOffset;
	_dotText.shadowOpacity = self.shadowOpacity;
	[_dotText setWordSize:_dotSize];
	
	[_linkTexts removeAllObjects];
	
	void (^_drawDot)(CGFloat _l, CGFloat _h, CGFloat _a) = ^(CGFloat _l, CGFloat _h, CGFloat _a){
		[self _drawLine:[NSArray arrayWithObject:_dotText]
			topLeft:CGPointMake(_lineSizeLimit - _l,
				_a + (_h - _dotSize.height) )
			lineHeight:_h inContext:ctx];
	};
	
	for ( RichText *_word in _wordList ) {
		if ( _word.font == nil ) _word.font = [UIFont systemFontOfSize:RICHLB_DEFAULT_FONT_SIZE];
		if ( _word.shadowColor == nil ) _word.shadowColor = self.shadowColor;
		if ( CGSizeEqualToSize(_word.shadowOffset, CGSizeZero) ) _word.shadowOffset = self.shadowOffset;
		if ( _word.shadowOpacity == 0.f ) _word.shadowOpacity = self.shadowOpacity;
		if ( _word.glowColor == nil ) _word.glowColor = self.glowColor;
		if ( _word.glowSize == 0.f ) _word.glowSize = self.glowSize;
		
		// Get the word size
		CGSize _wordSize = [_word sizeWithFont:_word.font];
		
		if ( _wordSize.width < _currentLineLeftSize ) {
			[_word setWordSize:_wordSize];
			[_wordsArray addObject:_word];
			if ( _word.isLink ) {
				[_linkTexts addObject:_word];
			}
			
			// Line Height
			if ( _lineHeight < _wordSize.height ) _lineHeight = _wordSize.height;
			_currentLineLeftSize -= _wordSize.width;
				
		} else if ( _wordSize.width > _currentLineLeftSize ) {

			CGSize _subWordSize = _wordSize;
			RichText *_subWord = [_word retain];
			do {
				// Get the line-break point.
				int _lineBreakPoint = [self _checkAndCutTheRichText:_subWord toFitLineWidth:_currentLineLeftSize];
				if ( _lineBreakPoint == 0 ) {
					// we need a new line
					[self _drawLine:_wordsArray topLeft:CGPointMake(0, _allLineHeight)
						lineHeight:_lineHeight inContext:ctx];
						
					if ( self.multipleLine == NO ) {
						_drawDot(_currentLineLeftSize, _lineHeight, _allLineHeight); return;
					}
					[_wordsArray removeAllObjects];
					_currentLineLeftSize = _lineSizeLimit;
					_allLineHeight += _lineHeight;
					_lineHeight = 0.f;
					continue;
				}
				// New sub-word to the line-break point
				RichText *_subRichWord = [_subWord subTextToIndex:_lineBreakPoint];
				CGSize _s = [_subRichWord sizeWithFont:_subRichWord.font];
				[_subRichWord setWordSize:_s];
				_currentLineLeftSize -= _s.width;
				
				// Add to cache
				[_wordsArray addObject:_subRichWord];
				if ( _subRichWord.isLink ) { [_linkTexts addObject:_subRichWord]; }
				if ( _lineHeight < _s.height ) _lineHeight = _s.height;
				
				// Draw last line
				[self _drawLine:_wordsArray topLeft:CGPointMake(0, _allLineHeight)
					lineHeight:_lineHeight inContext:ctx];
				if ( self.multipleLine == NO ) {
					_drawDot(_currentLineLeftSize, _lineHeight, _allLineHeight); return;
				}

				// Modify the line size
				_allLineHeight += _lineHeight;
				_currentLineLeftSize = _lineSizeLimit;
				_lineHeight = 0.f;
				
				// Reset the cache
				[_wordsArray removeAllObjects];
				RichText *_leftSubword = [_subWord subTextFromIndex:_lineBreakPoint];
				_subWordSize = [_leftSubword sizeWithFont:_leftSubword.font];
				
				[_subWord release];
				_subWord = [_leftSubword retain];
				[_subWord setWordSize:_subWordSize];
			} while (_subWordSize.width > _currentLineLeftSize );
			
			// Add the last part of the word to new line
			if ( _subWordSize.width == 0 && [_subWord.text length] == 0 ) {
				// Nothing left
				[_subWord release];
				continue;
			}
			[_wordsArray addObject:_subWord];
			if ( _subWord.isLink ) { [_linkTexts addObject:_subWord]; }
			
			_currentLineLeftSize -= _subWordSize.width;
			if ( _lineHeight < _subWordSize.height ) _lineHeight = _subWordSize.height;
			
			if ( _currentLineLeftSize == 0 ) {
				// Draw last line
				[self _drawLine:_wordsArray topLeft:CGPointMake(0, _allLineHeight)
					 lineHeight:_lineHeight inContext:ctx];
				if ( self.multipleLine == NO ) {
					_drawDot(_currentLineLeftSize, _lineHeight, _allLineHeight); return;
				}
				
				// Modify the line size
				_allLineHeight += _lineHeight;
				_currentLineLeftSize = _lineSizeLimit;
				_lineHeight = 0.f;
				
				// Reset
				[_wordsArray removeAllObjects];
			}
			[_subWord release];
		} else {
			[_word setWordSize:_wordSize];
			[_wordsArray addObject:_word];
			if ( _word.isLink ) { [_linkTexts addObject:_word]; }
			
			if ( _lineHeight < _wordSize.height ) _lineHeight = _wordSize.height;
			[self _drawLine:_wordsArray topLeft:CGPointMake(0, _allLineHeight)
				lineHeight:_lineHeight inContext:ctx];
			if ( self.multipleLine == NO ) {
				_drawDot(_currentLineLeftSize, _lineHeight, _allLineHeight); return;
			}
				
			// Reset cache
			[_wordsArray removeAllObjects];
			_allLineHeight += _lineHeight;
			_currentLineLeftSize = _lineSizeLimit;
			_lineHeight = 0.f;
		}
	}
	
	if ( [_wordsArray count] == 0 ) return;
	[self _drawLine:_wordsArray topLeft:CGPointMake(0, _allLineHeight)
		lineHeight:_lineHeight inContext:ctx];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	_tapLink = YES;
	[super touchesBegan:touches withEvent:event];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	_tapLink = NO;
	[super touchesBegan:touches withEvent:event];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ( _tapLink == NO ) {
		[super touchesEnded:touches withEvent:event];
		return;
	}
	_tapLink = NO;

	UITouch *_touch = [touches anyObject];
	CGPoint _touchPoint = [_touch locationInView:self];
	for ( RichText *linkText in _linkTexts )
	{
		if ( CGRectContainsPoint(linkText.drawingRect, _touchPoint) ) {
			NSLog(@"click link: %@[%@]", linkText, linkText.address);
			// call the target
			if ( self.linkClickBlock ) self.linkClickBlock(linkText.text, linkText.address);
			return;
		}
	}

	[super touchesEnded:touches withEvent:event];
}

@end
