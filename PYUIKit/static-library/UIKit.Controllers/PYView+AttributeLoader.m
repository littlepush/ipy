//
//  PYView+AttributeLoader.m
//  PYUIKit
//
//  Created by Push Chen on 11/13/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import "PYView+AttributeLoader.h"
#import "UIView+AttributeLoader.h"

@implementation PYView (AttributeLoader)

+ (void)rendView:(PYView *)view withOption:(NSDictionary *)option
{
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
    [super rendView:switcher withOption:option];
    // Background Image
    // Button Image
    // Left Label
    // Right Label
    // left text
    // right text
}

@end

@implementation PYLabelLayer (AttributeLoader)

+ (void)rendLayer:(PYLabelLayer *)labelLayer withOption:(NSDictionary *)option
{
    
}

@end

@implementation PYLabel (AttributeLoader)

+ (void)rendView:(PYLabel *)label withOption:(NSDictionary *)option
{
    [super rendView:label withOption:option];
}

@end

@implementation PYImageLayer (AttributeLoader)

+ (void)rendLayer:(PYImageLayer *)imageLayer withOption:(NSDictionary *)option
{
    
}

@end

@implementation PYImageView (AttributeLoader)

+ (void)rendView:(PYImageView *)imageView withOption:(NSDictionary *)option
{
    [super rendView:imageView withOption:option];
}

@end

