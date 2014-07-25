//
//  PYRequest.h
//  PYNetwork
//
//  Created by Push Chen on 7/23/14.
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

#import <Foundation/Foundation.h>
#import "PYDomainSwitcher.h"

/*
 The api request is an interface for all detail APIs.
 */
@interface PYApiRequest : NSObject
{
    PYDomainSwitcher            *_domainSwitcher;
    NSString                    *_urlString;
    NSDictionary                *_parameters;
    
    // If need domain switcher to combine the url
    BOOL                        _isNeedDomainSwitcher;
    
    // Retry times.
    NSUInteger                  _retriedTimes;
    NSUInteger                  _minimalRetryTimes; // Default is equal to _domainSwticher.count
    NSUInteger                  _maximalRetryTimes; // Default is equal to _domainSwitcher.count
}

+ (NSString *)requestIdentifyWithParameter:(NSDictionary *)parameters;

// Create an api request with full url.
+ (instancetype)requestWithParameters:(NSDictionary *)parameters;

// Before invoking the api, call this method to generate a request object use
// specified domain.
- (NSMutableURLRequest *)generateRequest;

// Retry times
@property (nonatomic, assign)   NSUInteger              minimalRetryTimes;
@property (nonatomic, assign)   NSUInteger              maximalRetryTimes;
@property (nonatomic, readonly) NSUInteger              retriedTimes;

// HTTP 304, default is YES if the same request has been invoked
// The request manager will maintain a cache to log all invocation data.
@property (nonatomic, assign)   BOOL                    containsModifiedSinceFlag;

// Replace the url schema with specified parameters
- (NSString *)formatUrl:(NSString *)url withParameters:(NSDictionary *)parameters;

// Should be overwrite by the sub-class
- (void)initializeDomainSwitcher;

// Set the base url schema
- (void)initializeUrlSchema;

@end

@interface PYApiRequest (Private)

// Not available
- (id)init;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
