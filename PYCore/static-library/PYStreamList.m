//
//  PYStreamList.m
//  PYCore
//
//  Created by Push Chen on 11/5/12.
//  Copyright (c) 2012 PushLab. All rights reserved.
//

#import "PYStreamList.h"
#import "PYMainMacro.h"
#import "NSObject+Extended.h"

@interface PYStreamList (Private)

-(void) insertArrayToHead:(NSArray *)array;
-(void) addArrayToTail:(NSArray *)array;

-(void) autoRefreshTimerHandler:(NSTimer *)timer;

@end

@implementation PYStreamList

@synthesize identify, userInfo, autoRefresh, autoRefreshInterval, pageSize=_pageSize;
@synthesize isCacheToEnd = _cacheToEnd, maxCountInCacheTop, datasource, delegate;

@dynamic refreshNotifyKey, loadMoreNotifyKey;
-(NSString *) refreshNotifyKey
{
	return [NSString stringWithFormat:@"k%@RefreshNotification", self.identify];
}

-(NSString *) loadMoreNotifyKey
{
	return [NSString stringWithFormat:@"k%@LoadMoreNotification", self.identify];
}

-(NSUInteger) count
{
	return [_innerArray count];
}
-(id) objectAtIndex:(NSUInteger)index
{
	return [_innerArray objectAtIndex:index];
}
-(void) insertObject:(id)object atIndex:(NSUInteger)index
{
	[_innerArray insertObject:object atIndex:index];
}
-(void) removeObjectAtIndex:(NSUInteger)index
{
	[_innerArray removeObjectAtIndex:index];
}
-(void) addObject:(id)object
{
	[_innerArray addObject:object];
}
-(void) removeLastObject
{
	[_innerArray removeLastObject];
}
-(void) removeObject:(id)object
{
	[_innerArray removeObject:object];
}
-(void) removeAllObjects
{
	[_innerArray removeAllObjects];
	_cacheToEnd = NO;
}
-(void) replaceObjectAtIndex:(NSUInteger)index withObject:(id)object
{
	[_innerArray replaceObjectAtIndex:index withObject:object];
}
-(BOOL) containsObject:(id)object
{
	return [_innerArray containsObject:object];
}
-(NSUInteger)indexOfObject:(id)anObject
{
	return [_innerArray indexOfObject:anObject];
}
-(id)lastObject
{
	return [_innerArray lastObject];
}
-(NSArray *) subarrayWithRange:(NSRange)range
{
	return [_innerArray subarrayWithRange:range];
}


-(void) dealloc
{
	[_innerArray release];
	_innerArray = nil;
	self.identify = nil;
	self.userInfo = nil;
	self.datasource = nil;
	self.delegate = nil;
	
	[super dealloc];
}

-(id) init
{
	self = [super init];
	if ( !self ) return nil;
	_innerArray = [[NSMutableArray array] retain];
	return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	_innerArray = [[aDecoder decodeObjectForKey:@"kArcInnerArray"] retain];
	if ( _innerArray == nil ) _innerArray = [[NSMutableArray array] retain];
	PYUnArchiveObject(identify);
	PYUnArchiveObject(userInfo);
	PYUnArchiveBool(autoRefresh);
	PYUnArchiveDouble(autoRefreshInterval);
	PYUnArchiveInt(maxCountInCacheTop);
	
	self.datasource = nil;
	self.delegate = nil;
	
	_cacheToEnd = [aDecoder decodeBoolForKey:@"kArcCacheToEnd"];
	return self;
}

-(void) encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:_innerArray forKey:@"kArcInnerArray"];
	PYArchiveObject(identify);
	PYArchiveObject(userInfo);
	PYArchiveBool(autoRefresh);
	PYArchiveDouble(autoRefreshInterval);
	PYArchiveInt(maxCountInCacheTop);
	
	[aCoder encodeBool:_cacheToEnd forKey:@"kArcCacheToEnd"];
}

