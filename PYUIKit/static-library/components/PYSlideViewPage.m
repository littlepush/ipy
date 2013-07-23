//
//  PYSlideViewPage.m
//  PYUIKit
//
//  Created by Chen Push on 3/13/13.
//  Copyright (c) 2013 Markphone Culture Media Co.Ltd. All rights reserved.
//

#import "PYSlideViewPage.h"
#import "PYSlideView+Pages.h"

/*
 PYSlideViewPage
 */

@implementation PYSlideViewPage

@synthesize pageIndex = _pageIndex;
@synthesize slideView = _slideView;
@synthesize reusableIdentify;

- (void)setSlideView:(PYSlideView *)slideView
{
    _slideView = slideView;
}
- (void)setPageIndex:(NSUInteger)index
{
    _pageIndex = index;
}

- (id)initWithReusableIdentify:(NSString *)identify
{
    self = [super init];
    if ( self ) {
        self.reusableIdentify = identify;
    }
    return self;
}

- (void)prepareForReuse
{
    // Do nothing
}

#pragma mark --
#pragma mark Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _isBeginToTap = YES;
    CGPoint _touchPoint = [[touches anyObject] locationInView:self.superview];
    [_slideView _userBeganToTouchOnPage:self atPoint:_touchPoint];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    _isBeginToTap = NO;
    CGPoint _touchPoint = [[touches anyObject] locationInView:self.superview];
    [_slideView _userMoveTouchOnPage:self toPoint:_touchPoint];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint _touchPoint = [[touches anyObject] locationInView:self.superview];
    if ( _isBeginToTap ) {
        // click event
        [_slideView _userTapOnPage:self];
    } else {
        // end move
        [_slideView _userEndTouchOnPage:self atPoint:_touchPoint];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    _isBeginToTap = NO;
    [_slideView _userCancelTouch];
}

@end
