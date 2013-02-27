//
//  PYFileCache.m
//  PYCore
//
//  Created by littlepush on 9/5/12.
//  Copyright (c) 2012 PushLab. All rights reserved.
//

#import "PYFileCache.h"
#import "NSObject+Extended.h"
#import "NSString+PYAppend.h"
#import "PYMainMacro.h"
#import "PYFileManager.h"

static NSString *cacheDir = @"pycore-filecache-a10d70f9981c96264acf8a4cb9dc45ef";
static PYFileCache *gCache;

@interface PYFileCache (Internal)

/* Organize the Cache */
-(void) organizeCache;

/* Get the data cache path */
-(NSString *) dataCachePathForKey:(NSString *)key;

/* Inner cache */
-(void) addToCacheWithData:(NSData *)data forKey:(NSString *)key;
-(NSData *) dataInCacheForKey:(NSString *)key;
-(void) removeInnerCacheDataForKey:(NSString *)key;

@end

@implementation PYFileCache

@synthesize maxMemCacheSize = _maxCacheSize;
@synthesize currentCacheSize = _currentCacheSize;
@synthesize cachedTimeLimit = _cachedTimeLimit;

#pragma Init
-(id) init {
	self = [super init];
	if (!self) return self;
	_currentCacheSize = 0;
	_maxCacheSize = 10 * 1024 * 1024;		// 10MB
	_cachedTimeLimit = 86400;				// 1Day
	
	_coreCache = [[NSMutableDictionary dictionary] retain];
	_keyCache = [[NSMutableArray array] retain];

	// check the cache directory
	NSArray *paths = NSSearchPathForDirectoriesInDomains(
		NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [paths objectAtIndex:0];
	NSString *_cacheDirectory = [documentDirectory 
		stringByAppendingPathComponent:cacheDir];
	NSFileManager *fm = [NSFileManager defaultManager];
	BOOL dir = NO;
	BOOL exist = [fm fileExistsAtPath:_cacheDirectory isDirectory:&dir];
	
	if ( !exist ) {
		NSError *_error = nil;
		[fm createDirectoryAtPath:_cacheDirectory withIntermediateDirectories:YES 
			attributes:nil error:&_error];
		if ( _error != nil ) {
			[self raiseExceptionWithMessage:[_error localizedDescription]];
		}
	} else if ( exist && (dir == NO) ) {
		[self raiseExceptionWithMessage:@"Failed to create the file cache directory"];
	}
	return self;
}

-(void) dealloc {
	
	[_coreCache release];
	[_keyCache release];
	_coreCache = nil;
	_keyCache = nil;
	
	[super dealloc];
}

#pragma Singleton
PYSingleton(PYFileCache, sharedCache, gCache)

#pragma Messages
-(void) setData:(NSData *)data forKey:(NSString *)key
{
	NSString *_innerKey = [key md5sum];
	// write to file
	PYSingletonLock
	NSString *_path = [self dataCachePathForKey:_innerKey];
	if ( [data writeToFile:_path atomically:YES] ) {
		[self addToCacheWithData:data forKey:_innerKey];
	}
	PYSingletonUnLock
}
-(NSData *) dataForKey:(NSString *)key
{
	NSString *_innerKey = [key md5sum];
	PYSingletonLock
	NSData *_data = [self dataInCacheForKey:_innerKey];
	if (_data != nil ) return _data;

	NSString *_path = [self dataCachePathForKey:_innerKey];
	
	if ( _cachedTimeLimit != 0 ) {
		long _createDate = [PYFileManager createTimeOfFile:_path];
		if ( _createDate == -1 ) return nil;
		time_t nowSec = time(NULL);
		
		// Release the file if expired
		if ( (nowSec - _createDate) >= _cachedTimeLimit ) {
			[PYFileManager deleteFile:_path];
			return nil;
		}
	}
	
	NSData *_fdata = [NSData dataWithContentsOfFile:_path];
	if ( _fdata == nil ) return nil;	// no such file
	[self addToCacheWithData:_fdata forKey:_innerKey];
	return _fdata;
	PYSingletonUnLock
}
-(void) removeDataForKey:(NSString *)key
{
	NSString *_innerKey = [key md5sum];
	PYSingletonLock
	[self removeInnerCacheDataForKey:_innerKey];
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *_path = [self dataCachePathForKey:_innerKey];
	if ( [fm fileExistsAtPath:_path] ) {
		NSError *_error;
		[fm removeItemAtPath:_path error:&_error];
		if ( !_error ) {
			[self raiseExceptionWithMessage:[_error localizedDescription]];
		}
	}
	PYSingletonUnLock
}
-(void) releaseDataForKey:(NSString *)key
{
	[self removeInnerCacheDataForKey:[key md5sum]];
}

#pragma Internal

/* Organize the Cache */
-(void) organizeCache
{
	if ( _currentCacheSize <= _maxCacheSize ) return;
	do {
		NSString *_key = [_keyCache lastObject];
		NSData *_data = [_coreCache objectForKey:_key];
		_currentCacheSize -= [_data length];
		[_coreCache removeObjectForKey:_key];
		[_keyCache removeLastObject];
	} while( _currentCacheSize > _maxCacheSize );
}

/* Get the data cache path */
-(NSString *) dataCachePathForKey:(NSString *)key
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(
		NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [paths objectAtIndex:0];
	NSString *cacheDirectory = [documentDirectory stringByAppendingPathComponent:cacheDir];
	return [cacheDirectory stringByAppendingPathComponent:key];
}

/* Inner cache */
-(void) addToCacheWithData:(NSData *)data forKey:(NSString *)key
{
	//@synchronized(self) {
		if ( [_coreCache objectForKey:key] != nil )
			[_keyCache removeObject:key];
		[_coreCache setObject:data forKey:key];
		[_keyCache insertObject:key atIndex:0];
		
		_currentCacheSize += [data length];
		[self organizeCache];
	//}
}
-(NSData *) dataInCacheForKey:(NSString *)key
{
	//@synchronized(self) {
		NSData *_data = [_coreCache objectForKey:key];
		if ( _data == nil ) return _data;
		
		[_keyCache removeObject:key];
		[_keyCache insertObject:key atIndex:0];
		[self organizeCache];
		return _data;
	//}	
}
-(void) removeInnerCacheDataForKey:(NSString *)key
{
	//@synchronized(self) {
		[_keyCache removeObject:key];
		[_coreCache removeObjectForKey:key];
	//}
}


@end
