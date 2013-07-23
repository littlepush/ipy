//
//  PYSlideViewPage.h
//  PYUIKit
//
//  Created by Chen Push on 3/13/13.
//  Copyright (c) 2013 Markphone Culture Media Co.Ltd. All rights reserved.
//

#import "PYView.h"
#import "PYSlideView.h"

/*
 Slide View Page
 */
@interface PYSlideViewPage : PYView
{
    NSUInteger                                              _pageIndex;
    PYSlideView                                             *_slideView;
    BOOL                                                    _isBeginToTap;
}

@property (nonatomic, copy)     NSString                    *reusableIdentify;
@property (nonatomic, readonly) PYSlideView                 *slideView;
@property (nonatomic, readonly) NSUInteger                  pageIndex;

- (id)initWithReusableIdentify:(NSString *)identify;

- (void)prepareForReuse;

@end
