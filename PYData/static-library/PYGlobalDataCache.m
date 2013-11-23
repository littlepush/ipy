//
//  PYGlobalDataCache.m
//  PYData
//
//  Created by Push Chen on 1/19/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
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

#import "PYGlobalDataCache.h"

// The GDC init options supported key.
NSString *const kGDCInitCacheTableName  = @"kGDCInitCacheTableName";
NSString *const kGDCInitLibraryFolder   = @"kGDCInitLibraryFolder";
NSString *const kGDCInitDBPath          = @"kGDCInitDBPath";
NSString *const kGDCInitiCloudEnable    = @"kGDCInitiCloudEnable";

@implementation PYGDCObject
@synthesize object, expire;
@end

static NSMutableDictionary		*_gdcDict;

@interface PYGlobalDataCache ()

- (NSData *)_formatObject:(id<NSCoding>)value;

- (void)_checkCacheSizeAndClean;

@end

@implementation PYGlobalDataCache

+ (void)initialize
{
	// Initialize the gdc dictionary
	_gdcDict = [NSMutableDictionary dictionary];
#ifdef PY_FORCE_THREASAFE
    NSError *_mtError = [PYGlobalDataCache initializeSqliteForMultipleThreadAndForceToSet:YES];
    if ( _mtError != nil ) {
        ALog(@"%@", _mtError.localizedDescription);
    }
#endif
}

+ (void)initializeSqliteForMultithreadSupport
{
    // Initialize the database for multiple thread usage.
    if ( sqlite3_config(SQLITE_CONFIG_SERIALIZED) != SQLITE_OK ) {
        [self raiseExceptionWithMessage:@"Failed to set the sqlite as thread-safe."];
    }
}
+ (NSError *)initializeSqliteForMultipleThread
{
    return [PYGlobalDataCache initializeSqliteForMultipleThreadAndForceToSet:NO];
}
+ (NSError *)initializeSqliteForMultipleThreadAndForceToSet:(BOOL)forced
{
    // It's the first time to set the config flag, done!
    if ( sqlite3_config(SQLITE_CONFIG_SERIALIZED) == SQLITE_OK ) return nil;
    if ( forced == NO )
        return [self errorWithCode:SQLITE_ERROR
                           message:@"Failed to set the sqlite as thread-safe."];
    int _ret = sqlite3_shutdown();
    if ( _ret != SQLITE_OK ) {
        return [self errorWithCode:_ret
                           message:
                @"Sqlite3 has already been shuted-down, "
                @"but failed to set thread-safe."];
    }
    NSError *_returnError = nil;
    _ret = sqlite3_config(SQLITE_CONFIG_SERIALIZED);
    if ( _ret != SQLITE_OK ) {
        _returnError = [self errorWithCode:_ret
                                   message:
                        @"Failed to set thread-safe flag when shuteddown, "
                        @"maybe others are doing something."];
    }
    _ret = sqlite3_initialize();
    if ( _ret != SQLITE_OK && _returnError == nil ) {
        _returnError = [self errorWithCode:_ret
                                   message:@"Failed to re-initialize the sqlite3"];
    }
    return _returnError;
}

- (NSData *)_formatObject:(id<NSCoding>)value
{
	return [NSKeyedArchiver archivedDataWithRootObject:value];
	//return [PYEncoder encodeBase64FromData:_codeData.bytes length:_codeData.length];
}

- (void)_checkCacheSizeAndClean
{
	while ( _cacheSizeInUse > _cacheSizeInBytes ) {
		NSString *_lastKey = [_coreKeysCache lastObject];
		PYKeyedDbRow *_lastValue = [_coreInMemCache objectForKey:_lastKey];
		_cacheSizeInUse -= [_lastValue.value length];
        _cacheSizeInUse -= [_lastKey length];
		[_coreKeysCache removeLastObject];
		[_coreInMemCache removeObjectForKey:_lastKey];
        _lastValue = nil;
        _lastKey = nil;
	}
}

#pragma mark --
#pragma mark -- Properties

@dynamic dcIdentify;
- (NSString *)dcIdentify { return _identify; }

@synthesize cacheSizeInBytes = _cacheSizeInBytes;
@synthesize cacheSizeInUse = _cacheSizeInUse;

@synthesize hitMemoryPercentage = _hitMemPercentage;
@synthesize lastHitInMemKey = _lastHitInMemKey;
@synthesize lastSearchedKey = _lastSearchedKey;

@dynamic inMemObjectCount;
- (NSUInteger)inMemObjectCount { return [_coreInMemCache count]; }
@synthesize allObjectCount = _allObjectCount;

#pragma mark --
#pragma mark -- Core Messages
- (void)batchOperation:(PYActionDone)operations
{
    if ( operations == nil ) return;
    if ( ![_innerDb beginBatchOperation] ) return;
    // Do the operations...
    operations();
    [_innerDb endBatchOperation];
}

