//
//  PYCore.h
//  PYCore
//
//  Created by Push Chen on 11/25/11.
//  Copyright (c) 2011 Push Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PYMainMacro.h"
#import "PYLRUCache.h"
#import "PYListCache.h"
#import "PYTypes.h"
#import "NSObject+Extended.h"
#import "NSString+PYAppend.h"
#import "NSArray+Extended.h"
#import "PYSharedManager.h"
#import "PYStopWatch.h"
#import "PYCoder.h"
#import "PYFileCache.h"
#import "PYFileManager.h"
#import "NSDictionary+Validate.h"
#import "PYStreamList.h"
#import "PYLock.h"

#import <errno.h>

typedef enum {
	PYWeekDaySun = 0,
	PYWeekDayMon = 1,
	PYWeekDayTue = 2,
	PYWeekDayWed = 3,
	PYWeekDayThu = 4,
	PYWeekDayFri = 5,
	PYWeekDaySat = 6
} PYWeekDay;

typedef struct {
	NSUInteger		year;
	NSUInteger		month;
	NSUInteger		day;
	PYWeekDay		weekdayId;
} PYCalendarDate;

#define PYCalendarDateEqual( d1, d2 )	\
	( memcmp( &d1, &d2, sizeof(PYCalendarDate) ) == 0 )

#define PYCalendarIsWeekend( day )		\
	(day == PYWeekDaySun || day == PYWeekDaySat)
#define PYCalendarIsWeekday( day )		\
	!(PYCalendarIsWeekend(day))
	
static inline
NSString *PYDayInWeek( PYWeekDay _day ) {
	static NSString *_days[] = {
		@"Sun", @"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat"
	};
	return _days[_day];
}

static inline
NSString *PYDayInWeekFull( PYWeekDay _day ) {
	static NSString *_days[] = {
		@"Sunday", @"Monday", @"Tuesday", @"Wednesday",
		@"Thursday", @"Friday", @"Saturday"
	};
	return _days[_day];
}

#define PYWeekDayConvert( _weekday )	(_weekday - 1)
#define PYCalendarWeeksInMonth			6
#define PYCalendarDaysInWeek			7

// Get document path
@interface PYCoreUtility : NSObject
{
	PYLRUCache				*_coreCache;
	NSString				*todayDateString;
	PYCalendarDate			todayDateInfo;
}

@property (nonatomic, readonly)	NSString		*todayDateString;
@property (nonatomic, readonly) PYCalendarDate	todayDateInfo;

/* Singleton */
+(PYCoreUtility *) sharedUtility;

+(NSString *)documentPath;
+(NSString *)guid;
+(NSString *)timestamp;

// Cache setting.
-(id)getObjectForKey:(NSString *)key;
-(void)setObject:(id)object forKey:(NSString *)key;
-(void)removeObjectOfKey:(NSString *)key;
-(void)clearCache;

-(PYCalendarDate) prevDateInfoOfDate:(PYCalendarDate)dateInfo;
-(PYCalendarDate) nextDateInfoOfDate:(PYCalendarDate)dateInfo;

-(NSString *) stringFromDate:(NSDate *)date;
-(NSString *) stringFromCalendarDate:(PYCalendarDate)date;

-(NSString *) timeIntervalStringOfdate:(NSDate *)date;

-(NSTimeInterval) beginningOfToday;
-(NSTimeInterval) endOfToday;

@end

#define SHARED_UTILITY	[PYCoreUtility sharedUtility]
#define SHARED_DATE_MGR	SHARED_UTILITY

#define DOCUMENTPATH	[PYCoreUtility documentPath]
#define GUID			[PYCoreUtility guid]
#define TIMESTAMP		[PYCoreUtility timestamp]
#define LOCATION(x,y)	[[[CLLocation alloc] initWithLatitude:x longitude:y] autorelease]
#define COORDINATE(x,y)	(CLLocationCoordinate2D){ x, y }

#define GlobalCacheGetObjectOfKey( key )				\
	[SHARED_UTILITY getObjectForKey:key]
#define GlobalCacheSetObjectValueOfKey( key, object )	\
	[SHARED_UTILITY setObject:object forKey:key]
#define GlobalCacheRemoveObjectOfKey( key )				\
	[SHARED_UTILITY removeObjectOfKey:key]
#define GlobalCacheClear								\
	[SHARED_UTILITY clearCache]

/*
	Application Normal notification handler protocol
 */	
@protocol PYApplication < NSObject >

@optional
/* application will be transformed to the background */
-(void) applicationEnterBackgroundHandler:(NSNotification *)notification;

/* application will be transformed to the foreground */
-(void) applicationEnterForegroundHandler:(NSNotification *)notification;

/* application will be terminated */
-(void) applicationTerminateHandler:(NSNotification *)notification;

/* when the date will changed in the midnight */
-(void) applicationSignificantTimeChangeHandler:(NSNotification *)notification;

@end

#define PYRegisterForAppTerminateHandler						\
	[[NSNotificationCenter defaultCenter] addObserver:self		\
		selector:@selector(applicationTerminateHandler:)		\
		name:UIApplicationWillTerminateNotification				\
		object:nil]
#define PYUnRegisterForAppTerminateHandler						\
	[[NSNotificationCenter defaultCenter] removeObserver:self	\
		name:UIApplicationWillTerminateNotification				\
		object:nil]
		
#define PYRegisterForAppEnterBackgroundHandler					\
	[[NSNotificationCenter defaultCenter] addObserver:self		\
		selector:@selector(applicationEnterBackgroundHandler:)	\
		name:UIApplicationDidEnterBackgroundNotification		\
		object:nil]
#define PYUnRegisterForAppEnterBackgroundHandler				\
	[[NSNotificationCenter defaultCenter] removeObserver:self	\
		name:UIApplicationDidEnterBackgroundNotification		\
		object:nil]

#define PYRegisterForAppEnterForegroundHandler					\
	[[NSNotificationCenter defaultCenter] addObserver:self		\
		selector:@selector(applicationEnterForegroundHandler:)	\
		name:UIApplicationWillEnterForegroundNotification		\
		object:nil]
#define PYUnRegisterForAppEnterForegroundHandler				\
	[[NSNotificationCenter defaultCenter] removeObserver:self	\
		name:UIApplicationWillEnterForegroundNotification		\
		object:nil]
		
#define PYRegisterForSignificantTimeChangeHandler						\
	[[NSNotificationCenter defaultCenter] addObserver:self				\
		selector:@selector(applicationSignificantTimeChangeHandler:)	\
		name:UIApplicationSignificantTimeChangeNotification				\
		object:nil]
#define PYUnRegisterForSignificantTimeChangeHandler						\
	[[NSNotificationCenter defaultCenter] removeObserver:self			\
		name:UIApplicationSignificantTimeChangeNotification				\
		object:nil]


/* Request Object Protocols */
@protocol PYJsonObject <NSObject>
@optional
-(NSDictionary *) objectToJsonDict;
@required
-(void) objectFromJsonDict:(NSDictionary *)jsonDict;

@end

#define PYLongToString(value)	[NSString stringWithFormat:@"%ld", value]
#define PYLongToObject(value)	[NSNumber numberWithLong:value]
#define PYIntToString(value)	[NSString stringWithFormat:@"%d", value]
#define PYIntToObject(value)	[NSNumber numberWithInt:value]
#define PYDoubleToObject(value)	[NSNumber numberWithDouble:value]
#define PYBoolToObject(value)	[NSNumber numberWithBool:value]

