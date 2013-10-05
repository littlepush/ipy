//
//  PYDate.m
//  PYCore
//
//  Created by Push Chen on 6/10/13.
//  Copyright (c) 2013 PushLab. All rights reserved.
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

#import "PYDate.h"
#import "PYLocalizedString.h"
#import "NSObject+PYCore.h"

@implementation PYDate

// Properties
@synthesize year = _year;
@synthesize month = _month;
@synthesize day = _day;
@synthesize weekday = _weekday;
@synthesize hour = _hour;
@synthesize minute = _minute;
@synthesize second = _second;
@synthesize timestamp = _timestamp;

+ (NSUInteger)daysInMonth:(NSUInteger)month ofYear:(NSUInteger)year
{
	static NSUInteger _daysInMonth[] = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
	NSUInteger _days = _daysInMonth[month - 1];
	if ( month == 2 && (
                        (year % 100 == 0 && year % 400 == 0) || (year % 100 != 0 && year % 4 == 0)
                        ) ) _days += 1;
	return _days;
}

// Private
- (void)_initFromDate:(NSDate *)date
{
    //    NSTimeZone *_timeZoen = [NSTimeZone defaultTimeZone];
    //    NSDate *_calDate = [date dateByAddingTimeInterval:-[_timeZoen secondsFromGMTForDate:date]];
    NSCalendar *calendar = __AUTO_RELEASE([[NSCalendar alloc]
                            initWithCalendarIdentifier:NSGregorianCalendar]);
	NSCalendarUnit _unit = NSWeekdayCalendarUnit |
    NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit |
    NSTimeZoneCalendarUnit;
    
	NSDateComponents *_dateComponents = [calendar components:_unit fromDate:date];
    
    _year = _dateComponents.year;
    _month = _dateComponents.month;
    _day = _dateComponents.day;
    _weekday = (PYWeekDay)_dateComponents.weekday;
    _hour = _dateComponents.hour;
    _minute = _dateComponents.minute;
    _second = _dateComponents.second;
    _timestamp = (NSUInteger)[date timeIntervalSince1970];
}

+ (void)initialize
{
    [PYLocalizedString addStrings:@{
                PYLanguageEnglish:@"just now",
      PYLanguageChineseSimplified:@"就在刚才"
     } forKey:@"RIGHTNOW"];
    [PYLocalizedString addStrings:@{
                PYLanguageEnglish:@"%ds",
      PYLanguageChineseSimplified:@"%d秒之前"
     } forKey:@"SECONDS_AGO"];
    [PYLocalizedString addStrings:@{
                PYLanguageEnglish:@"%dm",
      PYLanguageChineseSimplified:@"%d分钟之前"
     } forKey:@"MINUTS_AGO"];
    [PYLocalizedString addStrings:@{
                PYLanguageEnglish:@"%dh",
      PYLanguageChineseSimplified:@"%d小时之前"
     } forKey:@"HOUR_AGO"];
    [PYLocalizedString addStrings:@{
                PYLanguageEnglish:@"%dd",
      PYLanguageChineseSimplified:@"%d天之前"
     } forKey:@"DAY_AGO"];
    [PYLocalizedString addStrings:@{
                PYLanguageEnglish:@"Sun",
      PYLanguageChineseSimplified:@"周日"
     } forKey:@"DAY_1"];
    [PYLocalizedString addStrings:@{
                PYLanguageEnglish:@"Mon",
      PYLanguageChineseSimplified:@"周一"
     } forKey:@"DAY_2"];
    [PYLocalizedString addStrings:@{
                PYLanguageEnglish:@"Tue",
      PYLanguageChineseSimplified:@"周二"
     } forKey:@"DAY_3"];
    [PYLocalizedString addStrings:@{
                PYLanguageEnglish:@"Wed",
      PYLanguageChineseSimplified:@"周三"
     } forKey:@"DAY_4"];
    [PYLocalizedString addStrings:@{
                PYLanguageEnglish:@"Thu",
      PYLanguageChineseSimplified:@"周四"
     } forKey:@"DAY_5"];
    [PYLocalizedString addStrings:@{
                PYLanguageEnglish:@"Fri",
      PYLanguageChineseSimplified:@"周五"
     } forKey:@"DAY_6"];
    [PYLocalizedString addStrings:@{
                PYLanguageEnglish:@"Sat",
      PYLanguageChineseSimplified:@"周六"
     } forKey:@"DAY_7"];
}

