//
//  PYSlideView.h
//  PYUIKit
//
//  Created by Chen Push on 3/12/13.
//  Copyright (c) 2013 Markphone Culture Media Co.Ltd. All rights reserved.
//

#import "PYView.h"

@protocol PYSlideViewDelegate;
@protocol PYSlideViewDataSource;

// The Page View
@class PYSlideViewPage;

// Default Identify for the Slide Page
extern NSString * kPYSlideViewPageDefaultIdentify;

/*
 PY Slide Show View.
 Support auto-slide when use not touch the view.
 When use slide manually, the auto-slide timer will be 
 stoped and resume when the user stop to do any thing.
 
 Also, the PYSlideView is a UITableView-liked controller,
 which means it need two callback object: delegate & datasource.
 The datasource provide the count of the page, and create the 
 instance of the page when slide view need to load a new page.
 The delegate will be notified when the page in slide view has
 been changed. Such as will-show, will-remove, did-select, etc.
 
 In default, the slide view uses a cycled-sliding mechanism.
 When slide to the last page, and try to slide the next page, 
 the first page will be shown, vice versa.
 */
@interface PYSlideView : PYView
{
    // Caches
    NSMutableArray                          *_visiblePages;
    NSMutableDictionary                     *_cachedPages;
    
    //
    NSUInteger                              _centerPageIndex;
    NSUInteger                              _allPageCount;

    // Auto Slide
    NSTimer                                 *_autoSlideTimer;
    CGFloat                                 _autoSlideInterval;
    BOOL                                    _isAutoSliding;
    
    // Animation Timer
    NSTimer                                 *_animationTimer;
    struct timeval                          _timeTick;
    
    // User inactive
    CGPoint                                 _lastTouchPoint;
}

@property (nonatomic, assign)   IBOutlet    id<PYSlideViewDataSource>       datasource;
@property (nonatomic, assign)   IBOutlet    id<PYSlideViewDelegate>         delegate;

// Properties of the slide view
@property (nonatomic, readonly) NSUInteger                                  count;
@property (nonatomic, readonly) NSUInteger                                  centerPageIndex;
@property (nonatomic, readonly) NSArray                                     *visiblePages;

// Animation control properties
@property (nonatomic, assign)   CGFloat                                     lingerAnimationTime;
@property (nonatomic, assign)   CGFloat                                     autoSlideInterval;

// Navigation for the page cells
- (void)slideToPage:(NSUInteger)page animated:(BOOL)animated;
- (void)slideToNextPageAnimated:(BOOL)animated;
- (void)slideToPreviousPageAnimated:(BOOL)animated;
- (void)slideToFirstPageAnimated:(BOOL)animated;
- (void)slideToLastPageAnimated:(BOOL)animated;

// Data
- (void)reloadPages;

// Auto Slide
- (void)startAutoSlide;
- (void)stopAutoSlide;

// Cache
- (PYSlideViewPage *)dequeueSlideViewPageWithIdentify:(NSString *)identify;

@end

// Delegate Protocol
@protocol PYSlideViewDelegate <NSObject>

@optional
// The slide page has been selected.
- (void)slideView:(PYSlideView *)slideView didSelectedPage:(PYSlideViewPage *)page atIndex:(NSUInteger)index;

// Display callback, last thing slide view to do before the [addSubView] been invoked.
- (void)slideView:(PYSlideView *)slideView willShowPage:(PYSlideViewPage *)page atIndex:(NSUInteger)index;

// Will change to page
- (void)slideView:(PYSlideView *)slideView changeToPageAtIndex:(NSUInteger)index;

@end

// DataSource Protocol
@protocol PYSlideViewDataSource <NSObject>

@required
// Get the page count.
- (NSUInteger)numberOfPagesInSlideView:(PYSlideView *)slideView;
// Get each page.
- (PYSlideViewPage *)slideView:(PYSlideView *)slideView pageAtIndex:(NSUInteger)index;

@end

