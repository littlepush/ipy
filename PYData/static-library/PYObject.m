//
//  PYObject.m
//  PYData
//
//  Created by Push Chen on 8/19/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
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

#import "PYObject.h"

@implementation PYObject

@synthesize objectId, updateTime, name, type;
@dynamic objectIdentify;
@dynamic objectClass;
- (NSString *)objectIdentify
{
    return [NSString stringWithFormat:@"%@+%@",
            NSStringFromClass([self objectClass]), self.objectId];
}

- (Class)objectClass
{
    return [self class];
}

#pragma mark --
#pragma mark Object

+ (NSString *)identifyOfId:(NSString *)objectId
{
    return [NSString stringWithFormat:@"%@+%@", [self class], objectId];
}

// Equal
- (BOOL)isEqual:(id)object
{
    if ( ![object isKindOfClass:[PYObject class]] ) return NO;
    PYObject *_otherObject = (PYObject *)object;
    if ( ![_otherObject.type isEqualToString:self.type] ) return NO;
    return [_otherObject.objectId isEqualToString:self.objectId];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"{objectId:%@; name:%@; type:%@}",
            self.objectId, self.name, self.type];
}

#pragma mark --
#pragma mark Override

- (void)objectFromJsonDict:(NSDictionary *)jsonDict
{
    self.objectId   = PYIntToString([jsonDict tryIntObjectForKey:@"id" withDefaultValue:0]);
    self.updateTime = [PYDate dateWithDate:[jsonDict utcDateObjectForKey:@"updatetime"]];
    self.name       = [jsonDict stringObjectForKey:@"name" withDefaultValue:@""];
    self.type       = [jsonDict stringObjectForKey:@"type" withDefaultValue:@""];
}

- (NSDictionary *)objectToJsonDict
{
    // Return an empty dictionary.
    return @{
             @"id"              :self.objectId,
             @"name"            :self.name,
             @"type"            :self.type,
             @"updatetime"      :PYIntToString((int)[self.updateTime timestamp])
             };
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