-(void) setAutoRefresh:(BOOL)isRefresh
{
	autoRefresh = isRefresh;
	if ( autoRefresh == NO ) {
		if ( _refreshTimer == nil ) return;
		[_refreshTimer invalidate];
		[_refreshTimer release];
		_refreshTimer = nil;
		if ( [self.delegate respondsToSelector:@selector(streamListDidStopToAutoRefresh:)] )
		{
			[self.delegate streamListDidStopToAutoRefresh:self];
		}
		return;
	} else {
		if ( _refreshTimer != nil ) return;
		if ( self.autoRefreshInterval == 0 ) autoRefreshInterval = 30.f;
		_refreshTimer = [NSTimer scheduledTimerWithTimeInterval:self.autoRefreshInterval target:self
			selector:@selector(autoRefreshTimerHandler:) userInfo:nil repeats:YES];
		[_refreshTimer retain];
		if ( [self.delegate respondsToSelector:@selector(streamListDidStartToAutoRefresh:)] )
		{
			[self.delegate streamListDidStartToAutoRefresh:self];
		}
	}
}

-(void) setAutoRefreshInterval:(double)interval
{
	autoRefreshInterval = interval;
	if ( autoRefresh == YES && _refreshTimer != nil )
	{
		// Reset the timer
		[_refreshTimer invalidate];
		[_refreshTimer release];
		_refreshTimer = [NSTimer scheduledTimerWithTimeInterval:self.autoRefreshInterval target:self
			selector:@selector(autoRefreshTimerHandler:) userInfo:nil repeats:YES];
		[_refreshTimer retain];
	}
}

-(void) setDatasource:(id<PYStreamListDatasource>)ds
{
	[datasource release];
	datasource = nil;
	if ( ds == nil ) return;
	datasource = [ds retain];
	_pageSize = [ds pageSizeOfStreamList:self];
}

@dynamic currentPageId, morePageId;
-(int) currentPageId { return [self count] / _pageSize + ([self count] % _pageSize == 0 ? 0 : 1); }
-(int) morePageId {
	PYLog(@"count: %d", [self count]);
	return [self count] / _pageSize + ([self count] % _pageSize == 0 ? 1 : 0);
}

// Messages

-(void) refreshStream
{
	PYASSERT(self.datasource != nil, @"The datasource of stream list cannot be nil!");
	_pageSize = [self.datasource pageSizeOfStreamList:self];
	[self.datasource refreshStreamList:self getResultArray:^(id result) {
		PYSingletonLock
		NSArray *_a = (NSArray *)result;
		[self insertArrayToHead:_a];
		PYSingletonUnLock
	}];
}
-(void) loadMoreStream
{
	PYASSERT(self.datasource != nil, @"The datasource of stream list cannot be nil!");
	_pageSize = [self.datasource pageSizeOfStreamList:self];
	[self.datasource loadMoreStreamList:self getResultArray:^(id result) {
		PYSingletonLock
		NSArray *_a = (NSArray *)result;
		[self addArrayToTail:_a];
		PYSingletonUnLock
	}];
}

// Private

-(void) insertArrayToHead:(NSArray *)array
{
	// insert
	NSMutableArray *_insertArray = [NSMutableArray array];
	for ( int i = [array count] - 1; i >= 0; --i ) {
		id obj = [array objectAtIndex:i];
		if ( [self containsObject:obj] ) continue;
		[self insertObject:obj atIndex:0];
		[_insertArray insertObject:obj atIndex:0];
	}
	if ( self.maxCountInCacheTop != PYINFINITE )
	{
		if ( [self count] > self.maxCountInCacheTop )
		{
			NSRange _r;
			_r.location = self.maxCountInCacheTop;
			_r.length = [self count] - self.maxCountInCacheTop;
			[_innerArray removeObjectsInRange:_r];
			_cacheToEnd = NO;
		}
	}
	
	if ( [self.delegate respondsToSelector:@selector(streamList:didReciveNewIncomingStream:)] )
	{
		[self.delegate streamList:self didReciveNewIncomingStream:_insertArray];
	}
}

-(void) addArrayToTail:(NSArray *)array
{
	// add
	NSMutableArray *_moreArray = [NSMutableArray array];
	for ( id object in array )
	{
		if ( [self containsObject:object] ) continue;
		[self addObject:object];
		[_moreArray addObject:object];
	}
	if ( [_moreArray count] == 0 ) _cacheToEnd = YES;
	if ( [self.delegate respondsToSelector:@selector(streamList:didLoadMoreOldStream:)] )
	{
		[self.delegate streamList:self didLoadMoreOldStream:_moreArray];
	}
}

-(void) autoRefreshTimerHandler:(NSTimer *)timer
{
	[self refreshStream];
}

@end
