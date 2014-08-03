//
//  NSDictionary+Validation.m
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

#import "NSDictionary+Validation.h"
#import "NSObject+PYCore.h"
#import "NSString+Validation.h"

#define __NO_VALUE_EXP__                                                            \
    NSString *_err = [NSString stringWithFormat:@"No value for key<%@>", key];      \
    [self raiseExceptionWithMessage:_err];
#define __INVALIDATE_TYPE_EXP__(_t)                                                 \
    NSString *_err = [NSString stringWithFormat:                                    \
    @"The value for key<%@> is a(n) %@, not " @#_t, key, _class];               \
    [self raiseExceptionWithMessage:_err];
#define __GET_VALUE_OBJECT__                                                        \
    id _object = [self objectForKey:key];                                           \
    if ( _object == nil ) { __NO_VALUE_EXP__ }
#define __GET_VALUE_TYPE__                                                          \
    NSString *_class = NSStringFromClass([_object class]);
#define __CHECK_VALUE_TYPE__(_t)                                                    \
    [_object mustBeTypeOrFailed:[_t class]];
#define __DEFAULT_TYPE_VALIDATE__(_t)                                               \
    __GET_VALUE_OBJECT__                                                            \
    __CHECK_VALUE_TYPE__(_t)

@implementation NSDictionary (Validation)
/* The value must be int */
- (int)intObjectForKey:(NSString *)key
{
    __DEFAULT_TYPE_VALIDATE__(NSNumber)
	return [_object intValue];
}
/* The value must be long */
- (long)longObjectForKey:(NSString *)key
{
    __DEFAULT_TYPE_VALIDATE__(NSNumber)
	return [_object longValue];
}
/* The value must be longlong */
- (long long)longlongObjectForKey:(NSString *)key
{
    __DEFAULT_TYPE_VALIDATE__(NSNumber)
	return [_object longLongValue];
}
/* The value must be bool(true or false) */
- (BOOL)boolObjectForKey:(NSString *)key
{
    __GET_VALUE_OBJECT__;
    if ( [_object isKindOfClass:[NSNumber class]] == NO ) {
        if ( [_object isKindOfClass:[NSString class]] == NO ) {
            NSString *_errInfo = [NSString stringWithFormat:
                                  @"the object for %@ cannot be recognized as bool value", key];
            [self raiseExceptionWithMessage:_errInfo];
        }
    }
	return [_object boolValue];
}
/* The value must be a double */
- (double)doubleObjectForKey:(NSString *)key
{
    __DEFAULT_TYPE_VALIDATE__(NSNumber)
	return [_object doubleValue];
}
/* The value must be an array */
- (NSArray *)arrayObjectForKey:(NSString *)key
{
    __DEFAULT_TYPE_VALIDATE__(NSArray)
	return (NSArray *)_object;
}
/* The value must be a string */
- (NSString *)stringObjectForKey:(NSString *)key
{
    __DEFAULT_TYPE_VALIDATE__(NSString)
	return _object;
}
/* The value must be another dictionary */
- (NSDictionary *)dictObjectForKey:(NSString *)key
{
    __DEFAULT_TYPE_VALIDATE__(NSDictionary)
	return _object;
}

/* The value should be int or string, but convert it to int */
- (int)tryIntObjectForKey:(NSString *)key
{
    id _object = [self objectForKey:key];
    if ( _object == nil ) {
        __NO_VALUE_EXP__
    }
    __GET_VALUE_TYPE__
    if ( ![_object isKindOfClass:[NSNumber class]] ) {
        if ( ![_object isKindOfClass:[NSString class]] ) {
            __INVALIDATE_TYPE_EXP__(NSNumber or NSString)
        } else {
            // Try to validate the string
            if ( [((NSString *)_object) isIntager] ) return [_object intValue];
            [self raiseExceptionWithMessage:[NSString
                                             stringWithFormat:@"The value for key<%@> is not in validate format", key]];
        }
    }
    return [_object intValue];
}

// With Default Value
/* The value must be int */
- (int)intObjectForKey:(NSString *)key withDefaultValue:(int)defaultValue
{
    id _object = [self objectForKey:key];
	if ( _object == nil ) return defaultValue;
	if ( ![_object isKindOfClass:[NSNumber class]] ) return defaultValue;
	return [_object intValue];
}
/* The value must be long */
- (long)longObjectForKey:(NSString *)key withDefaultValue:(long)defaultValue
{
    id _object = [self objectForKey:key];
	if ( _object == nil ) return defaultValue;
	if ( ![_object isKindOfClass:[NSNumber class]] ) return defaultValue;
	return [_object longValue];
}
/* The value must be longlong */
- (long long)longlongObjectForKey:(NSString *)key withDefaultValue:(long long)defaultValue
{
    id _object = [self objectForKey:key];
	if ( _object == nil ) return defaultValue;
	if ( ![_object isKindOfClass:[NSNumber class]] ) return defaultValue;
	return [_object longLongValue];
}
/* The value must be bool(true or false) */
- (BOOL)boolObjectForKey:(NSString *)key withDefaultValue:(BOOL)defaultValue
{
    id _object = [self objectForKey:key];
	if ( _object == nil ) return defaultValue;
	if ( ![_object isKindOfClass:[NSNumber class]] ) {
        if ( ![_object isKindOfClass:[NSString class]] ) {
            return defaultValue;
        }
    }
	return [_object boolValue];
}
/* The value must be a double */
- (double)doubleObjectForKey:(NSString *)key withDefaultValue:(double)defaultValue
{
    id _object = [self objectForKey:key];
	if ( _object == nil ) return defaultValue;
	if ( ![_object isKindOfClass:[NSNumber class]] ) return defaultValue;
	return [_object doubleValue];
}
/* The value must be a string */
- (NSString *)stringObjectForKey:(NSString *)key withDefaultValue:(NSString *)defaultValue
{
    id _object = [self objectForKey:key];
	if ( _object == nil ) return defaultValue;
	if ( ![_object isKindOfClass:[NSString class]] ) return defaultValue;
	return (NSString *)_object;
}

/* The value should be int or string, or nil, try to conver it to int or return default value */
- (int)tryIntObjectForKey:(NSString *)key withDefaultValue:(int)defaultValue
{
    id _object = [self objectForKey:key];
    if ( _object == nil ) return defaultValue;
    if ( ![_object isKindOfClass:[NSNumber class]] ) {
        if (![_object isKindOfClass:[NSString class]]) return defaultValue;
        if ( [(NSString *)_object isIntager] ) return [_object intValue];
        return defaultValue;
    }
    return [_object intValue];
}

/* Get an SNS(sina) date object (UTC), default should be 1970.1.1 00:00:00 */
- (NSDate *)snsDateObjectForKey:(NSString *)key
{
    NSString *_dateString = [self stringObjectForKey:key withDefaultValue:0];
	NSDateFormatter *_formater = [NSDateFormatter object];
	[_formater setDateFormat:@"EEE MMM dd HH:mm:ss ZZ yyyy"];
	NSDate *_date = [_formater dateFromString:_dateString];
	return _date;
}
/* Get an date object ( +%s ), default should be 1970.1.1 00:00:00 */
- (NSDate *)utcDateObjectForKey:(NSString *)key
{
    long _dateValue = [self longObjectForKey:key withDefaultValue:0];
	if ( _dateValue == 0 ) {
		_dateValue = [[self stringObjectForKey:key withDefaultValue:@"0"] intValue];
	}
	NSDate *_date = [NSDate dateWithTimeIntervalSince1970:((double)_dateValue)];
	return _date;
}
/* Get an date object of millisecond, default should be 1970.1.1 00:00:00 */
- (NSDate *)mDateObjectForKey:(NSString *)key
{
    NSNumber *_value = [self objectForKey:key];
	if ( _value == nil || ![_value isKindOfClass:[NSNumber class]] )
		return [NSDate dateWithTimeIntervalSince1970:0];
	long long _dateValue = [_value longLongValue];
	double _timeInterval = (double)((_dateValue) / 1000.f) + ((double)(_dateValue % 1000)) / 1000.f;
	NSDate *_date = [NSDate dateWithTimeIntervalSince1970:_timeInterval];
	return _date;
}
/* Get an date object of Nodejs style(basicly, when use sails, format should be yyyy-MM-ddTHH:mm:ss.SSSZ */
- (NSDate *)jsDateObjectForKey:(NSString *)key
{
    NSString *_dateString = [self stringObjectForKey:key withDefaultValue:@""];
    if ( [_dateString length] == 0 ) return [NSDate dateWithTimeIntervalSince1970:0];
    _dateString = [_dateString stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    _dateString = [_dateString stringByReplacingOccurrencesOfString:@"Z" withString:@""];
    NSDateFormatter *_formater = [NSDateFormatter object];
    [_formater setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSDate *_date = [_formater dateFromString:_dateString];
    return _date;
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
