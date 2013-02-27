//
//  PYNetworkUtility.h
//  PYNetwork
//
//  Created by Push Chen on 7/11/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#ifndef PYNetwork_PYNetworkUtility_h
#define PYNetwork_PYNetworkUtility_h

#include <sys/socket.h>
#include <unistd.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/ioctl.h>
#include <netinet/tcp.h>
#import <PYCore/PYCore.h>

#define PLIB_NETWORK_NOSIGNAL			0
#define PLIB_NETWORK_IOCTL_CALL			ioctl
#define PLIB_NETWORK_CLOSESOCK			close

#define PYNINVALIDATE					(unsigned int)(-1L)

typedef long SOCKET_T;

/* Translate Domain to IP Address */
static inline
char * PYCDomainToIp( const char * _domain, char * _ip, unsigned int _length )
{
	struct hostent * _hostEnt;
	struct in_addr _inAddr;
	char *_addr;
	
	memset( _ip, 0, _length );
	_hostEnt = gethostbyname(_domain);
	if ( _hostEnt == NULL ) return _ip;
	_addr = _hostEnt->h_addr_list[0];
	if ( _addr == NULL ) return _ip;
	memmove(&_inAddr, _addr, 4);
	strcpy(_ip, inet_ntoa(_inAddr));
	
	return _ip;
}

/* Translate Domain to InAddr */
static inline
unsigned int PYCDomainToInAddr( const char * _domain )
{
	/* Get the IP Address of the domain by invoking usp_DomainToIP */
	char _ipAddress[16];
	
	if ( _domain == NULL ) return INADDR_ANY;
	if ( PYCDomainToIp(_domain, _ipAddress, 16)[0] == '\0' ) {
		return PYNINVALIDATE;
	}
	return inet_addr(_ipAddress);
}

static inline
NSString * PYNDomainToIp( NSString *_domain )
{
	if ( [_domain isEqual:[NSNull null]] || [_domain length] == 0 )
		return @"";
	char _ipAddress[16] = {0};
	PYCDomainToIp([_domain cStringUsingEncoding:
		NSUTF8StringEncoding], _ipAddress, 16);
	if ( _ipAddress[0] == '\0' ) return @"";
	return [NSString stringWithFormat:@"%s", _ipAddress];
}

static inline
unsigned int PYNDomainToInAddr( NSString *_domain )
{
	if ( [_domain isEqual:[NSNull null]] || [_domain length] == 0 )
		return PYNINVALIDATE;
	return PYCDomainToInAddr([_domain 
		cStringUsingEncoding:NSUTF8StringEncoding]);
}

// Socket Peer Infomation
@interface PYSocketPeerInfo : NSObject<NSCoding>

@property (nonatomic, retain) NSString		*peerAddress;
@property (nonatomic, assign) NSUInteger	peerPort;

+(PYSocketPeerInfo *) peerInfoWithAddress:(NSString *)address port:(NSUInteger)port;

@end

@interface NSMutableData( Socket )

-(int) appendDataFromSocket:(SOCKET_T)socket;

@end

#endif
