//
//  PYNetworkUtility.m
//  PYNetwork
//
//  Created by Push Chen on 7/11/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "PYNetworkUtility.h"

@implementation PYSocketPeerInfo

#define kPYSO_PI_ADDRESS	@"kPYSO_PI_ADDRESS"
#define kPYSO_PI_PORT		@"kPYSO_PI_PORT"

@synthesize peerAddress, peerPort;

+(PYSocketPeerInfo *)peerInfoWithAddress:(NSString *)address port:(NSUInteger)port
{
	PYSocketPeerInfo *peerInfo = [[[PYSocketPeerInfo alloc] init] autorelease];
	peerInfo.peerAddress = address;
	peerInfo.peerPort = port;
	
	return peerInfo;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if ( self ) {
		self.peerAddress	= [aDecoder decodeObjectForKey:kPYSO_PI_ADDRESS];
		self.peerPort		= [aDecoder decodeIntForKey:kPYSO_PI_PORT];
	}
	return self;
}

-(void) encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:peerAddress	forKey:kPYSO_PI_ADDRESS];
	[aCoder encodeInt:peerPort			forKey:kPYSO_PI_PORT];
}

-(NSString *)description
{
	NSString *_string = [NSString stringWithFormat:@"%@:%u", peerAddress, peerPort];
	return _string;
}

@end

@implementation NSMutableData( Socket )

-(int) appendDataFromSocket:(SOCKET_T)socket
{
	int retCode = 0;
	char block[512] = {0};
	
	retCode = recv(socket, block, 512, 0);
	if ( retCode > 0 ) {
		[self appendBytes:block length:retCode];
	}
	return retCode;
}

@end

