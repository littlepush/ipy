//
//  PYCore1.m
//  PYCore
//
//  Created by Push Chen on 12/21/11.
//  Copyright (c) 2011 Push Lab. All rights reserved.
//

#import "PYCore.h"
#include <sys/time.h>
#include <sys/timeb.h>
#include <sys/stat.h>
#ifndef PY_CONSOLE_DEBUG
#import <UIKit/UIKit.h>
#endif

static PYCoreUtility *gUtility;
static NSString *coreUtilityArchivePath = @"py.core.utility.archive.dat";

@interface PYCoreUtility (Private)

-(void) applicationTerminateHandler:(NSNotification *)notification;

-(void) gatherTodayDateInfomation;

-(NSUInteger) daysInMonth:(NSUInteger)month ofYear:(NSUInteger)year;

@end

@implementation PYCoreUtility

@synthesize todayDateString;
@synthesize todayDateInfo;

#ifndef PY_CONSOLE_DEBUG
/* Application */
-(void) applicationTerminateHandler:(NSNotification *)notification
{	
	PYLRUCache *_archiveArray = [PYLRUCache object];
	NSEnumerator *_enumerator = [_coreCache objectEnumerator];
	for ( NSString *key in _enumerator ) {
		id< NSObject > val = [_enumerator valueForKey:key];
		NSString *_valClass = NSStringFromClass([val class]);
		if ( [_valClass isEqualToString:@"UIViewController"] )
			continue;
		[_archiveArray setValue:val forKey:key];
	}
	
	NSString *_archivePath = [DOCUMENTPATH
		stringByAppendingPathComponent:coreUtilityArchivePath];
	NSData *_archiveData = [NSKeyedArchiver archivedDataWithRootObject:_archiveArray];
	[_archiveData writeToFile:_archivePath atomically:YES];
}
-(void) applicationEnterForegroundHandler:(NSNotification *)notification
{
	[self gatherTodayDateInfomation];
}

-(void) applicationSignificantTimeChangeHandler:(NSNotification *)notification
{
	[self gatherTodayDateInfomation];
}
#endif

