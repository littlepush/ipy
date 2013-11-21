//
//  PYNetworkPeerInfo.h
//  PYCore
//
//  Created by Push Chen on 6/11/13.
//  Copyright (c) 2013 PushLab. All rights reserved.
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

#include <sys/socket.h>
#include <unistd.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/ioctl.h>
#include <netinet/tcp.h>

#define PLIB_NETWORK_NOSIGNAL			0
#define PLIB_NETWORK_IOCTL_CALL			ioctl
#define PLIB_NETWORK_CLOSESOCK			close

#define PYNINVALIDATE					(unsigned int)(-1L)

typedef long SOCKET_T;

#ifdef __cplusplsh
extern "C" {
#endif

    /* Translate Domain to IP Address */
    char * PYCDomainToIp( const char * _domain, char * _ip, unsigned int _length );
    NSString * PYNSDomainToIp( NSString *_domain );

    /* Translate Domain to InAddr */
    unsigned int PYCDomainToInAddr( const char * _domain );
    unsigned int PYNSDomainToInAddr( NSString *_domain );
    
#ifdef __cplusplus
}
#endif

@interface PYNetworkPeerInfo : NSObject <NSCoding>

@property (nonatomic, retain) NSString		*peerAddress;
@property (nonatomic, assign) NSUInteger	peerPort;

+ (PYNetworkPeerInfo *)peerInfoWithAddress:(NSString *)address port:(NSUInteger)port;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
