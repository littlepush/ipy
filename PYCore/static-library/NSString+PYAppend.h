//
//  NSString+PYAppend.h
//  PYCore
//
//  Created by Push Chen on 7/17/12.
//  Copyright (c) 2012 PushLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (PYAppend)

@property (nonatomic, readonly)	BOOL		isValidateEmailAddress;

/* Write a string to the end of the file */
- (BOOL)appendToFile:(NSString *)path usingEncoding:(NSStringEncoding)encoding;

/* write a line to the end of the file */
- (BOOL)appendLineToFile:(NSString *)path usingEncoding:(NSStringEncoding)encoding;

/* Encoding use base64 */
- (NSString *) base64EncodeString;
- (NSString *) base64DecodeString;

- (NSString *) md5sum;

- (NSString	*) reformTelphone;

- (NSString *) urlEncodeString;
- (NSString *) urlDecodeString;

@end
