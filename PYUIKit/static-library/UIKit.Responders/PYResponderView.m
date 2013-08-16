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

@interface PYResponderView (Internal)

// Invoke the target of specified event.
- (void)_invokeTargetForEvent:(PYResponderEvent)event;

// Responder Gesture Handler
- (void)_responderGestureHandler:(id)sender;

@end

@implementation PYResponderView

// Touch Info.
@synthesize firstTouchPoint = _firstTouchPoint;
@synthesize lastMovePoint = _lastMovePoint;

// Dynamic Properties
@dynamic canTap;
- (BOOL)canTap
{
    return _responderGesture.canTap;
}
@dynamic canPress;
- (BOOL)canPress
{
    return _responderGesture.canPress;
}
@dynamic canPen;
- (BOOL)canPen
{
    return _responderGesture.canPen;
}
@dynamic canSwipe;
- (BOOL)canSwipe
{
    return _responderGesture.canSwipe;
}
@dynamic canPinch;
- (BOOL)canPinch
{
    return _responderGesture.canPinch;
}

@dynamic tapCount;
- (NSUInteger)tapCount
{
    return _responderGesture.tapCount;
}
@dynamic pressFingers;
- (NSUInteger)pressFingers
{
    return _responderGesture.pressFingers;
}
@dynamic penDirections;
- (NSUInteger)penDirections
{
    return _responderGesture.penDirections;
}
@dynamic swipeDirections;
- (NSUInteger)swipeDirections
{
    return _responderGesture.swipeDirections;
}

// Messages.
- (void)viewJustBeenCreated
{
    [super viewJustBeenCreated];
    _responderGesture = [[PYResponderGestureRecognizer alloc]
                         initWithTarget:self action:@selector(_responderGestureHandler:)];
    [_responderGesture setCancelsTouchesInView:NO];
    [self addGestureRecognizer:_responderGesture];
}

- (void)setEvent:(PYResponderEvent)event withRestraint:(PYResponderRestraint)restraint
{
    [_responderGesture setEvent:event withRestraint:restraint];
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
    PYViewEvent *_event = _responderGesture.eventInfo;
    _event.touches = [touches copy];
    _event.sysEvent = event;
    [self _invokeTargetForEvent:PYResponderEventTouchBegin info:_event];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    PYViewEvent *_event = _responderGesture.eventInfo;
    _event.touches = [touches copy];
    _event.sysEvent = event;
    [self _invokeTargetForEvent:PYResponderEventTouchMove info:_event];
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    PYViewEvent *_event = _responderGesture.eventInfo;
    _event.touches = [touches copy];
    _event.sysEvent = event;
    [self _invokeTargetForEvent:PYResponderEventTouchEnd info:_event];
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    PYViewEvent *_event = _responderGesture.eventInfo;
    _event.touches = [touches copy];
    _event.sysEvent = event;
    [self _invokeTargetForEvent:PYResponderEventTouchCancel info:_event];
    [super touchesCancelled:touches withEvent:event];
}

- (void)_responderGestureHandler:(id)sender
{
    [self _invokeTargetForEvent:_responderGesture.eventInfo.eventId
                           info:_responderGesture.eventInfo];
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
