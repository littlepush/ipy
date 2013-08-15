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
#import "UIColor+PYUIKit.h"
#import "PYUIKitMacro.h"

@implementation PYScrollView (SideAnimation)

@dynamic isLoopEnabled;
- (BOOL)isLoopEnabled
{
    return _loopSupported;
}

- (void)setSupportLoop:(BOOL)isLoopEnabled
{
    _loopSupported = isLoopEnabled;
}

- (void)calculateDecelerateDistanceAndSetJellyPointWithInitSpeed:(CGSize)initSpeed
                                              decelerateDuration:(CGFloat *)dduration
                                                  bounceDuration:(CGFloat *)bduration
{
    // for default
    if ( dduration == NULL ) return;
    *dduration = PYScrollDecelerateDuration;
    
    _willBounceBack = NO;
    CGFloat _horDistance = [PYResponderView
                            distanceToMoveWithInitSpeed:initSpeed.width
                            stepRate:PYScrollDecelerateStepRate
                            timePieces:PYScrollDecelerateTimePiece];
    CGFloat _verDistance = [PYResponderView
                            distanceToMoveWithInitSpeed:initSpeed.height
                            stepRate:PYScrollDecelerateStepRate
                            timePieces:PYScrollDecelerateTimePiece];
    
    CGRect _predirectContentFrame = CGRectMake(
                                               -(_contentOffset.width - _horDistance),
                                               -(_contentOffset.height - _verDistance),
                                               _contentSize.width,
                                               _contentSize.height);
    _willStopOffset = CGSizeMake(_horDistance, _verDistance);
    if ( _pagable == YES && (_pageSize.width * _pageSize.height) != 0.f ) {
        for ( int i = 0; i < 2; ++i ) {
            if ( _SIDE(_pageSize) == 0 ) continue;
            CGFloat _position = _SIDE(_predirectContentFrame.origin);
            int _pages = (int)(_position / _SIDE(_pageSize));
            CGFloat _stopPosition = _pages * _SIDE(_pageSize);
            _SIDE(_willStopOffset) += (_stopPosition - _position);
        }
    }
    
    // If current scroll view support loop, the stop offset is what we will stop place.
    if ( _loopSupported == YES ) return;
    
    // Check side.
    // Get the minimal visiable frame
    CGRect _bounds = self.bounds;
    CGRect _minimalVisiableFrame = CGRectMake(0, 0,
                                              MIN(_bounds.size.width, _contentSize.width),
                                              MIN(_bounds.size.height, _contentSize.height));
    BOOL _needBounceBack = !PYIsRectInside(_minimalVisiableFrame, _predirectContentFrame);
    // Just scroll it!
    if ( _needBounceBack == NO ) return;
    
    CGPoint _currentPoint = CGPointMake(-_contentOffset.width,
                                       -_contentOffset.height);
    CGPoint _predirectPoint = _predirectContentFrame.origin;
    
    // calculate each side.
    _willBounceOffset = CGSizeZero;
    for ( int i = 0; i < 2; ++i ) {
        CGFloat _finalVisiablePosition = 0.f;
        // Get the final stop position.
        if ( _SIDE(_minimalVisiableFrame.size) < _SIDE(_bounds.size) ) {
            _finalVisiablePosition = 0.f;
        } else {
            if ( _SIDE(_predirectPoint) > 0 ) _finalVisiablePosition = 0;
            else _finalVisiablePosition = _SIDE(_bounds.size) - _SIDE(_contentSize);
        }
        
        // calculate the reentry point
        if ( _BOUNCE_STATUE_ == NO ) {
            _SIDE(_willStopOffset) = (_SIDE(_contentOffset) - _finalVisiablePosition);
            *dduration = PYScrollDecelerateDuration;
        } else {
            CGFloat _tmp = ((_SIDE(_currentPoint) - _finalVisiablePosition) *
                            (_SIDE(_predirectPoint) - _finalVisiablePosition));
            if ( _tmp > 0 ) {
                // Already overhead
                CGFloat _distance = _SIDE(_predirectPoint) - _SIDE(_currentPoint);
                _distance = PYINDICATION_F(powf(PYABSF(_distance), PYScrollOverheadRate), _distance);
                _SIDE(_willStopOffset) = _distance;
                _SIDE(_willBounceOffset) = -(_SIDE(_currentPoint) - _finalVisiablePosition + _distance);
                *dduration = PYScrollBounceBackDuration / 2;
            } else {
                CGFloat _step1 = _finalVisiablePosition - _SIDE(_currentPoint);
                CGFloat _step2 = _SIDE(_predirectPoint) - _finalVisiablePosition;
                _step2 = PYINDICATION_F(pow(PYABSF(_step2), PYScrollOverheadRate), _step2);
                _SIDE(_willStopOffset) = _step1 + _step2;
                _SIDE(_willBounceOffset) = -_step2;
                *dduration = PYScrollDecelerateNeedBounceDuration;
            }
            *bduration = PYScrollBounceBackDuration;
        }
    }
    
    // check if need bounce back.
    _willBounceBack = ((_bounceStatus[0] | _bounceStatus[1]) & _needBounceBack);
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
                              withinTimePieces:_SCROLL_TIME_PIECE_(_bounceDuration)];
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
    //DUMPFloat(contentOffset.height);
    [self willMoveToOffsetWithDistance:contentOffset];
    if ( duration > 0 ) {
        [CATransaction begin];
        [CATransaction setAnimationDuration:duration];
        [CATransaction
         setAnimationTimingFunction:
         [CAMediaTimingFunction
          functionWithName:kCAMediaTimingFunctionLinear]];
        __block PYScrollView *_bss = self;
        [CATransaction setCompletionBlock:^{
            [_bss didMoveToOffsetWithDistance:contentOffset];
        }];
    }
    
    //[self _visiableSectionsMoveWithOffset:_offset];
    for ( UIView *_sc in _subContentList ) {
#ifdef _SCROLL_USE_LAYER_TRANSFORM_
        CATransform3D _transform = _sc.layer.transform;
        _transform = CATransform3DTranslate(_transform, contentOffset.width, contentOffset.height, 0);
        [_sc.layer setTransform:_transform];
#else
        CGAffineTransform _transform = _sc.transform;
        _transform = CGAffineTransformTranslate(_transform, contentOffset.width, contentOffset.height);
        [_sc setTransform:_transform];
#endif
        //DUMPRect(_sc.frame);
    }
    
    // Set the content offset.
    _contentOffset.width -= contentOffset.width;
    _contentOffset.height -= contentOffset.height;
    
    // Change the cover frame origin.
    _coverFrame.origin.x += contentOffset.width;
    _coverFrame.origin.y += contentOffset.height;
    
    if ( duration == 0 ) {
        [self didMoveToOffsetWithDistance:contentOffset];
    }
    
    // Tell the delegate we are moving...
    [((NSObject *)self.delegate)
     tryPerformSelector:@selector(pyScrollViewDidScroll:)
     withObject:self];
    
    if ( duration > 0 ) {
        [CATransaction commit];
    }
}

