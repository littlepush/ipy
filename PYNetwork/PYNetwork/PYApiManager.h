//
//  PYApiManager.h
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

#import <Foundation/Foundation.h>
#import <PYData/PYData.h>
#import "PYApiRequest.h"
#import "PYApiResponse.h"

typedef NS_ENUM(NSInteger, PYApiErrorCode){
    PYApiSuccess                            = 0,
    PYApiErrorInvalidateRequestClass        = 101,
    PYApiErrorFailedToCreateRequestObject,
    PYApiErrorInvalidateResponseClass,
    PYApiErrorFailedToCreateResponseObject,
    PYApiErrorReachMaxRetryTimes,
    PYApiErrorInvalidateHttpStatus,
    PYApiErrorFailedToParseResponse
};

@interface PYApiManager : NSObject
{
    // The async operation queue.
    NSOperationQueue            *_apiOpQueue;
    // API last request info cache.
    PYGlobalDataCache           *_apiCache;
}

// Get specified api's last request time.
+ (NSString *)lastRequestTimeForApi:(NSString *)identifier;

// Get the error message in detail
+ (NSString *)errorMessageWithCode:(PYApiErrorCode)code;

@end

typedef void (^PYApiActionInit)(PYApiRequest *);
typedef void (^PYApiActionSuccess)(id);
typedef void (^PYApiActionFailed)(NSError *);

@interface PYApiManager (Private)

+ (void)invokeApi:(NSString *)apiname
   withParameters:(NSDictionary *)parameters
           onInit:(PYApiActionInit)init
        onSuccess:(PYApiActionSuccess)success
         onFailed:(PYApiActionFailed)failed;

@end

#define PY_CUSTOMIZED_API(api_name, req_base_class, resp_base_class, ...)   \
extern NSString *const API##api_name;                                       \
@interface api_name##Request : req_base_class @end                          \
@interface api_name##Response : resp_base_class                             \
__VA_ARGS__                                                                 \
@end                                                                        \
@interface PYApiManager (api_name)                                          \
+ (void)invoke##api_name##WithParameters:(NSDictionary *)params             \
                                  onInit:(PYApiActionInit)init              \
                               onSuccess:(PYApiActionSuccess)success        \
                                onFailed:(PYApiActionFailed)failed;         \
@end

#define PY_API(api_name, ...)                                               \
    PY_CUSTOMIZED_API(api_name, PYApiRequest, PYApiResponse, ##__VA_ARGS__)
#define PY_JSON_API(api_name, ...)                                          \
    PY_CUSTOMIZED_API(api_name, PYApiRequest, PYApiJSONResponse, ##__VA_ARGS__)


#define PY_API_IMPL(api_name)                           \
NSString *const API##api_name = @#api_name;             \
@implementation PYApiManager (api_name)                 \
+ (void)invoke##api_name##WithParameters:(NSDictionary *)params\
                                  onInit:(PYApiActionInit)init \
                               onSuccess:(PYApiActionSuccess)success\
                                onFailed:(PYApiActionFailed)failed{\
    [PYApiManager                                       \
     invokeApi:@#api_name                               \
withParameters:params                                   \
        onInit:init                                     \
     onSuccess:success                                  \
      onFailed:false];                                  \
}                                                       \
@end
#define PY_BEGIN_OVERWRITE_REQUEST(api_name)            \
@implementation api_name##Request
#define PY_SET_DOMAINSWITCHER(...)                      \
- (void)initializeDomainSwitcher { _domainSwitcher = __VA_ARGS__; }
#define PY_SET_URLSCHEMA(...)                           \
- (void)initializeUrlSchema { _urlString = __VA_ARGS__; }
#define PY_SET_FORMATER(...)                            \
- (NSString *)formatUrl:(NSString *)url                 \
         withParameters:(NSDictionary *)parameters {    \
    __VA_ARGS__;                                        \
}
#define PY_END_OVERWRITE_REQUEST                    @end
#define PY_BEGIN_OVERWRITE_RESPONSE(api_name)           \
@implementation api_name##Response
#define PY_END_OVERWRITE_RESPONSE                   @end

#define PY_API_COMMON_IMPL(api_name, url)               \
PY_API_IMPL(api_name)                                   \
PY_BEGIN_OVERWRITE_REQUEST(api_name)                    \
PY_SET_URLSCHEMA( url )                                 \
PY_END_OVERWRITE_REQUEST                                \
PY_BEGIN_OVERWRITE_RESPONSE(api_name)                   \
- (BOOL)parseBodyWithData:(NSData *)data

#define PY_JSON_API_COMMON_IMPL(api_name, url)          \
PY_API_IMPL(api_name)                                   \
PY_BEGIN_OVERWRITE_REQUEST(api_name)                    \
PY_SET_URLSCHEMA( url )                                 \
PY_END_OVERWRITE_REQUEST                                \
PY_BEGIN_OVERWRITE_RESPONSE(api_name)                   \
- (BOOL)parseBodyWithJSON:(id)jsonObject

#define PY_END_API                                  @end

PY_JSON_API
(
 TestApi,   // Api Name
 // Response objects
 @property (nonatomic, strong)  NSArray *resultList;
 @property (nonatomic, copy)    NSString *objectIdentifier;
)

// @littlepush
// littlepush@gmail.com
// PYLab
