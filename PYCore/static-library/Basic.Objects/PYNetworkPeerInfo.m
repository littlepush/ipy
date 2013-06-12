//
//  PYNetworkPeerInfo.m
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

#import "PYNetworkPeerInfo.h"
#import "NSObject+PYCore.h"

#ifdef __cplusplus
extern "C" {
#endif
    
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

    NSString * PYNDomainToIp( NSString *_domain )
    {
        if ( [_domain isEqual:[NSNull null]] || [_domain length] == 0 )
            return @"";
        char _ipAddress[16] = {0};
        PYCDomainToIp([_domain UTF8String], _ipAddress, 16);
        if ( _ipAddress[0] == '\0' ) return __AUTO_RELEASE([_domain copy]);
        return [NSString stringWithFormat:@"%s", _ipAddress];
    }
    
    unsigned int PYNDomainToInAddr( NSString *_domain )
    {
        if ( [_domain isEqual:[NSNull null]] || [_domain length] == 0 )
            return PYNINVALIDATE;
        return PYCDomainToInAddr([_domain
                                  cStringUsingEncoding:NSUTF8StringEncoding]);
    }

#ifdef __cplusplus
}
#endif

#define kPYSO_PI_ADDRESS	@"kPYSO_PI_ADDRESS"
#define kPYSO_PI_PORT		@"kPYSO_PI_PORT"

@implementation PYNetworkPeerInfo
@synthesize peerAddress, peerPort;

+ (PYNetworkPeerInfo *)peerInfoWithAddress:(NSString *)address port:(NSUInteger)port
{
	PYNetworkPeerInfo *peerInfo = [PYNetworkPeerInfo object];
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
	NSString *_string = [NSString stringWithFormat:@"<%@:%p> %@:%u",
                         NSStringFromClass([self class]), self,
                         peerAddress, peerPort];
	return _string;
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
