//
//  PYApiManager.m
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

#import "PYApiManager.h"

static PYApiManager *_g_apiManager;

@interface PYApiManager (Internal)
// Singleton interface.
+ (instancetype)shared;
// The operation queue.
@property (nonatomic, readonly) NSOperationQueue        *apiOpQueue;

// Update the modified time
- (void)updateModifiedTime:(NSString *)modifyInfo forIdentifier:(NSString *)reqIdentifier;

// Generate error object
+ (NSError *)apiErrorWithCode:(PYApiErrorCode)code;

@end

@implementation PYApiManager

PYSingletonAllocWithZone(_g_apiManager)
PYSingletonDefaultImplementation
+ (instancetype)shared
{
    PYSingletonLock
    if ( _g_apiManager == nil ) {
        _g_apiManager = [PYApiManager object];
    }
    return _g_apiManager;
    PYSingletonUnLock
}

- (id)init
{
    self = [super init];
    if ( self ) {
        _apiOpQueue = [NSOperationQueue object];
        [_apiOpQueue setMaxConcurrentOperationCount:10];
        
        // Initialize the api cache to store the request info.
        _apiCache = [PYGlobalDataCache gdcWithIdentify:@"com.ipy.network.apicache"];
    }
    return self;
}

+ (NSString *)lastRequestTimeForApi:(NSString *)identifier
{
    PYSingletonLock
    return [[PYApiManager shared]->_apiCache objectForKey:identifier];
    PYSingletonUnLock
}

- (void)updateModifiedTime:(NSString *)modifyInfo forIdentifier:(NSString *)reqIdentifier
{
    PYSingletonLock
    [_apiCache setObject:modifyInfo forKey:reqIdentifier];
    PYSingletonUnLock
}

+ (NSString *)errorMessageWithCode:(PYApiErrorCode)code
{
    static NSString *_errorMsg[] = {
        @"Success",
        @"No such API Request Object",
        @"Failed to create request object",
        @"No such API Response Object",
        @"Failed to create response object",
        @"Reach max retry times",
        @"Invalidate HTTP status code, except 200-399"
    };
    if ( code == PYApiSuccess ) return _errorMsg[0];
    if ( code >= PYApiErrorInvalidateRequestClass && code <= PYApiErrorInvalidateHttpStatus ) {
        return _errorMsg[code - 100];
    }
    return @"Unknow code";
}

+ (NSError *)apiErrorWithCode:(PYApiErrorCode)code
{
    return [self errorWithCode:code message:[PYApiManager errorMessageWithCode:code]];
}

+ (void)invokeApi:(NSString *)apiname
   withParameters:(NSDictionary *)parameters
           onInit:(PYApiActionInit)init
        onSuccess:(PYApiActionSuccess)success
         onFailed:(PYApiActionFailed)failed
{
    NSString *_requestClassName = [apiname stringByAppendingString:@"Request"];
    Class _requestClass = NSClassFromString(_requestClassName);
    if ( _requestClass == nil ) {
        if ( failed ) failed( [PYApiManager apiErrorWithCode:PYApiErrorInvalidateRequestClass] );
        return;
    }
    PYApiRequest *_req = [_requestClass requestWithParameters:parameters];
    if ( _req == nil ) {
        if ( failed ) failed( [PYApiManager apiErrorWithCode:PYApiErrorFailedToCreateRequestObject] );
        return;
    }
    NSString *_responseClassName = [apiname stringByAppendingString:@"Response"];
    Class _responseClass = NSClassFromString(_responseClassName);
    if ( _responseClassName == nil ) {
        if ( failed ) failed( [PYApiManager apiErrorWithCode:PYApiErrorInvalidateResponseClass] );
        return;
    }
    PYApiResponse *_resp = [_responseClass object];
    if ( _resp == nil ) {
        if ( failed ) failed( [PYApiManager apiErrorWithCode:PYApiErrorFailedToCreateResponseObject] );
        return;
    }
    
    // Initialize the request object
    if ( init ) {
        init( _req );
    }
    
    NSBlockOperation *_workingOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSString *_requestIdentifier = [[_req class] requestIdentifyWithParameter:parameters];
        do {
            NSMutableURLRequest *_urlReq = [_req generateRequest];
            if ( _urlReq == nil ) {
                if ( failed ) failed( [PYApiManager apiErrorWithCode:PYApiErrorReachMaxRetryTimes] );
                break;
            }
            if ( _req.containsModifiedSinceFlag ) {
                NSString *_lastModifyTimeInfo =
                [PYApiManager lastRequestTimeForApi:_requestIdentifier];
                if ( [_lastModifyTimeInfo length] > 0 ) {
                    [_urlReq addValue:_lastModifyTimeInfo
                   forHTTPHeaderField:@"Last-Modified-Since"];
                }
            }
            NSError *_error;
            NSHTTPURLResponse *_response;
            NSData *_data = [NSURLConnection
                             sendSynchronousRequest:_urlReq
                             returningResponse:&_response
                             error:&_error];
            if ( _error ) { continue; }
            
            if ( _response.statusCode >= 400 ) {
                if ( failed ) failed( [PYApiManager apiErrorWithCode:PYApiErrorInvalidateHttpStatus] );
                break;
            }
            
            // Update modified time
            NSString *_lastModifiedDateString = @"";
            NSString *_date = @"";
            for ( NSString *_headKey in _response.allHeaderFields ) {
                if ( [[_headKey lowercaseString] isEqualToString:@"last-modified"] ) {
                    _lastModifiedDateString = [_response.allHeaderFields objectForKey:_headKey];
                    //continue;
                }
                if ( [[_headKey lowercaseString] isEqualToString:@"date"] ) {
                    _date = [_response.allHeaderFields objectForKey:_headKey];
                    //continue;
                }
                if ( [_lastModifiedDateString length] > 0 && [_date length] > 0 ) break;
            }
            if ( [_date length] > 0 ) {
                _lastModifiedDateString = _date;
            }
            if ( [_lastModifiedDateString length] > 0 ) {
                [[PYApiManager shared]
                 updateModifiedTime:_lastModifiedDateString
                 forIdentifier:_requestIdentifier];
            }

            // Parse the data
            if ( [_resp parseBodyWithData:_data] ) {
                if ( success ) success ( _resp );
            } else {
                if ( failed ) failed( _resp.error );
            }
            break;
        } while ( true );
    }];
    
    [[PYApiManager shared].apiOpQueue addOperation:_workingOperation];
}

@end

// The following test api object will be convert to Macro
@implementation TestApiRequest

- (void)initializeDomainSwitcher
{
    _domainSwitcher = PYDefaultDomainSwitcher;
}
- (void)initializeUrlSchema
{
    _urlString = @"/api/login/username/<username>/password/<password>";
}
- (NSString *)formatUrl:(NSString *)url withParameters:(NSDictionary *)parameters
{
    return [super formatUrl:url withParameters:parameters];
}

@end

@implementation TestApiResponse

// Do something

@end

@implementation PYApiManager (TestApi)

+ (void)invokeTestApiWithParameters:(NSDictionary *)params
                             onInit:(PYApiActionInit)init
                          onSuccess:(PYApiActionSuccess)success
                           onFailed:(PYApiActionFailed)failed
{
    [PYApiManager invokeApi:@"TestApi" withParameters:params onInit:init onSuccess:success onFailed:false];
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
