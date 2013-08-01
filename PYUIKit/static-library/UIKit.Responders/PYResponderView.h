//
//  PYResponderView.h
//  PYUIKit
//
//  Created by Push Chen on 7/24/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import "PYView.h"

typedef enum {
    PYResponderEventTap                 = 0x0001,
    PYResponderEventPress               = 0x0002,
    PYResponderEventPen                 = 0x0004,
    PYResponderEventSwipe               = 0x0008,
    PYResponderEventPinch               = 0x0010,
    PYResponderEventRotate              = 0x0020,
    PYResponderEventNeedPredirect       = (PYResponderEventTap | PYResponderEventPress |
                                           PYResponderEventPen | PYResponderEventSwipe |
                                           PYResponderEventPinch | PYResponderEventRotate),
    PYResponderEventSupportDragging     = (PYResponderEventPen | PYResponderEventSwipe |
                                           PYResponderEventPinch | PYResponderEventRotate),
    PYResponderEventMultipleTouches     = (PYResponderEventPress | PYResponderEventPinch |
                                           PYResponderEventRotate),
    
    // The following 4 events are default event, you can not disable them or
    // set and restraint.
    PYResponderEventTouchBegin          = 0x0040,
    PYResponderEventTouchMove           = 0x0080,
    PYResponderEventTouchEnd            = 0x0100,
    PYResponderEventTouchCancel         = 0x0200
} PYResponderEvent;

typedef enum {
    // Sub action default
    PYResponderRestraintDisable             = 0x00000000,
    // Sub action for tap
    PYResponderRestraintSingleTap           = 0x00000001,   // Default
    PYResponderRestraintDoubleTap           = 0x00000002,
    PYResponderRestraintTripleTap           = 0x00000004,
    // Sub action for press
    PYResponderRestraintOneFingerPress      = 0x00000010,   // Default
    PYResponderRestraintTwoFingersPress     = 0x00000020,
    PYResponderRestraintThreeFingersPress   = 0x00000040,
    // Sub action for pen
    PYResponderRestraintPenFreedom          = 0x80000F00,   // Default
    PYResponderRestraintPenHorizontal       = (0x00000100 | 0x00000200),
    PYResponderRestraintPenVerticalis       = (0x00000400 | 0x00000800),
    // Sub action for swipe
    PYResponderRestraintSwipeLeft           = 0x00001000,
    PYResponderRestraintSwipeRight          = 0x00002000,
    PYResponderRestraintSwipeTop            = 0x00004000,
    PYResponderRestraintSwipeBottom         = 0x00008000,
    PYResponderRestraintSwipeHorizontal     = (PYResponderRestraintSwipeLeft |
                                               PYResponderRestraintSwipeRight),
    PYResponderRestraintSwipeVerticalis     = (PYResponderRestraintSwipeTop |
                                               PYResponderRestraintSwipeBottom),
    // Sub action for Pinch
    PYResponderRestraintPinchDefault        = 0x00010000,   // Default
    PYResponderRestraintRotateDefault       = 0x00020000,   // Default    
} PYResponderRestraint;

typedef enum {
    PYDecelerateSpeedZero                   = 0,        // Disable the decelerate, Stop immediately
    PYDecelerateSpeedVerySlow,
    PYDecelerateSpeedSlow,
    PYDecelerateSpeedNormal,                            // Default decelerate speed.
    PYDecelerateSpeedFast,
    PYDecelerateSpeedVeryFast
} PYDecelerateSpeed;

// Event for the target.
@interface PYViewEvent : NSObject

@property (nonatomic, assign)   PYResponderEvent        eventId;
@property (nonatomic, strong)   UIEvent                 *sysEvent;
@property (nonatomic, assign)   CGFloat                 pinchRate;
@property (nonatomic, assign)   CGFloat                 rotateDeltaArc;
@property (nonatomic, assign)   CGSize                  movingDeltaDistance;
@property (nonatomic, assign)   CGPoint                 movingSpeed;

@end

@interface PYResponderView : PYView
{
    @private
    PYResponderEvent                    _possibleAction;
    // Action Status
    CGPoint                             _firstTouchPoint;
    CGPoint                             _lastMovePoint;
    
    CGFloat                             _pinchDistance;
    CGFloat                             _rotateArc;
    
    BOOL                                _isUserIntractiviting;
    BOOL                                _isUserMoved;
    unsigned int                        _tapCount;
    NSTimer                             *_lagEventTimer;
    PYStopWatch                         *_speedTicker;
    CGPoint                             _movingSpeed;
    CGSize                              _lastMoveDistrance;
    
    // Decelerate Speed, default is normal.
    PYDecelerateSpeed                   _decelerateSpeed;
    
    // Actions
    PYResponderEvent                    _responderAction;
    PYResponderRestraint                 _responderRestraint;
    
    // Call back
    NSMutableArray                      *_eventTargetsActions[10];
    BOOL                                _nextResponderReceivedBeginEvent;
}

// Set the responder's supported event's restraint.
// the responder view will detect the event and try to find the target/action
// the event will occurred with the specified restraint.
- (void)setEvent:(PYResponderEvent)event withRestraint:(PYResponderRestraint)subAction;

@property (nonatomic, readonly) CGPoint             firstTouchPoint;
@property (nonatomic, readonly) CGPoint             lastMovePoint;

// Action Status
@property (nonatomic, readonly) BOOL                canTap;
@property (nonatomic, readonly) BOOL                canPress;
@property (nonatomic, readonly) BOOL                canPen;
@property (nonatomic, readonly) BOOL                canSwipe;
@property (nonatomic, readonly) BOOL                canPinch;

// Subaction status
@property (nonatomic, readonly) NSUInteger          tapCount;
@property (nonatomic, readonly) NSUInteger          pressFingers;
@property (nonatomic, readonly) NSUInteger          penDirections;
@property (nonatomic, readonly) NSUInteger          swipeDirections;

// Action Call back
- (void)addTarget:(id)target action:(SEL)action forResponderEvent:(PYResponderEvent)event;
- (void)removeTarget:(id)target action:(SEL)action forResponderEvent:(PYResponderEvent)event;

@end
