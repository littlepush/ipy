//
//  PYActionDispatcher.h
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

#import <Foundation/Foundation.h>
#import "PYKVOObject.h"

@protocol PYActionDispatcher <NSObject>

@required
// Add or remove the actions
- (void)addTarget:(id)target action:(SEL)action forEvent:(NSUInteger)event;
- (void)removeTarget:(id)target action:(SEL)action forEvent:(NSUInteger)event;

@end

@interface PYActionDispatcher : PYKVOObject <PYActionDispatcher>
{
    NSMutableDictionary             *_actionContainer;
}

// Register the event with specified key.
// for example, we have an enum definition like following:
//  typedef NS_ENUM(NSUInteger, MyEnum) {
//      MyEnumValue1    = 0,
//      MyEnumValue2    = 1
//  };
// And we have an action dispathcer named MyActDispatcher,
// we should register the event with MyActDispatcher use
// following codes:
//  [PYActionDispatcher registerEvent:MyEnumValue1 forDispatcher:[MyActDispatcher class] withKey:@"MyEnumValue1"]
//  [PYActionDispatcher registerEvent:MyEnumValue2 forDispatcher:[MyActDispatcher class] withKey:@"MyEnumValue2"]
// or:
//  [MyActDispatcher registerEvent:MyEnumValue1 withKey:@"MyEnumValue1"];
//  [MyActDispatcher registerEvent:MyEnumValue2 withKey:@"MyEnumValue2"];
+ (void)registerEvent:(NSUInteger)event forDispatcher:(Class)dpClass withKey:(NSString *)key;
+ (void)registerEvent:(NSUInteger)event withKey:(NSString *)key;
#define registerEvent(event)    registerEvent:event withKey:@#event

// The dispatcher identify
@property (nonatomic, copy)     NSString    *identify;
// The default target object
@property (nonatomic, assign)   id          defaultTarget;

// Invoke the target with specified event and ex-info.
- (id)invokeTargetWithEvent:(NSUInteger)event;
- (id)invokeTargetWithEvent:(NSUInteger)event exInfo:(id)info;
- (id)invokeTargetWithEvent:(NSUInteger)event exInfo:(id)info exInfo:(id)info2;

@end

#define PYEventHandler(dpIdentify, event)               \
_py_event_handler_##dpIdentify##_##event:(id)obj1 exInfo:(id)obj2

// @littlepush
// littlepush@gmail.com
// PYLab
