//
//  PYEncoder.m
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

#import "PYEncoder.h"
#import "NSObject+PYCore.h"
#import <CommonCrypto/CommonDigest.h>

@implementation PYEncoder
// Base64 Coder of data
+ (NSString *)encodeBase64FromData:(const char *)input length:(int)length
{
	int wrapWidth = 0;
    const char lookup[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    
    long long inputLength = length;
    const unsigned char *inputBytes = (const unsigned char *)input;
    
    long long maxOutputLength = (inputLength / 3 + 1) * 4;
    maxOutputLength += wrapWidth? (maxOutputLength / wrapWidth) * 2: 0;
    unsigned char *outputBytes = (unsigned char *)malloc(maxOutputLength);
    
    long long i;
    long long outputLength = 0;
    for (i = 0; i < inputLength - 2; i += 3)
    {
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0xFC) >> 2];
        outputBytes[outputLength++] = lookup[((inputBytes[i] & 0x03) << 4) | ((inputBytes[i + 1] & 0xF0) >> 4)];
        outputBytes[outputLength++] = lookup[((inputBytes[i + 1] & 0x0F) << 2) | ((inputBytes[i + 2] & 0xC0) >> 6)];
        outputBytes[outputLength++] = lookup[inputBytes[i + 2] & 0x3F];
        
        //add line break
        if (wrapWidth && (outputLength + 2) % (wrapWidth + 2) == 0)
        {
            outputBytes[outputLength++] = '\r';
            outputBytes[outputLength++] = '\n';
        }
    }
    
    //handle left-over data
    if (i == inputLength - 2)
    {
        // = terminator
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0xFC) >> 2];
        outputBytes[outputLength++] = lookup[((inputBytes[i] & 0x03) << 4) | ((inputBytes[i + 1] & 0xF0) >> 4)];
        outputBytes[outputLength++] = lookup[(inputBytes[i + 1] & 0x0F) << 2];
        outputBytes[outputLength++] =   '=';
    }
    else if (i == inputLength - 1)
    {
        // == terminator
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0xFC) >> 2];
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0x03) << 4];
        outputBytes[outputLength++] = '=';
        outputBytes[outputLength++] = '=';
    }
    
    if (outputLength >= 4)
    {
        //truncate data to match actual output length
        outputBytes = realloc(outputBytes, outputLength);
        return __AUTO_RELEASE([[NSString alloc]
                               initWithBytesNoCopy:outputBytes
                               length:outputLength
                               encoding:NSASCIIStringEncoding
                               freeWhenDone:YES]);
    }
    else if (outputBytes)
    {
        free(outputBytes);
    }
    return nil;
}

+ (NSData *)decodeBase64ToData:(NSString *)input
{
    const char lookup[] =
    {
        99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99,
        99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99,
        99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 62, 99, 99, 99, 63,
        52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 99, 99, 99, 99, 99, 99,
        99,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
        15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 99, 99, 99, 99, 99,
        99, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
        41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 99, 99, 99, 99, 99
    };
    
    NSData *inputData = [input dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    long long inputLength = [inputData length];
    const unsigned char *inputBytes = [inputData bytes];
    
    long long maxOutputLength = (inputLength / 4 + 1) * 3;
    NSMutableData *outputData = [NSMutableData dataWithLength:maxOutputLength];
    unsigned char *outputBytes = (unsigned char *)[outputData mutableBytes];
    
    int accumulator = 0;
    long long outputLength = 0;
    unsigned char accumulated[] = {0, 0, 0, 0};
    for (long long i = 0; i < inputLength; i++)
    {
        unsigned char decoded = lookup[inputBytes[i] & 0x7F];
        if (decoded != 99)
        {
            accumulated[accumulator] = decoded;
            if (accumulator == 3)
            {
                outputBytes[outputLength++] = (accumulated[0] << 2) | (accumulated[1] >> 4);
                outputBytes[outputLength++] = (accumulated[1] << 4) | (accumulated[2] >> 2);
                outputBytes[outputLength++] = (accumulated[2] << 6) | accumulated[3];
            }
            accumulator = (accumulator + 1) % 4;
        }
    }
    
    //handle left-over data
    if (accumulator > 0) outputBytes[outputLength] = (accumulated[0] << 2) | (accumulated[1] >> 4);
    if (accumulator > 1) outputBytes[++outputLength] = (accumulated[1] << 4) | (accumulated[2] >> 2);
    if (accumulator > 2) outputLength++;
    
    //truncate data to match actual output length
    outputData.length = outputLength;
    return outputLength ? outputData: nil;
}

// String Coder for base64
+ (NSString *)encodeBase64:(NSString *)input
{
	NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    return [PYEncoder encodeBase64FromData:data.bytes length:data.length];
}
+ (NSString *)decodeBase64:(NSString *)input
{
    NSData *data = [PYEncoder decodeBase64ToData:input];
    if (data)
    {
        return __AUTO_RELEASE([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }
    return nil;
}

// MD5 Sum
+ (NSString *)md5sum:(NSString *)input
{
    const char *cStr = [input UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
