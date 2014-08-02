//
//  PYRequest.m
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

#import "PYApiRequest.h"

@interface PYApiRequest (Internal)

// Generate the request url
- (NSString *)_generateRequestUrl;

@end

@implementation PYApiRequest

+ (NSString *)requestIdentifyWithParameter:(NSDictionary *)parameters
{
    //return [[self class] requestWithParameters:parameters];
    NSString *_api_name = NSStringFromClass([self class]);
    NSMutableString *_paramString = [NSMutableString stringWithString:_api_name];
    for ( NSString *_key in parameters ) {
        NSString *_value = parameters[_key];
        [_paramString appendString:[NSString stringWithFormat:@";%@=%@", _key, _value]];
    }
    NSString *_urlIdentify = [_paramString md5sum];
    return _urlIdentify;
}

+ (instancetype)requestWithParameters:(NSDictionary *)parameters
{
    PYApiRequest *_req = [[self class] object];
    _req->_parameters = [parameters copy];
    return _req;
}

- (NSString *)_generateRequestUrl
{
    NSString *_url = nil;
    
    if ( _isNeedDomainSwitcher == NO ) {
        _url = [_urlString copy];
    } else {
        _url = [_domainSwitcher.selectedDomain stringByAppendingString:_urlString];
    }
    return _url;
}

@synthesize retriedTimes = _retriedTimes;
@synthesize maximalRetryTimes = _maximalRetryTimes;
@synthesize minimalRetryTimes = _minimalRetryTimes;

// Before invoking the api, call this method to generate a request object use
// specified domain.
- (NSMutableURLRequest *)generateRequest
{
    NSString *_requestUrl;
    if ( _isNeedDomainSwitcher ) {
        if ( _domainSwitcher.isAvailable == NO ) return nil;
    }
    if ( _retriedTimes >= _maximalRetryTimes ) return nil;
    _requestUrl = [self _generateRequestUrl];
    _retriedTimes += 1;
    if ( _isNeedDomainSwitcher ) {
        [_domainSwitcher next];
    }
    _requestUrl = [self formatUrl:_requestUrl withParameters:_parameters];
    return [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_requestUrl]];
}

// HTTP 304, default is YES if the same request has been invoked
// The request manager will maintain a cache to log all invocation data.
@synthesize containsModifiedSinceFlag;

// Should be overwrite by the sub-class
- (void)initializeDomainSwitcher
{
    _domainSwitcher = PYDefaultDomainSwitcher;
}

// Should be overwrite by the sub-class
- (void)initializeUrlSchema
{
    _urlString = @"demo/url/string/<param_key1>/<param_key2>";
}

// Replace the url schema with specified parameters
- (NSString *)formatUrl:(NSString *)url withParameters:(NSDictionary *)parameters
{
    NSString *_url = [url copy];
    for ( NSString *_key in parameters ) {
        NSString *_value = parameters[_key];
        if ( [_value isKindOfClass:[NSString class]] == NO ) continue;
        _url = [_url
                stringByReplacingOccurrencesOfString:
                [NSString stringWithFormat:@"<%@>", _key]
                withString:[_value urlEncodeString]];
    }
    return _url;
}

@end

@implementation PYApiRequest (Private)

- (id)init
{
    self = [super init];
    if ( self ) {
        self.containsModifiedSinceFlag = YES;
        [self initializeDomainSwitcher];
        [self initializeUrlSchema];
        _isNeedDomainSwitcher = ([_urlString rangeOfString:@"://"].location == NSNotFound);
        _retriedTimes = 0;
        if ( _domainSwitcher == nil || [_domainSwitcher.domainList count] == 0 ) {
            _minimalRetryTimes = 1;
            _maximalRetryTimes = 1;
        } else {
            _minimalRetryTimes = [_domainSwitcher.domainList count];
            _maximalRetryTimes = _minimalRetryTimes;
        }
    }
    return self;
}

@end

@implementation PYApiPostRequest

- (NSMutableURLRequest *)generateRequest
{
    NSMutableURLRequest *_req = [super generateRequest];
    if ( _req == nil ) return nil;
    [_req setHTTPMethod:@"POST"];
    return _req;
}

@end
// @littlepush
// littlepush@gmail.com
// PYLab
