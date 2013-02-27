//
//  NSDictionary+Validate.m
//  PYCore
//
//  Created by littlepush on 9/4/12.
//  Copyright (c) 2012 PushLab. All rights reserved.
//

#import "NSDictionary+Validate.h"
#import "NSObject+Extended.h"

@implementation NSDictionary (Validate)

/* The value must be int */
-(int) intObjectForKey:(NSString *)key
{
	id _object = [self objectForKey:key];
	if ( _object == nil ) {
		[self raiseExceptionWithMessage:[NSString 
			stringWithFormat:@"No value for key<%@>", key]];
	}
	NSString *_class = NSStringFromClass([_object class]);
	if ( ![_object isKindOfClass:[NSNumber class]] ) {
		[self raiseExceptionWithMessage:[NSString
			stringWithFormat:@"The value for key<%@> is a(n) %@, not NSNumber", 
			key, _class]];
	}
	return [_object intValue];
}
/* The value must be long */
-(long) longObjectForKey:(NSString *)key
{
	id _object = [self objectForKey:key];
	if ( _object == nil ) {
		[self raiseExceptionWithMessage:[NSString 
			stringWithFormat:@"No value for key<%@>", key]];
	}
	NSString *_class = NSStringFromClass([_object class]);
	if ( ![_object isKindOfClass:[NSNumber class]] ) {
		[self raiseExceptionWithMessage:[NSString
			stringWithFormat:@"The value for key<%@> is a(n) %@, not NSNumber", 
			key, _class]];
	}
	return [_object longValue];
}
/* The value must be longlong */
-(long long) longlongObjectForKey:(NSString *)key
{
	id _object = [self objectForKey:key];
	if ( _object == nil ) {
		[self raiseExceptionWithMessage:[NSString
			stringWithFormat:@"No value for key<%@>", key]];
	}
	NSString *_class = NSStringFromClass([_object class]);
	if ( ![_object isKindOfClass:[NSNumber class]] ) {
		[self raiseExceptionWithMessage:[NSString
			stringWithFormat:@"The value for key<%@> is a(n) %@, not NSNumber",
			key, _class]];
	}
	return [_object longLongValue];
}
/* The value must be bool(true or false) */
-(BOOL) boolObjectForKey:(NSString *)key
{
	id _object = [self objectForKey:key];
	if ( _object == nil ) {
		[self raiseExceptionWithMessage:[NSString 
			stringWithFormat:@"No value for key<%@>", key]];
	}
	NSString *_class = NSStringFromClass([_object class]);
	if ( ![_object isKindOfClass:[NSNumber class]] ) {
		[self raiseExceptionWithMessage:[NSString
			stringWithFormat:@"The value for key<%@> is a(n) %@, not BOOL", 
			key, _class]];
	}
	return [_object boolValue];
}
/* The value must be a double */
-(double) doubleObjectForKey:(NSString *)key
{
	id _object = [self objectForKey:key];
	if ( _object == nil ) {
		[self raiseExceptionWithMessage:[NSString 
			stringWithFormat:@"No value for key<%@>", key]];
	}
	NSString *_class = NSStringFromClass([_object class]);
	if ( ![_object isKindOfClass:[NSNumber class]] ) {
		[self raiseExceptionWithMessage:[NSString
			stringWithFormat:@"The value for key<%@> is a(n) %@, not NSNumber", 
			key, _class]];
	}
	return [_object doubleValue];
}
/* The value must be an array */
-(NSArray *) arrayObjectForKey:(NSString *)key
{
	id _object = [self objectForKey:key];
	if ( _object == nil ) {
		[self raiseExceptionWithMessage:[NSString 
			stringWithFormat:@"No value for key<%@>", key]];
	}
	NSString *_class = NSStringFromClass([_object class]);
	if ( ![_object isKindOfClass:[NSArray class]] ) {
		[self raiseExceptionWithMessage:[NSString
			stringWithFormat:@"The value for key<%@> is a(n) %@, not NSArray", 
			key, _class]];
	}
	return _object;
}
/* The value must be a string */
-(NSString *) stringObjectForKey:(NSString *)key
{
	id _object = [self objectForKey:key];
	if ( _object == nil ) {
		[self raiseExceptionWithMessage:[NSString 
			stringWithFormat:@"No value for key<%@>", key]];
	}
	NSString *_class = NSStringFromClass([_object class]);
	if ( ![_object isKindOfClass:[NSString class]] ) {
		[self raiseExceptionWithMessage:[NSString
			stringWithFormat:@"The value for key<%@> is a(n) %@, not NSString", 
			key, _class]];
	}
	return _object;
}
/* The value must be another dictionary */
-(NSDictionary *) dictObjectForKey:(NSString *)key
{
	id _object = [self objectForKey:key];
	if ( _object == nil ) {
		[self raiseExceptionWithMessage:[NSString 
			stringWithFormat:@"No value for key<%@>", key]];
	}
	NSString *_class = NSStringFromClass([_object class]);
	if ( ![_object isKindOfClass:[NSDictionary class]] ) {
		[self raiseExceptionWithMessage:[NSString
			stringWithFormat:@"The value for key<%@> is a(n) %@, not NSDictionary", 
			key, _class]];
	}
	return _object;
}

