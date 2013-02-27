//
//  PYFileCache.h
//  PYCore
//
//  Created by littlepush on 9/5/12.
//  Copyright (c) 2012 PushLab. All rights reserved.
//

#import <Foundation/Foundation.h>


#define SHARED_PYFILECACHE	[PYFileCache sharedCache]
/*
	File Cache
	Store the data in file and cached a limit group in memory.
	The MaxCacheSize is default to 10MB, and default limit cache time is 1day.
 */
@interface PYFileCache : NSObject
{
	long					_currentCacheSize;
	long					_maxCacheSize;
	long					_cachedTimeLimit;
	
	NSMutableDictionary		*_coreCache;
	NSMutableArray			*_keyCache;
}

/* Max MemCacheSize, applied when the next setData:forKey occurred. */
@property (nonatomic, assign)	long				maxMemCacheSize;
/* Return the current cache size */
@property (nonatomic, readonly)	long				currentCacheSize;
/* Cached Time Limit, set to zero means never expired. */
@property (nonatomic, assign)	long				cachedTimeLimit;

+(PYFileCache *) sharedCache;

/* Set the data for specified key, store to disk */
-(void) setData:(NSData *)data forKey:(NSString *)key;
/* Load the data from cache, or disk, for specified key */
-(NSData *) dataForKey:(NSString *)key;
/* Remove the data for specified key from mem-cache and disk */
-(void) removeDataForKey:(NSString *)key;
/* Just release the memory in cache for specified kye */
-(void) releaseDataForKey:(NSString *)key;

@end
