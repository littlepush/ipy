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

@interface PYDate : NSObject<NSCoding>
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

@property (nonatomic, readonly) NSUInteger          year;
@property (nonatomic, readonly) NSUInteger          month;
@property (nonatomic, readonly) NSUInteger          day;
@property (nonatomic, readonly) PYWeekDay           weekday;
@property (nonatomic, readonly) NSUInteger          hour;
@property (nonatomic, readonly) NSUInteger          minute;
@property (nonatomic, readonly) NSUInteger          second;

@property (nonatomic, readonly) long                timestamp;

// Date Creater
// Now date
+ (PYDate *)date;
// Specified date
+ (PYDate *)dateWithTimpstamp:(NSUInteger)timestamp;
// From an NSDate
+ (PYDate *)dateWithDate:(NSDate *)date;
// Date from string, default format "yyyy-MM-dd hh:mm:ss"
+ (PYDate *)dateWithString:(NSString *)dateString;
// Date format: "yyyy-MM-dd"
+ (PYDate *)dateWithDayString:(NSString *)dayString;
+ (PYDate *)dateWithString:(NSString *)dateString format:(NSString *)format;

+ (PYDate *)dateFromDate:(PYDate *)date;

// Get the weekday name
+ (NSString *)weekdayNameofDay:(NSUInteger)day;

// Get the day count of specified year and month.
+ (NSUInteger)daysInMonth:(NSUInteger)month ofYear:(NSUInteger)year;

// Instance
- (id)initWithDate:(PYDate *)date;
- (id)initWithTimpstamp:(NSUInteger)timestamp;
- (id)initWithString:(NSString *)dateString format:(NSString *)format;

// Convert to NSDate
- (NSDate *)nsDate;

// Current date actions
- (NSString *)stringOfDay;
- (NSString *)stringOfDate:(NSString *)format;
- (NSString *)timeIntervalStringFromNow;
- (NSString *)timeIntervalStringFromDate:(PYDate *)date;
- (NSInteger)timeIntervalSince:(PYDate *)date;
- (PYDate *)beginOfDay;
- (PYDate *)endOfDay;

// Date Navigation
- (PYDate *)yesterday;
- (PYDate *)tomorrow;
- (PYDate *)dateDaysAgo:(NSUInteger)dayCount;
- (PYDate *)dateDaysAfter:(NSUInteger)dayCount;
- (PYDate *)dateMinuterAfter:(NSUInteger)minuterCount;

//
// Expire Checking
- (BOOL)isExpiredFromNow;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
