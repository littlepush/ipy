//
//  PYListCache.m
//  PYCore
//
//  Created by Push Chen on 10/24/11.
//  Copyright 2011 PushLab. All rights reserved.
//

#import "PYListCache.h"
#import "PYMainMacro.h"

@implementation PYListCache

@synthesize count = _allAvailableCount;
@synthesize delegate = _delegate;
// Implementation

+(PYListCache *)listCacheWithDelegate:(id<PYListCacheDelegate>)delegate
{
	PYListCache *_cache = [[[PYListCache alloc] initWithDelegate:delegate] autorelease];
	return _cache;
}

-(PYListCache*)initWithDelegate:(id<PYListCacheDelegate>)target
{
	self = (PYListCache *)[super init];
	if ( self == nil ) return nil;
	
	_delegate = target;
	_startIndex = 0;
	return self;
}

-(void)fillCache
{
	CFRange range = CFRangeMake(0, STATIC_PAGE_SIZE);
	_cacheArray = [_delegate listCache:self getDataOfRange:range];
	if ( _cacheArray == nil )
	{
		// Failed to get the init data.
		return;
	}
	[_cacheArray retain];
	_endIndex = [_cacheArray count];
	
	// Get all data count.
	_allAvailableCount = [_delegate listCacheGetAllDataCount:self];
}

// Get the specified object in the cache.
// If not, update the cache to get the data.
-(id)getObjectAtIndex:(NSInteger)index
{
	if ( index < _endIndex && index >= _startIndex )
	{
		// query object is in the cache.
		return [_cacheArray objectAtIndex:(index - _startIndex)];
	}
	
	if ( index >= _endIndex && index < _allAvailableCount )
	{
		if ( index >= (_endIndex + STATIC_PAGE_SIZE) )
		{
			PYLog(@"Invalidate access of the page cache.");
			return nil;
		}
		// Load next page
		CFRange nextPageRange = CFRangeMake(_endIndex, STATIC_PAGE_SIZE);
		NSMutableArray * nextPage = [_delegate listCache:self getDataOfRange:nextPageRange];
		if ( nextPage == nil )
		{
			PYLog(@"Failed to get the next page.");
			return nil;
		}
		_endIndex += [nextPage count];
		[_cacheArray addObjectsFromArray:nextPage];
		
		// Remove old data.
		if ( [_cacheArray count] > (STATIC_BUFFER_SIZE + STATIC_PAGE_SIZE) )
		{
			// When the object in the array reach the max limitation,
			// release the top STATIC_PAGE_SIZE ones.
			for ( int i = 0; i < STATIC_PAGE_SIZE; ++i )
			{
				[_cacheArray removeObjectAtIndex:0];
				_startIndex += 1;
			}
		}
	}
	else if ( index < _startIndex && index >= 0 )
	{
		if ( index < (_startIndex - STATIC_PAGE_SIZE) )
		{
			PYLog(@"Invalidate access of the page cache.");
			return nil;
		}
		// Load previous
		NSInteger locStart = (( _startIndex - STATIC_PAGE_SIZE )) > 0 ? (_startIndex - STATIC_PAGE_SIZE) : 0;
		NSInteger length = _startIndex - locStart;
		CFRange prevPageRange = CFRangeMake(_startIndex, length);
		NSMutableArray *prevPage = [_delegate listCache:self getDataOfRange:prevPageRange];
		if ( prevPage == nil )
		{
			PYLog(@"Failed to get the prev page.");
			return nil;
		}
		_startIndex = locStart;
		for ( int i = [prevPage count] - 1; i >= 0; --i )
		{
			[_cacheArray insertObject:[prevPage objectAtIndex:i] atIndex:0];
		}
		
		// Remove old data
		if ( [_cacheArray count] > (STATIC_BUFFER_SIZE + STATIC_PAGE_SIZE) )
		{
			// When the object in the array reach the max limitation,
			// release the last STATIC_PAGE_SIZE ones.
			for ( int i = 0; i < STATIC_PAGE_SIZE; ++i )
			{
				[_cacheArray removeLastObject];
				_endIndex -= 1;
			}
		}		
	}
	else
	{
		PYLog(@"Invalidate index value.");
		return nil;
	}
	
	return [_cacheArray objectAtIndex:(index - _startIndex)];
}

// Update the cache
-(void)addObject:(id)object
{
	_allAvailableCount += 1;
	if ( _endIndex < _allAvailableCount )
	{
		// Nothing need to do.
		return;
	}
	// Add the object to the end of the array.
	//[object retain];
	if ( _cacheArray == nil ) {
		_cacheArray = [[NSMutableArray array] retain];
	}
	[_cacheArray addObject:object];
	_endIndex += 1;
	
	if ( [_cacheArray count] > (STATIC_BUFFER_SIZE + STATIC_PAGE_SIZE) )
	{
		// When the object in the array reach the max limitation,
		// release the top STATIC_PAGE_SIZE ones.
		for ( int i = 0; i < STATIC_PAGE_SIZE; ++i )
		{
			[_cacheArray removeObjectAtIndex:0];
			_startIndex += 1;
		}
	}
}
-(void)insertObjectAtBegin:(id)object
{
	_allAvailableCount += 1;
	if ( _startIndex != 0 )
	{
		// The cache is not start from the begin.
		// nothing need to do to update the cache.
		_startIndex += 1;
		_endIndex += 1;
		return;
	}
	//[object retain];
	if ( _cacheArray == nil ) {
		_cacheArray = [[NSMutableArray array] retain];
	}
	[_cacheArray insertObject:object atIndex:0];
	_endIndex += 1;
	
	if ( [_cacheArray count] > (STATIC_BUFFER_SIZE + STATIC_PAGE_SIZE) )
	{
		// When the object in the array reach the max limitation,
		// release the last STATIC_PAGE_SIZE ones.
		for ( int i = 0; i < STATIC_PAGE_SIZE; ++i )
		{
			[_cacheArray removeLastObject];
			_endIndex -= 1;
		}
	}
}

// Delete one object
-(void)deleteObject:(id)object
{
	_allAvailableCount -= 1;
	// Search for the object
	if ( [_cacheArray containsObject:object] )
	{
		[_cacheArray removeObject:object];
		_endIndex -= 1;
	}
	// else nothing to do.
}

// Clear Cache
-(void)clear
{
	[_cacheArray removeAllObjects];
	_startIndex = _endIndex = _allAvailableCount = -1;
}

// Memory Part
-(void)dealloc
{
	[_cacheArray release];
	_delegate = nil;
	[super dealloc];
}

@end
