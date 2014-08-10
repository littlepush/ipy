//
//  PYDataManager.h
//  PYData
//
//  Created by Push Chen on 8/11/14.
//  Copyright (c) 2014 Push Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PYObject.h"

extern NSString *const kCurrentLoggedInUserId;
extern NSString *const kDefaultUserId;

/*! Basic Data Manager */
@interface PYDataManager : NSObject
{
    PYGlobalDataCache               *_dataCache;
    PYGlobalDataCache               *_userCache;
    
    NSString                        *_currentUserId;
}

// Shared instance
+ (instancetype)shared;

// Switch the user and the user cache
- (void)switchUser:(NSString *)userId;

- (void)logout;

// Readonly
@property (nonatomic, readonly) PYGlobalDataCache   *userCache;
@property (nonatomic, readonly) PYGlobalDataCache   *dataCache;

// Shared Cache Operator for Uplevel
- (void)setData:(PYObject *)object forKey:(NSString *)key;
- (void)setData:(PYObject *)object forKey:(NSString *)key expire:(PYDate *)expire;
- (void)setNSObject:(id<NSCoding>)object forKey:(NSString *)key;
- (void)setNSObject:(id<NSCoding>)object forKey:(NSString *)key expire:(PYDate *)expire;
- (PYObject *)dataForKey:(NSString *)key;
- (id)objectForKey:(NSString *)key;
- (PYGDCObject *)fullNSObjectForKey:(NSString *)key;
- (void)removeDataForKey:(NSString *)key;
- (BOOL)containsKey:(NSString *)key;
- (BOOL)isDataForKey:(NSString *)key expiredFromDate:(PYDate *)date;

// User Cache
- (void)setUserData:(PYObject *)object forKey:(NSString *)key;
- (PYObject *)userDataForKey:(NSString *)key;
- (void)removeUserDataForKey:(NSString *)key;

// Erase all cached data, when done, invoke the callback block.
- (void)eraseAllDataCompletion:(PYActionDone)done;

@end
