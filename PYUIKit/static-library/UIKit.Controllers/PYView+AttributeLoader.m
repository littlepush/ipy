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
    if ( slider == nil ) return;
    [super rendView:slider withOption:option];
    if ( [slider isKindOfClass:[PYSlider class]] == NO ) return;
    
    // backgroundImage
    NSString *_bkgImageInfo = [option stringObjectForKey:@"backgroundImage" withDefaultValue:@""];
    if ( [_bkgImageInfo length] > 0 ) {
        UIImage *_bkgImage = [PYResource imageNamed:_bkgImageInfo];
        [slider setBackgroundImage:_bkgImage];
    }
    // slideButtonImage
    NSString *_slideBtnImageInfo = [option stringObjectForKey:@"slideButtonImage" withDefaultValue:@""];
    if ( [_slideBtnImageInfo length] > 0 ) {
        UIImage *_slideBtnImage = [PYResource imageNamed:_slideBtnImageInfo];
        [slider setSlideButtonImage:_slideBtnImage];
    }
    // slideButtonColor
    NSString *_slideBtnColorInfo = [option stringObjectForKey:@"slideButtonColor" withDefaultValue:@""];
    if ( [_slideBtnColorInfo length] > 0 ) {
        UIColor *_slideBtnColor = [UIColor colorWithOptionString:_slideBtnColorInfo];
        [slider setSlideButtonColor:_slideBtnColor];
    }
    // minTrackTintImage
    NSString *_minTrackTintImageInfo = [option stringObjectForKey:@"minTrackTintImage" withDefaultValue:@""];
    if ( [_minTrackTintImageInfo length] > 0 ) {
        UIImage *_minTrackTintImage = [PYResource imageNamed:_minTrackTintImageInfo];
        [slider setMinTrackTintImage:_minTrackTintImage];
    }
    // minTrackTintColor
    NSString *_minTrackTintColorInfo = [option stringObjectForKey:@"minTrackTintColor" withDefaultValue:@""];
    if ( [_minTrackTintColorInfo length] > 0 ) {
        UIColor *_minTrackTintColor = [UIColor colorWithOptionString:_minTrackTintColorInfo];
        [slider setMinTrackTintColor:_minTrackTintColor];
    }
    // minimum
    slider.minimum = [option doubleObjectForKey:@"minimum" withDefaultValue:slider.minimum];
    // maximum
    slider.maximum = [option doubleObjectForKey:@"maximum" withDefaultValue:slider.maximum];
    // hideSlideButton
    slider.hideSlideButton = [option boolObjectForKey:@"hideSlideButton"
                                     withDefaultValue:slider.hideSlideButton];
    // slideDirection
    NSString *_slideDirection = [option stringObjectForKey:@"slideDirection" withDefaultValue:@""];
    if ( [_slideDirection length] > 0 ) {
        if ( [_slideDirection isEqualToString:@"horizontal"] ) {
            slider.slideDirection = PYSliderDirectionHorizontal;
        } else if ( [_slideDirection isEqualToString:@"verticalis"] ) {
            slider.slideDirection = PYSliderDirectionVerticalis;
        }
    }
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
    CGFloat _paddingLeft = [option doubleObjectForKey:@"paddingLeft" withDefaultValue:NAN];
    if ( !isnan(_paddingLeft) ) {
        labelLayer.paddingLeft = _paddingLeft;
    }
    CGFloat _paddingRight = [option doubleObjectForKey:@"paddingRight" withDefaultValue:NAN];
    if ( !isnan(_paddingRight) ) {
        labelLayer.paddingRight = _paddingRight;
    }
    
    // Multiple line
    labelLayer.multipleLine = [option boolObjectForKey:@"multipleLine"
                                      withDefaultValue:labelLayer.multipleLine];
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

@implementation PYGridItem (AttributeLoader)

