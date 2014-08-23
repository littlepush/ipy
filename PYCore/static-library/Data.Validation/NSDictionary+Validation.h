//
//  NSDictionary+Validation.h
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

@interface NSDictionary (Validation)

/* The value must be int */
- (int)intObjectForKey:(NSString *)key;
/* The value must be long */
- (long)longObjectForKey:(NSString *)key;
/* The value must be longlong */
- (long long)longlongObjectForKey:(NSString *)key;
/* The value must be bool(true or false) */
- (BOOL)boolObjectForKey:(NSString *)key;
/* The value must be a double */
- (double)doubleObjectForKey:(NSString *)key;
/* The value must be an array */
- (NSArray *)arrayObjectForKey:(NSString *)key;
/* The value must be a string */
- (NSString *)stringObjectForKey:(NSString *)key;
/* The value must be another dictionary */
- (NSDictionary *)dictObjectForKey:(NSString *)key;

/* The value should be int or string, but convert it to int */
- (int)tryIntObjectForKey:(NSString *)key;

// With Default Value
/* The value must be int */
- (int)intObjectForKey:(NSString *)key withDefaultValue:(int)defaultValue;
/* The value must be long */
- (long)longObjectForKey:(NSString *)key withDefaultValue:(long)defaultValue;
/* The value must be longlong */
- (long long)longlongObjectForKey:(NSString *)key withDefaultValue:(long long)defaultValue;
/* The value must be bool(true or false) */
- (BOOL)boolObjectForKey:(NSString *)key withDefaultValue:(BOOL)defaultValue;
/* The value must be a double */
- (double)doubleObjectForKey:(NSString *)key withDefaultValue:(double)defaultValue;
/* The value must be a string */
- (NSString *)stringObjectForKey:(NSString *)key withDefaultValue:(NSString *)defaultValue;

/* The value should be int or string, or nil, try to conver it to int or return default value */
- (int)tryIntObjectForKey:(NSString *)key withDefaultValue:(int)defaultValue;

/* Get an SNS(sina) date object (UTC), default should be 1970.1.1 00:00:00 */
- (NSDate *)snsDateObjectForKey:(NSString *)key;
/* Get an date object ( +%s ), default should be 1970.1.1 00:00:00 */
- (NSDate *)utcDateObjectForKey:(NSString *)key;
/* Get an date object of millisecond, default should be 1970.1.1 00:00:00 */
- (NSDate *)mDateObjectForKey:(NSString *)key;
/* Get an date object of Nodejs style(basicly, when use sails, format should be yyyy-MM-ddTHH:mm:ss.SSSZ */
- (NSDate *)jsDateObjectForKey:(NSString *)key;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
