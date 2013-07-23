//
//  PYSlideView.m
//  PYUIKit
//
//  Created by Chen Push on 3/12/13.
//  Copyright (c) 2013 Markphone Culture Media Co.Ltd. All rights reserved.
//

#import "PYSlideView.h"
#import "PYSlideViewPage.h"
#import "PYSlideView+Pages.h"

@implementation PYSlideView

@synthesize delegate, datasource;
@synthesize count = _allPageCount;
@synthesize centerPageIndex = _centerPageIndex;
@dynamic visiblePages;
- (NSArray *)visiblePages
{
    return [NSArray arrayWithArray:_visiblePages];
}

@synthesize lingerAnimationTime;
@dynamic autoSlideInterval;
- (CGFloat)autoSlideInterval
{
    return _autoSlideInterval;
}
- (void)setAutoSlideInterval:(CGFloat)interval
{
    _autoSlideInterval = interval;
    if ( PYFLOATEQUAL(interval, 0.) == YES ) {
        if ( _autoSlideTimer != nil ) {
            [_autoSlideTimer invalidate];
            _autoSlideTimer = nil;
        }
    }
}

- (void)viewJustBeenCreated
{
    [super viewJustBeenCreated];
    // Just been created
    _visiblePages = [NSMutableArray array];
    _cachedPages = [NSMutableDictionary dictionary];

    _centerPageIndex = 0;
    _allPageCount = 0;
    
    _autoSlideTimer = nil;
    [self setAutoSlideInterval:5.f];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self _resizeVisiablePageSize];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if ( newSuperview == nil ) // remove
    {
        [self _removeAllPages];
        return;
    }
    // When the super view is a scroll view. 
    if ( [newSuperview isKindOfClass:[UIScrollView class]] ) {
        [(UIScrollView *)newSuperview setCanCancelContentTouches:NO];
    }
    [self reloadPages];
}

#pragma mark --
#pragma mark Instance Messages

// Navigation for the page cells
- (void)slideToPage:(NSUInteger)page animated:(BOOL)animated
{
    if ( page == _centerPageIndex ) return;
    int _goLeftNeedStep = 0, _goRightNeedStep = 0;
    // test go left;
    if ( page < _centerPageIndex ) {
        _goLeftNeedStep = _centerPageIndex - page;
    } else {
        _goLeftNeedStep = _centerPageIndex + (_allPageCount - page);
    }
    
    // test go right;
    if ( page > _centerPageIndex ) {
        _goRightNeedStep = page - _centerPageIndex;
    } else {
        _goRightNeedStep = (_allPageCount - _centerPageIndex) + page;
    }

    while ( _centerPageIndex != page ) {
        if ( _goLeftNeedStep < _goRightNeedStep ) {
            [self slideToPreviousPageAnimated:animated];
        } else {
            [self slideToNextPageAnimated:animated];
        }
    }
}
- (void)slideToNextPageAnimated:(BOOL)animated
{
    @synchronized(self) {
        if ( _allPageCount <= 1 ) return;

        // Prepare for data
        PYSlideViewPage *_prevPage = [_visiblePages objectAtIndex:0];
        if ( _prevPage.pageIndex != _centerPageIndex ) {
            // remove prev page.
            [self _enqueuePage:_prevPage];
            [_visiblePages removeObjectAtIndex:0];
        }
        
        PYSlideViewPage *_lastPage = [_visiblePages lastObject];
        if ( _centerPageIndex == _lastPage.pageIndex ) {
            // We need to load the new page
            int _loadPageIndex = _centerPageIndex + 1;
            if ( _loadPageIndex == _allPageCount ) _loadPageIndex = 0;
            PYSlideViewPage *_nextPage = [self _loadPageFromDataSourceAtIndex:_loadPageIndex];
            if ( _nextPage == nil ) return;
            [self _addSlidePage:_nextPage withDelta:1];
            [_visiblePages addObject:_nextPage];
        }
        _centerPageIndex += 1;
        if ( _centerPageIndex == _allPageCount ) _centerPageIndex = 0;
        
        if ( animated ) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:.35];
        }
        
        if ( [self.delegate respondsToSelector:@selector(slideView:changeToPageAtIndex:)] ) {
            [self.delegate slideView:self changeToPageAtIndex:_centerPageIndex];
        }
        
        [self _resizeVisiablePageSize];
        
        if ( animated ) {
            [UIView commitAnimations];
        }
    }
}
- (void)slideToPreviousPageAnimated:(BOOL)animated
{
    @synchronized(self) {
        if ( _allPageCount <= 1 ) return;
        
        PYSlideViewPage *_nextPage = [_visiblePages lastObject];
        if ( _nextPage.pageIndex != _centerPageIndex ) {
            // need to remove the next page, because it will move out of the view
            [self _enqueuePage:_nextPage];
            [_visiblePages removeLastObject];
        }
        
        PYSlideViewPage *_prevPage = [_visiblePages objectAtIndex:0];
        if ( _prevPage.pageIndex == _centerPageIndex ) {
            // we do not has a prev page in visiable cache
            // load a new one
            int _loadPageIndex = _centerPageIndex - 1;
            if ( _loadPageIndex < 0 ) _loadPageIndex = (_allPageCount - 1);
            PYSlideViewPage *_newPage = [self _loadPageFromDataSourceAtIndex:_loadPageIndex];
            if ( _newPage == nil ) return;
            [self _addSlidePage:_newPage withDelta:-1];
            [_visiblePages insertObject:_newPage atIndex:0];
        }
        _centerPageIndex -= 1;
        if ( (int)_centerPageIndex < 0 ) _centerPageIndex = (_allPageCount - 1);
        
        if ( animated ) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:.35];
        }
        
        if ( [self.delegate respondsToSelector:@selector(slideView:changeToPageAtIndex:)] ) {
            [self.delegate slideView:self changeToPageAtIndex:_centerPageIndex];
        }

        [self _resizeVisiablePageSize];
        
        if ( animated ) {
            [UIView commitAnimations];
        }
    }
}
- (void)slideToFirstPageAnimated:(BOOL)animated
{
    [self slideToPage:0 animated:animated];
}
- (void)slideToLastPageAnimated:(BOOL)animated
{
    [self slideToPage:(_allPageCount - 1) animated:animated];
}

