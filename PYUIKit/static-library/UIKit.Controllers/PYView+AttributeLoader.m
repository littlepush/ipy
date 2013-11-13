//
//  PYView+AttributeLoader.m
//  PYUIKit
//
//  Created by Push Chen on 11/13/13.
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

#import "PYView+AttributeLoader.h"
#import "UIView+AttributeLoader.h"

@implementation PYView (AttributeLoader)

+ (void)rendView:(PYView *)view withOption:(NSDictionary *)option
{
    if ( view == nil ) return;
    [super rendView:view withOption:option];
    if ( [view isKindOfClass:[PYView class]] == NO ) return;
    
    NSString *_innerShadowInfo = [option stringObjectForKey:@"innerShadowColor" withDefaultValue:@""];
    if ( [_innerShadowInfo length] > 0 ) {
        UIColor *_innerShadowColor = [UIColor colorWithOptionString:_innerShadowInfo];
        view.innerShadowColor = _innerShadowColor;
    }
    
    NSString *_innerShadowPadding = [option stringObjectForKey:@"innerShadowPadding" withDefaultValue:@""];
    if ( [_innerShadowPadding length] > 0 ) {
        if ( [_innerShadowInfo length] == 0 ) return;
        PYPadding _padding = PYPaddingFromString(_innerShadowPadding);
        view.innerShadowRect = _padding;
    }
}

@end

@implementation PYScrollView (AttributeLoader)

+ (void)rendView:(PYScrollView *)scrollView withOption:(NSDictionary *)option
{
    if ( scrollView == nil ) return;
    [super rendView:scrollView withOption:option];
    // Page info
    // pageSize, isPagable, maxDeceleratePageCount, scrollSide, decelerateSpeed
    if ( [scrollView isKindOfClass:[PYScrollView class]] == NO ) return;
    
    // Page Size
    NSString *_pageSizeInfo = [option stringObjectForKey:@"pageSize" withDefaultValue:@""];
    if ( [_pageSizeInfo length] > 0 ) {
        CGSize _pageSize = CGSizeFromString(_pageSizeInfo);
        scrollView.pageSize = _pageSize;
    }
    
    // isPagable
    scrollView.isPagable = [option boolObjectForKey:@"isPagable"
                                   withDefaultValue:scrollView.isPagable];
    
    // maxDeceleratePageCount
    scrollView.maxDeceleratePageCount = [option intObjectForKey:@"maxDeceleratePageCount"
                                               withDefaultValue:scrollView.maxDeceleratePageCount];
    
    // scrollSide
    //PYScrollDirection
    NSString *_sideInfo = [[option stringObjectForKey:@"scrollSide"
                                     withDefaultValue:@""]
                           lowercaseString];
    if ( [_sideInfo length] > 0 ) {
        if ( [_sideInfo isEqualToString:@"freedom"] ) {
            scrollView.scrollSide = PYScrollFreedom;
        } else if ( [_sideInfo isEqualToString:@"horizontal"] ) {
            scrollView.scrollSide = PYScrollHorizontal;
        } else if ( [_sideInfo isEqualToString:@"verticalis"] ) {
            scrollView.scrollSide = PYScrollVerticalis;
        }
    }
    
    NSString *_decelerateSpeed = [[option stringObjectForKey:@"decelerateSpeed"
                                            withDefaultValue:@""]
                                  lowercaseString];
    if ( [_decelerateSpeed length] > 0 ) {
        if ( [_decelerateSpeed isEqualToString:@"none"] ) {
            scrollView.decelerateSpeed = PYDecelerateSpeedZero;
        } else if ( [_decelerateSpeed isEqualToString:@"very slow"] ) {
            scrollView.decelerateSpeed = PYDecelerateSpeedVerySlow;
        } else if ( [_decelerateSpeed isEqualToString:@"slow"] ) {
            scrollView.decelerateSpeed = PYDecelerateSpeedSlow;
        } else if ( [_decelerateSpeed isEqualToString:@"normal"] ) {
            scrollView.decelerateSpeed = PYDecelerateSpeedNormal;
        } else if ( [_decelerateSpeed isEqualToString:@"fast"] ) {
            scrollView.decelerateSpeed = PYDecelerateSpeedFast;
        } else if ( [_decelerateSpeed isEqualToString:@"very fast"] ) {
            scrollView.decelerateSpeed = PYDecelerateSpeedVeryFast;
        }
    }
}

