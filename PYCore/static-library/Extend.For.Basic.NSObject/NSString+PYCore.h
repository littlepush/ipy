//
//  NSString+PYCore.h
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

@interface NSString (PYCore)

// File actions
// Append current string to the end of specified file
- (BOOL)appendToFile:(NSString *)path usingEncoding:(NSStringEncoding)encoding;
// Append current string as a line to the end of the specified file
- (BOOL)appendLineToFile:(NSString *)path usingEncoding:(NSStringEncoding)encoding;

// Get a base64 encoded string from current string
- (NSString *)base64EncodeString;
// Decode current string as base64 encoded.
- (NSString *)base64DecodeString;

// Url Encode & Decode of current string
- (NSString *)urlEncodeString;
- (NSString *)urlDecodeString;

// Get the md5 sum of current string
- (NSString *)md5sum;

// Convert current JSON string to an Objective-C Object.
- (id)JSONObject;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