// With Default Value
/* The value must be int */
-(int) intObjectForKey:(NSString *)key withDefaultValue:(int)defaultValue
{
	id _object = [self objectForKey:key];
	if ( _object == nil ) return defaultValue;
	if ( ![_object isKindOfClass:[NSNumber class]] ) return defaultValue;
	return [_object intValue];	
}
/* The value must be long */
-(long) longObjectForKey:(NSString *)key withDefaultValue:(long)defaultValue
{
	id _object = [self objectForKey:key];
	if ( _object == nil ) return defaultValue;
	if ( ![_object isKindOfClass:[NSNumber class]] ) return defaultValue;
	return [_object longValue];	
}
/* The value must be longlong */
-(long long) longlongObjectForKey:(NSString *)key withDefaultValue:(long long)defaultValue
{
	id _object = [self objectForKey:key];
	if ( _object == nil ) return defaultValue;
	if ( ![_object isKindOfClass:[NSNumber class]] ) return defaultValue;
	return [_object longLongValue];
}
/* The value must be bool(true or false) */
-(BOOL) boolObjectForKey:(NSString *)key withDefaultValue:(BOOL)defaultValue
{
	id _object = [self objectForKey:key];
	if ( _object == nil ) return defaultValue;
	if ( ![_object isKindOfClass:[NSNumber class]] ) return defaultValue;
	return [_object boolValue];	
}
/* The value must be a double */
-(double) doubleObjectForKey:(NSString *)key withDefaultValue:(double)defaultValue
{
	id _object = [self objectForKey:key];
	if ( _object == nil ) return defaultValue;
	if ( ![_object isKindOfClass:[NSNumber class]] ) return defaultValue;
	return [_object doubleValue];	
}
/* The value must be a string */
-(NSString *) stringObjectForKey:(NSString *)key withDefaultValue:(NSString *)defaultValue
{
	id _object = [self objectForKey:key];
	if ( _object == nil ) return defaultValue;
	if ( ![_object isKindOfClass:[NSString class]] ) return defaultValue;
	return (NSString *)_object;
}

/* Get an SNS(sina) date object (UTC), default should be 1970.1.1 00:00:00 */
-(NSDate *) snsDateObjectForKey:(NSString *)key
{
	NSString *_dateString = [self stringObjectForKey:key withDefaultValue:0];
	NSDateFormatter *_formater = [NSDateFormatter object];
	[_formater setDateFormat:@"EEE MMM dd HH:mm:ss ZZ yyyy"];
	NSDate *_date = [_formater dateFromString:_dateString];
	return _date;
}
/* Get an date object ( +%s ), default should be 1970.1.1 00:00:00 */
-(NSDate *) utcDateObjectForKey:(NSString *)key
{
	long _dateValue = [self longObjectForKey:key withDefaultValue:0];
	if ( _dateValue == 0 ) {
		_dateValue = [[self stringObjectForKey:key withDefaultValue:@"0"] intValue];
	}
	NSDate *_date = [NSDate dateWithTimeIntervalSince1970:((double)_dateValue)];
	return _date;
}
/* Get an date object of millisecond, default should be 1970.1.1 00:00:00 */
-(NSDate *) mDateObjectForKey:(NSString *)key
{
	NSNumber *_value = [self objectForKey:key];
	if ( _value == nil || ![_value isKindOfClass:[NSNumber class]] ) 
		return [NSDate dateWithTimeIntervalSince1970:0];
	long long _dateValue = [_value longLongValue];
	double _timeInterval = (double)((_dateValue) / 1000.f) + ((double)(_dateValue % 1000)) / 1000.f;
	NSDate *_date = [NSDate dateWithTimeIntervalSince1970:_timeInterval];
	return _date;
}

@end
