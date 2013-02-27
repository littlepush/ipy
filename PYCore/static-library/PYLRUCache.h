//
//  PYLRUCache.h
//  PYCore
//
//  Created by Push Chen on 11/28/11.
//  Copyright (c) 2011 PushLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PYTypes.h"

/*
 PushLab Team All Rights Reserved.
 This is a LRU Cache container. The cache object can 
 maintain it memory and object count automatically.
 We can change the max object limitation to upgrade
 or downgrade the cache size.
 The effect of cache size changing will be affect the
 next time we add new object into the cache.
 
 Usually, we can use a shared cache as the global cache.
 For example:
	PYLRUCache *gCache = [PYLRUCache sharedCache];
 Also, we can create other cache instances and add the
 cache to the shared cache.
 We still provide some delegate callback messages to notify
 the observer which object will be remove from the cache.
 And when the application is out of memory, we can 
 directly remove all objects of the cache.
 */

/* Default Limitation of shared cache. */
#define	PYLRUCacheDefaultMaxLimitation		100

#define SHARED_PYCACHE					[PYLRUCache sharedCache]

/* Cache Event Notification Key */
/* Notify the observer when a new value has been added to the cache. */
//#define kPYLRUCacheNotificationAddedObject		@"kPYLRUCacheNotificationAddedObject"
/* Notify the observer when an old value has been removed from the cache */
//#define kPYLRUCacheNotificationRemovedObject	@"kPYLRUCacheNotificationRemovedObject"
/* ***if we remove all object at the same time, no notification. */

/* Tuita Library Cache Container. */
@interface PYLRUCache : NSObject < NSCoding >
{
	/* Key-Value Map */
	NSMutableDictionary		*cacheDictStorage;
	/* Key List, store the key in order. */
	NSMutableArray			*cacheKeyOrderList;
	/* Max object limitation setting */
	NSInteger				maxObjectLimitation;
	
	/* Observer list. */
//	NSMutableDictionary		*observerAddedList;
//	NSMutableDictionary		*observerRemovedList;
	
//	PYKeyValuePair			*lastRemovedPair;
//	PYKeyValuePair			*lastAddedPair;
}

/*
 All properties are readonly.
 */
@property (nonatomic, readonly) NSInteger limitation;
//@property (nonatomic, readonly) PYKeyValuePair	*lastRemovedPair;
//@property (nonatomic, readonly) PYKeyValuePair	*lastAddedPair;

@property (nonatomic, readonly) NSArray		*keys;

/*
 Global Messages.
 We can create an autoreleased or shared cache object by these
 two messages.
 */
+(PYLRUCache *)sharedCache;
+(PYLRUCache *)cacheWithMaxObjectLimitation:(NSInteger)limit;

/* 
 Default initialize the cache with PYLRUCacheDefaultMaxLimitation, 
 and we can specifie the limitation by invoke this message.
 */
-(PYLRUCache *)initWithMaxObjectLimitation:(NSInteger)limit;

/*
 Change the limitation of the cache, the changing will be affect
 after the next add operation.
 */
-(void)setMaxObjectLimitation:(NSInteger)limit;

/* add observer to the cache. */
/*
-(void)addObserver:(id)observer selector:(SEL)sel
			  name:(NSString *)kPYLRUCacheNotification;
*/
/* remove an observer */
/*
-(void)removeObserver:(id)observer;
*/
/*
 Add new value or update older value into the cache.
 */
-(void)setObject:(id)value forKey:(id)key;
/*
 Get the value of speicified key, will also update
 the order in the cache.
 */
-(id)objectForKey:(id)key;
/*
 Remove an object in the cache.
 */
-(void)removeObjectForKey:(id)key;
/*
 Erase the cache.
 */
-(void)removeAllObjects;
/*
 Enumerator
 */
-(NSEnumerator *)objectEnumerator;

@end