// Setter
- (void)setObject:(id<NSCoding>)value forKey:(NSString *)key
{
    // The key will never expired.
    [self setObject:value forKey:key expire:[PYDate dateWithTimestamp:(-1)]];
}

- (void)setObject:(id<NSCoding>)value forKey:(NSString *)key expire:(id<PYDate>)expire
{
    if ( [key isEqual:[NSNull null]] ||
        (![key isKindOfClass:[NSString class]]) ||
        [key length] == 0 )
        return;
    [_lock lock];
	NSData *_dbValue = (value == nil) ? nil : [self _formatObject:value];
	NSUInteger _index = [_coreKeysCache indexOfObject:key];
	if ( _index != NSNotFound ) {
		PYKeyedDbRow *_oldValue = [_coreInMemCache objectForKey:key];
		_cacheSizeInUse -= [_oldValue.value length];
        _cacheSizeInUse -= [key length];
		[_coreKeysCache removeObjectAtIndex:_index];
        [_coreInMemCache removeObjectForKey:key];
	}
    if ( [_dbValue length] > 0 ) {
        PYKeyedDbRow *_row = [PYKeyedDbRow object];
        _row.value = _dbValue;
        _row.expire = expire;
        
        [_coreInMemCache setObject:_row forKey:key];
        [_coreKeysCache insertObject:key atIndex:0];
        _cacheSizeInUse += [_dbValue length];
        _cacheSizeInUse += [key length];
        // Clean the cache
        [self _checkCacheSizeAndClean];
        
        if ( [_innerDb containsKey:key] ) {
            // update
            [_innerDb updateValue:_dbValue forKey:key expireOn:expire];
        } else {
            [_innerDb addValue:_dbValue forKey:key expireOn:expire];
            _allObjectCount += 1;
        }
    } else {
        if ( [_innerDb containsKey:key] ) {
            // delete
            [_innerDb deleteValueForKey:key];
        }
    }

    [_lock unlock];
}

// Getter
- (id)objectForKey:(NSString *)key
{
    PYGDCObject *_object = [self fullObjectForKey:key];
    if ( _object == nil ) return nil;
    return _object.object;
}
- (PYGDCObject *)fullObjectForKey:(NSString *)key
{
    if ( [key isEqual:[NSNull null]] ||
        (![key isKindOfClass:[NSString class]]) ||
        [key length] == 0 )
        return nil;
    [_lock lock];
	// Check in-mem cache...
	if ( _lastSearchedKey != nil ) _lastSearchedKey = nil;
	_lastSearchedKey = key;
	_searchedTimes += 1;
	NSUInteger _index = [_coreKeysCache indexOfObject:key];
	PYKeyedDbRow *_value;
	if ( _index != NSNotFound ) {
		// contains the key in cache
		_hitMemPercentage = ((_hitMemPercentage * (_searchedTimes - 1) + 1) / (double)_searchedTimes);
		if ( _lastHitInMemKey != nil ) _lastHitInMemKey = nil;
		_lastHitInMemKey = key;
		
		[_coreKeysCache removeObjectAtIndex:_index];
		// Move the searched key to top
		[_coreKeysCache insertObject:key atIndex:0];
		_value = [_coreInMemCache objectForKey:key];
	} else {
		if ( ![_innerDb containsKey:key] ) {
			// no such key in both cache.
			_hitMemPercentage = (_hitMemPercentage * (_searchedTimes - 1) / (double)_searchedTimes);
            [_lock unlock];
			return nil;
		}
		_value = [_innerDb valueForKey:key];
		// Put the value into in-mem cache
		[_coreKeysCache insertObject:key atIndex:0];
		[_coreInMemCache setObject:_value forKey:key];
		_cacheSizeInUse += [_value.value length];
        _cacheSizeInUse += [key length];
		[self _checkCacheSizeAndClean];
	}

	//NSData *_dbData = [PYEncoder decodeBase64ToData:_value.value];
	id _object = [NSKeyedUnarchiver unarchiveObjectWithData:_value.value];
    PYGDCObject *_gdcObject = [PYGDCObject object];
    _gdcObject.object = _object;
    _gdcObject.expire = _value.expire;
    [_lock unlock];
    return _gdcObject;
}

- (BOOL)containsKey:(NSString *)key
{
    if ( [key isEqual:[NSNull null]] ||
        (![key isKindOfClass:[NSString class]]) ||
        [key length] == 0 )
        return NO;
    [_lock lock];
    
    BOOL _isContained = [_coreInMemCache objectForKey:key] != nil;
    if ( _isContained == NO ) {
        _isContained = [_innerDb containsKey:key];
    }
    
    [_lock unlock];
    return _isContained;
}

