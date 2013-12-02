//
//  UIView+AttributeLoader.m
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

#import "UIView+AttributeLoader.h"
#import "UIColor+PYUIKit.h"
#import "PYResource.h"

@implementation UIFont (AttributeLoader)

+ (UIFont *)fontWithOption:(NSDictionary *)option
{
    NSString *_fontFmailyName = [option stringObjectForKey:@"name" withDefaultValue:@""];
    BOOL _isBold = [option boolObjectForKey:@"bold" withDefaultValue:NO];
    int _fontSize = [option intObjectForKey:@"size" withDefaultValue:11];
    UIFont *_font = nil;
    if ( [_fontFmailyName length] == 0 ) {
        // Use system font
        if ( _isBold ) {
            _font = [UIFont boldSystemFontOfSize:_fontSize];
        } else {
            _font = [UIFont systemFontOfSize:_fontSize];
        }
    } else {
        NSArray *_fontFamily = [UIFont fontNamesForFamilyName:_fontFmailyName];
        NSString *_fontName = [_fontFamily safeObjectAtIndex:0];
        if ( _isBold ) {
            for ( NSString *_fn in _fontFamily ) {
                NSString *_lowcaseFn = [_fn lowercaseString];
                NSRange _searchResult = [_lowcaseFn rangeOfString:@"bold"];
                if ( _searchResult.location == NSNotFound ) continue;
                _fontName = [_fn copy];
            }
        }
        _font = [UIFont fontWithName:_fontName size:_fontSize];
    }
    return _font;
}

@end

@implementation UIView (AttributeLoader)

+ (void)rendView:(UIView *)view withOption:(NSDictionary *)option
{
    if ( view == nil ) return;

    // UI Attribute in deep is all CALayer's job...
    [CALayer rendLayer:view.layer withOption:option];
    
    BOOL _clipToBounds = [option boolObjectForKey:@"clipToBounds"
                                 withDefaultValue:view.clipsToBounds];
    [view setClipsToBounds:_clipToBounds];
}

@end

@implementation CALayer (AttributeLoader)

+ (void)rendLayer:(CALayer *)layer withOption:(NSDictionary *)option
{
    if ( layer == nil ) return;
    // Load frame
    NSString *_frameInfo = [option stringObjectForKey:@"frame" withDefaultValue:@""];
    if ( [_frameInfo length] > 0 ) {
        CGRect _frame = CGRectFromString(_frameInfo);
        [layer setFrame:_frame];
    }
    
    // Load background color
    NSString *_bkgColorInfo = [option stringObjectForKey:@"backgroundColor" withDefaultValue:@""];
    if ( [_bkgColorInfo length] != 0 ) {
        UIColor *_bkgColor = [UIColor colorWithOptionString:_bkgColorInfo reverseOnVerticalis:YES];
        // core rotate fuction
        [layer setBackgroundColor:_bkgColor.CGColor];
    }
    
    // Load border
    NSDictionary *_borderInfo = [option objectForKey:@"border"];
    if ( _borderInfo != nil ) {
        float _borderWidth = [_borderInfo doubleObjectForKey:@"borderWidth" withDefaultValue:0.5];
        NSString *_borderColorInfo = [_borderInfo stringObjectForKey:@"borderColor"
                                                    withDefaultValue:@"#CCCCCC"];
        UIColor *_borderColor = [UIColor colorWithOptionString:_borderColorInfo];
        layer.borderWidth = _borderWidth;
        layer.borderColor = _borderColor.CGColor;
    }
    
    // Load corner radius
    float _cornerRadius = [option doubleObjectForKey:@"cornerRadius" withDefaultValue:0.f];
    layer.cornerRadius = _cornerRadius;
    
    // Load shadow
    NSDictionary *_shadowInfo = [option objectForKey:@"shadow"];
    if ( _shadowInfo != nil ) {
        BOOL _disablePath = [_shadowInfo boolObjectForKey:@"disable-path" withDefaultValue:NO];
        if ( _disablePath == NO ) {
            layer.shadowPath = [UIBezierPath
                                bezierPathWithRoundedRect:layer.bounds
                                cornerRadius:layer.cornerRadius].CGPath;
        }
        layer.shadowOffset = CGSizeFromString([_shadowInfo stringObjectForKey:@"offset"
                                                             withDefaultValue:@"{1, 1}"]);
        layer.shadowColor = [UIColor colorWithOptionString:
                             [_shadowInfo stringObjectForKey:@"color"
                                            withDefaultValue:@"#333333"]].CGColor;
        layer.shadowOpacity = [_shadowInfo doubleObjectForKey:@"opacity" withDefaultValue:.7f];
        layer.shadowRadius = [_shadowInfo doubleObjectForKey:@"radius" withDefaultValue:3.f];
    }
}

@end

@implementation UILabel (AttributeLoader)