+ (void)rendView:(PYGridItem *)itemView withOption:(NSDictionary *)option
{
    static NSString *_buttonStateString[] = {
        @"normal", @"highlighted", @"selected", @"disable"};
    static UIControlState _buttonState[] = {
        UIControlStateNormal, UIControlStateHighlighted,
        UIControlStateSelected, UIControlStateDisabled
    };

    if ( itemView == nil ) return;
    [super rendView:itemView withOption:option];
    if ( [itemView isKindOfClass:[PYGridItem class]] == NO ) return;
    
    // For Grid Item Options...
    // Collapse Rate
    CGFloat _collapseRate = [option doubleObjectForKey:@"collapseRate" withDefaultValue:NAN];
    if ( !isnan(_collapseRate) ) {
        [itemView setCollapseRate:_collapseRate];
    }
    
    // Collapse Direction
    NSString *_collapseDirection = [option stringObjectForKey:@"collapseDirection" withDefaultValue:@""];
    if ( [_collapseDirection length] > 0 ) {
        if ( [_collapseDirection isEqualToString:@"horizontal"] ) {
            itemView.collapseDirection = PYGridItemCollapseDirectionHorizontal;
        } else {
            itemView.collapseDirection = PYGridItemCollapseDirectionVerticalis;
        }
    }
    
    // Collapse Info
    NSDictionary *_collapseViewInfo = [option objectForKey:@"collapseView"];
    if ( _collapseViewInfo != nil ) {
        [PYView rendView:itemView.collapseView withOption:_collapseViewInfo];
    }
    
    for ( int i = 0; i < 4; ++i ) {
        NSDictionary *_stateOption = [option objectForKey:_buttonStateString[i]];
        if ( _stateOption == nil ) continue;
        UIControlState _state = _buttonState[i];

        // Background Color
        NSString *_backgroundColor = [_stateOption stringObjectForKey:@"backgroundColor"
                                                     withDefaultValue:@""];
        if ( [_backgroundColor length] > 0 ) {
            UIColor *_bkgColor = [UIColor colorWithOptionString:_backgroundColor reverseOnVerticalis:YES];
            [itemView setBackgroundColor:_bkgColor forState:_state];
        }
        
        // Background Image
        NSString *_backgrondImage = [_stateOption stringObjectForKey:@"backgroundImage"
                                                    withDefaultValue:@""];
        if ( [_backgrondImage length] > 0 ) {
            UIImage *_bkgImage = [PYResource imageNamed:_backgrondImage];
            [itemView setBackgroundImage:_bkgImage forState:_state];
        }
        
        // Border Width
        CGFloat _borderWidth = [_stateOption doubleObjectForKey:@"borderWidth" withDefaultValue:NAN];
        if ( !isnan(_borderWidth) ) {
            [itemView setBorderWidth:_borderWidth forState:_state];
        }
        
        // Border Color
        NSString *_borderColorInfo = [_stateOption stringObjectForKey:@"borderColor" withDefaultValue:@""];
        if ( [_borderColorInfo length] > 0 ) {
            UIColor *_borderColor = [UIColor colorWithOptionString:_borderColorInfo];
            [itemView setBorderColor:_borderColor forState:_state];
        }
        
        // Shadow
        NSDictionary *_shadowInfo = [_stateOption objectForKey:@"shadow"];
        if ( _shadowInfo != nil ) {
            // Shadow Offset
            NSString *_shadowOffsetInfo = [_shadowInfo stringObjectForKey:@"shadowOffset" withDefaultValue:@""];
            if ( [_shadowOffsetInfo length] > 0 ) {
                CGSize _shadowOffset = CGSizeFromString(_shadowOffsetInfo);
                [itemView setShadowOffset:_shadowOffset forState:_state];
            }
            
            // Shadow Color
            NSString *_shadowColorInfo = [_shadowInfo stringObjectForKey:@"shadowColor" withDefaultValue:@""];
            if ( [_shadowColorInfo length] > 0 ) {
                UIColor *_shadowColor = [UIColor colorWithOptionString:_shadowColorInfo];
                [itemView setShadowColor:_shadowColor forState:_state];
            }
            
            // Shadow Opacity
            CGFloat _shadowOpacity = [_shadowInfo doubleObjectForKey:@"shadowOpacity" withDefaultValue:NAN];
            if ( !isnan(_shadowOpacity) ) {
                [itemView setShadowOpacity:_shadowOpacity forState:_state];
            }
            
            // Shadow Radius
            CGFloat _shadowRadius = [_shadowInfo doubleObjectForKey:@"shadowRadius" withDefaultValue:NAN];
            if ( !isnan(_shadowRadius) ) {
                [itemView setShadowRadius:_shadowRadius forState:_state];
            }
        }
        
        // Title
        NSString *_title = [_stateOption stringObjectForKey:@"title" withDefaultValue:@""];
        if ( [_title length] > 0 ) {
            [itemView setTitle:_title forState:_state];
        }
        
        // Text Color
        NSString *_textColorInfo = [_stateOption stringObjectForKey:@"textColor" withDefaultValue:@""];
        if ( [_textColorInfo length] > 0 ) {
            UIColor *_textColor = [UIColor colorWithOptionString:_textColorInfo];
            [itemView setTextColor:_textColor forState:_state];
        }
        
        // Text Font
        NSDictionary *_textFontInfo = [_stateOption objectForKey:@"font"];
        if ( _textFontInfo != nil ) {
            UIFont *_textFont = [UIFont fontWithOption:_textFontInfo];
            [itemView setTextFont:_textFont forState:_state];
        }
        
        // Text Shadow
        NSDictionary *_textShadowInfo = [option objectForKey:@"textShadow"];
        if ( _textShadowInfo != nil ) {
            // Shadow Offset
            NSString *_textShadowOffsetInfo = [_textShadowInfo stringObjectForKey:@"shadowOffset"
                                                                 withDefaultValue:@""];
            if ( [_textShadowOffsetInfo length] > 0 ) {
                CGSize _shadowOffset = CGSizeFromString(_textShadowOffsetInfo);
                [itemView setTextShadowOffset:_shadowOffset forState:_state];
            }
            
            // Shadow Color
            NSString *_textShadowColorInfo = [_textShadowInfo stringObjectForKey:@"shadowColor"
                                                                withDefaultValue:@""];
            if ( [_textShadowColorInfo length] > 0 ) {
                UIColor *_shadowColor = [UIColor colorWithOptionString:_textShadowColorInfo];
                [itemView setTextShadowColor:_shadowColor forState:_state];
            }
            
            // Shadow Radius
            CGFloat _textShadowRadius = [_textShadowInfo doubleObjectForKey:@"shadowRadius"
                                                           withDefaultValue:NAN];
            if ( !isnan(_textShadowRadius) ) {
                [itemView setTextShadowRadius:_textShadowRadius forState:_state];
            }
        }
        
        // Icon
        NSString *_iconImageInfo = [_stateOption stringObjectForKey:@"icon" withDefaultValue:@""];
        if ( [_iconImageInfo length] > 0 ) {
            UIImage *_iconImage = [PYResource imageNamed:_iconImageInfo];
            [itemView setIconImage:_iconImage forState:_state];
        }
        
        // Indicate
        NSString *_indicateInfo = [_stateOption stringObjectForKey:@"indicate" withDefaultValue:@""];
        if ( [_indicateInfo length] > 0 ) {
            UIImage *_indicateImage = [PYResource imageNamed:_indicateInfo];
            [itemView setIndicateImage:_indicateImage forState:_state];
        }
        
        // InnerShadow - Color
        NSString *_innerShadowColorInfo = [_stateOption stringObjectForKey:@"innerShadowColor"
                                                          withDefaultValue:@""];
        if ( [_innerShadowColorInfo length] > 0 ) {
            UIColor *_innerShadowColor = [UIColor colorWithOptionString:_innerShadowColorInfo];
            [itemView setInnerShadowColor:_innerShadowColor forState:_state];
        }
        
        // InnerShadow - Padding
        NSString *_innerShadowPaddingInfo = [_stateOption stringObjectForKey:@"innerShadowPadding"
                                                            withDefaultValue:@""];
        if ( [_innerShadowPaddingInfo length] > 0 ) {
            PYPadding _innerShadowPadding = PYPaddingFromString(_innerShadowPaddingInfo);
            [itemView setInnerShadowRect:_innerShadowPadding forState:_state];
        }
    }
}

