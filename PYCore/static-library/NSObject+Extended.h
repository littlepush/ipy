//
//  NSObject+Extended.h
//  PYCore
//
//  Created by Push Chen on 6/15/12.
//  Copyright (c) 2012 PushLab. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
	NSobject Extended
 */
@interface NSObject(Extended)

/* Raise an exception and throw the message specifed. */
-(void) raiseExceptionWithMessage:(NSString *)message;

/* Create a NSError object with message */
-(NSError *) errorWithCode:(int)code message:(NSString *)message;

/* return an autorelease object */
+(id) object;

@end
