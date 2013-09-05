//
//  NSArray+PYCore.m
//  PYCore
//
//  Created by Push Chen on 6/10/13.
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

#import "NSArray+PYCore.h"
#import "NSObject+PYCore.h"
#import "PYCoreMacro.h"

@implementation NSArray (PYCore)

- (void)objectsTryToPerformSelector:(SEL)selector
{
    NSEnumerator *enumerator = self.objectEnumerator;
    for ( id object in enumerator ) {
        [object tryPerformSelector:selector];
    }
}

- (void)objectsTryToPerformSelector:(SEL)selector withObject:(id)obj
{
    NSEnumerator *enumerator = self.objectEnumerator;
    for ( id object in enumerator ) {
        [object tryPerformSelector:selector withObject:obj];
    }
}

- (void)objectsTryToPerformSelector:(SEL)selector withObject:(id)obj1 withObject:(id)obj2
{
    NSEnumerator *enumerator = self.objectEnumerator;
    for ( id object in enumerator ) {
        [object tryPerformSelector:selector withObject:obj1 withObject:obj2];
    }
}

- (id)safeObjectAtIndex:(NSUInteger)index
{
    @synchronized(self) {
        if ( self == nil ) return nil;
        if ( [self count] == 0 ) return nil;
        if ( index >= [self count] ) {
            return nil;
        }
        @try {
            return [self objectAtIndex:index];
        } @catch ( NSException *ex ) {
            PYLog(@"exception: %@\nCall Stack: \n%@", ex.reason, ex.callStackSymbols);
            return nil;
        }
    }
}

- (NSArray *)reverseArray
{
    NSMutableArray *_reversedArray = [NSMutableArray array];
    NSEnumerator *_reverseEnum = self.reverseObjectEnumerator;
    for ( NSObject *_obj in _reverseEnum ) {
        [_reversedArray addObject:_obj];
    }
    return [NSArray arrayWithArray:_reversedArray];
}

@end

@implementation NSMutableArray (PYCore)

- (void)safeInsertObject:(id)anObject atIndex:(NSUInteger)index
{
    @synchronized(self) {
        if ( anObject == nil ) return;
        if ( index >= [self count] ) {
            [self safeAddObject:anObject];
            return;
        }
        @try {
            [self insertObject:anObject atIndex:index];
        } @catch ( NSException *ex ) {
            PYLog(@"exception: %@\nCall Stack: \n%@", ex.reason, ex.callStackSymbols);
        }
    }
}
- (void)safeInsertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes
{
    @synchronized(self) {
        if ( objects == nil || [objects count] == 0 ) return;
        @try {
            [self insertObjects:objects atIndexes:indexes];
        } @catch ( NSException *ex ) {
            PYLog(@"exception: %@\nCall Stack: \n%@", ex.reason, ex.callStackSymbols);
        }
    }
}
- (void)safeAddObject:(id)anObject
{
    @synchronized(self) {
        if ( anObject == nil ) return;
        @try {
            [self addObject:anObject];
        } @catch ( NSException *ex ) {
            PYLog(@"exception: %@\nCall Stack: \n%@", ex.reason, ex.callStackSymbols);
        }
    }
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
