//
//  PYApiResponse.m
//  PYNetwork
//
//  Created by Push Chen on 7/24/14.
//  Copyright (c) 2014 PushLab. All rights reserved.
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

#import "PYApiResponse.h"

@implementation PYApiResponse

@synthesize errorCode;
@synthesize errorMessage;

@dynamic error;
- (NSError *)error
{
    if ( self.errorCode == 0 ) return nil;
    return [self errorWithCode:(int)self.errorCode message:self.errorMessage];
}

// Override
- (BOOL)parseBodyWithData:(NSData *)data
{
    return NO;
}

@end

@implementation PYApiJSONResponse

- (BOOL)parseBodyWithData:(NSData *)data
{
    NSError *_error;
    id object = [NSJSONSerialization
                 JSONObjectWithData:data
                 options:NSJSONReadingAllowFragments
                 error:&_error];
    if ( _error || object == nil ) {
        self.errorCode = _error.code;
        self.errorMessage = _error.localizedDescription;
        return NO;
    }
    return [self parseBodyWithJSON:object];
}

// Override
- (BOOL)parseBodyWithJSON:(id)jsonObject
{
    return NO;
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
