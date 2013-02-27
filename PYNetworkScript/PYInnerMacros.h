//
//  PYInnerMacros.h
//  PYNetworkScript
//
//  Created by littlepush on 08/26/12.
//  Copyright (c) 2012 PushLab. All rights reserved.
//

#ifndef PYNetworkScript_PYInnerMacros_H
#define PYNetworkScript_PYInnerMacros_H

#import "JSONKit.h"

#ifdef NEED_SNS_SUPPORT
// Common Request
typedef enum {
	PYSNSSina,		// https://api.weibo.com/oauth2/authorize
	PYSNSTencent,	//
	PYSNSRenren		//
} PYSNSAuthSite;
#endif

/* Common Request */
@protocol PYRequest <NSObject>
@required
@property (nonatomic, copy)		NSString		*token;
#ifdef NEED_SNS_SUPPORT
@property (nonatomic, copy)		NSString		*appSecretKey;
@property (nonatomic, assign)	PYSNSAuthSite	authSite;
#endif
@end

#ifdef NEED_SNS_SUPPORT
#define PY_REQUEST_IMPLEMENTATION			\
@synthesize	token, appSecretKey, authSite;
#define PY_REQUEST_DEALLOC					\
	self.token = nil;						\
	self.appSecretKey = nil;
#else
#define PY_REQUEST_IMPLEMENTATION			\
@synthesize token;
#define PY_REQUEST_DEALLOC					\
	self.token = nil;
#endif

/* Create a common request object */
#ifdef NEED_SNS_SUPPORT
static inline
id<PYRequest> PYCommonRequestMake(Class _reqClass, PYSNSAuthSite _authSite) {
	id<PYRequest> _req = (id<PYRequest>)[_reqClass object];
	[_req setAuthSite:_authSite];
	[_req setToken:@""];
	[_req setAppSecretKey:@""];
	//__PY_NOT_IMPLEMENTATION__;
	return _req;
}
#else
static inline
id<PYRequest> PYCommonRequestMake(Class _reqClass) {
	id<PYRequest> _req = (id<PYRequest>)[_reqClass object];
	[_req setToken:SHARED_USER.token];
	return _req;
}
#endif

#define PY_DELCARE_REQUEST_BEAN( _actName, _bean )	\
@interface _actName##Request : _bean<PYRequest>
#define PY_DECLARE_REQUEST( _actName )				\
	PY_DECLARE_REQUEST_BEAN( _actName, NSObject )
#define PY_END_DECLARE_REQUEST						\
@end

#define PY_IMPLEMENTATION_REQUEST( _actName )		\
@implementation _actName##Request					\
PY_REQUEST_IMPLEMENTATION
#define PY_END_IMPLEMENTATION_REQUEST				\
@end

/* Common Response */
@interface PYCommonResponse : NSObject

@property (nonatomic, assign)	NSInteger		errorNo;
@property (nonatomic, copy)		NSString		*errorMsg;
@property (nonatomic, retain)	id				data;

// Format result data
-(NSObject *) formatResultWithData:(NSData *)jsonData;

@end

/* Normal response content protocol */
@protocol PYResponse <NSObject>
/* usually the data is a JSON dictionayr */
-(void) getResponseWithData:(NSObject *)data;
@end

#define PY_DECLARE_RESPONSE( _actName, _bean )			\
@interface _actName##Response : _bean < PYResponse >
#define PY_END_DECLARE_RESPONSE							\
@end

#define PY_IMPLEMENTATION_RESPONSE( _actName )			\
@implementation _actName##Response
#define PY_END_IMPLEMENTATION_RESPONSE					\
@end

/* Formater */
// Request
#define PY_DECLARE_REQUEST_FORMATER( _actName )					\
	+(ASIHTTPRequest *) _actName##RequestFormater:(id)request
#define PY_IMPLEMENTATION_REQUEST_FORMATER( _actName )			\
	PY_DECLARE_REQUEST_FORMATER( _actName ) {					\
		_actName##Request *_req = (_actName##Request *)request;
#define PY_END_REQUEST_FORMATER									\
	}

// Response
#define PY_DECLARE_RESPONSE_FORMATER( _actName )				\
	+(PYCommonResponse *) _actName##ResponseFormater:(NSData *)data
#define PY_IMPLEMENTATION_RESPONSE_FORMATER( _actName )			\
	PY_DECLARE_RESPONSE_FORMATER( _actName ) {					\
    return [PYResponseFormater _commonResponse:data				\
		forObject:[_actName##Response class]];
#define PY_END_RESPONSE_FORMATER			}

/* Action Delegate */
/* Declare of the response */
#define PY_DECLARE_ACTION_DELEGATE(_actName)					\
	-(void) action:(RemoteAction *)action						\
		did##_actName:(_actName##Response *)result

/* Manager */
#define PY_DECLARE_ACTION_CREATER(_actName)						\
	-(RemoteAction *) create##_actName:(id)param				\
		owner:(id<HttpActionResponse>)owner
#define PY_IMPLEMENTATION_ACTION_CREATER(_actName)				\
	PY_DECLARE_ACTION_CREATER(_actName) {						\
		return [self ASIActionWithRequest:param owner:owner		\
			actionName:_actName];								\
	}
/* Action Adaptor */
#define PY_IMPLEMENTATION_ACTION_ADAPTER( _actName )			\
IMPLEMENTATION_ACTIONADAPTER(_actName)							\
+(id) generateHttpRequest:(id)param								\
{																\
    return [PYRequestFormater _actName##RequestFormater:param];	\
}																\
-(id) dataToResult:(NSData *)data 								\
{																\
    return [PYResponseFormater _actName##ResponseFormater:data];\
}																\
-(void) tellDelegateAction:(RemoteAction *)action 				\
	didSucessWithResult:(id)result 								\
{																\
if ( [self.delegate respondsToSelector:							\
		@selector(action:did##_actName:)] ) {					\
    [self.delegate action:action did##_actName:result];			\
}																\
}																\
END_IMPLEMENTATION

#endif