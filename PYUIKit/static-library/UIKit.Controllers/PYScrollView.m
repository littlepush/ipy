//
//  PYScrollView.m
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

#import "PYScrollView.h"

NSUInteger const         PYScrollDecelerateTimePiece        = 60;
CGFloat const            PYScrollDecelerateStepRate         = .9f;
CGFloat const            PYScrollDecelerateDuration         = 1.5f;
CGFloat const            PYScrollDecelerateDurationPiece    = .025f;

@implementation PYScrollView

@synthesize scrollSide = _scrllSide;
@synthesize decelerateSpeed = _decelerateSpeed;

- (void)_actionTouchBeginHandler:(id)sender event:(PYViewEvent *)event
{
    // Tell the delegate
    if ( _decelerateTimer != nil ) {
        [_decelerateTimer invalidate];
        _decelerateTimer = nil;
        _isDecelerating = NO;
    }
    [((NSObject *)self.delegate)
     tryPerformSelector:@selector(pyScrollViewWillBeginToScroll:)
     withObject:self];
}

- (void)_actionTouchEndHandler:(id)sender event:(PYViewEvent *)event
{
    if ( event.hasMoved == NO ) return;
    BOOL _willDecelerate = YES;
    if ( event.movingSpeed.x == 0 && event.movingSpeed.y == 0 ) {
        _willDecelerate = NO;
    }
    if ( _decelerateSpeed == PYDecelerateSpeedZero ) {
        _willDecelerate = NO;
    }
    
    if ( _willDecelerate == YES ) {
        CGFloat _decelerateRate = _decelerateSpeed * 2.5f;
        CGSize _initDecelerateSpeed = CGSizeMake(event.movingSpeed.x * _decelerateRate,
                                                 event.movingSpeed.y * _decelerateRate);
        if ( (_scrllSide & PYScrollHorizontal) == 0 ) _initDecelerateSpeed.width = 0;
        if ( (_scrllSide & PYScrollVerticalis) == 0 ) _initDecelerateSpeed.height = 0;
        
        CGFloat _horDistance = [PYResponderView
                                distanceToMoveWithInitSpeed:_initDecelerateSpeed.width
                                stepRate:PYScrollDecelerateStepRate
                                timePieces:PYScrollDecelerateTimePiece];
        CGFloat _verDistance = [PYResponderView
                                distanceToMoveWithInitSpeed:_initDecelerateSpeed.height
                                stepRate:PYScrollDecelerateStepRate
                                timePieces:PYScrollDecelerateTimePiece];
        _willStopOffset = CGSizeMake(_horDistance, _verDistance);
        _willDecelerate = [self willScrollWithMovingDistance:_willStopOffset];
    }
    if ( [self.delegate respondsToSelector:@selector(pyScrollViewDidEndScroll:willDecelerate:)] ) {
        [self.delegate pyScrollViewDidEndScroll:self willDecelerate:_willDecelerate];
    }
    
    // Return if not need to decelerate
    if ( _willDecelerate == NO ) return;
    
    // Begin to decelerate
    _currentDeceleratedOffset = CGSizeZero;
    _currentStepPiece = 1;
    _maxStepPiece = PYScrollDecelerateTimePiece;
    // Re-calculate the init speed
    CGFloat _horSpeed = [PYResponderView
                         initSpeedWithAllMovingDistance:_willStopOffset.width
                         stepRate:PYScrollDecelerateStepRate
                         timePieces:PYScrollDecelerateTimePiece];
    CGFloat _verSpeed = [PYResponderView
                         initSpeedWithAllMovingDistance:_willStopOffset.height
                         stepRate:PYScrollDecelerateStepRate
                         timePieces:PYScrollDecelerateTimePiece];
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
                                 forMode:UITrackingRunLoopMode];
    _isDecelerating = YES;
    while ( _isDecelerating &&
           [[NSRunLoop currentRunLoop]
            runMode:UITrackingRunLoopMode
            beforeDate:[NSDate distantFuture]]);
}

- (void)_actionTouchPenHandler:(id)sender event:(PYViewEvent *)event
{
    // Move the subviews
    CGSize _movingDistance = event.movingDeltaDistance;
    if ( (_scrllSide & PYScrollHorizontal) == 0 ) _movingDistance.width = 0;
    if ( (_scrllSide & PYScrollVerticalis) == 0 ) _movingDistance.height = 0;

    for ( UIView *_sub in self.subviews ) {
        CGRect _sFrame = _sub.frame;
        _sFrame.origin.x += _movingDistance.width;
        _sFrame.origin.y += _movingDistance.height;
        [_sub setFrame:_sFrame];
    }
}

