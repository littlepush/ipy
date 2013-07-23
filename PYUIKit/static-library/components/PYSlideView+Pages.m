//
//  PYSlideView+Pages.m
//  PYUIKit
//
//  Created by Chen Push on 3/13/13.
//  Copyright (c) 2013 Markphone Culture Media Co.Ltd. All rights reserved.
//

#import "PYSlideView+Pages.h"

@implementation PYSlideView (Pages)

#pragma mark --
#pragma mark Private

- (void)_resizeVisiablePageSize
{
    if ( [_visiblePages count] == 0 ) return;
    CGFloat _width = self.bounds.size.width;
    CGFloat _height = self.bounds.size.height;
    
    int _centerPageIndexInVisiablePages = -1;
    for ( int _vindex = 0; _vindex < [_visiblePages count]; ++_vindex ) {
        PYSlideViewPage *_page = [_visiblePages objectAtIndex:_vindex];
        if ( _page.pageIndex == _centerPageIndex ) {
            _centerPageIndexInVisiablePages = _vindex;
            break;
        }
    }
    assert(_centerPageIndexInVisiablePages != -1);
    for ( int _pindex = 0; _pindex < [_visiblePages count]; ++_pindex ) {
        PYSlideViewPage *_page = [_visiblePages objectAtIndex:_pindex];
        CGRect _pageFrame = CGRectInfinite;
        int _deltaIndex = _pindex - _centerPageIndexInVisiablePages;
        _pageFrame.origin.x = (_deltaIndex * _width);
        _pageFrame.origin.y = 0;
        _pageFrame.size.width = _width;
        _pageFrame.size.height = _height;
        [_page setFrame:_pageFrame];
    }
}

- (void)_resizeSpecifiedPage:(PYSlideViewPage *)page withDelta:(int)delta
{
    CGFloat _width = self.bounds.size.width;
    CGFloat _height = self.bounds.size.height;
    [page setFrame:CGRectMake((delta * _width), 0, _width, _height)];
}

- (void)_removeAllPages
{
    for ( PYSlideViewPage *_page in _visiblePages ) {
        [self _enqueuePage:_page];
    }
    [_visiblePages removeAllObjects];
    
    _allPageCount = 0;
    _centerPageIndex = 0;
}

- (void)_enqueuePage:(PYSlideViewPage *)page
{
    [page removeFromSuperview];
    // throw the page if it's not a PYSlideViewPage or the reusableIdentify is not validate
    if ( ![page isKindOfClass:[PYSlideViewPage class]] ) return;
    [page setSlideView:nil];
    if ( [page.reusableIdentify length] == 0 ) return;
    
    NSMutableArray *_identifyedCache = [_cachedPages objectForKey:page.reusableIdentify];
    if ( _identifyedCache == nil ) {
        _identifyedCache = [NSMutableArray array];
        [_cachedPages setValue:_identifyedCache forKey:page.reusableIdentify];
    }
    [_identifyedCache addObject:page];
}

- (PYSlideViewPage *)_loadPageFromDataSourceAtIndex:(NSUInteger)index
{
    assert(index < _allPageCount);
    if ( ![self.datasource respondsToSelector:@selector(slideView:pageAtIndex:)] )
        return nil;
    PYSlideViewPage *_page = [self.datasource slideView:self pageAtIndex:index];
    if ( _page == nil ) return nil;
    [_page setPageIndex:index];
    [_page setSlideView:self];
    
    return _page;
}

- (void)_addSlidePage:(PYSlideViewPage *)page
{
    if ( [self.delegate respondsToSelector:@selector(slideView:willShowPage:atIndex:)] ) {
        [self.delegate slideView:self willShowPage:page atIndex:page.pageIndex];
    }
    [self insertSubview:page atIndex:0];
}
- (void)_addSlidePage:(PYSlideViewPage *)page withDelta:(int)delta
{
    [self _resizeSpecifiedPage:page withDelta:delta];
    if ( [self.delegate respondsToSelector:@selector(slideView:willShowPage:atIndex:)] ) {
        [self.delegate slideView:self willShowPage:page atIndex:page.pageIndex];
    }
    [self insertSubview:page atIndex:0];
}

- (void)_autoSlideTimerHandler:(NSTimer *)timer
{
    [self slideToNextPageAnimated:YES];
    //[self slideToPreviousPageAnimated:YES];
}

// user inactive
- (void)_userBeganToTouchOnPage:(PYSlideViewPage *)page atPoint:(CGPoint)touchPoint
{
    @synchronized(self) {
        _lastTouchPoint = touchPoint;
        _isAutoSliding = (_autoSlideTimer != nil);
    }
}
- (void)_userMoveTouchOnPage:(PYSlideViewPage *)page toPoint:(CGPoint)touchPoint
{
    @synchronized(self) {
        [self stopAutoSlide];
        // Calculate the delte size
        CGFloat _delta = _lastTouchPoint.x - touchPoint.x;
        if ( _delta >= 0.f ) {
            [self _movePagesFromRightToLeft:ABS(_delta)];
        } else {
            [self _movePagesFromLeftToRight:ABS(_delta)];
        }
        _lastTouchPoint = touchPoint;
    }
}
- (void)_userEndTouchOnPage:(PYSlideViewPage *)page atPoint:(CGPoint)touchPoint
{
    @synchronized(self) {
        if ( _isAutoSliding ) [self startAutoSlide];
        [UIView animateWithDuration:.35 animations:^{
            [self _resizeVisiablePageSize];
        }];
    }
}
- (void)_userCancelTouch
{
    @synchronized(self) {
        if ( _isAutoSliding ) [self startAutoSlide];
        [UIView animateWithDuration:.35 animations:^{
            [self _resizeVisiablePageSize];
        }];
    }
}
- (void)_userTapOnPage:(PYSlideViewPage *)page
{
    if ( [self.delegate respondsToSelector:@selector(slideView:didSelectedPage:atIndex:)] ) {
        [self.delegate slideView:self didSelectedPage:page atIndex:page.pageIndex];
    }
}

