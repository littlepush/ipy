//
//  PYCoder.h
//  PYCore
//
//  Created by littlepush on 8/28/12.
//  Copyright (c) 2012 PushLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PYCoder : NSObject

+(NSString *) encodeBase64FromData:(const char *)input length:(int)length;
+(NSData *) decodeBase64ToData:(NSString *)input;

+(NSString *) encodeBase64:(NSString *)input;
+(NSString *) decodeBase64:(NSString *)input;

+(NSString *) md5sum:(NSString *)input;

@end
