//
//  PYScrollView.h
//  PYUIKit
//
//  Created by Push Chen on 7/30/13.
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

#import "PYResponderView.h"

#define _SIDE_ITEM(_item)                                                   \
    ((float *)(&(_item)))[(int)((self.scrollSide & PYScrollHorizontal) == 0)]
#define _VSIDE_ITEM(_item)                                                  \
    ((float *)(&(_item)))[(int)((self.scrollSide & PYScrollHorizontal) != 0)]

// Predefined Delegate
@protocol PYScrollViewDelegate;

typedef NS_OPTIONS(int32_t, PYScrollDirection) {
    PYScrollHorizontal      = PYResponderRestraintPanHorizontal,
    PYScrollVerticalis      = PYResponderRestraintPanVerticalis,
    PYScrollFreedom         = (PYScrollHorizontal | PYScrollVerticalis)
};

typedef NS_OPTIONS(NSInteger, PYDecelerateSpeed) {
    PYDecelerateSpeedZero                   = 0,        // Disable the decelerate, Stop immediately
    PYDecelerateSpeedVerySlow               = 5,
    PYDecelerateSpeedSlow                   = 10,
    PYDecelerateSpeedNormal                 = 15,       // Default decelerate speed.
    PYDecelerateSpeedFast                   = 20,
    PYDecelerateSpeedVeryFast               = 25
};

extern NSUInteger const         PYScrollDecelerateTimePiece;
extern CGFloat const            PYScrollDecelerateStepRate;
extern CGFloat const            PYScrollDecelerateNeedBounceDuration;
extern CGFloat const            PYScrollBounceBackDuration;
extern CGFloat const            PYScrollDecelerateDuration;
extern CGFloat const            PYScrollDecelerateDurationPiece;
extern CGFloat const            PYScrollOverheadRate;

@interface PYScrollView : PYResponderView
{
    @private
    NSMutableArray              *_subContentList;
    UIView                      *_contentView;
    CGRect                      _coverFrame;
    CGSize                      _contentSize;
    CGRect                      _contentRect;
    PYScrollDirection           _scrllSide;
    CGSize                      _contentOffset;
    UIEdgeInsets                _contentInsets;
    BOOL                        _willDecelerate;
    
    BOOL                        _bounceStatus[2];
    
    // Decelerate Speed, default is normal.
    PYDecelerateSpeed           _decelerateSpeed;
    
    // Status & Timer
    BOOL                        _willBounceBack;
    NSTimer                     *_decelerateTimer;
    
    // Pre-calculate info
    CGSize                      _willStopOffset;
    CGSize                      _willBounceOffset;
    CGFloat                     _decelerateDuration;
    CGFloat                     _bounceDuration;

    // For decelerate animated/time handler.
    CGSize                      _decelerateInitSpeed;
    CGSize                      _currentDeceleratedOffset;
    NSUInteger                  _currentStepPiece;
    NSUInteger                  _maxStepPiece;
    
    // Pagable
    // The paging property will affect the decelerate distance.
    CGSize                      _pageSize;
    BOOL                        _pagable;
    NSUInteger                  _maxDeceleratePageCount;    // Default is 1.
    BOOL                        _canFallback;
    
    // Make current scroll view to support loop scroll,
    // I will use a double-cache machanism (according to the content size, maybe more caches)
    // Default is NO, and is not availabe in scroll view.
    // In develop mode with source code, one can include PYScrollView+SideAnimation.h to
    // Enable this feature.
    BOOL                        _loopSupported;
}

// Get the content view's class, default is UIView.
+ (Class)contentViewClass;

// The delegate to get the callback.
@property (nonatomic, assign)   IBOutlet id<PYScrollViewDelegate>   delegate;

// Set the decelerate speed.
@property (nonatomic, assign)   PYDecelerateSpeed                   decelerateSpeed;

// Set the scroll side, default is freedom.
@property (nonatomic, assign)   PYScrollDirection                   scrollSide;

// To get the scrolling statue.
@property (nonatomic, readonly) BOOL                                isScrolling;

// Get the content size ( combine all subview's frame )
@property (nonatomic, assign)   CGSize                              contentSize;
- (void)setContentSize:(CGSize)contentSize animated:(BOOL)animated;

// Get current content offset.
@property (nonatomic, readonly) CGSize                              contentOffset;
// Set the content offset with animated
- (void)setContentOffset:(CGSize)contentOffset animated:(BOOL)animated;

// The content insets
@property (nonatomic, assign)   UIEdgeInsets                        contentInsets;

// Page
@property (nonatomic, assign)   CGSize                              pageSize;
@property (nonatomic, assign, setter = setPagable:) BOOL            isPagable;
@property (nonatomic, assign)   NSUInteger                          maxDeceleratePageCount;
// if pagable, and doesn't scroll half page, if can fallback to the last page.
// default is NO.
@property (nonatomic, assign)   BOOL                                canFallback;

// When the scroll end scroll and prepare for decelerating, this
// property will be set to tell where the content will stop.
// You can modify this value to make the scroll to decelerate and stop
// at a different position.
@property (nonatomic, assign)   CGSize                              willStopOffset;

// Always bounce setting
@property (nonatomic, assign)   BOOL                                alwaysBounceVertical;
@property (nonatomic, assign)   BOOL                                alwaysBounceHorizontal;

// Specified message to redirect the content offset.
- (void)scrollToTop;
- (void)scrollToLeft;
- (void)scrollToRight;
- (void)scrollToBottom;

// When page enabled, the following methods is available.
- (void)scrollToNextPage:(BOOL)animated;
- (void)scrollToPreviousPage:(BOOL)animated;

// For securety reason, invoke this message to make the object be thread safe...
- (void)cancelAllAnimation;

@end

// The delegate
@protocol PYScrollViewDelegate <NSObject>

// All messages are optional
@optional

- (void)pyScrollViewWillBeginToScroll:(PYScrollView *)scrollView;
- (void)pyScrollViewDidScroll:(PYScrollView *)scrollView;
- (void)pyScrollViewDidEndScroll:(PYScrollView *)scrollView willDecelerate:(BOOL)decelerated;
- (void)pyScrollViewDidEndDecelerate:(PYScrollView *)scrollView;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
