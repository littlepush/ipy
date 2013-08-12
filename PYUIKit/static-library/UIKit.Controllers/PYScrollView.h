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

// Predefined Delegate
@protocol PYScrollViewDelegate;

typedef enum {
    PYScrollHorizontal      = PYResponderRestraintPenHorizontal,
    PYScrollVerticalis      = PYResponderRestraintPenVerticalis,
    PYScrollFreedom         = (PYScrollHorizontal | PYScrollVerticalis)
} PYScrollDirection;

typedef enum {
    PYDecelerateSpeedZero                   = 0,        // Disable the decelerate, Stop immediately
    PYDecelerateSpeedVerySlow               = 10,
    PYDecelerateSpeedSlow                   = 15,
    PYDecelerateSpeedNormal                 = 20,       // Default decelerate speed.
    PYDecelerateSpeedFast                   = 25,
    PYDecelerateSpeedVeryFast               = 30
} PYDecelerateSpeed;

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
    CGSize                      _contentSize;
    CGRect                      _contentRect;
    PYScrollDirection           _scrllSide;
    CGSize                      _contentOffset;
    UIEdgeInsets                _contentInsets;
    
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
    int                         _currentStepPiece;
    int                         _maxStepPiece;
    
    // Make current scroll view to support loop scroll,
    // I will use a double-cache machanism (according to the content size, maybe more caches)
    // Default is NO, and is not availabe in scroll view.
    // In develop mode with source code, one can include PYScrollView+SideAnimation.h to
    // Enable this feature.
    BOOL                        _loopSupported;
}

// The delegate to get the callback.
@property (nonatomic, assign)   id<PYScrollViewDelegate>            delegate;

// Set the decelerate speed.
@property (nonatomic, assign)   PYDecelerateSpeed                   decelerateSpeed;

// Set the scroll side, default is freedom.
@property (nonatomic, assign)   PYScrollDirection                   scrollSide;

// Get the content size ( combine all subview's frame )
@property (nonatomic, assign)   CGSize                              contentSize;

// Get current content offset.
@property (nonatomic, readonly) CGSize                              contentOffset;
// Set the content offset with animated
- (void)setContentOffset:(CGSize)contentOffset animated:(BOOL)animated;

// The content insets
@property (nonatomic, assign)   UIEdgeInsets                        contentInsets;

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

// For sub-class to override.
- (BOOL)willScrollWithMovingDistance:(CGSize)movingDistance;

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
