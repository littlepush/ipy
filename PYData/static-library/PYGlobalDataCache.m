//
//  PYGlobalDataCache.m
//  PYData
//
//  Created by Push Chen on 1/19/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import "PYGlobalDataCache.h"

static NSMutableDictionary		*_gdcDict;

@interface PYGlobalDataCache ()

- (NSString *) _formatObject:(id<NSCoding>)value;

- (void) _checkCacheSizeAndClean;

@end

@implementation PYGlobalDataCache

+(void)initialize
{
	// Initialize the gdc dictionary
	_gdcDict = [[NSMutableDictionary dictionary] retain];
}

- (NSString *) _formatObject:(id<NSCoding>)value
{
	NSData *_codeData = [NSKeyedArchiver archivedDataWithRootObject:value];
	return [PYCoder encodeBase64FromData:_codeData.bytes length:_codeData.length];
}

- (void) _checkCacheSizeAndClean
{
	while ( _cacheSizeInUse > _cacheSizeInBytes ) {
		NSString *_lastKey = [_coreKeysCache lastObject];
		NSString *_lastValue = [_coreInMemCache objectForKey:_lastKey];
		_cacheSizeInUse -= [_lastValue length];
		[_coreKeysCache removeLastObject];
		[_coreInMemCache removeObjectForKey:_lastKey];
	}
}

#pragma mark --
#pragma mark -- Properties

@dynamic dcIdentify;
- (NSString *) dcIdentify { return _identify; }

@synthesize cacheSizeInBytes = _cacheSizeInBytes;
@synthesize cacheSizeInUse = _cacheSizeInUse;

@synthesize hitMemoryPercentage = _hitMemPercentage;
@synthesize lastHitInMemKey = _lastHitInMemKey;
@synthesize lastSearchedKey = _lastSearchedKey;

@dynamic inMemObjectCount;
- (int) inMemObjectCount { return [_coreInMemCache count]; }
@synthesize allObjectCount = _allObjectCount;

#pragma mark --
#pragma mark -- Core Messages

// Setter
- (void) setInt:(int)value forKey:(NSString *)key
{
	[self setObject:PYIntToObject(value) forKey:key];
}

- (void) setDouble:(double)value forKey:(NSString *)key
{
	[self setObject:PYDoubleToObject(value) forKey:key];
}

- (void) setObject:(id<NSCoding>)value forKey:(NSString *)key
{
	PYSingletonLock
	NSString *_dbValue = [self _formatObject:value];
	NSUInteger _index = [_coreKeysCache indexOfObject:key];
	if ( _index != NSNotFound ) {
		NSString *_oldValue = [_coreInMemCache objectForKey:key];
		_cacheSizeInUse -= [_oldValue length];
		[_coreKeysCache removeObjectAtIndex:_index];
	}
	[_coreInMemCache setObject:_dbValue forKey:key];
	[_coreKeysCache insertObject:key atIndex:0];
	_cacheSizeInUse += [_dbValue length];
	// Clean the cache
	[self _checkCacheSizeAndClean];

	if ( [_innerDb containsKey:key] ) {
		// update
		[_innerDb updateValue:_dbValue forKey:key];
	} else {
		[_innerDb addValue:_dbValue forKey:key];
		_allObjectCount += 1;
	}
	
	// update in-men cache
	PYSingletonUnLock
}

// Getter
- (int) intForKey:(NSString *)key
{
	NSNumber *_objectInt = [self objectForKey:key];
	if ( _objectInt == nil ) return -1;
	return [_objectInt intValue];
}

- (double) doubleForKey:(NSString *)key
{
	NSNumber *_objectInt = [self objectForKey:key];
	if ( _objectInt == nil ) return 0.f;
	return [_objectInt doubleValue];
}

- (id) objectForKey:(NSString *)key
{
	PYSingletonLock
	// Check in-mem cache...
	if ( _lastSearchedKey != nil ) [_lastSearchedKey release];
	_lastSearchedKey = [key retain];
	_searchedTimes += 1;
	NSUInteger _index = [_coreKeysCache indexOfObject:key];
	NSString *_value;
	if ( _index != NSNotFound ) {
		// contains the key in cache
		_hitMemPercentage = ((_hitMemPercentage * (_searchedTimes - 1) + 1) / (double)_searchedTimes);
		if ( _lastHitInMemKey != nil ) [_lastHitInMemKey release];
		_lastHitInMemKey = [key retain];
		
		[_coreKeysCache removeObjectAtIndex:_index];
		// Move the searched key to top
		[_coreKeysCache insertObject:key atIndex:0];
		_value = [_coreInMemCache objectForKey:key];
	} else {
		if ( ![_innerDb containsKey:key] ) {
			// no such key in both cache.
			_hitMemPercentage = (_hitMemPercentage * (_searchedTimes - 1) / (double)_searchedTimes);
			return nil;
		}
		_value = [_innerDb valueForKey:key];
		// Put the value into in-mem cache
		[_coreKeysCache insertObject:key atIndex:0];
		[_coreInMemCache setObject:_value forKey:key];
		_cacheSizeInUse += [_value length];
		[self _checkCacheSizeAndClean];
	}

	NSData *_dbData = [PYCoder decodeBase64ToData:_value];
	id _object = [NSKeyedUnarchiver unarchiveObjectWithData:_dbData];
	return _object;
	PYSingletonUnLock
}

#pragma mark --
#pragma mark -- Global && Init

+ (PYGlobalDataCache *) gdcWithIdentify:(NSString *)identify
{
	if ( [_gdcDict objectForKey:identify] != nil )
		return [_gdcDict objectForKey:identify];
	PYGlobalDataCache *_gdc = [[[PYGlobalDataCache alloc]
		initGDCWithIdentify:identify] autorelease];
	if ( _gdc == nil ) return nil;
	[_gdcDict setValue:_gdc forKey:identify];
	return _gdc;
}
+ (void) releaseGdcWithIdentify:(NSString *)identify
{
	if ( [_gdcDict objectForKey:identify] != nil )
		[_gdcDict removeObjectForKey:_gdcDict];
}

- (id) init
{
	PYTHROW(@"Pure init is not supported for GDC");
	self = [super init];
	if ( self ) {}
	return self;
}

- (id) initGDCWithIdentify:(NSString *)identify
{
	self = [super init];
	if ( self ) {
		_cacheSizeInBytes = PYGDCSize4M;
		_cacheSizeInUse = 0;
		_identify = [identify retain];
		
		_coreInMemCache = [[NSMutableDictionary dictionary] retain];
		_coreKeysCache = [[NSMutableArray array] retain];
		
		_innerDb = [[PYKeyedDb keyedDbWithPath:[DOCUMENTPATH
			stringByAppendingPathComponent:identify]] retain];
		
		if ( _innerDb == nil ) {
			// Failed to initialize the database.
			[self release];
			return nil;
		}
		
		_hitMemPercentage = 0.f;
		_allObjectCount = [_innerDb count];
	}
	return self;
}

#pragma mark --
#pragma mark -- Description

- (NSString *) description
{
	return [NSString stringWithFormat:@"\nGDC<%@> (\nAll Object Count: %ld\nHit: %02f%%\nLast Searched Key: %@\nLast Hit Key: %@\n)",
		_identify, _allObjectCount, _hitMemPercentage, _lastSearchedKey, _lastHitInMemKey];
}

@end
