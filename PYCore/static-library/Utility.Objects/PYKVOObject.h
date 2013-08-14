//
//  PYKVOObject.h
//  PYCore
//
//  Created by Push Chen on 5/6/13.
//  Copyright (c) 2013 PushLab. All rights reserved.
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

#define PYKVO_CHANGED_RESPONSE(property, key)               \
    - (void)on_##property##_changing_##key:(id)newValue

#define PYObserve(property, key)                            \
    [self observeObject:property forKey:key named:@#property]
#define PYRemoveObserve(property, key)                      \
    [self removeObservedObject:property forKey:key]

@interface PYKVOObject : NSObject
{
    NSMutableDictionary                 *_kvoDictionary;
}

// Observe one of the property with specified key.
- (void)observeObject:(id)object forKey:(NSString *)key named:(NSString *)name;
// Remove the cache data.
- (void)removeObservedObject:(id)object forKey:(NSString *)key;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