@end

@implementation PYTableView (AttributeLoader)

+ (void)rendView:(PYTableView *)tableView withOption:(NSDictionary *)option
{
    if ( tableView == nil ) return;
    [super rendView:tableView withOption:option];
    // Loop enable
    
    if ( [tableView isKindOfClass:[PYTableView class]] == NO ) return;
    BOOL _loopEnable = [option boolObjectForKey:@"loop" withDefaultValue:tableView.loopEnabled];
    tableView.loopEnabled = _loopEnable;
}

@end

@implementation PYSlider (AttributeLoader)

+ (void)rendView:(PYSlider *)slider withOption:(NSDictionary *)option
{
    [super rendView:slider withOption:option];
}

@end

@implementation PYSwitcher (AttributeLoader)

+ (void)rendView:(PYSwitcher *)switcher withOption:(NSDictionary *)option
{
    if ( switcher == nil ) return;
    [super rendView:switcher withOption:option];
    // Background Image
    NSString *_backgroundImgInfo = [option stringObjectForKey:@"backgroundImage" withDefaultValue:@""];
    if ( [_backgroundImgInfo length] > 0 ) {
        UIImage *_bkgImage = [PYResource imageNamed:_backgroundImgInfo];
        switcher.backgroundImage = _bkgImage;
    }
    // Button Image
    NSString *_buttonImgInfo = [option stringObjectForKey:@"buttonImage" withDefaultValue:@""];
    if ( [_buttonImgInfo length] > 0 ) {
        UIImage *_btnImage = [PYResource imageNamed:_buttonImgInfo];
        switcher.buttonImage = _btnImage;
    }
    // Left Label
    NSDictionary *_leftLabelInfo = [option objectForKey:@"leftLabel"];
    if ( _leftLabelInfo != nil ) {
        [PYLabelLayer rendLayer:switcher.leftLabel withOption:_leftLabelInfo];
    }
    // Right Label
    NSDictionary *_rightLabelInfo = [option objectForKey:@"rightLabel"];
    if ( _rightLabelInfo != nil ) {
        [PYLabelLayer rendLayer:switcher.rightLabel withOption:_rightLabelInfo];
    }
}

@end

@implementation PYLabelLayer (AttributeLoader)

+ (void)rendLayer:(PYLabelLayer *)labelLayer withOption:(NSDictionary *)option
{
    if ( labelLayer == nil ) return;
    [super rendLayer:labelLayer withOption:option];
    
    if ( [labelLayer isKindOfClass:[PYLabelLayer class]] == NO ) return;

    // Text
    NSString *_text = [option stringObjectForKey:@"text" withDefaultValue:@""];
    if ( [_text length] > 0 ) {
        labelLayer.text = _text;
    }
    labelLayer.textColor = [UIColor colorWithOptionString:
                            [option stringObjectForKey:@"textColor"
                                      withDefaultValue:@"#000000"]];
    
    // Font
    NSDictionary *_fontInfo = [option objectForKey:@"font"];
    if ( _fontInfo != nil ) {
        labelLayer.textFont = [UIFont fontWithOption:_fontInfo];
    }
    
    // Alignment
    NSString *_alignment = [[option stringObjectForKey:@"alignment"
                                      withDefaultValue:@"left"] lowercaseString];
    if ( [_alignment isEqualToString:@"left"] ) {
        labelLayer.textAlignment = NSTextAlignmentLeft;
    } else if ( [_alignment isEqualToString:@"center"] ) {
        labelLayer.textAlignment = NSTextAlignmentCenter;
    } else if ( [_alignment isEqualToString:@"right"] ) {
        labelLayer.textAlignment = NSTextAlignmentRight;
    }
    
    // Breadmode
    NSString *_breakMode = [[option stringObjectForKey:@"breakMode" withDefaultValue:@"none"] lowercaseString];
    if ( [_breakMode isEqualToString:@"head"] ) {
        labelLayer.lineBreakMode = NSLineBreakByTruncatingHead;
    } else if ( [_breakMode isEqualToString:@"middle"] ) {
        labelLayer.lineBreakMode = NSLineBreakByTruncatingMiddle;
    } else if ( [_breakMode isEqualToString:@"tail"] ) {
        labelLayer.lineBreakMode = NSLineBreakByTruncatingTail;
    } else {
        labelLayer.lineBreakMode = NSLineBreakByClipping;
    }
    
    // Shadow info
    NSDictionary *_textShadowInfo = [option objectForKey:@"textShadow"];
    if ( _textShadowInfo != nil ) {
        labelLayer.textShadowOffset = CGSizeFromString([_textShadowInfo stringObjectForKey:@"offset"
                                                                          withDefaultValue:@"{1, 1}"]);
        labelLayer.textShadowColor = [UIColor colorWithOptionString:
                                      [_textShadowInfo stringObjectForKey:@"color"
                                                         withDefaultValue:@"#333333"]];
        labelLayer.textShadowRadius = [_textShadowInfo doubleObjectForKey:@"opacity" withDefaultValue:.7f];
    }
    
    // Text border
    NSDictionary *_textBorderInfo = [option objectForKey:@"textBorder"];
    if ( _textBorderInfo != nil ) {
        float _borderWidth = [_textBorderInfo doubleObjectForKey:@"borderWidth" withDefaultValue:0.5];
        NSString *_borderColorInfo = [_textBorderInfo stringObjectForKey:@"borderColor"
                                                        withDefaultValue:@"#CCCCCC"];
        UIColor *_borderColor = [UIColor colorWithOptionString:_borderColorInfo];
        labelLayer.textBorderWidth = _borderWidth;
        labelLayer.textBorderColor = _borderColor;
    }

    // Padding
    labelLayer.paddingLeft = [option doubleObjectForKey:@"paddingLeft"
                                       withDefaultValue:labelLayer.paddingLeft];
    labelLayer.paddingRight = [option doubleObjectForKey:@"paddingRight"
                                        withDefaultValue:labelLayer.paddingRight];
    
    // Multiple line
    labelLayer.multipleLine = [option boolObjectForKey:@"multipleLine"
                                      withDefaultValue:NO];
}

