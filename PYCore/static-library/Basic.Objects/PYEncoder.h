//
//  PYEncoder.h
//  PYCore
//
//  Created by Push Chen on 6/10/13.
//  Copyright (c) 2013 PushLab. All rights reserved.
//

/*
 LISENCE FOR IPY
 COPYRIGHT (c) 2013, Push Chen.
 ALL RIGHTS RESERVED.
 
 REDISTRIBUTION AND USE IN SOURCE AND BINARY
 FORMS, WITH OR WITHOUT MODIFICATION, ARE
 PERMITTED PROVIDED THAT THE FOLLOWING CONDITIONS
 ARE MET:
 
 YOU USE IT, AND YOU JUST USE IT!.
 WHY NOT USE THIS LIBRARY IN YOUR CODE TO MAKE
 THE DEVELOPMENT HAPPIER!
 ENJOY YOUR LIFE AND BE FAR AWAY FROM BUGS.
 */

#import <Foundation/Foundation.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <zlib.h>

@interface PYEncoder : NSObject

// Base64 Coder of data
+ (NSString *)encodeBase64FromData:(const char *)input length:(int)length;
+ (NSData *)decodeBase64ToData:(NSString *)input;

// String Coder for base64
+ (NSString *)encodeBase64:(NSString *)input;
+ (NSString *)decodeBase64:(NSString *)input;

// MD5 Sum
+ (NSString *)md5sum:(NSString *)input;

// GZip.
+ (BOOL)zipFile:(NSString *)sourcePath toDest:(NSString *)destPath
          error:(NSError **)error;
+ (BOOL)unzipFile:(NSString *)sourcePath toDest:(NSString *)destPath
            error:(NSError **)error;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