- (void)clearAllCacheData:(PYActionDone)done
{
    BEGIN_ASYNC_INVOKE
    [_lock lock];
    [_innerDb clearDBData];
    [_coreInMemCache removeAllObjects];
    [_coreKeysCache removeAllObjects];
    _cacheSizeInUse = 0;
    _allObjectCount = 0;
    _hitMemPercentage = 0.f;
    _searchedTimes = 0;
    _lastHitInMemKey = @"";
    _lastSearchedKey = @"";
    [_lock unlock];
    BEGIN_MAINTHREAD_INVOKE
    if (done) done();
    END_MAINTHREAD_INVOKE
    END_ASYNC_INVOKE
}

#pragma mark --
#pragma mark -- Global && Init

+ (PYGlobalDataCache *)gdcWithIdentify:(NSString *)identify options:(NSDictionary *)options
{
    @synchronized(self) {
        if ( [_gdcDict objectForKey:identify] != nil )
            return [_gdcDict objectForKey:identify];
        PYGlobalDataCache *_gdc = [[PYGlobalDataCache alloc]
            initGDCWithIdentify:identify options:options];
        if ( _gdc == nil ) return nil;
        [_gdcDict setValue:_gdc forKey:identify];
        return _gdc;
    }
}
+ (PYGlobalDataCache *)gdcWithIdentify:(NSString *)identify
{
    return [PYGlobalDataCache
            gdcWithIdentify:identify
            options:@{
                      kGDCInitCacheTableName:kKeyedDBTableName,
                      kGDCInitLibraryFolder:@"PYData",
                      kGDCInitDBPath:PYLIBRARYPATH,
                      kGDCInitiCloudEnable:PYBoolToObject(NO)
                      }];
}

+ (void)releaseGdcWithIdentify:(NSString *)identify
{
    @synchronized(self) {
        if ( [_gdcDict objectForKey:identify] != nil )
            [_gdcDict removeObjectForKey:_gdcDict];
    }
}

- (id)init
{
	PYTHROW(@"Pure init is not supported for GDC");
	self = [super init];
	if ( self ) {}
	return self;
}

- (id)initGDCWithIdentify:(NSString *)identify options:(NSDictionary *)options
{
	self = [super init];
	if ( self ) {
		_cacheSizeInBytes = PYGDCSize4M;
		_cacheSizeInUse = 0;
		_identify = identify;
        
        NSString *_path = [options stringObjectForKey:kGDCInitDBPath withDefaultValue:PYLIBRARYPATH];
        NSString *_folder = [options stringObjectForKey:kGDCInitLibraryFolder withDefaultValue:@"PYData"];
        NSString *_tbname = [options stringObjectForKey:kGDCInitCacheTableName withDefaultValue:kKeyedDBTableName];
        BOOL _iCloudEnable = [options boolObjectForKey:kGDCInitiCloudEnable withDefaultValue:NO];
		
		_coreInMemCache = [NSMutableDictionary dictionary];
		_coreKeysCache = [NSMutableArray array];
		
        NSFileManager *_fm = [NSFileManager defaultManager];
        NSString *_dbPath = [_path stringByAppendingPathComponent:_folder];
        if ( ![_fm fileExistsAtPath:_dbPath] ) {
            NSError *_error;
            [_fm createDirectoryAtPath:_dbPath
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:&_error];
            if ( _error != nil ) {
                NSLog(@"error: %@", [_error localizedDescription]);
                self = nil;
                return nil;
            }
        }
        NSString *_filePath = [_dbPath stringByAppendingPathComponent:identify];
		_innerDb = [PYKeyedDb keyedDbWithPath:_filePath cacheTableName:_tbname];
		
		if ( _innerDb == nil ) {
			// Failed to initialize the database.
			self = nil;
			return self;
		}
		
        if ( _iCloudEnable == NO ) {
            PYSKIPICLOUD(_filePath);
        }
		
		_hitMemPercentage = 0.f;
		_allObjectCount = [_innerDb count];
        
        _lock = [NSRecursiveLock object];
        _lock.name = [NSString stringWithFormat:@"com.%@.lock", identify];
	}
	return self;
}

#pragma mark --
#pragma mark -- Description

- (NSString *)description
{
	return [NSString stringWithFormat:@"\nGDC<%@> (\n"
            @"All Object Count: %ld\n"
            @"Hit: %02f%%\n"
            @"Last Searched Key: %@\n"
            @"Last Hit Key: %@\n"
            @"Cache Limit Size: %u Bytes\n"
            @"Cache Size In Use: %u Bytes\n"
            @")",
            _identify, _allObjectCount, _hitMemPercentage * 100,
            _lastSearchedKey, _lastHitInMemKey,
            _cacheSizeInBytes, _cacheSizeInUse];
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
