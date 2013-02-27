//
//  PYLRUCache.m
//  PYCore
//
//  Created by Push Chen on 11/28/11.
//  Copyright (c) 2011 Push Lab. All rights reserved.
//

#import "PYLRUCache.h"

#define kArcCacheDict		@"kArcCacheDict"
#define kArcCacheList		@"kArcCacheList"
#define kArcMaxLimitation	@"kArcMaxLimitation"
#define kArcAddObserver		@"kArcAddObserver"
#define kArcRemoveObserver	@"kArcRemoveObserver"
#define kArcLastRmPair		@"kArcLastRmPair"
#define kArcLastAddPair		@"kArcLastAddPair"

/*
 Private PYLRUCache Message
 */
@interface PYLRUCache(Private)

-(void)clearCache;

@end

/* PL Cache */
@implementation PYLRUCache
@synthesize limitation/*, lastAddedPair, lastRemovedPair*/;
@dynamic keys;
-(NSArray *) keys {
	return [(NSArray *)[cacheKeyOrderList copy] autorelease];
}

+(PYLRUCache *)sharedCache 
{
	static PYLRUCache *sharableCache = nil;
	if ( sharableCache == nil ) {
		sharableCache = [[[PYLRUCache alloc] 
			initWithMaxObjectLimitation:PYLRUCacheDefaultMaxLimitation]
			retain];
	}
	return sharableCache;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if ( self ) {
		cacheDictStorage = [[aDecoder decodeObjectForKey:kArcCacheDict] retain];
		cacheKeyOrderList = [[aDecoder decodeObjectForKey:kArcCacheList] retain];
		maxObjectLimitation = [aDecoder decodeIntegerForKey:kArcMaxLimitation];
	}
	return self;
}

-(void) encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:cacheDictStorage forKey:kArcCacheDict];
	[aCoder encodeObject:cacheKeyOrderList forKey:kArcCacheList];
	[aCoder encodeInteger:maxObjectLimitation forKey:kArcMaxLimitation];
}

-(void) dealloc
{
	cacheDictStorage = nil;
	cacheKeyOrderList = nil;
	[super dealloc];
}

+(PYLRUCache *)cacheWithMaxObjectLimitation:(NSInteger)limit 
{
	PYLRUCache *autoreleaseCache = [[[PYLRUCache alloc] 
		initWithMaxObjectLimitation:limit] autorelease];
	return autoreleaseCache;
}

/* Instance Initialize */
-(PYLRUCache *)init 
{
	self = (PYLRUCache *)[super init];
	if (self) {
		maxObjectLimitation = PYLRUCacheDefaultMaxLimitation;
		cacheDictStorage = [[[NSMutableDictionary alloc] 
			initWithCapacity:maxObjectLimitation] retain];
		cacheKeyOrderList = [[[NSMutableArray alloc]
			initWithCapacity:maxObjectLimitation] retain];
	}
	return self;
}
-(PYLRUCache *)initWithMaxObjectLimitation:(NSInteger)limit 
{
	self = (PYLRUCache *)[super init];
	if (self) {
		maxObjectLimitation = limit;
		cacheDictStorage = [[[NSMutableDictionary alloc] 
			initWithCapacity:maxObjectLimitation] retain];
		cacheKeyOrderList = [[[NSMutableArray alloc]
			initWithCapacity:maxObjectLimitation] retain];
	}
	return self;
}

-(void)setMaxObjectLimitation:(NSInteger)limit 
{
	@synchronized(self) {
		maxObjectLimitation = limit;
		[self clearCache];
	}
}

/* Value */
-(void)setValue:(id)value forKey:(NSString *)key
{
	[self setObject:value forKey:key];
}
-(void)setObject:(id)value forKey:(id)key 
{
	@synchronized(self) {
		id existedValue = [cacheDictStorage objectForKey:key];
		if ( existedValue != nil ) {
			// existed
			[cacheDictStorage removeObjectForKey:key];
			[cacheKeyOrderList removeObject:key];
		}
		[cacheDictStorage setValue:value forKey:key];
		[cacheKeyOrderList insertObject:key atIndex:0];
		
		[self clearCache];
	}
}
-(id)valueForKey:(NSString *)key
{
	return [self objectForKey:key];
}
-(id)objectForKey:(id)key 
{
	@synchronized(self) {
		id existedValue = [cacheDictStorage objectForKey:key];
		if ( existedValue == nil ) return nil;
		[cacheKeyOrderList removeObject:key];
		[cacheKeyOrderList insertObject:key atIndex:0];
		return existedValue;
	}
}
-(void)removeObjectForKey:(id)key 
{
	@synchronized(self) {
		id value = [cacheDictStorage objectForKey:key];
		if ( value == nil ) return;
	}
}

-(void)removeAllObjects 
{
	@synchronized(self) {
		[cacheKeyOrderList removeAllObjects];
		[cacheDictStorage removeAllObjects];
	}
}

-(NSEnumerator *)objectEnumerator
{
	return [cacheDictStorage objectEnumerator];
}

/* Private */
-(void)clearCache
{
	if ( [cacheDictStorage count] > maxObjectLimitation ) 
	{
		int removeCount = [cacheDictStorage count] - maxObjectLimitation;
		for ( int rc = 0; rc < removeCount; ++rc )
		{
			NSString *removeKey = [cacheKeyOrderList lastObject];
			//id value = [cacheDictStorage objectForKey:removeKey];
			[cacheDictStorage removeObjectForKey:removeKey];
			[cacheKeyOrderList removeLastObject];			
		}
	}
}

@end