@end

@implementation PYLabel (AttributeLoader)

+ (void)rendView:(PYLabel *)label withOption:(NSDictionary *)option
{
    if ( label == nil ) return;
    [super rendView:label withOption:option];
    if ( [label isKindOfClass:[PYLabel class]] == NO ) return;
    [PYLabelLayer rendLayer:label.layer withOption:option];
}

@end

@implementation PYImageLayer (AttributeLoader)

+ (void)rendLayer:(PYImageLayer *)imageLayer withOption:(NSDictionary *)option
{
    if ( imageLayer == nil ) return;
    [super rendLayer:imageLayer withOption:option];
    if ( [imageLayer isKindOfClass:[PYImageLayer class]] == NO ) return;
    
    NSString *_placeholdImageInfo = [option stringObjectForKey:@"placehold" withDefaultValue:@""];
    if ( [_placeholdImageInfo length] > 0 ) {
        imageLayer.placeholdImage = [PYResource imageNamed:_placeholdImageInfo];
    }
    
    BOOL _setImageDirectly = NO;
    NSString *_imageInfo = [option stringObjectForKey:@"image" withDefaultValue:@""];
    if ( [_imageInfo length] > 0 ) {
        _setImageDirectly = YES;
        imageLayer.image = [PYResource imageNamed:_imageInfo];
    }
    
    if ( _setImageDirectly == YES ) return;
    NSString *_imageUrl = [option stringObjectForKey:@"imageUrl" withDefaultValue:@""];
    if ( [_imageUrl length] > 0 ) {
        [imageLayer setImageUrl:_imageUrl];
    }
}

@end

@implementation PYImageView (AttributeLoader)

+ (void)rendView:(PYImageView *)imageView withOption:(NSDictionary *)option
{
    if ( imageView == nil ) return;
    [super rendView:imageView withOption:option];
    if ( [imageView isKindOfClass:[PYImageView class]] == NO ) return;
    
    NSString *_placeholdImageInfo = [option stringObjectForKey:@"placehold" withDefaultValue:@""];
    if ( [_placeholdImageInfo length] > 0 ) {
        imageView.placeholdImage = [PYResource imageNamed:_placeholdImageInfo];
    }

    // If has image, return
    if ( [[option stringObjectForKey:@"image" withDefaultValue:@""] length] > 0 ) return;
    NSString *_imageUrl = [option stringObjectForKey:@"imageUrl" withDefaultValue:@""];
    if ( [_imageUrl length] > 0 ) {
        [imageView setImageUrl:_imageUrl];
    }
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
