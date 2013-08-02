//
//  PYResponderView.m
//  PYUIKit
//
//  Created by Push Chen on 7/24/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import "PYResponderView.h"
#include <math.h>

// The event.
@implementation PYViewEvent

@synthesize eventId;
@synthesize sysEvent;
@synthesize pinchRate;
@synthesize rotateDeltaArc;
@synthesize movingDeltaDistance;
@synthesize movingSpeed;

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
    PYViewEvent *_event = [PYViewEvent object];
    _event.sysEvent = event;
    [self _invokeTargetForEvent:PYResponderEventTouchBegin info:_event];
    // Increase the tap count.
    _tapCount += 1;
    int _touchCount = [[event touchesForView:self] count];
    if ( (_responderAction & PYResponderEventNeedPredirect) == 0 ) {
        _nextResponderReceivedBeginEvent = YES;
        return [self.nextResponder touchesBegan:touches withEvent:event];
    }
    
    // Check finger press
    if ( (_responderAction & PYResponderEventPress) > 0 ) {
        unsigned int _pressRestraintMask = 0x000000F0;
        unsigned int _pressFingerCount = (_responderRestraint & _pressRestraintMask) >> 4;
        IF ( _touchCount > _pressFingerCount ) {
            //_possibleAction &= ~PYResponderEventPress;
            //_nextResponderReceivedBeginEvent = YES;
            if ( _lagEventTimer != nil ) {
                [_lagEventTimer invalidate];
                _lagEventTimer = nil;
            }
            // return [self.nextResponder touchesBegan:touches withEvent:event];
        }
        IF ( _touchCount == _pressFingerCount ) {
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
        UITouch *_touch = [touches anyObject];
        _firstTouchPoint = [_touch locationInView:self];
        _lastMovePoint = _firstTouchPoint;
        [_speedTicker start];
    }
    if ( _touchCount == 2 ) {
        NSArray *_touches = [[event touchesForView:self] allObjects];
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
    // DUMPInt([[event touchesForView:self] count]);
    if ( _isUserIntractiviting == NO ) {
        return [self.nextResponder touchesMoved:touches withEvent:event];
    }
    _tapCount = 0;
    PYViewEvent *_event = [PYViewEvent object];
    _event.sysEvent = event;
    [self _invokeTargetForEvent:PYResponderEventTouchMove info:_event];
    
    int _touchCount = [[event touchesForView:self] count];
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
        UITouch *_touch = [touches anyObject];
        
        if ( (_responderAction & PYResponderEventPen) > 0 ) {
            // Calculate the point in side
            CGPoint _movePoint = [_touch locationInView:self];
            CGSize _delta = CGSizeMake((_movePoint.x - _firstTouchPoint.x),
                                       (_movePoint.y - _firstTouchPoint.y));
            CGSize _moveDistance =
            CGSizeMake( powf(_delta.width, .9f), powf(_delta.height, .9f) );
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
    } else if ( _touchCount == 2 ) {
        NSArray *_touches = [[event touchesForView:self] allObjects];
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
    DUMPInt([[event touchesForView:self] count]);
    if ( _isUserIntractiviting == NO ) {
        return [self.nextResponder touchesEnded:touches withEvent:event];
    }
    PYViewEvent *_event = [PYViewEvent object];
    _event.sysEvent = event;
    [self _invokeTargetForEvent:PYResponderEventTouchEnd info:_event];
    
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
        }
    }
    
    _tapCount = 0;
    return [self.nextResponder touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ( _isUserIntractiviting == NO ) {
        return [self.nextResponder touchesCancelled:touches withEvent:event];
    }
    PYViewEvent *_event = [PYViewEvent object];
    _event.sysEvent = event;
    [self _invokeTargetForEvent:PYResponderEventTouchCancel info:_event];
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

@end
