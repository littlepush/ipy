//
//  PYListCache.h
//  PYCore
//
//  Created by Push Chen on 10/24/11.
//  Copyright 2011 PushLab. All rights reserved.
//

#import <Foundation/Foundation.h>

// Static Pre-defined Page Size
#define STATIC_PAGE_SIZE	10
#define STATIC_BUFFER_SIZE	40

/*
 The Delegate is for the PYListCache, to get enough information
 from the source structure object.
 */
@protocol PYListCacheDelegate;

/*
 The Cache Object.
 Manage the data in a NSMutableArray, make sure the 
 data count in an enough range but few memory.
 */
@interface PYListCache : NSObject {
    NSMutableArray	*_cacheArray;
	NSInteger		_startIndex;
	NSInteger		_endIndex;
	NSInteger		_allAvailableCount;
	
	id<PYListCacheDelegate>		_delegate;
}

@property (nonatomic, readonly) NSInteger count;
@property (nonatomic, retain)	id<PYListCacheDelegate>	delegate;

+(PYListCache *)listCacheWithDelegate:(id<PYListCacheDelegate>)delegate;

// Init the cache object
-(PYListCache *)initWithDelegate:(id<PYListCacheDelegate>)delegate;

-(void)fillCache;

// Get the specified object in the cache.
// If not, update the cache to get the data.
-(id)getObjectAtIndex:(NSInteger)index;

// Update the cache
-(void)addObject:(id)object;
-(void)insertObjectAtBegin:(id)object;

// Delete one object
-(void)deleteObject:(id)object;

// Clear cache
-(void)clear;

@end

@protocol PYListCacheDelegate <NSObject>

@required
// Get the data of an range.
-(NSMutableArray *)listCache:(PYListCache *)cache getDataOfRange:(CFRange)range;

// Get all data count.
-(NSInteger)listCacheGetAllDataCount:(PYListCache *)cache;

@end


