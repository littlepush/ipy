//
//  PYDataManager.m
//  PYData
//
//  Created by Push Chen on 8/11/14.
//  Copyright (c) 2014 Push Lab. All rights reserved.
//

#import "PYDataManager.h"

static PYDataManager *_gDataManager = nil;
NSString *const kCurrentLoggedInUserId = @"kCurrentLoggedInUserId";
NSString *const kDefaultUserId = @"py20120403";

NSString *const PYDataManagerUserLoginStatusChangedNotification = @"PYDataManagerUserLoginStatusChangedNotification";

@implementation PYDataManager

+ (instancetype)shared
{
    PYSingletonLock
    if ( !_gDataManager ) {
        _gDataManager = [PYDataManager object];
    }
    return _gDataManager;
    PYSingletonUnLock
}

PYSingletonAllocWithZone(_gDataManager)
PYSingletonDefaultImplementation

- (id)init
{
    self = [super init];
    if ( self ) {
        _dataCache = [PYGlobalDataCache gdcWithIdentify:[PYKernel currentKernel].bundleId];
        _currentUserId = @"";
        NSString *_tempUserId = [_dataCache objectForKey:kCurrentLoggedInUserId];
        if ( [_tempUserId length] == 0 ) {
            _tempUserId = kDefaultUserId;
        }
        [self switchUser:_tempUserId];
    }
    return self;
}

- (void)switchUser:(NSString *)userId
{
    PYSingletonLock
    if ( [_currentUserId isEqualToString:userId] ) return;
    if ( [_currentUserId length] > 0 ) {
        [PYGlobalDataCache
         releaseGdcWithIdentify:[NSString stringWithFormat:@"%@.%@",
                                 [PYKernel currentKernel].bundleId,
                                 _currentUserId]];
    }
    _currentUserId = [userId copy];
    _userCache = [PYGlobalDataCache
                  gdcWithIdentify:[NSString stringWithFormat:@"%@.%@",
                                   [PYKernel currentKernel].bundleId,
                                   userId]];
    [_dataCache setObject:userId forKey:kCurrentLoggedInUserId];
    
    [NF_CENTER postNotificationName:PYDataManagerUserLoginStatusChangedNotification object:nil];
    PYSingletonUnLock
}

- (void)logout
{
    PYSingletonLock
    [self switchUser:kDefaultUserId];
    PYSingletonUnLock
}

// Shared Cache Operator for Uplevel
- (void)setData:(PYObject *)object forKey:(NSString *)key
{
    [_dataCache setPYObject:object forKey:key];
}
- (void)setData:(PYObject *)object forKey:(NSString *)key expire:(PYDate *)expire
{
    [_dataCache setPYObject:object forKey:key expire:expire];
}
- (void)setNSObject:(id<NSCoding>)object forKey:(NSString *)key
{
    [_dataCache setObject:object forKey:key];
}
- (void)setNSObject:(id<NSCoding>)object forKey:(NSString *)key expire:(PYDate *)expire
{
    [_dataCache setObject:object forKey:key expire:expire];
}

- (PYObject *)dataForKey:(NSString *)key
{
    PYObject *_data = [_dataCache PYObjectForKey:key];
    if ( _data == nil ) {
        _data = [_userCache PYObjectForKey:key];
    }
    return _data;
}
- (id)objectForKey:(NSString *)key
{
    id _obj = [_dataCache objectForKey:key];
    return _obj;
}

- (PYGDCObject *)fullNSObjectForKey:(NSString *)key;
{
    PYGDCObject *_data = [_dataCache fullObjectForKey:key];
    if ( _data == nil ) {
        _data = [_userCache fullObjectForKey:key];
    }
    return _data;
}
- (void)removeDataForKey:(NSString *)key
{
    [_dataCache setObject:nil forKey:key];
}

- (BOOL)containsKey:(NSString *)key    // If contains the key, search local & offline cache.
{
    if ( [_dataCache containsKey:key] ) return YES;
    return [_userCache containsKey:key];
}

- (BOOL)isDataForKey:(NSString *)key expiredFromDate:(PYDate *)date
{
    return [_dataCache isObjectForKey:key expiredFrom:date];
}

// User Cache
- (void)setUserData:(PYObject *)object forKey:(NSString *)key
{
    [_userCache setPYObject:object forKey:key];
}
- (PYObject *)userDataForKey:(NSString *)key
{
    return [_userCache PYObjectForKey:key];
}
- (void)removeUserDataForKey:(NSString *)key
{
    [_userCache setObject:nil forKey:key];
}

// Erase all cached data, when done, invoke the callback block.
- (void)eraseAllDataCompletion:(PYActionDone)done
{
    PYSingletonLock
    [_dataCache clearAllCacheData:^{
        if ( done ) {
            done();
        }
    }];
    PYSingletonUnLock
}

@end
