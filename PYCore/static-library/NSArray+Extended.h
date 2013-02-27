//
//  NSArray+Extended.h
//  PYCore
//
//  Created by littlepush on 8/6/12.
//  Copyright (c) 2012 PushLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Extended)

-(void) objectsTryToPerformSelector:(SEL)selector;

-(void) objectsTryToPerformSelector:(SEL)selector withObject:(id)obj;

-(void) objectsTryToPerformSelector:(SEL)selector withObject:(id)obj1 withObject:(id)obj2;

@end
