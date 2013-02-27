//
//  PYNetworkActionManager_Internal.h
//  PYNetwork
//
//  Created by Push Chen on 7/23/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "PYNetworkActionManager.h"
#import "PYBaseSocket.h"

typedef enum {
	PYNetworkActionSuccessed,
	PYNetworkActionWriteFailed,
	PYNetworkActionReadTimeOut
} PYNetworkActionStatus;

typedef void (^NetworkAction)(PYBaseSocket *asyncConnection);
typedef void (^NetworkTimedOut)(void);
typedef void (^NetworkError)(NSError *error);

@interface PYNetworkActionManager (Internal)

-(void) getConnectionToPeer:(PYSocketPeerInfo *)peer 
	timedout:(NetworkTimedOut)tblock connected:(NetworkAction)cblock
	error:(NetworkError)eblock;

@end
