//
//  PYRichLabel.m
//  PYUIKit
//
//  Created by Push Chen on 7/30/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import "PYRichLabel.h"
#import "PYRichText+Label.h"
#import <QuartzCore/QuartzCore.h>

@implementation PYRichLabel
@synthesize text = _pureText;

@synthesize font, textColor, textAlignment;
@synthesize shadowColor, shadowOpacity, shadowOffset;
@synthesize borderWidth, borderColor;

@synthesize linkClickBlock;
@synthesize multipleLine;

- (void)viewJustBeenCreated
{
    // Initialization code
    _wordList = [NSMutableArray array];
    _pureText = [NSMutableString stringWithString:@""];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setUserInteractionEnabled:YES];
    _linkTexts = [NSMutableArray array];
    self.font = [UIFont systemFontOfSize:RICHLB_DEFAULT_FONT_SIZE];
}

- (void)setText:(NSString *)aText
{
	[_wordList removeAllObjects];
    [_pureText setString:aText];
    
	if ( [aText length] == 0 ) {
		[self setNeedsDisplay];
		return;
	}
    
	PYRichText *_defaultText = [[PYRichText alloc] init];
	
	_defaultText.text = aText;
	_defaultText.font = self.font;
	_defaultText.textColor = self.textColor;
	_defaultText.shadowOffset = self.shadowOffset;
	_defaultText.shadowColor = self.shadowColor;
	_defaultText.shadowOpacity = self.shadowOpacity;
    _defaultText.borderWidth = self.borderWidth;
    _defaultText.borderColor = self.borderColor;
	
	[_wordList addObject:_defaultText];
	[self setNeedsDisplay];
}

- (void)setRichTexts:(NSArray *)richTexts
{
    [self resetLabel];
    [_wordList addObjectsFromArray:richTexts];
    for ( PYRichText *_rt in richTexts ) {
        [_pureText appendString:_rt.text];
    }
    [self setNeedsDisplay];
}

- (void)resetLabel
{
	[_wordList removeAllObjects];
    [_pureText setString:@""];
}

- (void)appendWord:(NSString *)pureWord
{
	if ( [pureWord length] == 0 ) return;
	if ( [_wordList count] == 0 ) {
		[self setText:pureWord];
		return;
	}
	PYRichText *_lastWord = [_wordList lastObject];
	_lastWord.text = [_lastWord.text stringByAppendingString:pureWord];
    
	[_pureText appendString:pureWord];
	[self setNeedsDisplay];
}

- (void)appendRichText:(PYRichText *)richText
{
	if ( richText == nil || [richText.text length] == 0 ) return;
	[_wordList addObject:richText];
    
    [_pureText appendString:richText.text];
	[self setNeedsDisplay];
}

- (int)_checkAndCutTheRichText:(PYRichText *)richText toFitLineWidth:(CGFloat)lineWidth
{
	BOOL _isTooShort = NO;
	int _shouldSubStringAtIndex = [richText length] / 2;
	if ( _shouldSubStringAtIndex == 0 ) return 0;
	
	int _topLimit = [richText length];
	int _bottomLimit = 0;
	
	UIFont *_font = (richText.font == nil) ?
    [UIFont systemFontOfSize:RICHLB_DEFAULT_FONT_SIZE] : richText.font;
    
	while (true) {
		PYRichText *_subString = [richText subTextToIndex:_shouldSubStringAtIndex];
		CGSize _subSize = [_subString sizeWithFont:_font];
		// If fit, then return;
		if ( _subSize.width == lineWidth )
            return _shouldSubStringAtIndex;
		
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
		if ( _shouldSubStringAtIndex == 0 )
            return 0;
	}
}

