//
//  PYResponseFormater.m
//  PYNetworkScript
//
//  Created by littlepush on 8/26/12.
//  Copyright (c) 2012 PushLab. All rights reserved.
//

#import "PYResponseFormater.h"
#import "PYCommonResponse.h"

// The Following code is automatic created by the PYNetwork Script.
// Copyright (c) 2012 PushLab. All rights reserved.
// Connect the author: 
//		Mail: littlepush@gmail.com
//		Twitter: @littlepush
// 		Web site: http://pushchen.com
//

@implementation PYResponseFormater

+ (PYCommonResponse *) _commonResponse:(NSData *)data forObject:(Class)class
{
	PYCommonResponse *response = [PYCommonResponse object];
	NSObject *_data = [response formatResultWithData:data];
	if ( response.errorNo == 0 ) {
		id<PYResponse> respdata = [class object];
		[respdata getResponseWithData:_data];
		response.data = respdata;
	}
	return response;
}

// @Insert New Response Formater Before This Line@

@end
