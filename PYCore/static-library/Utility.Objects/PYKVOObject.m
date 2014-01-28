//
//  PYKVOObject.m
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

#import "PYKVOObject.h"
#import "NSObject+PYCore.h"

#define     kPYKVOPropertyName              @"kPYKVOPropertyName"
#define     kPYKVOPropertyObject            @"kPYKVOPropertyObject"

@implementation PYKVOObject

- (void)observeObject:(id)object forKey:(NSString *)key named:(NSString *)name
{
    @synchronized(self) {
        if ( object == nil ) return;
        if ( [name isEqual:[NSNull null]] || name == nil || [name length] == 0 ) return;
        if ( [key isEqual:[NSNull null]] || key == nil || [key length] == 0 ) return;
        if ( _kvoDictionary == nil ) {
            _kvoDictionary = [NSMutableDictionary dictionary];
        }
        // Set data.
        NSString *_class = [NSString stringWithFormat:@"%p", object];
        NSString *_kvoKey = [NSString stringWithFormat:@"%@+%@", _class, key];
        
        [_kvoDictionary setObject:@{kPYKVOPropertyName:name,kPYKVOPropertyObject:object}
                           forKey:_kvoKey];
    }
    // Add observer
    [object addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObservedObject:(id)object forKey:(NSString *)key
{
    @synchronized(self) {
        if ( object == nil ) return;
        if ( [key isEqual:[NSNull null]] || key == nil || [key length] == 0 ) return;
        if ( _kvoDictionary != nil ) {
            NSString *_class = [NSString stringWithFormat:@"%p", object];
            NSString *_kvoKey = [NSString stringWithFormat:@"%@+%@", _class, key];

            [_kvoDictionary removeObjectForKey:_kvoKey];
        }
    }
    [object removeObserver:self forKeyPath:key];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ( _kvoDictionary == nil ) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    // Search the kvo dictionary.
    NSString *_class = [NSString stringWithFormat:@"%p", object];
    NSString *_kvoKey = [NSString stringWithFormat:@"%@+%@", _class, keyPath];
    if ( [_kvoDictionary objectForKey:_kvoKey] == nil ) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    NSDictionary *_info = [_kvoDictionary objectForKey:_kvoKey];
    
    // Create the responder selector
    NSString *_responder = [NSString stringWithFormat:@"on_%@_changing_%@:",
                            [_info objectForKey:kPYKVOPropertyName],
                            keyPath];
    SEL _sel = NSSelectorFromString(_responder);
    if ( ![self respondsToSelector:_sel] ) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    // Tell the responder.
    [self tryPerformSelector:_sel withObject:[change objectForKey:NSKeyValueChangeNewKey]];
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
