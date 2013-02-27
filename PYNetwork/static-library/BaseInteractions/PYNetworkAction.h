//
//  PYNetworkAction.h
//  PYNetwork
//
//  Created by Push Chen on 7/19/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PYNetworkRequest.h"
#import "PYNetworkResponse.h"
#import "PYBaseSocket.h"

@protocol PYNetworkActionDelegate;

typedef PYSocketPeerInfo PYPeerInfo;
typedef enum {
	PYNetworkProcessStageConnecting,
	PYNetworkProcessStageReceive
} PYNetworkProcessStage;

@interface PYNetworkAction : NSObject
{
	PYBaseSocket				*_asyncConnection;
	PYNetworkRequest			*_request;
	PYNetworkResponse			*_response;
	id<PYNetworkActionDelegate>	_owner;
	NSString					*_name;
	NSMutableDictionary			*_userInfo;
}

@property (nonatomic, retain)			PYNetworkRequest			*request;
@property (nonatomic, retain, readonly) PYNetworkResponse			*response;
@property (nonatomic, retain)			id<PYNetworkActionDelegate>	owner;
@property (nonatomic, copy)				NSString					*name;
@property (nonatomic, readonly)			PYPeerInfo					*peerInfo;

+(PYNetworkAction *) actionWithRequest:(PYNetworkRequest *)req 
	owner:(id)owner name:(NSString *)name;

-(id) initWithRequest:(PYNetworkRequest *)req
	owner:(id)owner name:(NSString *)name;

@end

@protocol PYNetworkActionDelegate <NSObject>

@optional
-(void) action:(PYNetworkAction *)action didStartWithData:(NSData *)dataToSend;
-(void) action:(PYNetworkAction *)action didFinishWithResponse:(PYNetworkResponse *)response;
-(void) action:(PYNetworkAction *)action didFailedWithError:(NSError *)error;
-(void) action:(PYNetworkAction *)action didTimedoutOnStage:(PYNetworkProcessStage)stage;

@end

