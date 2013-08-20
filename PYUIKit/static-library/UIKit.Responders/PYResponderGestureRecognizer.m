//
//  PYResponderGestureRecognizer.m
//  PYUIKit
//
//  Created by Push Chen on 8/16/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import "PYResponderGestureRecognizer.h"

// The event.
@implementation PYViewEvent

@synthesize eventId;
@synthesize touches;
@synthesize sysEvent;
@synthesize pinchRate;
@synthesize rotateDeltaArc;
@synthesize movingDeltaDistance;
@synthesize movingSpeed;
@synthesize swipeSide;
@synthesize hasMoved;

@end

@implementation PYResponderGestureRecognizer

// Touch Info.
@synthesize firstTouchPoint = _firstTouchPoint;
@synthesize lastMovePoint = _lastMovePoint;

@synthesize eventInfo = _eventInfo;
@synthesize movingSpeed = _movingSpeed;

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
    return (_responderAction & PYResponderEventPan) > 0;
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
    return (_responderRestraint & PYResponderRestraintPanFreedom);
}
@dynamic swipeDirections;
- (NSUInteger)swipeDirections
{
    return (_responderRestraint & 0x000F0000);
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
//            if ( (_responderAction & PYResponderEventMultipleTouches) > 0 ) {
//                [self setMultipleTouchEnabled:YES];
//            } else {
//                [self setMultipleTouchEnabled:NO];
//            }
        } else {
            _responderAction &= (~event);
        }
    }
}

- (id)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithTarget:target action:action];
    if ( self ) {
        _eventInfo = [PYViewEvent object];
        _speedTicker = [PYStopWatch object];
    }
    return self;
}

