//
//  NSString+PYCore.m
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

#import "NSString+PYCore.h"
#import "NSObject+PYCore.h"
#import "PYEncoder.h"

@implementation NSString (PYCore)

// File actions
// Append current string to the end of specified file
- (BOOL)appendToFile:(NSString *)path usingEncoding:(NSStringEncoding)encoding
{
    NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:path];
    if (fh == nil)
        return [self writeToFile:path atomically:YES encoding:encoding error:nil];
    
    [fh truncateFileAtOffset:[fh seekToEndOfFile]];
    NSData *encoded = [self dataUsingEncoding:encoding];
    
    if (encoded == nil) return NO;
    
    [fh writeData:encoded];
    return YES;
}

// Append current string as a line to the end of the specified file
- (BOOL)appendLineToFile:(NSString *)path usingEncoding:(NSStringEncoding)encoding
{
	NSString *_line = [self stringByAppendingFormat:@"\n"];
    NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:path];
    if (fh == nil) {
        return [_line writeToFile:path
                       atomically:YES encoding:encoding error:nil];
    }
    [fh truncateFileAtOffset:[fh seekToEndOfFile]];
    NSData *encoded = [_line dataUsingEncoding:encoding];
    
    if (encoded == nil) return NO;
    
    [fh writeData:encoded];
    return YES;
}

// Get a base64 encoded string from current string
- (NSString *)base64EncodeString
{
    return [PYEncoder encodeBase64:self];
}
// Decode current string as base64 encoded.
- (NSString *)base64DecodeString
{
    return [PYEncoder decodeBase64:self];
}

// Url Encode & Decode of current string
- (NSString *)urlEncodeString
{
    NSString *outputStr =
    (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes
                                  (kCFAllocatorDefault, (CFStringRef)self,
                                   NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                   kCFStringEncodingUTF8)
                                  );
    return outputStr;
}
- (NSString *)urlDecodeString
{
    NSMutableString *outputStr = [NSMutableString stringWithString:self];
    [outputStr replaceOccurrencesOfString:@"+"
                               withString:@" "
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0, [outputStr length])];
    
    return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

// Get the md5 sum of current string
- (NSString *)md5sum
{
    return [PYEncoder md5sum:self];
}

- (id)JSONObject
{
    NSData *_jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *_error = nil;
    id _object = [NSJSONSerialization JSONObjectWithData:_jsonData
                                                 options:NSJSONReadingAllowFragments
                                                   error:&_error];
    if ( _error != nil ) {
        [self raiseExceptionWithMessage:[_error localizedDescription]];
    }
    return _object;
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
