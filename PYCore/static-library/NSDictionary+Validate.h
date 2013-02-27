//
//  NSDictionary+Validate.h
//  PYCore
//
//  Created by littlepush on 9/4/12.
//  Copyright (c) 2012 PushLab. All rights reserved.
//

#import <Foundation/Foundation.h>

/* Validate the object for the key in specified type */
@interface NSDictionary (Validate)

/* The value must be int */
-(int) intObjectForKey:(NSString *)key;
/* The value must be long */
-(long) longObjectForKey:(NSString *)key;
/* The value must be longlong */
-(long long) longlongObjectForKey:(NSString *)key;
/* The value must be bool(true or false) */
-(BOOL) boolObjectForKey:(NSString *)key;
/* The value must be a double */
-(double) doubleObjectForKey:(NSString *)key;
/* The value must be an array */
-(NSArray *) arrayObjectForKey:(NSString *)key;
/* The value must be a string */
-(NSString *) stringObjectForKey:(NSString *)key;
/* The value must be another dictionary */
-(NSDictionary *) dictObjectForKey:(NSString *)key;

// With Default Value
/* The value must be int */
-(int) intObjectForKey:(NSString *)key withDefaultValue:(int)defaultValue;
/* The value must be long */
-(long) longObjectForKey:(NSString *)key withDefaultValue:(long)defaultValue;
/* The value must be longlong */
-(long long) longlongObjectForKey:(NSString *)key withDefaultValue:(long long)defaultValue;
/* The value must be bool(true or false) */
-(BOOL) boolObjectForKey:(NSString *)key withDefaultValue:(BOOL)defaultValue;
/* The value must be a double */
-(double) doubleObjectForKey:(NSString *)key withDefaultValue:(double)defaultValue;
/* The value must be a string */
-(NSString *) stringObjectForKey:(NSString *)key withDefaultValue:(NSString *)defaultValue;

/* Get an SNS(sina) date object (UTC), default should be 1970.1.1 00:00:00 */
-(NSDate *) snsDateObjectForKey:(NSString *)key;
/* Get an date object ( +%s ), default should be 1970.1.1 00:00:00 */
-(NSDate *) utcDateObjectForKey:(NSString *)key;
/* Get an date object of millisecond, default should be 1970.1.1 00:00:00 */
-(NSDate *) mDateObjectForKey:(NSString *)key;

@end
