//
//  PYHumanInfo.m
//  PYDataDemo
//
//  Created by Push Chen on 5/9/14.
//  Copyright (c) 2014 PushLab. All rights reserved.
//

#import "PYHumanInfo.h"

@implementation PYHumanInfo

@synthesize gender;
@synthesize age;
@synthesize dateCheckIn;
@synthesize phoneNumber;
@synthesize email;

- (id)init
{
    self = [super init];
    if ( self ) {
        self.objectId = PYGUID;
        self.type = NSStringFromClass([self class]);
        self.updateTime = [PYDate date];
        self.name = @"";
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if ( self ) {
        PYUnArchiveObject(objectId);
        PYUnArchiveObject(name);
        PYUnArchiveObject(type);
        PYUnArchiveObject(updateTime);
        
        PYUnArchiveObject(gender);
        PYUnArchiveInteger(age);
        PYUnArchiveObject(dateCheckIn);
        PYUnArchiveObject(phoneNumber);
        PYUnArchiveObject(email);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    PYArchiveObject(objectId);
    PYArchiveObject(name);
    PYArchiveObject(type);
    PYArchiveObject(updateTime);
    
    PYArchiveObject(gender);
    PYArchiveInteger(age);
    PYArchiveObject(dateCheckIn);
    PYArchiveObject(phoneNumber);
    PYArchiveObject(email);
}

- (void)objectFromJsonDict:(NSDictionary *)jsonDict
{
    [super objectFromJsonDict:jsonDict];
    
    self.gender = [jsonDict stringObjectForKey:@"gender" withDefaultValue:@"Secret"];
    self.age = [jsonDict tryIntObjectForKey:@"age" withDefaultValue:0];
    self.dateCheckIn = [PYDate dateWithDate:[jsonDict utcDateObjectForKey:@"datecheckin"]];
    self.phoneNumber = [jsonDict stringObjectForKey:@"phone" withDefaultValue:@""];
    self.email = [jsonDict stringObjectForKey:@"email" withDefaultValue:@""];
}

- (NSDictionary *)objectToJsonDict
{
    NSMutableDictionary *_dict = [NSMutableDictionary dictionaryWithDictionary:[super objectToJsonDict]];
    [_dict setObject:self.gender forKey:@"gender"];
    [_dict setObject:@(self.age) forKey:@"age"];
    [_dict setObject:@(self.dateCheckIn.timestamp) forKey:@"datecheckin"];
    [_dict setObject:self.phoneNumber forKey:@"phone"];
    [_dict setObject:self.email forKey:@"email"];
    
    return _dict;
}

@end