/* Private */
-(void) gatherTodayDateInfomation
{
	// today
	NSDateFormatter *fmt = [NSDateFormatter object];
	[fmt setDateFormat:@"yyyy-MM-dd"];
	todayDateString = [[fmt stringFromDate:NOWDATE] retain];
	
	NSCalendar *calendar = [[[NSCalendar alloc] 
		initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	NSCalendarUnit _unit = NSWeekdayCalendarUnit | 
		NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	
	NSDateComponents *_dateComponents = [calendar components:_unit fromDate:NOWDATE];
	
	todayDateInfo = (PYCalendarDate){
		_dateComponents.year,
		_dateComponents.month,
		_dateComponents.day,
		_dateComponents.weekday - 1
	};
}

-(NSUInteger) daysInMonth:(NSUInteger)month ofYear:(NSUInteger)year
{
	static NSUInteger _daysInMonth[] = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
	NSUInteger _days = _daysInMonth[month - 1];
	if ( month == 2 && (
		(year % 100 == 0 && year % 400 == 0) || (year % 100 != 0 && year % 4 == 0)
	) ) _days += 1;
	return _days;
}

-(id) init 
{
	self = [super init];
	if ( self ) {
		NSString *_archivePath = [DOCUMENTPATH 
			stringByAppendingPathComponent:coreUtilityArchivePath];
		_coreCache = [[NSKeyedUnarchiver unarchiveObjectWithFile:_archivePath] retain];
		if ( _coreCache == nil ) {
			_coreCache = [[PYLRUCache object] retain];
		}
		[_coreCache setMaxObjectLimitation:50];
		

		[self gatherTodayDateInfomation];
		
#ifndef PY_CONSOLE_DEBUG
		// add notification handle
		[[NSNotificationCenter defaultCenter] 
			addObserver:self 
			selector:@selector(applicationTerminateHandler:) 
			name:UIApplicationWillTerminateNotification 
			object:nil];
		[[NSNotificationCenter defaultCenter]
			addObserver:self 
			selector:@selector(applicationEnterForegroundHandler:) 
			name:UIApplicationDidBecomeActiveNotification 
			object:nil];
		[[NSNotificationCenter defaultCenter]
			addObserver:self 
			selector:@selector(applicationSignificantTimeChangeHandler:) 
			name:UIApplicationSignificantTimeChangeNotification 
			object:nil];
#endif
	}
	return self;
}

+(PYCoreUtility *) sharedUtility
{
	PYSingletonLock
	if ( gUtility == nil ) {
		gUtility = [[PYCoreUtility object] retain];
		return gUtility;
	}
	PYSingletonUnLock
	return gUtility;	
}

PYSingletonAllocWithZone(gUtility)
PYSingletonDefaultImplementation

+(NSString *)documentPath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(
		NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [paths objectAtIndex:0];
	return documentDirectory;	
}

+(NSString *)guid
{
	// create a new UUID which you own
	CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
	
	// create a new CFStringRef (toll-free bridged to NSString)
	// that you own
	NSString *uuidString = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
	[uuidString autorelease];
	uuidString = [uuidString stringByReplacingOccurrencesOfString:@"-" withString:@""];
	// transfer ownership of the string
	// to the autorelease pool
	
	// release the UUID
	CFRelease(uuid);
	
	return uuidString;
}

+(NSString *)timestamp
{
	struct timeval _timenow;
	gettimeofday( &_timenow, NULL );
	int64_t _milesecond = _timenow.tv_sec;
	_milesecond *= 1000;
	_milesecond += (_timenow.tv_usec / 1000);
	NSString *_timestamp = [NSString stringWithFormat:@"%lld", _milesecond];
	return _timestamp;
}

-(id)getObjectForKey:(NSString *)key
{
	return [_coreCache objectForKey:key];
}

-(void)setObject:(id)object forKey:(NSString *)key
{
	[_coreCache setValue:object forKey:key];
}

-(void)removeObjectOfKey:(NSString *)key
{
	[_coreCache removeObjectForKey:key];
}

-(void)clearCache
{
	[_coreCache removeAllObjects];
}

/* Message */
-(PYCalendarDate) prevDateInfoOfDate:(PYCalendarDate)dateInfo
{
	PYCalendarDate newDateInfo = dateInfo;
	if ( newDateInfo.weekdayId != PYWeekDaySun ) {
		newDateInfo.weekdayId -= 1;
	} else {
		newDateInfo.weekdayId = PYWeekDaySat;
	}
	
	if ( newDateInfo.day != 1 ) {
		newDateInfo.day -= 1;
	}
	else {
		if ( newDateInfo.month == 1 ) {
			newDateInfo.year -= 1;
			newDateInfo.month = 12;
		} else {
			newDateInfo.month -= 1;
		}
		newDateInfo.day = [self daysInMonth:newDateInfo.month ofYear:newDateInfo.year];
	}
	
	return newDateInfo;
}

-(PYCalendarDate) nextDateInfoOfDate:(PYCalendarDate)dateInfo
{
	PYCalendarDate newDateInfo = dateInfo;
	if ( newDateInfo.weekdayId != PYWeekDaySat ) {
		newDateInfo.weekdayId += 1;
	} else {
		newDateInfo.weekdayId = PYWeekDaySun;
	}
	
	NSUInteger currentMonthDays = [self 
		daysInMonth:newDateInfo.month ofYear:newDateInfo.year];
	
	if ( newDateInfo.day != currentMonthDays ) {
		newDateInfo.day += 1;
	}
	else {
		if ( newDateInfo.month == 12 ) {
			newDateInfo.year += 1;
			newDateInfo.month = 1;
		} else {
			newDateInfo.month += 1;
		}
		newDateInfo.day = 1;
	}
	
	return newDateInfo;
}

-(NSString *) stringFromDate:(NSDate *)date
{
	NSDateFormatter *_formater = [NSDateFormatter object];
	[_formater setDateFormat:@"yyyy-MM-dd"];
	return [_formater stringFromDate:date];
}

-(NSString *) stringFromCalendarDate:(PYCalendarDate)date
{
	return [NSString stringWithFormat:@"%d-%02d-%02d", 
		date.year, date.month, date.day];
}

-(NSString *) timeIntervalStringOfdate:(NSDate *)date
{
	NSTimeInterval _interval = [NOWDATE timeIntervalSinceDate:date];
	if ( _interval < 0.f ) return @"就在刚才";
	if ( _interval < 60.f ) return [NSString stringWithFormat:@"%d 秒之前", (int)_interval];
	if ( _interval < 3600.f ) return [NSString stringWithFormat:@"%d 分钟之前", 
		((int)_interval) / 60];
	if ( _interval < 86400.f ) return [NSString stringWithFormat:@"%d 小时之前", 
		((int)_interval) / 3600];
	if ( _interval < 604800.f ) return [NSString stringWithFormat:@"%d 天之前",
		((int)_interval) / 86400];
	return [self stringFromDate:date];
}

-(NSTimeInterval) beginningOfToday 
{
	//NSTimeInterval _now = [NOWDATE timeIntervalSince1970];
	struct timeval _time;
	gettimeofday(&_time, NULL);
	long _sec = _time.tv_sec - _time.tv_sec % 86400 - [[NSTimeZone localTimeZone] secondsFromGMT];
	return (NSTimeInterval)_sec;
}

-(NSTimeInterval) endOfToday
{
	return [self beginningOfToday] + 86399.f;
}

@end
