//
//  PYBaseSocket.h
//  PYNetwork
//
//  Created by Push Chen on 7/11/12.
//  Copyright (c) 2012 PushLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PYNetworkUtility.h"

typedef enum {
	PYSocketStatusEmpyt = 0,
	PYSocketStatusIdle,
	PYSocketStatusConnecting,
	PYSocketStatusBinding,
	PYSocketStatusClosing,
	PYSocketStatusWriting,
	PYSocketStatusReading,
	PYSocketStatusTimeout,
	PYSocketStatusError
} PYSocketStatus;

static inline
NSString * PYSocketStatusDescription(PYSocketStatus status)
{
	switch (status) {
	case PYSocketStatusEmpyt: return @"Empty";
	case PYSocketStatusIdle: return @"Idle";
	case PYSocketStatusConnecting: return @"Connecting";
	case PYSocketStatusBinding: return @"Binding";
	case PYSocketStatusClosing: return @"Closing";
	case PYSocketStatusWriting: return @"Writing";
	case PYSocketStatusReading: return @"Reading";
	case PYSocketStatusTimeout: return @"Timeout";
	case PYSocketStatusError: return @"Error";
	};
}

typedef enum {
	PYSocketProcessStatusOK = 0,
	PYSocketProcessStatusError,
	PYSocketProcessStatusTimeOut
} PYSocketProcessStatus;

typedef enum {
	PYSocketReceiveStatusDone = 0,
	PYSocketReceiveStatusIlleage,
	PYSocketReceiveStatusUnfinished
} PYSocketReceiveStatus;

enum { 
	PYSO_ADDR_LENGTH = 64
};

typedef PYSocketReceiveStatus (^PYSocketRecvBlock)(NSData * partialData);
typedef void (^PYSocketTimeout)(void);
typedef void (^PYSocketWriteBlock)(int writenBytes);
typedef void (^PYSocketSuccess)(void);
typedef void (^PYSocketError)(NSError *error);

@protocol PYBaseSocketDelegate;

@interface PYBaseSocket : NSObject
{
	SOCKET_T					_socket;
	BOOL						_beBound;
	BOOL						_beBoundCloseOnDone;
	PYSocketPeerInfo			*_remotePeerInfo;
	PYSocketPeerInfo			*_localPeerInfo;
	
	// Status
	PYSocketStatus				_lastSocketStatus;
	PYSocketStatus				_currentSocketStatus;
	
	NSDate						*_idleTimer;
	
	NSError						*_lastError;
	
	id<PYBaseSocketDelegate>	_delegate;
}

@property (nonatomic, readonly) BOOL isSocketBeBound;

@property (nonatomic, readonly) PYSocketPeerInfo	*remotePeerInfo;
@property (nonatomic, readonly) PYSocketPeerInfo	*localPeerInfo;

@property (nonatomic, assign, setter = setWriteTimeout:) NSUInteger socketWriteTimeout;

@property (nonatomic, assign, setter = setReusable: ) BOOL isSocketReusable;
@property (nonatomic, assign, setter = setSendDelay: ) BOOL isSocketSendDelay;

@property (nonatomic, assign, setter = setWriteBufferSize:) NSUInteger socketWriteBufferSize;
@property (nonatomic, assign, setter = setReadBufferSize:) NSUInteger socketReadBufferSize;

@property (nonatomic, assign, setter = setLingerTime:) NSUInteger socketLingerTime;

@property (nonatomic, readonly ) BOOL	isSocketHasDataToRead;
@property (nonatomic, readonly ) BOOL	isSocketHasDataToWrite;
@property (nonatomic, readonly ) BOOL	isSocketConnected;

@property (nonatomic, readonly ) NSUInteger socketIdleTime;

@property (nonatomic, readonly ) NSError	*lastError;

@property (nonatomic, assign) id<PYBaseSocketDelegate>	delegate;

/* Socket connection */
// connect
-(PYSocketProcessStatus) connectToPeer:(PYSocketPeerInfo*)peerInfo 
	timedoutAfter:(NSUInteger)milliseconds;
-(void) asyncConnectToPeer:(PYSocketPeerInfo*)peerInfo 
	timedoutAfter:(NSUInteger)milliseconds
	completion:(PYSocketSuccess)cblock
	timedout:(PYSocketTimeout)tblock
	error:(PYSocketError)eblock;
// close
-(void) closeConnection;

/* bind with other socket */
-(void) bindWithSocket:(SOCKET_T)sock closeOnDone:(BOOL)close;

/* Data transmition */
// write data
-(int) writeData:(NSData *)data;
-(void) asyncWriteData:(NSData *)data
	completion:(PYSocketWriteBlock)wblock
	error:(PYSocketError)eblock;

// read data
-(NSData *) readDataWithTimeOut:(NSUInteger)timeout;
-(void)asyncReceiveWithTimeout:(NSUInteger)timeout
	data:(PYSocketRecvBlock)dblock 
	timedout:(PYSocketTimeout)tblock
	error:(PYSocketError)eblock;

@end


@protocol PYBaseSocketDelegate <NSObject>

@optional
-(void) socket:(PYBaseSocket *)socket 
	statusChangedTo:(PYSocketStatus)newStatus 
	from:(PYSocketStatus)oldStatus;

-(void) socket:(PYBaseSocket *)socket
	occurredError:(NSError *)error;
	
-(void) socket:(PYBaseSocket *)socket
	didCloseConnectionToPeer:(PYSocketPeerInfo *)peerInfo;
	
@end