// Date
// Date Creater
// Now date
+ (id)date
{
    return [PYDate object];
}
// Specified date
+ (id)dateWithTimestamp:(NSUInteger)timestamp
{
    return __AUTO_RELEASE([[PYDate alloc] initWithTimestamp:timestamp]);
}
// From an NSDate
+ (id)dateWithDate:(NSDate *)date
{
    return [PYDate dateWithTimestamp:(NSUInteger)[date timeIntervalSince1970]];
}
// Date from string, default format "YYYY-MM-DD HH:mm"
+ (id)dateWithString:(NSString *)dateString
{
    return [PYDate dateWithString:dateString format:@"yyyy-MM-dd hh:mm:ss"];
}
+ (id)dateWithDayString:(NSString *)dayString
{
    return [PYDate dateWithString:dayString format:@"yyyy-MM-dd"];
}
+ (id)dateWithString:(NSString *)dateString format:(NSString *)format
{
    NSDateFormatter *_fmt = __AUTO_RELEASE([[NSDateFormatter alloc] init]);
    [_fmt setDateFormat:format];
    NSDate *_theDate = [_fmt dateFromString:dateString];
    return [PYDate dateWithDate:_theDate];
}
+ (id)dateFromDate:(id<PYDate>)date
{
    return __AUTO_RELEASE([[PYDate alloc] initWithTimestamp:date.timestamp]);
}

// Get the weekday name
+ (NSString *)weekdayNameofDay:(NSUInteger)day
{
    NSString *_dayKey = [NSString stringWithFormat:@"DAY_%u", (unsigned int)day];
    return [PYLocalizedString stringForKey:_dayKey];
}

// Instance
- (id)init
{
    self = [super init];
    if ( self ) {
        [self _initFromDate:[NSDate date]];
    }
    return self;
}
- (id)initWithTimestamp:(NSUInteger)timestamp
{
    self = [super init];
    if ( self ) {
        [self _initFromDate:[NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)timestamp]];
    }
    return self;
}
- (id)initWithString:(NSString *)dateString format:(NSString *)format
{
    self = [super init];
    if ( self ) {
        NSDateFormatter *_fmt = __AUTO_RELEASE([[NSDateFormatter alloc] init]);
        [_fmt setDateFormat:format];
        NSDate *_theDate = [_fmt dateFromString:dateString];
        [self _initFromDate:_theDate];
    }
    return self;
}
- (id)initWithDate:(PYDate *)date
{
    self = [super init];
    if ( self ) {
        _year = date.year;
        _month = date.month;
        _day = date.day;
        _hour = date.hour;
        _minute = date.minute;
        _second = date.second;
        _weekday = date.weekday;
        _timestamp = date.timestamp;
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if ( self ) {
        _timestamp = [aDecoder decodeInt32ForKey:@"QTDateTimeStamp"];
        [self _initFromDate:[NSDate dateWithTimeIntervalSince1970:_timestamp]];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:(NSInteger)_timestamp forKey:@"QTDateTimeStamp"];
}

- (id)copy
{
    PYDate *_newDate = (PYDate *)[PYDate dateWithTimestamp:self.timestamp];
    return _newDate;
}

- (id)copyWithZone:(NSZone *)zone
{
    PYDate *_newData = [[PYDate allocWithZone:zone] initWithTimestamp:self.timestamp];
    return _newData;
}

// Convert to NSDate
- (NSDate *)nsDate
{
    return [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)_timestamp];
}

