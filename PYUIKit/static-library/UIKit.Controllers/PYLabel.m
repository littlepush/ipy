//
//  PYLabel.m
//  PYUIKit
//
//  Created by Push Chen on 7/30/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import "PYLabel.h"

@implementation PYLabel

+ (Class)layerClass
{
    return [PYLabelLayer class];
}

// Properties...
@dynamic layer;
- (PYLabelLayer *)layer
{
    return (PYLabelLayer *)[super layer];
}

@dynamic text;
- (NSString *)text
{
    return self.layer.text;
}
- (void)setText:(NSString *)text
{
    self.layer.text = text;
}

@dynamic textColor;
- (UIColor *)textColor
{
    return self.layer.textColor;
}
- (void)setTextColor:(UIColor *)textColor
{
    self.layer.textColor = textColor;
}

@dynamic textFont;
- (UIFont *)textFont
{
    return self.layer.textFont;
}
- (void)setTextFont:(UIFont *)textFont
{
    self.layer.textFont = textFont;
}

@dynamic textShadowOffset;
- (CGSize)textShadowOffset
{
    return self.layer.textShadowOffset;
}
- (void)setTextShadowOffset:(CGSize)textShadowOffset
{
    self.layer.textShadowOffset = textShadowOffset;
}

@dynamic textShadowColor;
- (UIColor *)textShadowColor
{
    return self.layer.textShadowColor;
}
- (void)setTextShadowColor:(UIColor *)textShadowColor
{
    self.layer.textShadowColor = textShadowColor;
}

@dynamic textShadowRadius;
- (CGFloat)textShadowRadius
{
    return self.layer.textShadowRadius;
}
- (void)setTextShadowRadius:(CGFloat)textShadowRadius
{
    self.layer.textShadowRadius = textShadowRadius;
}

@dynamic textBorderWidth;
- (CGFloat)textBorderWidth
{
    return self.layer.textBorderWidth;
}
- (void)setTextBorderWidth:(CGFloat)textBorderWidth
{
    self.layer.textBorderWidth = textBorderWidth;
}

@dynamic textBorderColor;
- (UIColor *)textBorderColor
{
    return self.layer.textBorderColor;
}
- (void)setTextBorderColor:(UIColor *)textBorderColor
{
    self.layer.textBorderColor = textBorderColor;
}

@dynamic multipleLine;
- (BOOL)multipleLine
{
    return self.layer.multipleLine;
}
- (void)setMultipleLine:(BOOL)multipleLine
{
    self.layer.multipleLine = multipleLine;
}

@dynamic textAlignment;
- (NSTextAlignment)textAlignment
{
    return self.layer.textAlignment;
}
- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    self.layer.textAlignment = textAlignment;
}

@dynamic lineBreakMode;
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
- (NSLineBreakMode)lineBreakMode
#else
- (UILineBreakMode)lineBreakMode
#endif
{
    return self.layer.lineBreakMode;
}
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode
#else
- (void)setLineBreakMode:(UILineBreakMode)lineBreakMode
#endif
{
    self.layer.lineBreakMode = lineBreakMode;
}

@dynamic paddingLeft;
- (CGFloat)paddingLeft
{
    return self.layer.paddingLeft;
}
- (void)setPaddingLeft:(CGFloat)paddingLeft
{
    self.layer.paddingLeft = paddingLeft;
}

@end
