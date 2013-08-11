//
//  PYScrollView+SideAnimation.h
//  PYUIKit
//
//  Created by Push Chen on 8/7/13.
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

#import "PYScrollView.h"

#define _SCROLL_TIME_PIECE_(T)                          (int)(((float)T) / PYScrollDecelerateDurationPiece)

@interface PYScrollView (SideAnimation)

// Make the content stop when arrive the side. set it to NO for further
// feature.
@property (nonatomic, assign, setter = setLoopEnabled:) BOOL        isLoopEnabled;

// This is a ... function! Which is designed to calculate the decelerate
// distance according to the init speed and current statue.
// If current scroll view has been set to support loop,
// use direct mathmatic function to get the resutl.
// If not loop-able, and after calculation, the content will out-of-bounds,
// set the jelly-effective to be enabled.
- (void)calculateDecelerateDistanceAndSetJellyPointWithInitSpeed:(CGSize)initSpeed
                                              decelerateDuration:(CGFloat *)dduration
                                                  bounceDuration:(CGFloat *)bduration;

// Reorder the content caches, according to the content size.
- (void)reorderContentViewCache;

// Animated scroll to specified offset within time.
- (void)animatedScrollWithOffsetDistance:(CGSize)offsetDistance
                        withinTimePieces:(NSUInteger)timepiece;

// Internal set content offset.
// The offset should be a piece of the whole moving distance.
- (void)setMovingOffset:(CGSize)contentOffset withAnimatDuration:(CGFloat)duration;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
