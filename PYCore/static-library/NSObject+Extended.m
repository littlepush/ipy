//
//  NSObject+Extended.m
//  PYCore
//
//  Created by Push Chen on 6/15/12.
//  Copyright (c) 2012 PushLab. All rights reserved.
//

#import "NSObject+Extended.h"

@implementation NSObject(Extended)

-(void) raiseExceptionWithMessage:(NSString *)message
{
	NSException *e = [NSException
			exceptionWithName:NSStringFromClass([self class])
					   reason:message
					 userInfo:nil];
	[e raise];
}

-(NSError *) errorWithCode:(int)code message:(NSString *)message
{
	NSDictionary *errMsg = [NSDictionary 
		dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
	NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
		code:code userInfo:errMsg];
	return error;
}

+(id) object
{
	return [[[self alloc] init] autorelease];
}

@end
