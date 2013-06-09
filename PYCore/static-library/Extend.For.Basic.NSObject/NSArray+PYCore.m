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
        if ( index >= [self count] ) return nil;
        return [self objectAtIndex:index];
    }
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
