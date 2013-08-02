//
//  PYLabelLayer.h
//  PYUIKit
//
//  Created by Push Chen on 7/29/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import "PYStaticLayer.h"

@interface PYLabelLayer : PYStaticLayer
{
    NSString                                        *_text;
    UIColor                                         *_textColor;
    UIFont                                          *_textFont;
    CGSize                                          _textShadowOffset;
    UIColor                                         *_textShadowColor;
    CGFloat                                         _textShadowRadius;
    CGFloat                                         _textBorderWidth;
    UIColor                                         *_textBorderColor;
    
    BOOL                                            _multipleLine;
    NSTextAlignment                                 _textAlignment;
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
    NSLineBreakMode                                 _lineBreakMode;
#else
    UILineBreakMode                                 _lineBreakMode;
#endif
    CGFloat                                         _paddingLeft;
}

// Properties like UILabel.
// But all this things will be used to draw text directly in layer.
@property (nonatomic, copy)     NSString            *text;
@property (nonatomic, strong)   UIColor             *textColor;
@property (nonatomic, strong)   UIFont              *textFont;
@property (nonatomic, assign)   CGSize              textShadowOffset;
@property (nonatomic, strong)   UIColor             *textShadowColor;
@property (nonatomic, assign)   CGFloat             textShadowRadius;
@property (nonatomic, assign)   CGFloat             textBorderWidth;
@property (nonatomic, strong)   UIColor             *textBorderColor;

@property (nonatomic, assign)   BOOL                multipleLine;
@property (nonatomic, assign)   NSTextAlignment     textAlignment;

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
@property (nonatomic, assign)   NSLineBreakMode     lineBreakMode;
#else
@property (nonatomic, assign)   UILineBreakMode     lineBreakMode;
#endif

// Padding the left side.
@property (nonatomic, assign)   CGFloat             paddingLeft;

@end
