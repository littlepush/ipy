//
//  PYHumanInfo.h
//  PYDataDemo
//
//  Created by Push Chen on 5/9/14.
//  Copyright (c) 2014 PushLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PYHumanInfo : PYObject < NSCoding >

@property (nonatomic, copy)     NSString            *gender;
@property (nonatomic, assign)   NSUInteger          age;
@property (nonatomic, strong)   PYDate              *dateCheckIn;
@property (nonatomic, copy)     NSString            *phoneNumber;
@property (nonatomic, copy)     NSString            *email;

@end
