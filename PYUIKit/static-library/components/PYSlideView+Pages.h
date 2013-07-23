//
//  PYSlideView+Pages.h
//  PYUIKit
//
//  Created by Chen Push on 3/13/13.
//  Copyright (c) 2013 Markphone Culture Media Co.Ltd. All rights reserved.
//

#import "PYSlideView.h"
#import "PYSlideViewPage.h"

@interface PYSlideViewPage (Views)

- (void)setPageIndex:(NSUInteger)index;
- (void)setSlideView:(PYSlideView *)slideView;

@end

@interface PYSlideView (Pages)

// Private
// Resize the visiable page size when the view's frame has been changed.
- (void)_resizeVisiablePageSize;

// Resize a specified page with specified delta;
- (void)_resizeSpecifiedPage:(PYSlideViewPage *)page withDelta:(int)delta;

// Remove all pages
- (void)_removeAllPages;

// Enqueue the page to cache
- (void)_enqueuePage:(PYSlideViewPage *)page;

// Load and initialize the page.
- (PYSlideViewPage *)_loadPageFromDataSourceAtIndex:(NSUInteger)index;

// Add the page to the view
- (void)_addSlidePage:(PYSlideViewPage *)page;
- (void)_addSlidePage:(PYSlideViewPage *)page withDelta:(int)delta;

// Auto slide handler
- (void)_autoSlideTimerHandler:(NSTimer *)timer;

// User inactrive
- (void)_userBeganToTouchOnPage:(PYSlideViewPage *)page atPoint:(CGPoint)touchPoint;
- (void)_userMoveTouchOnPage:(PYSlideViewPage *)page toPoint:(CGPoint)touchPoint;
- (void)_userEndTouchOnPage:(PYSlideViewPage *)page atPoint:(CGPoint)touchPoint;
- (void)_userCancelTouch;
- (void)_userTapOnPage:(PYSlideViewPage *)page;

// Page Moving
- (void)_movePagesFromLeftToRight:(CGFloat)delta;
- (void)_movePagesFromRightToLeft:(CGFloat)delta;

@end