- (void)viewJustBeenCreated
{
    [super viewJustBeenCreated];
    
    // Initialize the scroll side as freedom.
    _scrllSide = PYScrollFreedom;
    _decelerateSpeed = PYDecelerateSpeedNormal;
    
    // Initialize the data
    _contentSize = CGSizeZero;
    _contentOffset = CGSizeZero;
    _contentInsets = UIEdgeInsetsZero;
    _willStopOffset = CGSizeZero;
    _contentRect = CGRectZero;
    
    [self setEvent:PYResponderEventPen withRestraint:PYResponderRestraintPenFreedom];
    [self addTarget:self
             action:@selector(_actionTouchBeginHandler:event:)
  forResponderEvent:PYResponderEventTouchBegin];
    [self addTarget:self
             action:@selector(_actionTouchEndHandler:event:)
  forResponderEvent:PYResponderEventTouchEnd];
    [self addTarget:self
             action:@selector(_actionTouchPenHandler:event:)
  forResponderEvent:PYResponderEventPen];
}

- (void)_generateContentRect
{
    if ( [self.subviews count] == 0 ) {
        _contentRect = CGRectZero; return;
    }
    _contentRect = ((UIView *)[self.subviews lastObject]).frame;
    for ( UIView *_sub in self.subviews ) {
        _contentRect = PYRectCombine(_contentRect, _sub.frame);
    }
}

- (void)_decelerateAnimationTimerHandler:(id)sender
{
    CGFloat _horFn = _decelerateInitSpeed.width * powf(PYScrollDecelerateStepRate, _currentStepPiece);
    CGFloat _verFn = _decelerateInitSpeed.height * powf(PYScrollDecelerateStepRate, _currentStepPiece);
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
        _isDecelerating = NO;
        [((NSObject *)self.delegate)
         tryPerformSelector:@selector(pyScrollViewDidEndDecelerate:)
         withObject:self];
    } else {
        [self _setContentOffset:_offset
             withAnimatDuration:PYScrollDecelerateDurationPiece];
    }
}

- (void)_setContentOffset:(CGSize)contentOffset withAnimatDuration:(CGFloat)duration
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
    for ( UIView *_sub in self.subviews ) {
        CGRect _sFrame = _sub.frame;
        _sFrame.origin.x += contentOffset.width;
        _sFrame.origin.y += contentOffset.height;
        [_sub setFrame:_sFrame];
    }
    
    if ( duration > 0 ) {
        [CATransaction commit];
    }
}

- (void)setContentOffset:(CGSize)contentOffset animated:(BOOL)animated
{
    CGFloat _duration = (animated ? .175 : 0.f);
    [self _setContentOffset:contentOffset withAnimatDuration:_duration];
}

- (void)scrollToTop
{
    [self setContentOffset:CGSizeMake(_contentOffset.width, 0) animated:YES];
}
- (void)scrollToLeft
{
    [self setContentOffset:CGSizeMake(0, _contentOffset.height) animated:YES];
}
- (void)scrollToBottom
{
    if ( _contentSize.height < self.bounds.size.height ) {
        [self scrollToTop];
    } else {
        [self
         setContentOffset:CGSizeMake(_contentOffset.width,
                                     self.bounds.size.height - _contentSize.height)
         animated:YES];
    }
}
- (void)scrollToRight
{
    if ( _contentSize.width < self.bounds.size.width ) {
        [self scrollToLeft];
    } else {
        [self
         setContentOffset:CGSizeMake(
                                     self.bounds.size.width - _contentSize.width,
                                     _contentOffset.height)
         animated:YES];
    }
}

- (void)addSubview:(UIView *)view
{
    [super addSubview:view];
    if ( CGRectIsEmpty(_contentRect) ) {
        _contentRect = view.frame;
    } else {
        _contentRect = PYRectCombine(_contentRect, view.frame);
    }
}

- (void)insertSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview
{
    [super insertSubview:view aboveSubview:siblingSubview];
    if ( CGRectIsEmpty(_contentRect) ) {
        _contentRect = view.frame;
    } else {
        _contentRect = PYRectCombine(_contentRect, view.frame);
    }
}

- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index
{
    [super insertSubview:view atIndex:index];
    if ( CGRectIsEmpty(_contentRect) ) {
        _contentRect = view.frame;
    } else {
        _contentRect = PYRectCombine(_contentRect, view.frame);
    }
}

- (void)insertSubview:(UIView *)view belowSubview:(UIView *)siblingSubview
{
    [super insertSubview:view belowSubview:siblingSubview];
    if ( CGRectIsEmpty(_contentRect) ) {
        _contentRect = view.frame;
    } else {
        _contentRect = PYRectCombine(_contentRect, view.frame);
    }
}

- (void)willRemoveSubview:(UIView *)subview
{
    [super willRemoveSubview:subview];
    // Inside one...do nothing, side one, resize
    if ( !CGRectContainsRect(_contentRect, subview.frame) ) {
        [self _generateContentRect];
    }
}

- (BOOL)willScrollWithMovingDistance:(CGSize)movingDistance
{
    // nothing to do in super class
    return YES;
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
