//
//  PYStreamList.h
//  PYCore
//
//  Created by Push Chen on 11/5/12.
//  Copyright (c) 2012 PushLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PYTypes.h"

typedef enum { PYINFINITE = 0 } PYStreamListCount;

@protocol PYStreamListDelegate;
@protocol PYStreamListDatasource;

@interface PYStreamList : NSObject < NSCoding >
{
	NSMutableArray					*_innerArray;
	BOOL							_cacheToEnd;
	NSTimer							*_refreshTimer;
	int								_pageSize;
}

@property (nonatomic, copy)			NSString					*identify;
@property (nonatomic, retain)		NSMutableDictionary			*userInfo;
@property (nonatomic, assign)		BOOL						autoRefresh;
@property (nonatomic, assign)		double						autoRefreshInterval;

@property (nonatomic, readonly)		BOOL						isCacheToEnd;
@property (nonatomic, assign)		int							maxCountInCacheTop;
@property (nonatomic, retain)		id<PYStreamListDatasource>	datasource;
@property (nonatomic, retain)		id<PYStreamListDelegate>	delegate;

@property (nonatomic, readonly)		int							currentPageId;
@property (nonatomic, readonly)		int							morePageId;
@property (nonatomic, readonly)		int							pageSize;

@property (nonatomic, readonly)		NSString					*refreshNotifyKey;
@property (nonatomic, readonly)		NSString					*loadMoreNotifyKey;

/* NSMutableArray's basic actions */
-(NSUInteger) count;
-(id) objectAtIndex:(NSUInteger)index;
-(void) insertObject:(id)object atIndex:(NSUInteger)index;
-(void) removeObjectAtIndex:(NSUInteger)index;
-(void) addObject:(id)object;
-(void) removeLastObject;
-(void) removeAllObjects;
-(void) removeObject:(id)object;
-(void) replaceObjectAtIndex:(NSUInteger)index withObject:(id)object;
-(BOOL) containsObject:(id)object;
-(NSUInteger)indexOfObject:(id)anObject;
-(NSArray *) subarrayWithRange:(NSRange)range;
-(id)lastObject;

/* Stream List's Actions */
-(void) refreshStream;
-(void) loadMoreStream;

@end

@protocol PYStreamListDatasource <NSObject>

@required
-(int) pageSizeOfStreamList:(PYStreamList *)list;
-(void) refreshStreamList:(PYStreamList *)list getResultArray:(PYActionGet)get;
-(void) loadMoreStreamList:(PYStreamList *)list getResultArray:(PYActionGet)get;

@end

@protocol PYStreamListDelegate <NSObject>

@optional
-(void) streamListDidStartToAutoRefresh:(PYStreamList *)list;
-(void) streamListDidStopToAutoRefresh:(PYStreamList *)list;

-(void) streamList:(PYStreamList *)list didReciveNewIncomingStream:(NSArray *)newObjects;
-(void) streamList:(PYStreamList *)list didLoadMoreOldStream:(NSArray *)oldObjects;

@end
