//
//  PYMerger.m
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

#import "PYMerger.h"
#import "NSObject+PYCore.h"

@implementation PYMergerIterator

@synthesize topIndex, listCount, list;
@dynamic isEnd;
- (BOOL)isEnd
{
    return topIndex >= listCount;
}

// Methods
- (id)topObject
{
    if ( self.isEnd ) return nil;
    return [self.list objectAtIndex:self.topIndex];
}

- (void)goNext
{
    ++topIndex;
}

+ (PYMergerIterator *)iteratorBegin:(NSArray *)array
{
    PYMergerIterator *_iterator = __AUTO_RELEASE([[PYMergerIterator alloc] init]);
    _iterator.list = array;
    _iterator.listCount = [array count];
    _iterator.topIndex = 0;
    return _iterator;
}

+ (PYMergerIterator *)iteratorEnd:(NSArray *)array
{
    PYMergerIterator *_iterator = __AUTO_RELEASE([[PYMergerIterator alloc] init]);
    _iterator.list = array;
    _iterator.listCount = [array count];
    _iterator.topIndex = _iterator.listCount;
    return _iterator;
}

@end

@implementation PYMerger

+ (void)insertIterator:(PYMergerIterator *)iterator
               toArray:(NSMutableArray *)sortArray
               compare:(NSComparator)compare
{
    int _c = [sortArray count];
    if ( _c == 0 ) {
        [sortArray addObject:iterator];
        return;
    }
    
    int _insertIndex = _c;
    for ( int i = 0; i < _c; ++i ) {
        PYMergerIterator *_cIterator = [sortArray objectAtIndex:i];
        if ( compare(iterator.topObject, _cIterator.topObject) == NSOrderedDescending ) {
            _insertIndex = i;
            break;
        }
    }
    if ( _insertIndex == _c ) [sortArray addObject:iterator];
    else [sortArray insertObject:iterator atIndex:_insertIndex];
}

+ (NSMutableArray *)mergeWithLists:(NSArray *)lists compare:(NSComparator)compare
{
    return [PYMerger mergeWithLists:lists compare:compare enumItem:nil];
}

+ (NSMutableArray *)mergeWithLists:(NSArray *)lists compare:(NSComparator)compare
                          enumItem:(PYActionGet)onEnum
{
    NSMutableArray *_sortedArray = [NSMutableArray array];
    NSMutableArray *_resultArray = [NSMutableArray array];
    
    // Initialize the sort array.
    for ( NSArray *_list in lists ) {
        PYMergerIterator *_iterator = [PYMergerIterator iteratorBegin:_list];
        [PYMerger insertIterator:_iterator toArray:_sortedArray compare:compare];
    }
    
    // Kernel Sort.
    while ([_sortedArray count] > 0) {
        PYMergerIterator *_iterator = [_sortedArray objectAtIndex:0];
        [_sortedArray removeObjectAtIndex:0];
        
        if ( ![_resultArray containsObject:[_iterator topObject]] ) {
            if ( onEnum ) {
                onEnum([_iterator topObject]);
            }
            [_resultArray addObject:[_iterator topObject]];
        }
        [_iterator goNext];
        if ( [_iterator isEnd] ) continue;
        [PYMerger insertIterator:_iterator toArray:_sortedArray compare:compare];
    }
    
    return _resultArray;
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
