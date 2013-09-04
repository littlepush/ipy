//
//  PYDate.h
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

#import <Foundation/Foundation.h>

// The week day enumerate, sunday is the first day and starts with 1.
typedef enum {
    PYWeekDaySun = 1,
    PYWeekDayMon,
    PYWeekDayTue,
    PYWeekDayWed,
    PYWeekDayThu,
    PYWeekDayFri,
    PYWeekDaySat
} PYWeekDay;

@protocol PYDate <NSObject>

@required
@property (nonatomic, readonly) NSUInteger          year;
@property (nonatomic, readonly) NSUInteger          month;
@property (nonatomic, readonly) NSUInteger          day;
@property (nonatomic, readonly) PYWeekDay           weekday;
@property (nonatomic, readonly) NSUInteger          hour;
@property (nonatomic, readonly) NSUInteger          minute;
@property (nonatomic, readonly) NSUInteger          second;
// The timestamp property.
@property (nonatomic, readonly) long                timestamp;

// Initialize functions
// Now date
+ (id)date;
// Specified date
+ (id)dateWithTimestamp:(NSUInteger)timestamp;
// From an NSDate
+ (id)dateWithDate:(NSDate *)date;
// Date from string, default format "yyyy-MM-dd hh:mm:ss"
+ (id)dateWithString:(NSString *)dateString;
// Date format: "yyyy-MM-dd"
+ (id)dateWithDayString:(NSString *)dayString;
+ (id)dateWithString:(NSString *)dateString format:(NSString *)format;

+ (id)dateFromDate:(id<PYDate>)date;

//
- (id)beginOfDay;
- (id)endOfDay;

// Date Navigation
- (id)yesterday;
- (id)tomorrow;
- (id)dateDaysAgo:(NSUInteger)dayCount;
- (id)dateDaysAfter:(NSUInteger)dayCount;
- (id)dateMinuterAfter:(NSUInteger)minuterCount;

@end

@interface PYDate : NSObject<PYDate, NSCoding, NSCopying>
{
    NSUInteger                  _year;
    NSUInteger                  _month;
    NSUInteger                  _day;
    PYWeekDay                   _weekday;
    NSUInteger                  _hour;
    NSUInteger                  _minute;
    NSUInteger                  _second;
    NSUInteger                  _millisecond;
    
    long                        _timestamp;
}

// Date Creater
// Get the weekday name
+ (NSString *)weekdayNameofDay:(NSUInteger)day;

// Get the day count of specified year and month.
+ (NSUInteger)daysInMonth:(NSUInteger)month ofYear:(NSUInteger)year;

// Instance
- (id)initWithDate:(PYDate *)date;
- (id)initWithTimestamp:(NSUInteger)timestamp;
- (id)initWithString:(NSString *)dateString format:(NSString *)format;

// Convert to NSDate
- (NSDate *)nsDate;

// Current date actions
- (NSString *)stringOfDay;
- (NSString *)stringOfDate:(NSString *)format;
- (NSString *)timeIntervalStringFromNow;
- (NSString *)timeIntervalStringFromDate:(PYDate *)date;
- (NSInteger)timeIntervalSince:(PYDate *)date;

//
// Expire Checking
- (BOOL)isExpiredFromNow;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
