//
//  PYGlobalDataCache.h
//  PYData
//
//  Created by Push Chen on 1/19/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PYKeyedDb.h"

// GDC Cache Size Enum Definition.
enum {
	PYGDCSize256K		= 256 * 1024,
	PYGDCSize512K		= 512 * 1024,
	PYGDCSize1M			= 1024 * 1024,
	PYGDCSize2M			= 2 * PYGDCSize1M,
	PYGDCSize4M			= 4 * PYGDCSize1M,
	PYGDCSize10M		= 10 * PYGDCSize1M,
	
	// Default cache size is 4M
	PYGDCSizeDefault	= PYGDCSize4M
};

@interface PYGlobalDataCache : NSObject
{
	int					_cacheSizeInBytes;
	int					_cacheSizeInUse;
	NSString			*_identify;
	
	//PYLRUCache			*_lruCache;
	NSMutableDictionary	*_coreInMemCache;
	NSMutableArray		*_coreKeysCache;
	
	PYKeyedDb			*_innerDb;
	
	// inner data.
	double				_hitMemPercentage;
	long				_searchedTimes;
	NSString			*_lastHitInMemKey;
	NSString			*_lastSearchedKey;
	//int					_inMemObjectCount;
	long				_allObjectCount;
}

@property (nonatomic, readonly)		NSString		*dcIdentify;
@property (nonatomic, assign)		int				cacheSizeInBytes;
@property (nonatomic, readonly)		int				cacheSizeInUse;

// The following properties is for statistic usage.
@property (nonatomic, readonly)		double			hitMemoryPercentage;
@property (nonatomic, readonly)		NSString		*lastHitInMemKey;
@property (nonatomic, readonly)		NSString		*lastSearchedKey;
@property (nonatomic, readonly)		int				inMemObjectCount;
@property (nonatomic, readonly)		long			allObjectCount;

+(PYGlobalDataCache *) gdcWithIdentify:(NSString *)identify;
+(void) releaseGdcWithIdentify:(NSString *)identify;

// Extend methods.

// Type: Int
-(void) setInt:(int)value forKey:(NSString *)key;
-(int) intForKey:(NSString *)key;

// Type: Double
-(void)	setDouble:(double)value forKey:(NSString *)key;
-(double) doubleForKey:(NSString *)key;

// Type: GDCObject
-(void) setObject:(id<NSCoding>)value forKey:(NSString *)key;
-(id) objectForKey:(NSString *)key;

@end

@interface PYGlobalDataCache (Private)

// Private initialize functions
-(id) init;
-(id) initGDCWithIdentify:(NSString *)identify;

@end