// Method to override.
- (void)reset
{
    [super reset];
    // Clear old data & initialize as zero.
    _swipeSide = 0;
    _lastMoveDistrance = CGSizeZero;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _eventInfo.swipeSide = 0;
    _eventInfo.hasMoved = NO;
    _eventInfo.rotateDeltaArc = 0.f;
    _eventInfo.pinchRate = 0.f;
    
    [super touchesBegan:touches withEvent:event];
    _eventInfo.touches = [[event touchesForWindow:self.view.window] copy];
    _eventInfo.sysEvent = event;
    
    // Increase the tap count.
    _tapCount += 1;
    int _touchCount = [_eventInfo.touches count];
    // All action is possible.
    _possibleAction = _responderAction;
    
    // Check finger press
    if ( (_possibleAction & PYResponderEventPress) > 0 ) {
        unsigned int _pressRestraintMask = 0x000000F0;
        unsigned int _pressFingerCount = (_responderRestraint & _pressRestraintMask) >> 4;
        if ( _touchCount > _pressFingerCount ) {
            _possibleAction &= ~PYResponderEventPress;
            if ( _lagEventTimer != nil ) {
                [_lagEventTimer invalidate];
                _lagEventTimer = nil;
            }
        }
        if ( _touchCount == _pressFingerCount ) {
            if ( _lagEventTimer != nil ) {
                [_lagEventTimer invalidate];
            }
            _lagEventTimer = [NSTimer
                              scheduledTimerWithTimeInterval:2.f
                              target:self
                              selector:@selector(_pressEventHandler:)
                              userInfo:nil
                              repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:_lagEventTimer forMode:NSRunLoopCommonModes];
        } else {
            // Wait for more fingers...
        }
    }
    
    if ( (_possibleAction & PYResponderEventNeedPredirect) == 0 ) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    
    if ( _touchCount == 1 ) {
        UITouch *_touch = [_eventInfo.touches anyObject];
        _firstTouchPoint = [_touch locationInView:self.view];
        _lastMovePoint = _firstTouchPoint;
        [_speedTicker start];
    }
    if ( _touchCount == 2 ) {
        NSArray *_touches = [_eventInfo.touches allObjects];
        UITouch *_firstTouch = [_touches objectAtIndex:0];
        UITouch *_secondTouch = [_touches objectAtIndex:1];
        CGPoint _fPoint = [_firstTouch locationInView:self.view.window];
        CGPoint _sPoint = [_secondTouch locationInView:self.view.window];
        
        // Calculate the distance
        float _x = _fPoint.x - _sPoint.x;
        float _y = _fPoint.y - _sPoint.y;
        _pinchDistance = sqrt((_x * _x) + (_y * _y));
        // Calculate the rotate angle
        _rotateArc = atan(_y / _x);
    }
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    _eventInfo.hasMoved = YES;
    _eventInfo.touches = [[event touchesForWindow:self.view.window] copy];
    _eventInfo.sysEvent = event;

    // Reset the tap count.
    _tapCount = 0;
    
    int _touchCount = [_eventInfo.touches count];
    
    // If the supported action does not contain dragging event, return.
    // And check if the next responder has received the touche begin
    // event.
    _possibleAction &= ~PYResponderEventTap;
    _possibleAction &= ~PYResponderEventPress;
    if ( _lagEventTimer != nil ) {
        [_lagEventTimer invalidate];
        _lagEventTimer = nil;
    }
    
    // No press here, so the multiple touch events are pinch and rotate.
    // both need two fingers.
    if ( (_possibleAction & PYResponderEventMultipleTouches) > 0 && _touchCount != 2 ) {
        _possibleAction &= ~PYResponderEventMultipleTouches;    // Failed to pinch and rotate.
    }

    // Nothing to do for this action.
    if ( (_possibleAction & PYResponderEventNeedPredirect) == 0 ) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    
    if ( _touchCount == 1 && (_possibleAction & PYResponderEventSingleDragging) > 0 ) {
        UITouch *_touch = [_eventInfo.touches anyObject];
        CGPoint _movePoint = [_touch locationInView:self.view.window];
        CGSize _delta = CGSizeMake((_movePoint.x - _firstTouchPoint.x),
                                   (_movePoint.y - _firstTouchPoint.y));
        if ( (_possibleAction & PYResponderEventPan) > 0 ) {
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
            _eventInfo.movingSpeed = _movingSpeed;
            _eventInfo.movingDeltaDistance = _moveDelta;
            _eventInfo.eventId = PYResponderEventPan;
            self.state = UIGestureRecognizerStateChanged;
        } else if ( (_possibleAction & PYResponderEventSwipe) > 0 ) {
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
        } else {
            self.state = UIGestureRecognizerStateFailed;
            return;
        }
    } else if ( _touchCount == 2 && (_possibleAction & PYResponderEventDoubleDragging) > 0 ) {
        NSArray *_touches = [_eventInfo.touches allObjects];
        UITouch *_firstTouch = [_touches objectAtIndex:0];
        UITouch *_secondTouch = [_touches objectAtIndex:1];
        CGPoint _fPoint = [_firstTouch locationInView:self.view.window];
        CGPoint _sPoint = [_secondTouch locationInView:self.view.window];
        
        // Calculate the distance
        float _x = _fPoint.x - _sPoint.x;
        float _y = _fPoint.y - _sPoint.y;
        if ( (_possibleAction & PYResponderEventPinch) > 0 ) {
            CGFloat _currentDistance = sqrt((_x * _x) + (_y * _y));
            _eventInfo.pinchRate = (_currentDistance / _pinchDistance);
            _pinchDistance = _currentDistance;
            _eventInfo.eventId = PYResponderEventPinch;
            self.state = UIGestureRecognizerStateChanged;
        }
        // Calculate the rotate angle
        if ( (_possibleAction & PYResponderEventRotate) > 0 ) {
            CGFloat _currentArc = atan(_y / _x) + (M_PI * 2);
            _eventInfo.rotateDeltaArc = (_currentArc - _rotateArc);
            _rotateArc = _currentArc;
            _eventInfo.eventId = PYResponderEventRotate;
            self.state = UIGestureRecognizerStateChanged;
        }
    } else {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    _eventInfo.touches = [[event touchesForWindow:self.view.window] copy];
    _eventInfo.sysEvent = event;
    _eventInfo.movingDeltaDistance = CGSizeZero;

    // All supported events been canceled.
    if ( (_possibleAction & PYResponderEventNeedPredirect) == 0 ) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    
    if ( (_possibleAction & PYResponderEventTap) > 0 ) {
        if ( _lagEventTimer != nil ) {
            [_lagEventTimer invalidate];
        }
        _lagEventTimer = [NSTimer
                          scheduledTimerWithTimeInterval:.175
                          target:self
                          selector:@selector(_tapEventHandler:)
                          userInfo:nil
                          repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:_lagEventTimer forMode:NSRunLoopCommonModes];
        return;
    }
    
    if ( (_possibleAction & PYResponderEventPress) > 0 ) {
        // Nothing to do...
        if ( _lagEventTimer != nil ) {
            [_lagEventTimer invalidate];
            _lagEventTimer = nil;
        }
        _possibleAction &= ~PYResponderEventPress;
    }
    
    if ( (_possibleAction & PYResponderEventSwipe) ) {
        if ( _eventInfo.hasMoved == YES ) {
            // Calculate the swipe direction...
            if ( (_swipeSide & _responderRestraint) > 0 ) {
                _eventInfo.swipeSide = _swipeSide;
                _eventInfo.eventId = PYResponderEventSwipe;
                self.state = UIGestureRecognizerStateRecognized;
            } else {
                _possibleAction &= ~PYResponderEventSwipe;
            }
        } else {
            _possibleAction &= ~PYResponderEventSwipe;
        }
    }
    
    if ( (_possibleAction & PYResponderEventNeedPredirect) == 0 ) {
        self.state = UIGestureRecognizerStateFailed;
    } else {
        if ( _lagEventTimer == nil ) {
            self.state = UIGestureRecognizerStateRecognized;
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    _eventInfo.touches = [[event touchesForWindow:self.view.window] copy];
    _eventInfo.sysEvent = event;
    self.state = UIGestureRecognizerStateFailed;
}

#pragma mark --
#pragma mark Event Handler

- (void)_tapEventHandler:(id)sender
{
    int _tapId = PYLAST1INDEX(PYResponderEventTap);
    unsigned int _tapRestraint = ((0x0000000F << _tapId) & _responderRestraint);
    if ( _tapCount == _tapRestraint ) {
        _eventInfo.eventId = PYResponderEventTap;
        self.state = UIGestureRecognizerStateRecognized;
    } else {
        self.state = UIGestureRecognizerStateFailed;
    }
    _tapCount = 0;
    [_lagEventTimer invalidate];
    _lagEventTimer = nil;
}

- (void)_pressEventHandler:(id)sender
{
    _eventInfo.eventId = PYResponderEventPress;
    self.state = UIGestureRecognizerStateRecognized;
    [_lagEventTimer invalidate];
    _lagEventTimer = nil;
}

@end