- (void)_drawLine:(NSArray *)wordsArray topLeft:(CGPoint)topleft
       lineHeight:(CGFloat)lineHeight inContext:(CGContextRef)context
{
	if ( [wordsArray count] == 0 ) return;
	
	CGFloat _x = topleft.x;
    
    CGFloat _allWidth = 0.f;
    for ( PYRichText *_t in wordsArray ) {
        _allWidth += _t.wordSize.width;
    }
    
	if ( self.textAlignment == NSTextAlignmentCenter && topleft.x == 0 ) {
		_x = (self.bounds.size.width - _allWidth) / 2;
	} else if ( self.textAlignment == NSTextAlignmentRight && topleft.x == 0 ) {
		_x = (self.bounds.size.width - _allWidth);
	}
    
	for ( PYRichText *_t in wordsArray ) {
		UIColor *_textColor = _t.displayColor;
        
        // Calculate current text's drawing frame
		CGFloat _y = (_t.wordSize.height < lineHeight) ?
        lineHeight - _t.wordSize.height + topleft.y : topleft.y;
		
		CGRect _rectToDraw = CGRectMake(_x, _y, _t.wordSize.width, _t.wordSize.height);
		[_t setDrawingRect:_rectToDraw];
        
		if ( _t.image != nil ) {
			// Draw the image
			CGContextTranslateCTM(context, 0.0, _t.wordSize.height);
			CGContextScaleCTM(context, 1.0, -1.0);
            //
			CGContextDrawImage(context, _rectToDraw, _t.image.CGImage);
            
			CGContextScaleCTM(context, 1.0, -1.0);
			CGContextTranslateCTM(context, 0.0, -_t.wordSize.height);
		} else {
            // Set the text drawing color
            if ( _textColor == nil ) _textColor = self.textColor;
            // All nil, use default black color
            if ( _textColor == nil ) _textColor = [UIColor blackColor];
            
            if ( [self.text length] == 0 ) return;
            
            // Set Border
            CGContextSetFillColorWithColor(context, _textColor.CGColor);
            if ( _t.borderWidth > 0.f && _t.borderColor != nil ) {
                CGContextSetStrokeColorWithColor(context, _t.borderColor.CGColor);
                CGContextSetTextDrawingMode(context, kCGTextFillStroke);
            } else {
                CGContextSetTextDrawingMode(context, kCGTextFill);
            }
            
            // Set Shadow
            if ( _t.shadowColor != nil ) {
                CGContextSetShadowWithColor
                (context, _t.shadowOffset, _t.shadowOpacity,
                 _t.shadowColor.CGColor);
            }
            
            UIGraphicsPushContext(context);
            [_t.text drawInRect:_rectToDraw withFont:_t.font];
            UIGraphicsPopContext();
        }
		_x += _t.wordSize.width;
	}
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGSize _dotSize = [@"..."
                       sizeWithFont:(self.font == nil ?
                                     [UIFont systemFontOfSize:RICHLB_DEFAULT_FONT_SIZE] :
                                     self.font)];
	CGFloat _lineSizeLimit = self.bounds.size.width;
    if ( self.multipleLine == NO ) _lineSizeLimit -= _dotSize.width;
	CGFloat _currentLineLeftSize = _lineSizeLimit;
	CGFloat _allLineHeight = 0;
	CGFloat _lineHeight = 0;
	
	// Create a temp dot text, in anycase we need to draw ...
	PYRichText *_dotText = [PYRichText textWithString:@"..."];
	_dotText.font = self.font;
	_dotText.textColor = self.textColor;
	_dotText.shadowColor = self.shadowColor;
	_dotText.shadowOffset = self.shadowOffset;
	_dotText.shadowOpacity = self.shadowOpacity;
    _dotText.borderColor = self.borderColor;
    _dotText.borderWidth = self.borderWidth;
	[_dotText setWordSize:_dotSize];
	
	[_linkTexts removeAllObjects];
	
	void (^_drawDot)(CGFloat _l, CGFloat _h, CGFloat _a) =
    ^(CGFloat _l, CGFloat _h, CGFloat _a){
		[self _drawLine:[NSArray arrayWithObject:_dotText]
                topLeft:CGPointMake(_lineSizeLimit - _l, _a + (_h - _dotSize.height) )
             lineHeight:_h inContext:ctx];
	};
    
	// Words array for current line cache.
    NSMutableArray *_wordsArray = [NSMutableArray array];
    
	for ( PYRichText *_word in _wordList ) {
        
        // Check default value.
		if ( _word.font == nil ) _word.font = self.font;
		if ( _word.shadowColor == nil ) _word.shadowColor = self.shadowColor;
		if ( CGSizeEqualToSize(_word.shadowOffset, CGSizeZero) )
            _word.shadowOffset = self.shadowOffset;
		if ( _word.shadowOpacity == 0.f )
            _word.shadowOpacity = self.shadowOpacity;
		
		// Get the word size
		CGSize _wordSize = [_word sizeWithSelfFont];
		
		if ( _wordSize.width < _currentLineLeftSize ) {
			[_word setWordSize:_wordSize];
			[_wordsArray addObject:_word];
			if ( _word.isLink ) [_linkTexts addObject:_word];
			
			// Line Height
            _lineHeight = MAX(_wordSize.height, _lineHeight);
			_currentLineLeftSize -= _wordSize.width;
            
		} else if ( _wordSize.width > _currentLineLeftSize ) {
            // Calculate the fitness sub word
			CGSize _subWordSize = _wordSize;
			PYRichText *_subWord = [_word copy];
			do {
				// Get the line-break point.
				int _lineBreakPoint = [self _checkAndCutTheRichText:_subWord
                                                     toFitLineWidth:_currentLineLeftSize];
                
                // current line cannot draw any char.
				if ( _lineBreakPoint == 0 ) {
					// we need a new line
					[self _drawLine:_wordsArray topLeft:CGPointMake(0, _allLineHeight)
                         lineHeight:_lineHeight inContext:ctx];
                    
					if ( self.multipleLine == NO ) {
						_drawDot(_currentLineLeftSize, _lineHeight, _allLineHeight); return;
					}
                    
                    // Clear current line info
					[_wordsArray removeAllObjects];
					_currentLineLeftSize = _lineSizeLimit;
					_allLineHeight += _lineHeight;
					_lineHeight = 0.f;
					continue;
				}
                
				// New sub-word to the line-break point
				PYRichText *_subRichWord = [_subWord subTextToIndex:_lineBreakPoint];
				CGSize _s = [_subRichWord sizeWithFont:_subRichWord.font];
				[_subRichWord setWordSize:_s];
				_currentLineLeftSize -= _s.width;
				
				// Add to cache
				[_wordsArray addObject:_subRichWord];
				if ( _subRichWord.isLink ) [_linkTexts addObject:_subRichWord];
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
				PYRichText *_leftSubword = [_subWord subTextFromIndex:_lineBreakPoint];
				_subWordSize = [_leftSubword sizeWithFont:_leftSubword.font];
				
				_subWord = [_leftSubword copy];
				[_subWord setWordSize:_subWordSize];
			} while (_subWordSize.width > _currentLineLeftSize );
			
			// Add the last part of the word to new line
			if ( _subWordSize.width == 0 && [_subWord.text length] == 0 ) {
				// Nothing left
				continue;
			}
			[_wordsArray addObject:_subWord];
			if ( _subWord.isLink ) { [_linkTexts addObject:_subWord]; }
			
			_currentLineLeftSize -= _subWordSize.width;
			if ( _lineHeight < _subWordSize.height ) _lineHeight = _subWordSize.height;
			
            // If
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
		} else {
            // Just fit the line width.
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
	for ( PYRichText *linkText in _linkTexts )
	{
		if ( CGRectContainsPoint(linkText.drawingRect, _touchPoint) ) {
			//NSLog(@"click link: %@[%@]", linkText, linkText.address);
			// call the target
			if ( self.linkClickBlock ) self.linkClickBlock(linkText, linkText.drawingRect);
			return;
		}
	}
    
	[super touchesEnded:touches withEvent:event];
}

@end
