//
//  PYCommonResponse.m
//  PYNetworkScript
//
//  Created by littlepush on 08/26/12.
//  Copyright (c) 2012 PushLab. All rights reserved.
//

#import "PYCommonResponse.h"

// The Following code is automatic created by the PYNetwork Script.
// Copyright (c) 2012 PushLab. All rights reserved.
// Connect the author: 
//		Mail: littlepush@gmail.com
//		Twitter: @littlepush
// 		Web site: http://pushchen.com
//

@implementation PYCommonResponse
@synthesize errorNo;
@synthesize errorMsg;
@synthesize data;

-(NSObject *) formatResultWithData:(NSData *)jsonData
{
	NSDictionary *result = [jsonData objectFromJSONData];

	__PY_NOT_IMPLEMENTATION__;

	// Error No
	NSNumber *_resultNo = [result objectForKey:@""];
	self.errorNo = [_resultNo intValue];
	
	// Error Msg
	self.errorMsg = [result objectForKey:@""];
	
	return [result objectForKey:@""];
}

@end

// @Insert New Response Object Before This Line@
