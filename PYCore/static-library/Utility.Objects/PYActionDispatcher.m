//
//  PYActionDispatcher.m
//  PYCore
//
//  Created by Push Chen on 2/20/14.
//  Copyright (c) 2014 PushLab. All rights reserved.
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

#import "PYActionDispatcher.h"
#import "PYCoreMacro.h"
#import "PYPair.h"
#import "NSObject+PYCore.h"
#import "NSArray+PYCore.h"

static NSMutableDictionary      *_py_g_ad_event_map;

@implementation PYActionDispatcher

// The default target
@synthesize defaultTarget;
@synthesize identify;

+ (void)initialize
{
    // Initialize the global map.
    _py_g_ad_event_map = [NSMutableDictionary dictionary];
}

- (id)init
{
    self = [super init];
    if ( self ) {
        _actionContainer = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark --
#pragma mark Dispatcher Delegate

- (void)addTarget:(id)target action:(SEL)action forEvent:(NSUInteger)event
{
    if ( target == nil || action == NULL ) return;
    @synchronized( self ) {
        NSString *_eventKey = PYIntToString(event);
        NSMutableArray *_callbackList = [_actionContainer objectForKey:_eventKey];
        if ( _callbackList == nil ) {
            _callbackList = [NSMutableArray array];
            [_actionContainer setObject:_callbackList forKey:_eventKey];
        }
        NSString *_actionString = NSStringFromSelector(action);
        for ( PYPair *_pair in _callbackList ) {
            // Check if contains the same target/action pair.
            if ( _pair.first == target && [_pair.secondValue isEqualToString:_actionString] )
                return;
        }
        // Add to the callback list.
        PYPair *_taPair = [PYPair object];
        _taPair.first = target;
        _taPair.secondValue = _actionString;
        [_callbackList addObject:_taPair];
    }
}

- (void)removeTarget:(id)target action:(SEL)action forEvent:(NSUInteger)event
{
    if ( target == nil || action == NULL ) return;
    @synchronized( self ) {
        NSString *_eventKey = PYIntToString(event);
        NSMutableArray *_callbackList = [_actionContainer objectForKey:_eventKey];
        NSUInteger _targetIndex = 0;
        NSUInteger _taCount = [_callbackList count];
        NSString *_actionString = NSStringFromSelector(action);
        for ( ; _targetIndex < _taCount; ++_targetIndex ) {
            PYPair *_taPair = [_callbackList safeObjectAtIndex:_targetIndex];
            if ( _taPair.first == target && [_taPair.secondValue isEqualToString:_actionString] )
                break;
        }
        if ( _targetIndex == _taCount ) return;
        [_callbackList removeObjectAtIndex:_targetIndex];
    }
}

#pragma mark --
#pragma mark Self Method

// Event Bound
+ (void)registerEvent:(NSUInteger)event forDispatcher:(Class)dpClass withKey:(NSString *)key
{
    @synchronized( _py_g_ad_event_map ) {
        NSString *_nsKey = NSStringFromClass(dpClass);
        NSMutableDictionary *_registedEvent = [_py_g_ad_event_map objectForKey:_nsKey];
        if ( _registedEvent == nil ) {
            _registedEvent = [NSMutableDictionary dictionary];
            [_py_g_ad_event_map setObject:_registedEvent forKey:_nsKey];
        }
        [_registedEvent setObject:key forKey:PYIntToString(event)];
    }
}

+ (void)registerEvent:(NSUInteger)event withKey:(NSString *)key
{
    [PYActionDispatcher registerEvent:event forDispatcher:[self class] withKey:key];
}

- (id)invokeTargetWithEvent:(NSUInteger)event
{
    return [self invokeTargetWithEvent:event exInfo:nil exInfo:nil];
}
- (id)invokeTargetWithEvent:(NSUInteger)event exInfo:(id)info
{
    return [self invokeTargetWithEvent:event exInfo:info exInfo:nil];
}
- (id)invokeTargetWithEvent:(NSUInteger)event exInfo:(id)info exInfo:(id)info2
{
    NSString *_eventKey = PYIntToString(event);
    id _result = nil;
    
    // Try to invoke default object first
    // Do only once.
    do {
        if ( [self.identify length] == 0 || self.defaultTarget == nil ) break;
        NSMutableDictionary *_registedEvent = [_py_g_ad_event_map objectForKey:NSStringFromClass([self class])];
        if ( [_registedEvent count] == 0 ) break;
        NSString *_key = [_registedEvent objectForKey:_eventKey];
        if ( [_key length] == 0 ) break;
        NSString *_eventHandlerSelString = [NSString stringWithFormat:@"_py_event_handler_%@_%@:exInfo:",
                                            self.identify, _key];
        SEL _eventHandlerSel = NSSelectorFromString(_eventHandlerSelString);
        if ( _eventHandlerSel == nil ) break;
        
        _result = [(NSObject *)self.defaultTarget
                   tryPerformSelector:_eventHandlerSel
                   withObject:info
                   withObject:info2];
    } while (NO);
    
    NSMutableArray *_callbackList = [_actionContainer objectForKey:_eventKey];
    if ( [_callbackList count] == 0 ) return _result;
    
    for ( PYPair *_taPair in _callbackList ) {
        __unsafe_unretained id _target = _taPair.first;
        SEL _action = NSSelectorFromString(_taPair.secondValue);
        if ( info != nil && info2 != nil ) {
            _result = [(NSObject *)_target
                       tryPerformSelector:_action withObject:info withObject:info2];
        } else if ( info != nil && info2 == nil ) {
            _result = [(NSObject *)_target
                       tryPerformSelector:_action withObject:info];
        } else if ( info == nil && info2 == nil ) {
            _result = [(NSObject *)_target
                       tryPerformSelector:_action];
        } else if ( info == nil && info2 != nil ) {
            _result = [(NSObject *)_target
                       tryPerformSelector:_action withObject:info2];
        }
    }
    return _result;
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
