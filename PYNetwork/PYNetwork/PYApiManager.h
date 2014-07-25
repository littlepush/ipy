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
    PYApiErrorInvalidateHttpStatus
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

// The following test api object will be convert to Macro
@interface TestApiRequest : PYApiRequest
@end
@interface TestApiResponse : PYApiResponse
@property (nonatomic, strong)   NSMutableArray      *result;
@end
@interface PYApiManager (TestApi)
+ (void)invokeTestApiWithParameters:(NSDictionary *)params
                             onInit:(PYApiActionInit)init
                          onSuccess:(PYApiActionSuccess)success
                           onFailed:(PYApiActionFailed)failed;
@end

// @littlepush
// littlepush@gmail.com
// PYLab
