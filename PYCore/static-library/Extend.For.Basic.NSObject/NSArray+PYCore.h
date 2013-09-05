//
//  NSArray+PYCore.h
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

#import <Foundation/Foundation.h>

@interface NSArray (PYCore)

// For Delegated object group, try to perform selector
- (void)objectsTryToPerformSelector:(SEL)selector;
- (void)objectsTryToPerformSelector:(SEL)selector withObject:(id)obj;
- (void)objectsTryToPerformSelector:(SEL)selector withObject:(id)obj1 withObject:(id)obj2;

// Safely to get the object at index.
- (id)safeObjectAtIndex:(NSUInteger)index;

// Reverse current array.
- (NSArray *)reverseArray;

@end

@interface NSMutableArray (PYCore)

// Safely to insert object
- (void)safeInsertObject:(id)anObject atIndex:(NSUInteger)index;
- (void)safeInsertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes;
- (void)safeAddObject:(id)anObject;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
