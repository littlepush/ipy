//
//  PYResponderView.m
//  PYUIKit
//
//  Created by Push Chen on 7/24/13.
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
#include <math.h>

// The event.
@implementation PYViewEvent

@synthesize eventId;
@synthesize touches;
@synthesize pinchRate;
@synthesize rotateDeltaArc;
@synthesize movingDeltaDistance;
@synthesize movingSpeed;
@synthesize swipeSide;
@synthesize hasMoved;

@end

@interface PYResponderView (Internal)

// Invoke the target of specified event.
- (void)_invokeTargetForEvent:(PYResponderEvent)event;

@end

@implementation PYResponderView

// Touch Info.
@synthesize firstTouchPoint = _firstTouchPoint;
@synthesize lastMovePoint = _lastMovePoint;

// Dynamic Properties
@dynamic canTap;
- (BOOL)canTap
{
    return (_responderAction & PYResponderEventTap) > 0;
}
@dynamic canPress;
- (BOOL)canPress
{
    return (_responderAction & PYResponderEventPress) > 0;
}
@dynamic canPen;
- (BOOL)canPen
{
    return (_responderAction & PYResponderEventPen) > 0;
}
@dynamic canSwipe;
- (BOOL)canSwipe
{
    return (_responderAction & PYResponderEventSwipe) > 0;
}
@dynamic canPinch;
- (BOOL)canPinch
{
    return (_responderAction & PYResponderEventPinch) > 0;
}

@dynamic tapCount;
- (NSUInteger)tapCount
{
    int _tapId = PYLAST1INDEX(PYResponderEventTap);
    return ((0x0000000F << _tapId) & _responderRestraint);
}
@dynamic pressFingers;
- (NSUInteger)pressFingers
{
    unsigned int _pressRestraintMask = 0x000000F0;
    return (_responderRestraint & _pressRestraintMask) >> 4;
}
@dynamic penDirections;
- (NSUInteger)penDirections
{
    return (_responderRestraint & PYResponderRestraintPenFreedom);
}
@dynamic swipeDirections;
- (NSUInteger)swipeDirections
{
    return (_responderRestraint & 0x000F0000);
}

// Messages.
- (void)viewJustBeenCreated
{
    [super viewJustBeenCreated];
    _speedTicker = [PYStopWatch object];
}

- (void)setEvent:(PYResponderEvent)event withRestraint:(PYResponderRestraint)restraint
{
    @synchronized( self ) {
        if ( event >= PYResponderEventTouchBegin ) return;
        unsigned int _restraintMask = 0x0000000F;
        int _eventId = PYLAST1INDEX(event);
        _restraintMask <<= (_eventId * 4);
        // Clear old restraint mask
        _responderRestraint &= ~_restraintMask;
        // Set new restraint mask
        _responderRestraint |= restraint;
        // Enable the event
        if ( restraint != PYResponderRestraintDisable ) {
            _responderAction |= event;
            if ( (_responderAction & PYResponderEventMultipleTouches) > 0 ) {
                [self setMultipleTouchEnabled:YES];
            } else {
                [self setMultipleTouchEnabled:NO];
            }
        } else {
            _responderAction &= (~event);
        }
    }
}

- (void)_invokeTargetForEvent:(PYResponderEvent)event info:(PYViewEvent *)info
{
    NSMutableArray *_callbackList = _eventTargetsActions[PYLAST1INDEX(event)];
    if ( _callbackList == nil ) return;
    info.eventId = event;
    for ( PYPair *_taPair in _callbackList ) {
        id _target = _taPair.first;
        SEL _action = NSSelectorFromString((NSString *)_taPair.secondValue);
        [(NSObject *)_target tryPerformSelector:_action
                                     withObject:self
                                     withObject:info];
    }
}

- (void)addTarget:(id)target action:(SEL)action forResponderEvent:(PYResponderEvent)event
{
    NSMutableArray *_callbackList = _eventTargetsActions[PYLAST1INDEX(event)];
    if ( _callbackList == nil ) {
        _callbackList = [NSMutableArray array];
        _eventTargetsActions[PYLAST1INDEX(event)] = _callbackList;
    }
    PYPair *_taPair = [PYPair object];
    _taPair.first = target;
    _taPair.secondValue = NSStringFromSelector(action);
    [_callbackList addObject:_taPair];
}

