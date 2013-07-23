//
//  PYLabelLayer.m
//  PYRadio
//
//  Created by Push Chen on 3/19/13.
//  Copyright (c) 2013 Markphone Culture Media Co.Ltd. All rights reserved.
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

@synthesize text;
@synthesize textColor, textFont;
@synthesize textShadowColor, textShadowOffset, textShadowRadius;
@synthesize textBorderColor, textBorderWidth;
@synthesize textAlignment, lineBreakMode, multipleLine;
@synthesize paddingLeft;

- (id)init
{
    self = [super init];
    if ( self ) {
        self.contentsScale = [UIScreen mainScreen].scale;
        self.paddingLeft = 0.f;
        self.lineBreakMode = UILineBreakModeTailTruncation;
    }
    return self;
}
- (id)initWithLayer:(id)layer
{
    self = [super initWithLayer:layer];
    if ( self ) {
        self.contentsScale = [UIScreen mainScreen].scale;
        self.paddingLeft = 0.f;
        self.lineBreakMode = UILineBreakModeTailTruncation;
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self ) {
        self.contentsScale = [UIScreen mainScreen].scale;
        self.paddingLeft = 0.f;
        self.lineBreakMode = UILineBreakModeTailTruncation;
    }
    return self;
}

- (void)drawInContext:(CGContextRef)ctx
{
    if ( [self.text length] == 0 ) return;
    
    //[self.textColor setFill];
    CGContextSetFillColorWithColor(ctx, self.textColor.CGColor);
    if ( self.textBorderWidth > 0.f && self.textBorderColor != nil ) {
        CGContextSetStrokeColorWithColor(ctx, self.textBorderColor.CGColor);
        CGContextSetTextDrawingMode(ctx, kCGTextFillStroke);
    } else {
        CGContextSetTextDrawingMode(ctx, kCGTextFill);
    }
    // Set shadow
    CGContextSetShadowWithColor
        (ctx, self.textShadowOffset, self.textShadowRadius,
         self.textShadowColor.CGColor);
    
    // Calculate the text size.
    if ( self.textFont == nil ) self.textFont = _gPYLabelFont;
    if ( self.textColor == nil ) self.textColor = _gPYLabelColor;
    
    CGSize _textSize = [self.text sizeWithFont:self.textFont];
    CGRect _textFrame = self.bounds;
    _textFrame.origin.x += self.paddingLeft;
    _textFrame.size.width -= self.paddingLeft;
    if ( self.multipleLine ) {
        _textSize.height = _textSize.height * (((int)_textSize.width / (int)self.bounds.size.width) + 1);
        if ( _textSize.height > self.bounds.size.height )
            _textSize.height = self.bounds.size.height;
    }
    _textFrame.origin.y = (_textFrame.size.height - _textSize.height) / 2;
    _textFrame.size.height = _textSize.height;
    
    UIGraphicsPushContext(ctx);
    [self.text drawInRect:_textFrame
                 withFont:self.textFont
            lineBreakMode:lineBreakMode
                alignment:textAlignment];
}

@end
