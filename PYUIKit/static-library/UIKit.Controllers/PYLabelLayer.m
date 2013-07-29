//
//  PYLabelLayer.m
//  PYUIKit
//
//  Created by Push Chen on 7/29/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import "PYLabelLayer.h"

static UIFont       *_gPYLabelFont = nil;
static UIColor      *_gPYLabelColor = nil;

@implementation PYLabelLayer

+ (void)initialize
{
    _gPYLabelFont = [UIFont systemFontOfSize:14];
    _gPYLabelColor = [UIColor blackColor];
}

@synthesize text = _text;
- (void)setText:(NSString *)text
{
    _text = [text copy];
    if ( self.superlayer ) {
        [self setNeedsDisplay];
    }
}
@synthesize textColor = _textColor;
- (void)setTextColor:(UIColor *)aColor
{
    _textColor = aColor;
    if ( self.superlayer ) {
        [self setNeedsDisplay];
    }
}
@synthesize textFont = _textFont;
- (void)setTextFont:(UIFont *)aFont
{
    _textFont = aFont;
    if ( self.superlayer ) {
        [self setNeedsDisplay];
    }
}
@synthesize textShadowColor = _textShadowColor;
@synthesize textShadowOffset = _textShadowOffset;
@synthesize textShadowRadius = _textShadowRadius;
- (void)setTextShadowColor:(UIColor *)aColor
{
    _textShadowColor = aColor;
    if ( self.superlayer ) {
        [self setNeedsDisplay];
    }
}
- (void)setTextShadowOffset:(CGSize)offset
{
    _textShadowOffset = offset;
    if ( self.superlayer ) {
        [self setNeedsDisplay];
    }
}
- (void)setTextShadowRadius:(CGFloat)radius
{
    _textShadowRadius = radius;
    if ( self.superlayer ) {
        [self setNeedsDisplay];
    }
}
@synthesize textBorderColor = _textBorderColor;
@synthesize textBorderWidth = _textBorderWidth;
- (void)setTextBorderColor:(UIColor *)aColor
{
    _textBorderColor = aColor;
    if ( self.superlayer ) {
        [self setNeedsDisplay];
    }
}
- (void)setTextBorderWidth:(CGFloat)width
{
    _textBorderWidth = width;
    if ( self.superlayer ) {
        [self setNeedsDisplay];
    }
}

@synthesize textAlignment = _textAlignment;
@synthesize lineBreakMode = _lineBreakMode;
@synthesize multipleLine = _multipleLine;
@synthesize paddingLeft = _paddingLeft;
- (void)setTextAlignment:(NSTextAlignment)alignment
{
    _textAlignment = alignment;
    if ( self.superlayer ) {
        [self setNeedsDisplay];
    }
}
- (void)setLineBreakMode:(UILineBreakMode)mode
{
    _lineBreakMode = mode;
    if ( self.superlayer ) {
        [self setNeedsDisplay];
    }
}
- (void)setMultipleLine:(BOOL)multipleLine
{
    _multipleLine = multipleLine;
    if ( self.superlayer ) {
        [self setNeedsDisplay];
    }
}
- (void)setPaddingLeft:(CGFloat)padding
{
    _paddingLeft = padding;
    if ( self.superlayer ) {
        [self setNeedsDisplay];
    }
}

- (void)layerJustBeenCreated
{
    [super layerJustBeenCreated];
    [self setMasksToBounds:YES];
    self.paddingLeft = 0.f;
    self.lineBreakMode = UILineBreakModeTailTruncation;
}

- (void)layerJustBeenCopyed
{
    [super layerJustBeenCopyed];
    [self setMasksToBounds:YES];
    self.paddingLeft = 0.f;
    self.lineBreakMode = UILineBreakModeTailTruncation;
}

// Display
- (void)drawInContext:(CGContextRef)ctx
{
    if ( [_text length] == 0 ) return;
    
    //[self.textColor setFill];
    CGContextSetFillColorWithColor(ctx, _textColor.CGColor);
    if ( _textBorderWidth > 0.f && _textBorderColor != nil ) {
        CGContextSetStrokeColorWithColor(ctx, _textBorderColor.CGColor);
        CGContextSetTextDrawingMode(ctx, kCGTextFillStroke);
    } else {
        CGContextSetTextDrawingMode(ctx, kCGTextFill);
    }
    // Set shadow
    CGContextSetShadowWithColor
    (ctx, _textShadowOffset, _textShadowRadius,
     _textShadowColor.CGColor);
    
    // Calculate the text size.
    if ( _textFont == nil ) _textFont = _gPYLabelFont;
    if ( _textColor == nil ) _textColor = _gPYLabelColor;
    
    CGRect _bounds = self.bounds;
    CGSize _textSize = [_text sizeWithFont:_textFont];
    CGRect _textFrame = _bounds;
    _textFrame.origin.x += _paddingLeft;
    _textFrame.size.width -= _paddingLeft;
    if ( _multipleLine ) {
        _textSize.height = _textSize.height * (((int)_textSize.width / (int)_bounds.size.width) + 1);
        if ( _textSize.height > _bounds.size.height )
            _textSize.height = _bounds.size.height;
    }
    _textFrame.origin.y = (_textFrame.size.height - _textSize.height) / 2;
    _textFrame.size.height = _textSize.height;
    
    UIGraphicsPushContext(ctx);
    [_text drawInRect:_textFrame
             withFont:_textFont
        lineBreakMode:_lineBreakMode
            alignment:_textAlignment];
    UIGraphicsPopContext();
}

@end