// Data
- (void)reloadPages
{
    // must has a datasource.
    if ( self.datasource == nil ) return;
    
    [self _removeAllPages];
    // Get count
    if ( ![self.datasource respondsToSelector:@selector(numberOfPagesInSlideView:)] )
        @throw @"need numberOfPagesInSlideView: for the datasource";
    _allPageCount = [self.datasource numberOfPagesInSlideView:self];
    
    if ( _allPageCount == 0 ) return;
    
    // _load the zero page
    _centerPageIndex = 0;
    
    PYSlideViewPage *_centerPage = [self _loadPageFromDataSourceAtIndex:0];
    if ( _centerPage == nil ) return;
    [self _addSlidePage:_centerPage withDelta:0];
    [_visiblePages addObject:_centerPage];
}

// Auto Slide
- (void)startAutoSlide
{
    //return;
    @synchronized(self) {
        // if the time interval is equal to zero, do not start.
        if ( PYFLOATEQUAL(_autoSlideInterval, 0) ) return;
        if ( _autoSlideInterval < 0 ) return;
        if ( _autoSlideTimer != nil ) return;
        _autoSlideTimer = [NSTimer timerWithTimeInterval:self.autoSlideInterval
                                                  target:self
                                                selector:@selector(_autoSlideTimerHandler:)
                                                userInfo:nil
                                                 repeats:YES];
        //[[NSRunLoop currentRunLoop] addTimer:_autoSlideTimer forMode:NSRunLoopCommonModes];
    }
}
- (void)stopAutoSlide
{
    //return;
    @synchronized(self) {
        if (_autoSlideTimer == nil) return;
        [_autoSlideTimer invalidate];
        _autoSlideTimer = nil;
    }
}

// Cache
- (PYSlideViewPage *)dequeueSlideViewPageWithIdentify:(NSString *)identify
{
    if ( [identify length] == 0 ) return nil;
    NSMutableArray *_identifyCache = [_cachedPages objectForKey:identify];
    if ( _identifyCache == nil ) return nil;
    if ( [_identifyCache count] == 0 ) return nil;
    PYSlideViewPage *_cachePage = [_identifyCache objectAtIndex:0];
    [_identifyCache removeObjectAtIndex:0];
    return _cachePage;
}

// Hit test
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if ( CGRectContainsPoint(self.bounds, point) ) {
        for ( PYSlideViewPage *_page in _visiblePages ) {
            if ( _page.pageIndex == _centerPageIndex ) return _page;
        }
    }
	return [super hitTest:point withEvent:event];
}

@end
