//
//  PYAdaptor.m
//  PYNetworkScript
//
//  Created by littlepush on 08/26/12.
//  Copyright (c) 2012 PushLab. All rights reserved.
//

#import "PYAdaptor.h"
#import "PYCommonRequest.h"
#import "PYCommonResponse.h"
#import "PYRequestFormater.h"
#import "PYResponseFormater.h"
//#import "PYUser.h"

// The Following code is automatic created by the PYNetwork Script.
// Copyright (c) 2012 PushLab. All rights reserved.
// Connect the author: 
//		Mail: littlepush@gmail.com
//		Twitter: @littlepush
// 		Web site: http://pushchen.com
//
// Default Action
IMPLEMENTATION_ACTIONADAPTER(DefaultAction)
-(void) action:(RemoteAction *)action didFinishWithData:(NSData *)data
{
	NSLog(@"Action Finish WithData");
	NSLog(@"Action: %@", action.name);
	NSString *str = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	NSLog(@"Response: %@", str);

	if ([self.delegate respondsToSelector:@selector(action:didFinishWithData:)])
	[self.delegate action:action didFinishWithData:data];

	id result = nil;
	BOOL exceptionOcurred = NO;

	@try {
		result = [self dataToResult:data];
	}
	@catch (NSException *exception) {
		result = nil;
		exceptionOcurred = YES;
		
		// Notify delegate data convert failed
		if([self.delegate respondsToSelector:@selector(action:didFailWithError:)]){
			NSMutableDictionary *dict = nil;
			dict = [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
			[dict setValue:[NSString stringWithFormat:@"%@<%@>", 
				exception.name, exception.reason]
				forKey:NSLocalizedDescriptionKey];
			
			NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
												 code:0
											 userInfo:dict];
			[self.delegate action:action didFailWithError:error];
		}          
	}

	if (!exceptionOcurred){
		PYCommonResponse *response = result;
		if ( response.errorNo == 0 ) {
			[self tellDelegateAction:action didSucessWithResult:response.data];
		} else {
			// user token invalidate or expired
			// todo...
			/*
			if ( response.errorNo == -14001051 || response.errorNo == -14001052 )
			{
				[SHARED_USER logout];
				return;
			}
			*/
			NSLog(@"failed: [%d]%@", response.errorNo, response.errorMsg);
			if ( [self.delegate respondsToSelector:@selector(action:didFailWithError:)] )
			{
				NSError *_error = [NSError errorWithDomain:@"Validate" 
					code:response.errorNo 
					userInfo:[NSDictionary dictionaryWithObject:response.errorMsg 
							forKey:NSLocalizedDescriptionKey]
					];
				[self.delegate action:action didFailWithError:_error];
			}
		}
	}	
}
END_IMPLEMENTATION

// @Insert New Adaptor Before This Line@