@dynamic subContentViews;
- (NSArray *)subContentViews
{
    return _subContentList;
}

- (void)willMoveToOffsetWithDistance:(CGSize)distance
{
    // Calculate the cover frame
    // If not fill the bounds
    // load more content view
    // if fill all, do nothing, just tell the child view
    // we will move.
    
    if ( _loopSupported != YES ) return;
    CGRect _fakeCoverFrame = _coverFrame;
    _fakeCoverFrame.origin.x += distance.width;
    _fakeCoverFrame.origin.y += distance.height;
    
    while ( !PYIsRectInside(self.bounds, _fakeCoverFrame) ) {
        UIView *_sc = [[[self class] contentViewClass] object];
        [_sc setBackgroundColor:self.backgroundColor];
        if ( _fakeCoverFrame.origin.x > 0 || _fakeCoverFrame.origin.y > 0 ) {
            // Insert
            UIView *_fsc = (UIView *)[_subContentList safeObjectAtIndex:0];
            CGRect _sf = _fsc.frame;
#ifdef _SCROLL_USE_LAYER_TRANSFORM_
            CATransform3D _t = _fsc.layer.transform;
            _sf.origin.x -= _t.m41;
            _sf.origin.y -= _t.m42;
#else
            CGAffineTransform _t = _fsc.transform;
            _sf.origin.x -= _t.tx;
            _sf.origin.y -= _t.ty;
#endif
            if ( (_scrllSide & PYScrollHorizontal) > 0 ) {
                _sf.origin.x -= _sf.size.width;
                _fakeCoverFrame.origin.x -= _sf.size.width;
                _fakeCoverFrame.size.width += _sf.size.width;
                _coverFrame.origin.x -= _sf.size.width;
                _coverFrame.size.width += _sf.size.width;
            } else {
                _sf.origin.y -= _sf.size.height;
                _fakeCoverFrame.origin.y -= _sf.size.height;
                _fakeCoverFrame.size.height += _sf.size.height;
                _coverFrame.origin.y -= _sf.size.height;
                _coverFrame.size.height += _sf.size.height;
            }
            [_sc setFrame:_sf];
#ifdef _SCROLL_USE_LAYER_TRANSFORM_
            [_sc.layer setTransform:_fsc.layer.transform];
#else
            [_sc setTransform:_fsc.transform];
#endif
            [_subContentList insertObject:_sc atIndex:0];
        } else {
            // Append
            UIView *_lsc = (UIView *)[_subContentList lastObject];
            CGRect _sf = _lsc.frame;
#ifdef _SCROLL_USE_LAYER_TRANSFORM_
            CATransform3D _t = _lsc.layer.transform;
            _sf.origin.x -= _t.m41;
            _sf.origin.y -= _t.m42;
#else
            CGAffineTransform _t = _lsc.transform;
            _sf.origin.x -= _t.tx;
            _sf.origin.y -= _t.ty;
#endif
            if ( (_scrllSide & PYScrollHorizontal) > 0 ) {
                _sf.origin.x += _sf.size.width;
                _fakeCoverFrame.size.width += _sf.size.width;
                _coverFrame.size.width += _sf.size.width;
            } else {
                _sf.origin.y += _sf.size.height;
                _fakeCoverFrame.size.height += _sf.size.height;
                _coverFrame.size.height += _sf.size.height;
            }
            [_sc setFrame:_sf];
#ifdef _SCROLL_USE_LAYER_TRANSFORM_
            [_sc.layer setTransform:_lsc.layer.transform];
#else
            [_sc setTransform:_lsc.transform];
#endif
            [_subContentList addObject:_sc];
        }
        [self addSubview:_sc];
    }
}

- (void)didMoveToOffsetWithDistance:(CGSize)distance
{
    // Calculate the cover frame
    // Whether or not need to remove a previous content view.
    // Then tell the child we have been moved.
    
    if ( _loopSupported != YES ) return;
    
    NSMutableArray *_removeContentList = [NSMutableArray array];
    CGRect _myBounds = self.bounds;
    for ( PYView *_subContentView in _subContentList ) {
        CGRect _sFrame = _subContentView.frame;
        if ( PYIsRectJoined(_sFrame, _myBounds) ) {
            continue;
        }
        [_removeContentList addObject:_subContentView];
        
        if ( _SIDE_ITEM(distance) < 0 ) {
            // remove top
            _SIDE_ITEM(_coverFrame.origin) += _SIDE_ITEM(_sFrame.size);
        } else {
            // remove bottom
        }
        _SIDE_ITEM(_coverFrame.size) -= _SIDE_ITEM(_sFrame.size);
    }
    if ( [_removeContentList count] == 0 ) return;
    for ( PYView *_rContent in _removeContentList ) {
        [_subContentList removeObject:_rContent];
        [_rContent removeFromSuperview];
    }
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
