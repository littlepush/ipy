//
//  PYScrollView+SideAnimation.m
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

#import "PYScrollView+SideAnimation.h"

@implementation PYScrollView (SideAnimation)

@dynamic isLoopEnabled;
- (BOOL)isLoopEnabled
{
    return _loopSupported;
}

- (void)setLoopEnabled:(BOOL)isLoopEnabled
{
    _loopSupported = isLoopEnabled;
}

- (void)calculateDecelerateDistanceAndSetJellyPointWithInitSpeed:(CGSize)initSpeed
{
    _willBounceBack = NO;
    CGFloat _horDistance = [PYResponderView
                            distanceToMoveWithInitSpeed:initSpeed.width
                            stepRate:PYScrollDecelerateStepRate
                            timePieces:PYScrollDecelerateTimePiece];
    CGFloat _verDistance = [PYResponderView
                            distanceToMoveWithInitSpeed:initSpeed.height
                            stepRate:PYScrollDecelerateStepRate
                            timePieces:PYScrollDecelerateTimePiece];
    
    _willStopOffset = CGSizeMake(_horDistance, _verDistance);
    
    // If current scroll view support loop, the stop offset is what we will stop place.
    if ( _loopSupported == YES ) return;
    
    // Check side.
    // Get the minimal visiable frame
    CGRect _bounds = self.bounds;
    CGRect _minimalVisiableFrame = CGRectMake(0, 0,
                                              MIN(_bounds.size.width, _contentSize.width),
                                              MIN(_bounds.size.height, _contentSize.height));
    CGRect _predirectContentFrame = CGRectMake(
                                               -(_contentOffset.width - _horDistance),
                                               -(_contentOffset.height - _verDistance),
                                               _contentSize.width,
                                               _contentSize.height);
    BOOL _needBounceBack = !PYIsRectInside(_minimalVisiableFrame, _predirectContentFrame);
    PYLog(@"Need Bounce Back: %@", (_needBounceBack ? @"YES" : @"NO"));
    // Just scroll it!
    if ( _needBounceBack == NO ) return;
    CGSize _currentPoint = CGSizeMake(-_contentOffset.width,
                                      -_contentOffset.height);
    
    CGFloat _horFinalVisiablePosition = 0.f;
    if ( _minimalVisiableFrame.size.width < _bounds.size.width ) {
        _horFinalVisiablePosition = 0.f;
    } else {
        if ( _predirectContentFrame.origin.x > 0 ) _horFinalVisiablePosition = 0;
        else _horFinalVisiablePosition = _contentSize.width - _bounds.size.width;
    }
    
    CGFloat _verFinalVisiablePosition = 0.f;
    if ( _minimalVisiableFrame.size.height < _bounds.size.height ) {
        _verFinalVisiablePosition = 0.f;
    } else {
        if ( _predirectContentFrame.origin.y > 0 ) _verFinalVisiablePosition = 0;
        else _verFinalVisiablePosition = _contentSize.height - _bounds.size.height;
    }
    
    if ( _bounceHor == NO ) {
        _willStopOffset.width = (_contentOffset.width - _horFinalVisiablePosition);
    } else {
        CGFloat _toBoundsDistance = 0.f;
    }
    
    if ( _bounceVer == NO ) {
        _willStopOffset.height = (_contentOffset.height - _verFinalVisiablePosition);
    } else {
        
    }
    // check if need bounce back.
    _willBounceBack = ((_bounceVer | _bounceHor) & _needBounceBack);
}

- (void)reorderContentViewCache
{
    
}

- (void)animatedScrollWithOffsetDistance:(CGSize)offsetDistance
                        withinTimePieces:(NSUInteger)timepiece
{
    // Begin to decelerate
    _currentDeceleratedOffset = CGSizeZero;
    _currentStepPiece = 1;
    _maxStepPiece = timepiece;
    _willStopOffset = offsetDistance;
    
    // Re-calculate the init speed
    CGFloat _horSpeed = [PYResponderView
                         initSpeedWithAllMovingDistance:_willStopOffset.width
                         stepRate:PYScrollDecelerateStepRate
                         timePieces:timepiece];
    CGFloat _verSpeed = [PYResponderView
                         initSpeedWithAllMovingDistance:_willStopOffset.height
                         stepRate:PYScrollDecelerateStepRate
                         timePieces:timepiece];
    _decelerateInitSpeed = CGSizeMake(_horSpeed, _verSpeed);
    
    // Set the timer to run the animation.
    _decelerateTimer = [[NSTimer alloc]
                        initWithFireDate:[NSDate date]
                        interval:PYScrollDecelerateDurationPiece
                        target:self
                        selector:@selector(_decelerateAnimationTimerHandler:)
                        userInfo:nil
                        repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_decelerateTimer
                                 forMode:NSRunLoopCommonModes];
}

- (void)_decelerateAnimationDidStop
{
    if ( _willBounceBack == YES ) {
        _willBounceBack = NO;
        // Todo... bounce back.
        [self animatedScrollWithOffsetDistance:_willBounceOffset
                              withinTimePieces:60];
    } else {
        // We did stop the animation.
        [((NSObject *)self.delegate)
         tryPerformSelector:@selector(pyScrollViewDidEndDecelerate:)
         withObject:self];
    }
}

- (void)_decelerateAnimationTimerHandler:(id)sender
{
    CGFloat _rate = powf(PYScrollDecelerateStepRate, _currentStepPiece);
    CGFloat _horFn = (_decelerateInitSpeed.width * _rate);
    CGFloat _verFn = (_decelerateInitSpeed.height * _rate);
    _currentStepPiece += 1;
    
    if ( _currentStepPiece == _maxStepPiece ) {
        _horFn = _willStopOffset.width - _currentDeceleratedOffset.width;
        _verFn = _willStopOffset.height - _currentDeceleratedOffset.height;
    } else {
        _currentDeceleratedOffset.width += _horFn;
        _currentDeceleratedOffset.height += _verFn;
    }
    CGSize _offset = CGSizeMake(_horFn, _verFn);
    if ( _currentStepPiece > _maxStepPiece ) {
        [_decelerateTimer invalidate];
        _decelerateTimer = nil;
        [self _decelerateAnimationDidStop];
    } else {
        [self setMovingOffset:_offset
           withAnimatDuration:PYScrollDecelerateDurationPiece];
    }
}

- (void)setMovingOffset:(CGSize)contentOffset withAnimatDuration:(CGFloat)duration
{
    if ( duration > 0 ) {
        [CATransaction begin];
        [CATransaction setAnimationDuration:duration];
        [CATransaction
         setAnimationTimingFunction:
         [CAMediaTimingFunction
          functionWithName:kCAMediaTimingFunctionLinear]];
    }
    
    //[self _visiableSectionsMoveWithOffset:_offset];
    CATransform3D _transform = _contentView.layer.transform;
    _transform = CATransform3DTranslate(_transform, contentOffset.width, contentOffset.height, 0);
    [_contentView.layer setTransform:_transform];
    // Set the content offset.
    _contentOffset.width -= contentOffset.width;
    _contentOffset.height -= contentOffset.height;
    
    // Tell the delegate we are moving...
    [((NSObject *)self.delegate)
     tryPerformSelector:@selector(pyScrollViewDidScroll:)
     withObject:self];
    
    if ( duration > 0 ) {
        [CATransaction commit];
    }
}


@end

// @littlepush
// littlepush@gmail.com
// PYLab
