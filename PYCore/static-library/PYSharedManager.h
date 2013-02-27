//
//  PYSharedManager.h
//  PYCore
//
//  Created by littlepush on 8/27/12.
//  Copyright (c) 2012 PushLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PYTypes.h"
#import "NSArray+Extended.h"

@protocol PYSharedManagerDelegate;

@interface PYSharedManager : NSObject < NSCoding >
{
	NSMutableDictionary			*_actionCallbackCache;
	NSMutableArray				*_delegate;
}

/* Actions in queue */
@property (nonatomic, readonly)	NSUInteger		pendingActionCount;

#pragma Action Operations
/* Basic Action Cache Message */
-(void) action:(NSString *)name done:(PYActionDone)done get:(PYActionGet)get 
	failed:(PYActionFailed)failed finished:(PYActionFinished)finished;

/* Single call back block */
-(void) action:(NSString *)name done:(PYActionDone)done;
-(void) action:(NSString *)name get:(PYActionGet)get;
-(void) action:(NSString *)name failed:(PYActionFailed)failed;
-(void) action:(NSString *)name finished:(PYActionFinished)finished;

/* Two callback blocks */
-(void) action:(NSString *)name 
	done:(PYActionDone)done get:(PYActionGet)get;
-(void) action:(NSString *)name 
	done:(PYActionDone)done failed:(PYActionFailed)failed;
-(void) action:(NSString *)name 
	done:(PYActionDone)done finihsed:(PYActionFinished)finished;

-(void) action:(NSString *)name 
	get:(PYActionGet)get failed:(PYActionFailed)failed;
-(void) action:(NSString *)name 
	get:(PYActionGet)get finished:(PYActionFinished)finished;

-(void) action:(NSString *)name 
	finished:(PYActionFinished)finished failed:(PYActionFailed)failed;

/* Three callback blocks */
-(void) action:(NSString *)name done:(PYActionDone)done
	failed:(PYActionFailed)failed finished:(PYActionFinished)finished;
-(void) action:(NSString *)name done:(PYActionDone)done 
	get:(PYActionGet)get failed:(PYActionFailed)failed;
-(void) action:(NSString *)name done:(PYActionDone)done 
	get:(PYActionGet)get finished:(PYActionFinished)finished;
-(void) action:(NSString *)name get:(PYActionGet)get
	failed:(PYActionFailed)failed finished:(PYActionFinished)finished;
	
#pragma Get Action
// Get an action block and remain it in the cache
-(PYActionBlock *) actionWithName:(NSString *)name;
// Remove an action block from the cache
-(void) removeActionNamed:(NSString *)name;
// Get an action block and remove it from the cache
-(PYActionBlock *) fetchActionWithName:(NSString *)name;

#pragma Global
-(void) removeAllActions;

#pragma Service Status
+(id) sharedManager;
/* Start the manager */
-(void) startServices;
/* Stop the manager and save data */
-(void) stopServices;
/* Save the cache data to file or something else */
-(void) archiveData;

#pragma Delegates
-(void) addDelegate:(id<PYSharedManagerDelegate>)delegate;
-(void) removeDelegate:(id<PYSharedManagerDelegate>)delegate;
-(void) delegatesPerform:(SEL)selector;
-(void) delegatesPerform:(SEL)selector withObject:(id)object;
-(void) delegatesPerform:(SEL)selector withObject:(id)obj1 withObject:(id)obj2;

+(void) insertArray:(NSArray *)array toListHead:(NSMutableArray *)list compare:(PYActionCompare)comp;
+(void) insertArray:(NSArray *)array toListTail:(NSMutableArray *)list compare:(PYActionCompare)comp;

@end

/* The Shared Manager Delegate */
@protocol PYSharedManagerDelegate <NSObject>

@optional
-(void) manager:(PYSharedManager *)manager didStartService:(BOOL)statues;
-(void) managerDidStopService:(PYSharedManager *)manager;
-(void) manager:(PYSharedManager *)manager didArchiveDataWithOption:(NSDictionary *)option;

@end

/* For Timeline liked Cache Manager */
@protocol PYTimelineManager <NSObject>

@optional
/* The timeline cache */
@property (nonatomic, retain)	NSMutableArray		*timelineCache;

@optional
/* Already reach the end of the timeline, that means do not need to load more */
@property (nonatomic, readonly)	BOOL				reachEndOfTimeline;

@optional
/* New items in cache has not been displayed */
@property (nonatomic, readonly)	BOOL				hasNewItemsUnread;

@required
/* 
	Refresh new items, the manager will fetch the first item in timelineCache
	to set the request parameters. Invoker should not worry about this.
 */
-(void) refreshItemsGet:(PYActionGet)get failed:(PYActionFailed)failed;

/* 
	Load more items, the manager will fetch the last item in timelineCache
	to set the request parameters. Invoker should not worry about this.
 */
-(void) loadMoreItemsGet:(PYActionGet)get failed:(PYActionFailed)failed;

@end

/* For Multiple User's Timeine Cache */
@protocol PYMultibleTimelineManager <NSObject>

@optional
/* Two-Level Cache, first level is User-Timeline, second level is the ArrayCache */
@property (nonatomic, retain)	NSMutableDictionary	*multibleTimelineCache;
/* Get the timeline cache of specified keyed user(or other key specified) */
-(NSMutableArray *) timelineForKey:(id) tlKey;

@optional
/* Different Cache Statues */
@property (nonatomic, retain)	NSMutableDictionary	*timelineCacheStatus;
-(BOOL) reachEndOfTimelineForKey:(id) tlKey;
-(BOOL) hasNewItesUnreadForKey:(id) tlKey;

@required
/* 
	Refresh new items, the manager will fetch the first item in timelineCache
	to set the request parameters. Invoker should not worry about this.
 */
-(void) refreshItemsForKey:(id) tlKey get:(PYActionGet)get failed:(PYActionFailed)failed;

/* 
	Load more items, the manager will fetch the last item in timelineCache
	to set the request parameters. Invoker should not worry about this.
 */
-(void) loadMoreItemsForKey:(id) tlKey get:(PYActionGet)get failed:(PYActionFailed)failed;

@end