// Current date actions
- (NSString *)stringOfDay
{
    return [NSString stringWithFormat:@"%04u-%02u-%02u",
            (unsigned int)_year, (unsigned int)_month, (unsigned int)_day];
}
- (NSString *)stringOfDate:(NSString *)format
{
    NSDateFormatter *_fmt = __AUTO_RELEASE([[NSDateFormatter alloc] init]);
    [_fmt setDateFormat:format];
    NSDate *_theDate = [self nsDate];
    return [_fmt stringFromDate:_theDate];
}
- (NSString *)timeIntervalStringFromNow
{
	//NSTimeInterval _interval = [NOWDATE timeIntervalSinceDate:date];
    return [self timeIntervalStringFromDate:(PYDate *)[PYDate date]];
}
- (NSString *)timeIntervalStringFromDate:(PYDate *)date
{
    NSInteger _interval = date.timestamp - _timestamp;
	if ( _interval < 0 ) return [PYLocalizedString stringForKey:@"RIGHTNOW"];
	if ( _interval < 60 ) return
        [NSString stringWithFormat:[PYLocalizedString stringForKey:@"SECONDS_AGO"],
         (int)_interval];
	if ( _interval < 3600 ) return
        [NSString stringWithFormat:[PYLocalizedString stringForKey:@"MINUTS_AGO"],
         ((int)_interval) / 60];
	if ( _interval < 86400 ) return
        [NSString stringWithFormat:[PYLocalizedString stringForKey:@"HOUR_AGO"],
         ((int)_interval) / 3600];
	if ( _interval < 604800 ) return
        [NSString stringWithFormat:[PYLocalizedString stringForKey:@"DAY_AGO"],
         ((int)_interval) / 86400];
	return [self stringOfDay];
}
- (NSInteger)timeIntervalSince:(PYDate *)date
{
    return _timestamp - date.timestamp;
}
- (id)beginOfDay
{
    NSUInteger _secondPass = _hour * 3600 + _minute * 60 + _second;
    NSUInteger _beginTimeStamp = _timestamp - _secondPass;
    return [PYDate dateWithTimestamp:_beginTimeStamp];
}
- (id)endOfDay
{
    int _secondPass = _hour * 3600 + _minute * 60 + _second;
    int _timeLeft = 86400 - _secondPass;
    return [PYDate dateWithTimestamp:(_timestamp + _timeLeft)];
}

- (id)yesterday
{
    PYDate *_yesterday = [PYDate dateFromDate:self];
    if (_yesterday->_weekday != PYWeekDaySun) {
        _yesterday->_weekday -= 1;
    } else {
        _yesterday->_weekday = PYWeekDaySat;
    }
    
    if ( _yesterday->_day != 1 ) {
        _yesterday->_day -= 1;
    } else {
        if ( _yesterday->_month == 1 ) {
            _yesterday->_year -= 1;
            _yesterday->_month = 12;
        } else {
            _yesterday->_month -= 1;
        }
        _yesterday->_day = [PYDate daysInMonth:_yesterday->_month ofYear:_yesterday->_year];
    }
    _yesterday->_timestamp -= 86400;
    return _yesterday;
}
- (id)tomorrow
{
    PYDate *_tomorrow = [PYDate dateFromDate:self];
	if ( _tomorrow->_weekday != PYWeekDaySat ) {
		_tomorrow->_weekday += 1;
	} else {
		_tomorrow->_weekday = PYWeekDaySun;
	}
	
    NSUInteger _currentMonthDays = [PYDate daysInMonth:_tomorrow->_month ofYear:_tomorrow->_year];
	
	if ( _tomorrow->_day != _currentMonthDays ) {
		_tomorrow->_day += 1;
	}
	else {
		if ( _tomorrow->_month == 12 ) {
			_tomorrow->_year += 1;
			_tomorrow->_month = 1;
		} else {
			_tomorrow->_month += 1;
		}
		_tomorrow->_day = 1;
	}
	_tomorrow->_timestamp += 86400;
	return _tomorrow;
}
- (id)dateDaysAgo:(NSUInteger)dayCount
{
    return [PYDate dateWithTimestamp:(_timestamp - (dayCount * 86400))];
}
- (id)dateDaysAfter:(NSUInteger)dayCount
{
    return [PYDate dateWithTimestamp:(_timestamp + (dayCount * 86400))];
}

- (id)dateMinuterAfter:(NSUInteger)minuterCount
{
    return [PYDate dateWithTimestamp:(_timestamp + (minuterCount * 60))];
}

- (BOOL)isExpiredFromNow
{
    if ( _timestamp == -1 ) return NO;
    time_t _t = time(NULL);
    return _timestamp <= _t;
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
