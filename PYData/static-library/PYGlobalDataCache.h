//
//  PYGlobalDataCache.h
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

#import <Foundation/Foundation.h>
#import <PYCore/PYCoreMacro.h>
#import "PYKeyedDb.h"

// The GDC init options supported key.
extern NSString *const kGDCInitCacheTableName;
extern NSString *const kGDCInitLibraryFolder;
extern NSString *const kGDCInitDBPath;
extern NSString *const kGDCInitiCloudEnable;

// The object which contains the expire time.
@interface PYGDCObject : NSObject

@property (nonatomic, strong)   NSObject<NSCoding>          *object;
@property (nonatomic, strong)   id<PYDate>                  expire;

@end

// GDC Cache Size Enum Definition.
enum {
	PYGDCSize256K		= PYKiloByte * 256,
	PYGDCSize512K		= PYKiloByte * 512,
	PYGDCSize1M			= PYMegaByte,
	PYGDCSize2M			= 2 * PYMegaByte,
	PYGDCSize4M			= 4 * PYMegaByte,
	PYGDCSize10M		= 10 * PYMegaByte,
	
	// Default cache size is 4M
	PYGDCSizeDefault	= PYGDCSize4M
};

@interface PYGlobalDataCache : NSObject
{
	int					_cacheSizeInBytes;
	int					_cacheSizeInUse;
	NSString			*_identify;
	
	NSMutableDictionary	*_coreInMemCache;
	NSMutableArray		*_coreKeysCache;
	
	PYKeyedDb			*_innerDb;
	
	// inner data.
	double				_hitMemPercentage;
	long				_searchedTimes;
	NSString			*_lastHitInMemKey;
	NSString			*_lastSearchedKey;
	long				_allObjectCount;    
    
    // Lock
    NSRecursiveLock     *_lock;
}

@property (nonatomic, readonly)		NSString		*dcIdentify;
@property (nonatomic, assign)		int				cacheSizeInBytes;
@property (nonatomic, readonly)		int				cacheSizeInUse;

// The following properties is for statistic usage.
@property (nonatomic, readonly)		double			hitMemoryPercentage;
@property (nonatomic, readonly)		NSString		*lastHitInMemKey;
@property (nonatomic, readonly)		NSString		*lastSearchedKey;
@property (nonatomic, readonly)		NSUInteger      inMemObjectCount;
@property (nonatomic, readonly)		long			allObjectCount;

// Get all keys in current cache. I do not suggest to use this property very often.
// When the cache grows up to a large size, fetch all keys will cause a lot of
// time and use more memory than usual.
@property (nonatomic, readonly)     NSArray         *allKeys;

// The [initialize] method will force to set the thread-safe flag
// if set the [PY_FORCE_THREASAFE] when compilation.
// Make the sqlite to support multiple thread.
// Depecated in v0.9
+ (void)initializeSqliteForMultithreadSupport DEPRECATED_ATTRIBUTE;
// Now use this method to change the config.
// When failed to do so, return an error.
// By default, the method will not force to set the serialized flat,
// When [forced] is set to YES, and the sqlite library has been initialized
// by any other code in your project, the method will firstly invoke
// [sqlite3_shutdown] and then set the flag, then invoke [sqlite3_initliaze]
// again before return.
+ (NSError *)initializeSqliteForMultipleThread;
+ (NSError *)initializeSqliteForMultipleThreadAndForceToSet:(BOOL)forced;

+ (PYGlobalDataCache *)gdcWithIdentify:(NSString *)identify options:(NSDictionary *)options;
+ (PYGlobalDataCache *)gdcWithIdentify:(NSString *)identify;
+ (void)releaseGdcWithIdentify:(NSString *)identify;
// In Version 0.9.1, new api, remove the gdc cached sqlite file.
+ (void)removeGdcFileWithIdentify:(NSString *)identify options:(NSDictionary *)options;

// Begin the batch operations
- (void)batchOperation:(PYActionDone)operations;

// Type: GDCObject
// If no expire specified, the object will never expired.
- (void)setObject:(id<NSCoding>)value forKey:(NSString *)key;
- (void)setObject:(id<NSCoding>)value forKey:(NSString *)key expire:(id<PYDate>)expire;
- (id)objectForKey:(NSString *)key;
// Full object info with expire time.
- (PYGDCObject *)fullObjectForKey:(NSString *)key;

// Check if contains the specified key, but not decode the value.
- (BOOL)containsKey:(NSString *)key;
- (BOOL)isObjectForKey:(NSString *)key expiredFrom:(id<PYDate>)date;

// Clear all cache data.
- (void)clearAllCacheData:(PYActionDone)done;

@end

@interface PYGlobalDataCache (Private)

// Private initialize functions
- (id)init;
- (id)initGDCWithIdentify:(NSString *)identify;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