+ (void)rendView:(UILabel *)label withOption:(NSDictionary *)option;
{
    if ( label == nil ) return;
    [super rendView:label withOption:option];
    if ( [label isKindOfClass:[UILabel class]] == NO ) return;
    
    NSString *_text = [option stringObjectForKey:@"text" withDefaultValue:@""];
    if ( [_text length] > 0 ) {
        label.text = _text;
    }
    label.textColor = [UIColor colorWithOptionString:
                       [option stringObjectForKey:@"textColor"
                                 withDefaultValue:@"#000000"]];
    NSDictionary *_fontInfo = [option objectForKey:@"font"];
    if ( _fontInfo != nil ) {
        label.font = [UIFont fontWithOption:_fontInfo];
    }
    
    NSString *_alignment = [[option stringObjectForKey:@"alignment" withDefaultValue:@"left"] lowercaseString];
    if ( [_alignment isEqualToString:@"left"] ) {
        label.textAlignment = NSTextAlignmentLeft;
    } else if ( [_alignment isEqualToString:@"center"] ) {
        label.textAlignment = NSTextAlignmentCenter;
    } else if ( [_alignment isEqualToString:@"right"] ) {
        label.textAlignment = NSTextAlignmentRight;
    }
    
    NSString *_breakMode = [[option stringObjectForKey:@"breakMode" withDefaultValue:@"none"] lowercaseString];
    if ( [_breakMode isEqualToString:@"head"] ) {
        label.lineBreakMode = NSLineBreakByTruncatingHead;
    } else if ( [_breakMode isEqualToString:@"middle"] ) {
        label.lineBreakMode = NSLineBreakByTruncatingMiddle;
    } else if ( [_breakMode isEqualToString:@"tail"] ) {
        label.lineBreakMode = NSLineBreakByTruncatingTail;
    } else {
        label.lineBreakMode = NSLineBreakByClipping;
    }
}

@end

@implementation UIButton (AttributeLoader)

+ (void)rendView:(UIButton *)button withOption:(NSDictionary *)option
{
    static NSString *_buttonStateString[] = {@"normal", @"highlighted", @"selected", @"disable"};
    static UIControlState _buttonState[] = {
        UIControlStateNormal, UIControlStateHighlighted,
        UIControlStateSelected, UIControlStateDisabled
    };
    
    if ( button == nil ) return;
    [super rendView:button withOption:option];
    if ( [button isKindOfClass:[UIButton class]] == NO ) return;
    
    for ( int i = 0; i < 4; ++i ) {
        NSDictionary *_stateOption = [option objectForKey:_buttonStateString[i]];
        if ( _stateOption == nil ) continue;
        UIControlState _state = _buttonState[i];
        
        // Background Image
        NSString *_backgroundImageName = [_stateOption stringObjectForKey:@"backgroundImage"
                                                         withDefaultValue:@""];
        if ( [_backgroundImageName length] > 0 ) {
            UIImage *_bkgImage = [PYResource imageNamed:_backgroundImageName];
            [button setBackgroundImage:_bkgImage forState:_state];
        }
        
        // Image
        NSString *_imageName = [_stateOption stringObjectForKey:@"image" withDefaultValue:@""];
        if ( [_imageName length] > 0 ) {
            UIImage *_image = [PYResource imageNamed:_imageName];
            [button setImage:_image forState:_state];
        }
        
        // Title
        NSString *_title = [_stateOption stringObjectForKey:@"title" withDefaultValue:@""];
        if ( [_title length] > 0 ) {
            [button setTitle:_title forState:_state];
        }
        
        // Title color
        NSString *_titleColorInfo = [_stateOption stringObjectForKey:@"titleColor" withDefaultValue:@""];
        if ( [_titleColorInfo length] > 0 ) {
            UIColor *_titleColor = [UIColor colorWithOptionString:_titleColorInfo];
            [button setTitleColor:_titleColor forState:_state];
        }
    }
    
    [UILabel rendView:button.titleLabel withOption:option];
}

@end

@implementation UIImageView (AttributeLoader)

+ (void)rendView:(UIImageView *)imageView withOption:(NSDictionary *)option
{
    if ( imageView == nil ) return;
    [super rendView:imageView withOption:option];
    if ( [imageView isKindOfClass:[UIImageView class]] == NO ) return;
    
    NSString *_imageName = [option stringObjectForKey:@"image" withDefaultValue:@""];
    if ( [_imageName length] > 0 ) {
        UIImage *_image = [PYResource imageNamed:_imageName];
        [imageView setImage:_image];
    }
}

@end

@implementation UITableViewCell (AttributeLoader)

+ (void)rendView:(UITableViewCell *)cell withOption:(NSDictionary *)option
{
    if ( cell == nil ) return;
    [super rendView:cell withOption:option];
    
    // Now, just override the background color
    NSString *_bkgColorInfo = [option stringObjectForKey:@"backgroundColor" withDefaultValue:@""];
    if ( [_bkgColorInfo length] > 0 ) {
        UIColor *_bkgColor = [UIColor colorWithOptionString:_bkgColorInfo];
        [cell setBackgroundColor:_bkgColor];
    }
    
    NSString *_selectionStyle = [option stringObjectForKey:@"selectionStyle" withDefaultValue:@""];
    if ( [_selectionStyle length] > 0 ) {
        if ( [_selectionStyle isEqualToString:@"none"] ) {
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        } else if ( [_selectionStyle isEqualToString:@"blue"] ) {
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        } else if ( [_selectionStyle isEqualToString:@"gray"] ) {
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        } else if ( [_selectionStyle isEqualToString:@"default"] ) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
            if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
            }
#endif
        }
    }
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