- (void)_movePagesFromLeftToRight:(CGFloat)delta
{
    if ( [_visiblePages count] == 0 ) return;
    if ( _allPageCount > 1 ) {
        // Calculate the very left one,
        PYSlideViewPage *_leftPage = [_visiblePages objectAtIndex:0];
        // the very left one can not cover the screen
        if ( _leftPage.frame.origin.x + delta > 0 ) {
            // load a new one
            int _newLoadIndex = (_leftPage.pageIndex - 1);
            if ( _newLoadIndex < 0 ) _newLoadIndex = (_allPageCount - 1);
            PYSlideViewPage *_newPage = [self _loadPageFromDataSourceAtIndex:_newLoadIndex];
            CGRect _newFrame = _leftPage.frame;
            _newFrame.origin.x -= _newFrame.size.width;
            [_newPage setFrame:_newFrame];
            [self _addSlidePage:_newPage];
            [_visiblePages insertObject:_newPage atIndex:0];
        }
    }
    
    // Move the pages
    PYSlideViewPage *_centerPage = nil;
    for ( PYSlideViewPage *_page in _visiblePages ) {
        CGRect _moveFrame = _page.frame;
        _moveFrame.origin.x += delta;
        [_page setFrame:_moveFrame];
        if ( _page.pageIndex == _centerPageIndex ) _centerPage = _page;
    }
    
    // Calculate the very right one
    PYSlideViewPage *_rightPage = [_visiblePages lastObject];
    // the very right one is out of screen
    if ( _rightPage.frame.origin.x > self.bounds.size.width )
    {
        // remove the right one
        [self _enqueuePage:_rightPage];
        [_visiblePages removeLastObject];
    }
    
    // Caclulate the center page
    if ( _centerPage.frame.origin.x > (self.bounds.size.width / 2) ) {
        // the center page is no longer be center
        // the center index should be move the left one
        _centerPageIndex -= 1;
        if ( (int)_centerPageIndex < 0 ) _centerPageIndex = (_allPageCount - 1);
        if ( [self.delegate respondsToSelector:@selector(slideView:changeToPageAtIndex:)] ) {
            [self.delegate slideView:self changeToPageAtIndex:_centerPageIndex];
        }
    }
}
- (void)_movePagesFromRightToLeft:(CGFloat)delta
{
    if ( [_visiblePages count] == 0 ) return;
    if ( _allPageCount > 1 ) {
        // Calculate the very right one,
        PYSlideViewPage *_rightPage = [_visiblePages lastObject];
        // the very right one can not cover the screen
        if ( _rightPage.frame.origin.x - delta < 0 ) {
            // load a new one
            int _newLoadIndex = (_rightPage.pageIndex + 1);
            if ( _newLoadIndex == _allPageCount ) _newLoadIndex = 0;
            PYSlideViewPage *_newPage = [self _loadPageFromDataSourceAtIndex:_newLoadIndex];
            CGRect _newFrame = _rightPage.frame;
            _newFrame.origin.x += _newFrame.size.width;
            [_newPage setFrame:_newFrame];
            [self _addSlidePage:_newPage];
            [_visiblePages addObject:_newPage];
        }
    }
    
    // Move the pages
    PYSlideViewPage *_centerPage = nil;
    for ( PYSlideViewPage *_page in _visiblePages ) {
        CGRect _moveFrame = _page.frame;
        _moveFrame.origin.x -= delta;
        [_page setFrame:_moveFrame];
        if ( _page.pageIndex == _centerPageIndex ) _centerPage = _page;
    }
    
    // Calculate the very left one
    PYSlideViewPage *_leftPage = [_visiblePages objectAtIndex:0];
    // the very right one is out of screen
    if ( _leftPage.frame.origin.x < -self.bounds.size.width )
    {
        // remove the right one
        [self _enqueuePage:_leftPage];
        [_visiblePages removeObjectAtIndex:0];
    }
    
    // Caclulate the center page
    if ( _centerPage.frame.origin.x < -(self.bounds.size.width / 2) ) {
        // the center page is no longer be center
        // the center index should be move the right one
        _centerPageIndex += 1;
        if ( _centerPageIndex == _allPageCount ) _centerPageIndex = 0;
        if ( [self.delegate respondsToSelector:@selector(slideView:changeToPageAtIndex:)] ) {
            [self.delegate slideView:self changeToPageAtIndex:_centerPageIndex];
        }
    }
}

@end