- (void)removeTarget:(id)target action:(SEL)action forResponderEvent:(PYResponderEvent)event
{
    NSMutableArray *_callbackList = _eventTargetsActions[PYLAST1INDEX(event)];
    if ( _callbackList == nil ) return;
    int _targetIndex = 0;
    int _taCount = [_callbackList count];
    for ( ; _targetIndex < _taCount; ++_targetIndex ) {
        PYPair *_taPair = [_callbackList safeObjectAtIndex:_targetIndex];
        if ( _taPair == nil ) return;
        if ( _taPair.first == target &&
            [(NSString *)_taPair.second isEqualToString:NSStringFromSelector(action)] ) {
            break;
        }
    }
    if ( _targetIndex == _taCount ) return;
    [_callbackList removeObjectAtIndex:_targetIndex];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Clear old data & initialize as zero.
    _swipeSide = 0;
    _lastMoveDistrance = CGSizeZero;
    _movingSpeed = CGPointZero;
    _isUserMoved = NO;
    
    PYViewEvent *_event = [PYViewEvent object];
    _event.touches = [[event touchesForWindow:[UIApplication sharedApplication].keyWindow] copy];
    [self _invokeTargetForEvent:PYResponderEventTouchBegin info:_event];
    // Increase the tap count.
    _tapCount += 1;
    int _touchCount = [_event.touches count];
    if ( (_responderAction & PYResponderEventNeedPredirect) == 0 ) {
        _nextResponderReceivedBeginEvent = YES;
        return [self.nextResponder touchesBegan:touches withEvent:event];
    }
    
    // Check finger press
    if ( (_responderAction & PYResponderEventPress) > 0 ) {
        unsigned int _pressRestraintMask = 0x000000F0;
        unsigned int _pressFingerCount = (_responderRestraint & _pressRestraintMask) >> 4;
        if ( _touchCount > _pressFingerCount ) {
            //_possibleAction &= ~PYResponderEventPress;
            //_nextResponderReceivedBeginEvent = YES;
            if ( _lagEventTimer != nil ) {
                [_lagEventTimer invalidate];
                _lagEventTimer = nil;
            }
            // return [self.nextResponder touchesBegan:touches withEvent:event];
        }
        if ( _touchCount == _pressFingerCount ) {
            if ( _lagEventTimer != nil ) {
                [_lagEventTimer invalidate];
            }
            _lagEventTimer = [NSTimer
                              scheduledTimerWithTimeInterval:2.f
                              target:self
                              selector:@selector(_pressEventHandler:)
                              userInfo:_event
                              repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:_lagEventTimer forMode:NSRunLoopCommonModes];
        } else {
            // Wait for more fingers...
        }
    }
    
    if ( _touchCount == 1 ) {
        UITouch *_touch = [_event.touches anyObject];
        _firstTouchPoint = [_touch locationInView:self];
        _lastMovePoint = _firstTouchPoint;
        [_speedTicker start];
    }
    if ( _touchCount == 2 ) {
        NSArray *_touches = [_event.touches allObjects];
        UITouch *_firstTouch = [_touches objectAtIndex:0];
        UITouch *_secondTouch = [_touches objectAtIndex:1];
        CGPoint _fPoint = [_firstTouch locationInView:self.superview];
        CGPoint _sPoint = [_secondTouch locationInView:self.superview];
        
        // Calculate the distance
        float _x = _fPoint.x - _sPoint.x;
        float _y = _fPoint.y - _sPoint.y;
        _pinchDistance = sqrt((_x * _x) + (_y * _y));
        
        // Calculate the rotate angle
        _rotateArc = atan(_y / _x);
    }
    
    // All action is possible.
    _possibleAction = _responderAction;
    // DUMPInt(_possibleAction);
    _nextResponderReceivedBeginEvent = NO;
    _lastMoveDistrance = CGSizeZero;

    _isUserIntractiviting = YES;
    if ( [[NSRunLoop currentRunLoop].currentMode
          isEqualToString:UITrackingRunLoopMode] ) return;
    while ( _isUserIntractiviting &&
           [[NSRunLoop currentRunLoop]
            runMode:UITrackingRunLoopMode
            beforeDate:[NSDate distantFuture]]);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    PYViewEvent *_event = [PYViewEvent object];
    _event.hasMoved = YES;
    _event.touches = [[event touchesForWindow:[UIApplication sharedApplication].keyWindow] copy];
    [self _invokeTargetForEvent:PYResponderEventTouchMove info:_event];
    // DUMPInt([[event touchesForView:self] count]);
    if ( _isUserIntractiviting == NO ) {
        return [self.nextResponder touchesMoved:touches withEvent:event];
    }
    _tapCount = 0;
    
    int _touchCount = [_event.touches count];
    // If the supported action does not contain dragging event, return.
    // And check if the next responder has received the touche begin
    // event.
    _possibleAction &= ~PYResponderEventTap;
    _possibleAction &= ~PYResponderEventPress;
    if ( _lagEventTimer != nil ) {
        [_lagEventTimer invalidate];
        _lagEventTimer = nil;
    }
    
    //DUMPInt(_possibleAction);
    if ( (_possibleAction & PYResponderEventSupportDragging) == 0 ) {
        if ( _nextResponderReceivedBeginEvent == NO ) {
            [self.nextResponder touchesBegan:touches withEvent:event];
            _nextResponderReceivedBeginEvent = YES;
        }
        //DUMPInt(_possibleAction);
        return [self.nextResponder touchesMoved:touches withEvent:event];
    }
    
    // No press here, so the multiple touch events are pinch and rotate.
    // both need two fingers.
    if ( (_possibleAction & PYResponderEventMultipleTouches) > 0 && _touchCount != 2 ) {
        _possibleAction &= ~PYResponderEventMultipleTouches;    // Failed to pinch and rotate.
    }
    
    _isUserMoved = YES;
    
    // Nothing to do for this action.
    if ( (_possibleAction & PYResponderEventNeedPredirect) == 0 ) {
        return [self.nextResponder touchesMoved:touches withEvent:event];
    }
    
    if ( _touchCount == 1 ) {
        UITouch *_touch = [_event.touches anyObject];
        CGPoint _movePoint = [_touch locationInView:self];
        CGSize _delta = CGSizeMake((_movePoint.x - _firstTouchPoint.x),
                                   (_movePoint.y - _firstTouchPoint.y));
        if ( (_possibleAction & PYResponderEventPen) > 0 ) {
            // Calculate the point in side
            CGSize _moveDistance = CGSizeMake(
                                              PYINDICATION_F(powf(PYABSF(_delta.width), .9f), _delta.width),
                                              PYINDICATION_F(powf(PYABSF(_delta.height), .9f), _delta.height)
                                              );
            CGSize _moveDelta = CGSizeMake(_moveDistance.width - _lastMoveDistrance.width,
                                           _moveDistance.height - _lastMoveDistrance.height);
            _lastMoveDistrance = _moveDistance;
            _lastMovePoint = _movePoint;
            [_speedTicker tick];
            double _timePassed = _speedTicker.milleseconds;
            [_speedTicker start];
            _movingSpeed = CGPointMake(_moveDelta.width / _timePassed,
                                       _moveDelta.height / _timePassed);
            _event.movingSpeed = _movingSpeed;
            _event.movingDeltaDistance = _moveDelta;
            
            [self _invokeTargetForEvent:PYResponderEventPen info:_event];
        }
        if ( (_possibleAction & PYResponderEventSwipe) > 0 ) {
            BOOL _isVel = PYABSF(_delta.width) < PYABSF(_delta.height);
            BOOL _isNagitive = *(&_delta.width + _isVel) < 0;
            int _side = ((PYResponderRestraintSwipeLeft << (_isVel * 2)) << (!_isNagitive));
            if ( _swipeSide == 0 ) {
                _swipeSide = _side;
            } else {
                if ( _swipeSide != _side ) {
                    _possibleAction &= ~PYResponderEventSwipe;
                    _swipeSide = 0;
                }
            }
        }
    } else if ( _touchCount == 2 ) {
        NSArray *_touches = [_event.touches allObjects];
        UITouch *_firstTouch = [_touches objectAtIndex:0];
        UITouch *_secondTouch = [_touches objectAtIndex:1];
        CGPoint _fPoint = [_firstTouch locationInView:self.superview];
        CGPoint _sPoint = [_secondTouch locationInView:self.superview];
        
        // Calculate the distance
        float _x = _fPoint.x - _sPoint.x;
        float _y = _fPoint.y - _sPoint.y;
        if ( (_possibleAction & PYResponderEventPinch) > 0 ) {
            CGFloat _currentDistance = sqrt((_x * _x) + (_y * _y));
            _event.pinchRate = (_currentDistance / _pinchDistance);
            _pinchDistance = _currentDistance;
            [self _invokeTargetForEvent:PYResponderEventPinch info:_event];
        }
        // Calculate the rotate angle
        if ( (_possibleAction & PYResponderEventRotate) > 0 ) {
            CGFloat _currentArc = atan(_y / _x) + (M_PI * 2);
            _event.rotateDeltaArc = (_currentArc - _rotateArc);
            _rotateArc = _currentArc;
            [self _invokeTargetForEvent:PYResponderEventRotate info:_event];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    PYViewEvent *_event = [PYViewEvent object];
    _event.touches = [[event touchesForWindow:[UIApplication sharedApplication].keyWindow] copy];
    _event.movingSpeed = _movingSpeed;
    _event.movingDeltaDistance = CGSizeZero;
    _event.hasMoved = _isUserMoved;
    [self _invokeTargetForEvent:PYResponderEventTouchEnd info:_event];
    if ( _isUserIntractiviting == NO ) {
        return [self.nextResponder touchesEnded:touches withEvent:event];
    }
    
    _isUserIntractiviting = NO;
    // All supported events been canceled.
    if ( (_possibleAction & PYResponderEventNeedPredirect) == 0 ) {
        if ( _nextResponderReceivedBeginEvent == NO ) {
            [self.nextResponder touchesBegan:touches withEvent:event];
            _nextResponderReceivedBeginEvent = YES;
        }
        //DUMPInt(_possibleAction);
        return [self.nextResponder touchesEnded:touches withEvent:event];
    }
    
    if ( (_possibleAction & PYResponderEventTap) > 0 ) {
        if ( _lagEventTimer != nil ) {
            [_lagEventTimer invalidate];
        }
        _lagEventTimer = [NSTimer
                          scheduledTimerWithTimeInterval:.175
                          target:self
                          selector:@selector(_tapEventHandler:)
                          userInfo:_event
                          repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:_lagEventTimer forMode:NSRunLoopCommonModes];
        return [self.nextResponder touchesEnded:touches withEvent:event];
    }
    
    if ( (_possibleAction & PYResponderEventPress) > 0 ) {
        // Nothing to do...
        if ( _lagEventTimer != nil ) {
            [_lagEventTimer invalidate];
            _lagEventTimer = nil;
        }
    }
    
    if ( (_possibleAction & PYResponderEventSwipe) ) {
        if ( _isUserMoved == YES ) {
            // Calculate the swipe direction...
            if ( (_swipeSide & _responderRestraint) > 0 ) {
                _event.swipeSide = _swipeSide;
                [self _invokeTargetForEvent:PYResponderEventSwipe info:_event];
            }
        }
    }
    
    _tapCount = 0;
    return [self.nextResponder touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    PYViewEvent *_event = [PYViewEvent object];
    _event.touches = [[event touchesForView:self] copy];
    [self _invokeTargetForEvent:PYResponderEventTouchCancel info:_event];
    if ( _isUserIntractiviting == NO ) {
        return [self.nextResponder touchesCancelled:touches withEvent:event];
    }
}

#pragma mark --
#pragma mark Event Handler

- (void)_tapEventHandler:(id)sender
{
    int _tapId = PYLAST1INDEX(PYResponderEventTap);
    unsigned int _tapRestraint = ((0x0000000F << _tapId) & _responderRestraint);
    if ( _tapCount == _tapRestraint ) {
        [self _invokeTargetForEvent:PYResponderEventTap
                               info:(PYViewEvent *)_lagEventTimer.userInfo];
    }
    _tapCount = 0;
    [_lagEventTimer invalidate];
    _lagEventTimer = nil;
}

- (void)_pressEventHandler:(id)sender
{
    [self _invokeTargetForEvent:PYResponderEventPress
                           info:(PYViewEvent *)_lagEventTimer.userInfo];
    [_lagEventTimer invalidate];
    _lagEventTimer = nil;
}

#pragma mark --
#pragma mark Global Formular
+ (CGFloat)distanceToMoveWithInitSpeed:(CGFloat)speed stepRate:(CGFloat)step timePieces:(NSUInteger)piece
{
    if ( speed == 0 ) return 0;
    // D = S•(å•å^n - å)/(å - 1)
    CGFloat _distance = speed * (step * (powf(step, piece) - 1) / (step - 1.f));
    return _distance;
}

+ (CGFloat)initSpeedWithAllMovingDistance:(CGFloat)distance stepRate:(CGFloat)step timePieces:(NSUInteger)piece
{
    if ( distance == 0 ) return 0;
    // D = S•(å•å^n - å)/(å - 1)
    CGFloat _speed = distance / (step * (powf(step, piece) - 1) / (step - 1.f));
    return _speed;
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