@end

@implementation PYGridView (AttributeLoader)

+ (void)rendView:(PYGridView *)gridView withOption:(NSDictionary *)option
{
    static NSString *_buttonStateString[] = {
        @"normal", @"highlighted", @"selected", @"disable"};
    static UIControlState _buttonState[] = {
        UIControlStateNormal, UIControlStateHighlighted,
        UIControlStateSelected, UIControlStateDisabled
    };
    
    if ( gridView == nil ) return;
    [super rendView:gridView withOption:option];
    if ( [gridView isKindOfClass:[PYGridView class]] == NO ) return;

    // Grid Scale
    NSString *_gridScale = [option stringObjectForKey:@"gridScale" withDefaultValue:@""];
    if ( [_gridScale length] > 0 ) {
        CGSize _scale = CGSizeFromString(_gridScale);
        PYGridScale _gScale = (PYGridScale){(int32_t)_scale.width, (int32_t)_scale.height};
        [gridView initGridViewWithScale:_gScale];
    }
    
    // Support Touch Moving
    BOOL _supportTouchMoving = [option boolObjectForKey:@"supportTouchMoving"
                                       withDefaultValue:gridView.supportTouchMoving];
    [gridView setSupportTouchMoving:_supportTouchMoving];
    
    // Padding
    CGFloat _padding = [option doubleObjectForKey:@"padding" withDefaultValue:NAN];
    if ( !isnan(_padding) ) {
        [gridView setPadding:_padding];
    }
    
    // Merge Info
    NSArray *_mergeInfo = [option objectForKey:@"merge"];
    if ( _mergeInfo != nil ) {
        for ( NSDictionary *_mergeItem in _mergeInfo ) {
            if ( [_mergeItem isKindOfClass:[NSDictionary class]] == NO ) continue;
            NSString *_from = [_mergeItem stringObjectForKey:@"from" withDefaultValue:@""];
            if ( [_from length] == 0 ) continue;
            NSString *_to = [_mergeItem stringObjectForKey:@"to" withDefaultValue:@""];
            if ( [_to length] == 0 ) continue;
            
            CGPoint _pFrom = CGPointFromString(_from);
            CGPoint _pTo = CGPointFromString(_to);
            PYGridCoordinate _gFrom = {(int32_t)_pFrom.x, (int32_t)_pFrom.y};
            PYGridCoordinate _gTo = {(int32_t)_pTo.x, (int32_t)_pTo.y};
            [gridView mergeGridItemFrom:_gFrom to:_gTo];
        }
    }
    
    // Item style
    NSString *_itemStyle = [option stringObjectForKey:@"itemStyle" withDefaultValue:@""];
    if ( [_itemStyle length] > 0 ) {
        if ( [_itemStyle isEqualToString:@"title-only"] ) {
            [gridView setItemStyle:PYGridItemStyleTitleOnly];
        } else if ( [_itemStyle isEqualToString:@"icon-only"] ) {
            [gridView setItemStyle:PYGridItemStyleIconOnly];
        } else if ( [_itemStyle isEqualToString:@"icon-title-horizontal"] ) {
            [gridView setItemStyle:PYGridItemStyleIconTitleHorizontal];
        } else if ( [_itemStyle isEqualToString:@"icon-title-verticalis"] ) {
            [gridView setItemStyle:PYGridItemStyleIconTitleVerticalis];
        } else if ( [_itemStyle isEqualToString:@"icon-title-indicate"] ) {
            [gridView setItemStyle:PYGridItemStyleIconTitleIndicate];
        }
    }
    
    // Item corner radius
    CGFloat _itemCornerRadius = [option doubleObjectForKey:@"itemCornerRadius" withDefaultValue:NAN];
    if ( !isnan(_itemCornerRadius) ) {
        [gridView setItemCornerRadius:_itemCornerRadius];
    }
    
    // Item status
    for ( int i = 0; i < 4; ++i ) {
        NSDictionary *_stateOption = [option objectForKey:_buttonStateString[i]];
        if ( _stateOption == nil ) continue;
        UIControlState _state = _buttonState[i];
        
        // Background Color
        NSString *_backgroundColor = [_stateOption stringObjectForKey:@"backgroundColor"
                                                     withDefaultValue:@""];
        if ( [_backgroundColor length] > 0 ) {
            UIColor *_bkgColor = [UIColor colorWithOptionString:_backgroundColor reverseOnVerticalis:YES];
            [gridView setItemBackgroundColor:_bkgColor forState:_state];
        }
        
        // Background Image
        NSString *_backgrondImage = [_stateOption stringObjectForKey:@"backgroundImage"
                                                    withDefaultValue:@""];
        if ( [_backgrondImage length] > 0 ) {
            UIImage *_bkgImage = [PYResource imageNamed:_backgrondImage];
            [gridView setItemBackgroundImage:_bkgImage forState:_state];
        }
        
        // Border Width
        CGFloat _borderWidth = [_stateOption doubleObjectForKey:@"borderWidth" withDefaultValue:NAN];
        if ( !isnan(_borderWidth) ) {
            [gridView setItemBorderWidth:_borderWidth forState:_state];
        }
        
        // Border Color
        NSString *_borderColorInfo = [_stateOption stringObjectForKey:@"borderColor" withDefaultValue:@""];
        if ( [_borderColorInfo length] > 0 ) {
            UIColor *_borderColor = [UIColor colorWithOptionString:_borderColorInfo];
            [gridView setItemBorderColor:_borderColor forState:_state];
        }
        
        // Shadow
        NSDictionary *_shadowInfo = [_stateOption objectForKey:@"shadow"];
        if ( _shadowInfo != nil ) {
            // Shadow Offset
            NSString *_shadowOffsetInfo = [_shadowInfo stringObjectForKey:@"shadowOffset" withDefaultValue:@""];
            if ( [_shadowOffsetInfo length] > 0 ) {
                CGSize _shadowOffset = CGSizeFromString(_shadowOffsetInfo);
                [gridView setItemShadowOffset:_shadowOffset forState:_state];
            }
            
            // Shadow Color
            NSString *_shadowColorInfo = [_shadowInfo stringObjectForKey:@"shadowColor" withDefaultValue:@""];
            if ( [_shadowColorInfo length] > 0 ) {
                UIColor *_shadowColor = [UIColor colorWithOptionString:_shadowColorInfo];
                [gridView setItemShadowColor:_shadowColor forState:_state];
            }
            
            // Shadow Opacity
            CGFloat _shadowOpacity = [_shadowInfo doubleObjectForKey:@"shadowOpacity" withDefaultValue:NAN];
            if ( !isnan(_shadowOpacity) ) {
                [gridView setItemShadowOpacity:_shadowOpacity forState:_state];
            }
            
            // Shadow Radius
            CGFloat _shadowRadius = [_shadowInfo doubleObjectForKey:@"shadowRadius" withDefaultValue:NAN];
            if ( !isnan(_shadowRadius) ) {
                [gridView setItemShadowRadius:_shadowRadius forState:_state];
            }
        }
        
        // Title
        NSString *_title = [_stateOption stringObjectForKey:@"title" withDefaultValue:@""];
        if ( [_title length] > 0 ) {
            [gridView setItemTitle:_title forState:_state];
        }
        
        // Text Color
        NSString *_textColorInfo = [_stateOption stringObjectForKey:@"textColor" withDefaultValue:@""];
        if ( [_textColorInfo length] > 0 ) {
            UIColor *_textColor = [UIColor colorWithOptionString:_textColorInfo];
            [gridView setItemTextColor:_textColor forState:_state];
        }
        
        // Text Font
        NSDictionary *_textFontInfo = [_stateOption objectForKey:@"font"];
        if ( _textFontInfo != nil ) {
            UIFont *_textFont = [UIFont fontWithOption:_textFontInfo];
            [gridView setItemTextFont:_textFont forState:_state];
        }
        
        // Text Shadow
        NSDictionary *_textShadowInfo = [option objectForKey:@"textShadow"];
        if ( _textShadowInfo != nil ) {
            // Shadow Offset
            NSString *_textShadowOffsetInfo = [_textShadowInfo stringObjectForKey:@"shadowOffset"
                                                                 withDefaultValue:@""];
            if ( [_textShadowOffsetInfo length] > 0 ) {
                CGSize _shadowOffset = CGSizeFromString(_textShadowOffsetInfo);
                [gridView setItemTextShadowOffset:_shadowOffset forState:_state];
            }
            
            // Shadow Color
            NSString *_textShadowColorInfo = [_textShadowInfo stringObjectForKey:@"shadowColor"
                                                                withDefaultValue:@""];
            if ( [_textShadowColorInfo length] > 0 ) {
                UIColor *_shadowColor = [UIColor colorWithOptionString:_textShadowColorInfo];
                [gridView setItemTextShadowColor:_shadowColor forState:_state];
            }
            
            // Shadow Radius
            CGFloat _textShadowRadius = [_textShadowInfo doubleObjectForKey:@"shadowRadius"
                                                           withDefaultValue:NAN];
            if ( !isnan(_textShadowRadius) ) {
                [gridView setItemTextShadowRadius:_textShadowRadius forState:_state];
            }
        }
        
        // Icon
        NSString *_iconImageInfo = [_stateOption stringObjectForKey:@"icon" withDefaultValue:@""];
        if ( [_iconImageInfo length] > 0 ) {
            UIImage *_iconImage = [PYResource imageNamed:_iconImageInfo];
            [gridView setItemIconImage:_iconImage forState:_state];
        }
        
        // Indicate
        NSString *_indicateInfo = [_stateOption stringObjectForKey:@"indicate" withDefaultValue:@""];
        if ( [_indicateInfo length] > 0 ) {
            UIImage *_indicateImage = [PYResource imageNamed:_indicateInfo];
            [gridView setItemIndicateImage:_indicateImage forState:_state];
        }
        
        // InnerShadow - Color
        NSString *_innerShadowColorInfo = [_stateOption stringObjectForKey:@"innerShadowColor"
                                                          withDefaultValue:@""];
        if ( [_innerShadowColorInfo length] > 0 ) {
            UIColor *_innerShadowColor = [UIColor colorWithOptionString:_innerShadowColorInfo];
            [gridView setItemInnerShadowColor:_innerShadowColor forState:_state];
        }
        
        // InnerShadow - Padding
        NSString *_innerShadowPaddingInfo = [_stateOption stringObjectForKey:@"innerShadowPadding"
                                                            withDefaultValue:@""];
        if ( [_innerShadowPaddingInfo length] > 0 ) {
            PYPadding _innerShadowPadding = PYPaddingFromString(_innerShadowPaddingInfo);
            [gridView setItemInnerShadowRect:_innerShadowPadding forState:_state];
        }
    }
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
