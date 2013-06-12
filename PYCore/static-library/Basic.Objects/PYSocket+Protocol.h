//
//  PYSocket+Protocol.h
//  PYCore
//
//  Created by Push Chen on 6/12/13.
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
#import "PYNetworkPeerInfo.h"

@protocol PYSocket;

// Socket Status
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
        case PYSocketStatusEmpyt:       return @"Empty";
        case PYSocketStatusIdle:        return @"Idle";
        case PYSocketStatusConnecting:  return @"Connecting";
        case PYSocketStatusBinding:     return @"Binding";
        case PYSocketStatusClosing:     return @"Closing";
        case PYSocketStatusWriting:     return @"Writing";
        case PYSocketStatusReading:     return @"Reading";
        case PYSocketStatusTimeout:     return @"Timeout";
        case PYSocketStatusError:       return @"Error";
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

enum {
    PYSO_ERROR_OK       = 0,
    PYSO_ERROR_TIMEDOUT = 1024
};

// Callback function
typedef void (^PYSocketConnectionHandler)(BOOL statue, NSError *error);
typedef void (^PYSocketWriteBlock)(BOOL statue, int writenBytes, int timeUsed, NSError *error);
typedef PYSocketReceiveStatus (^PYSocketReadBlock)(BOOL statue, NSMutableData *data, NSError *error);
typedef void (^PYSocketAction)(NSObject<PYSocket> *socket);

// Socket Protocol
@protocol PYSocket <NSObject>

// The unique identify of each socket object.
@required
@property (nonatomic, readonly) NSString                *sockIdentify;

// Status Info
@required
@property (nonatomic, readonly) PYSocketStatus          status;

@optional
@property (nonatomic, readonly) BOOL                    isConnected;
@property (nonatomic, readonly) BOOL                    isReadable;
@property (nonatomic, readonly) BOOL                    isWritable;

// Peer Info
@required
@property (nonatomic, readonly) PYNetworkPeerInfo       *remotePeerInfo;
@property (nonatomic, readonly) PYNetworkPeerInfo       *localPeerInfo;

// Error
@required
@property (nonatomic, readonly) NSError                 *lastError;

// Connection
@required
- (void)buildConnectionUntil:(NSUInteger)timeout result:(PYSocketConnectionHandler)result;

// Do things when the socket is connected.
@required
- (void)doWhenConnected:(PYSocketAction)action;

// Write data
@required
- (void)sendData:(NSData *)data
          result:(PYSocketWriteBlock)result;
- (void)sendData:(NSData *)data
           until:(NSUInteger)timeout
          result:(PYSocketWriteBlock)result;

// Read data
@required
- (void)readDataUntil:(NSUInteger)timeout
               result:(PYSocketReadBlock)result;
- (void)readDataUntil:(NSUInteger)timeout
                  eof:(NSString *)eof       // The EOF String of the received package.
               result:(PYSocketReadBlock)result;
- (void)readDataUntil:(NSUInteger)timeout
                limit:(NSUInteger)limit     // All bytes to read before the timedout.
               result:(PYSocketReadBlock)result;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
