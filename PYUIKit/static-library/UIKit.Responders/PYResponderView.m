//
//  PYResponderView.m
//  PYUIKit
//
//  Created by Push Chen on 7/24/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import "PYResponderView.h"

@interface PYResponderView (Internal)

// Invoke the target of specified event.
- (void)_invokeTargetForEvent:(PYResponderEvent)event;

@end

@implementation PYResponderView

- (void)viewJustBeenCreated
{
    [super viewJustBeenCreated];
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
    }
}

- (void)_invokeTargetForEvent:(PYResponderEvent)event touches:(NSSet *)touches
{
    NSMutableArray *_callbackList = _eventTargetsActions[PYLAST1INDEX(event)];
    if ( _callbackList == nil ) return;
    for ( PYPair *_taPair in _callbackList ) {
        id _target = _taPair.first;
        SEL _action = NSSelectorFromString((NSString *)_taPair.second);
        [(NSObject *)_target tryPerformSelector:_action
                                     withObject:self
                                     withObject:touches];
    }
}

- (void)addTarget:(id)target action:(SEL)action forResponderEvent:(PYResponderEvent)event
{
    
}

- (void)removeTarget:(id)target action:(SEL)action forResponderEvent:(PYResponderEvent)event
{
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self _invokeTargetForEvent:PYResponderEventTouchBegin touches:touches];
    
    if ( (_responderAction & PYResponderEventNeedPredirect) == 0 ) {
        _nextResponderReceivedBeginEvent = YES;
        return [self.nextResponder touchesBegan:touches withEvent:event];
    }
    
    // Check finger press
    if ( (_responderAction & PYResponderEventPress) > 0 ) {
        unsigned int _pressRestraintMask = 0x000000F0;
        unsigned int _pressFingerCount = (_responderRestraint & _pressRestraintMask) >> 4;
        if ( [touches count] > _pressFingerCount ) {
            _possibleAction &= ~PYResponderEventPress;
            _nextResponderReceivedBeginEvent = YES;
            return [self.nextResponder touchesBegan:touches withEvent:event];
        }
        if ( [touches count] == _pressFingerCount ) {
            _pressBeginTime = time(NULL);
        } else {
            _pressBeginTime = 0;
        }
    }
    
    // All action is possible.
    _possibleAction = _responderAction;
    _nextResponderReceivedBeginEvent = NO;

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
    if ( _isUserIntractiviting == NO ) {
        return [self.nextResponder touchesMoved:touches withEvent:event];
    }
    [self _invokeTargetForEvent:PYResponderEventTouchMove touches:touches];
    
    // If the supported action does not contain dragging event, return.
    // And check if the next responder has received the touche begin
    // event.
    _possibleAction &= ~PYResponderEventTap;
    _possibleAction &= ~PYResponderEventPress;
    
    if ( (_possibleAction & PYResponderEventSupportDragging) == 0 ) {
        if ( _nextResponderReceivedBeginEvent == NO ) {
            [self.nextResponder touchesBegan:touches withEvent:event];
            _nextResponderReceivedBeginEvent = YES;
        }
        return [self.nextResponder touchesMoved:touches withEvent:event];
    }
    
    if ( (_possibleAction & PYResponderEventPinch) > 0 && [touches count] != 2 ) {
        _possibleAction &= ~PYResponderEventPinch;  // Failed to pinch
        
    }
    
    _isUserMoved = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ( _isUserIntractiviting == NO ) {
        return [self.nextResponder touchesEnded:touches withEvent:event];
    }
    [self _invokeTargetForEvent:PYResponderEventTouchEnd touches:touches];
    
    // All supported events been canceled.
    if ( (_possibleAction & PYResponderEventNeedPredirect) == 0 ) {
        
    }
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ( _isUserIntractiviting == NO ) {
        return [self.nextResponder touchesCancelled:touches withEvent:event];
    }
    [self _invokeTargetForEvent:PYResponderEventTouchCancel touches:touches];
    
}

@end
