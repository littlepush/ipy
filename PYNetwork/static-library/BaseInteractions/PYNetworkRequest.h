//
//  PYNetworkRequest.h
//  PYNetwork
//
//  Created by Push Chen on 7/19/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PYNetworkUtility.h"

@protocol PYNetworkRequest <NSObject>


-(NSData *) serializedData;


@property (nonatomic, retain) PYSocketPeerInfo	*peerInfo;
@property (nonatomic, assign) NSUInteger		timeOut;

@end

@interface PYNetworkRequest : NSObject < PYNetworkRequest >
{
	
}

@end
