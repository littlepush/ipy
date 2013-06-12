//
//  PYSocket.h
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
#import "PYStopWatch.h"
#import "PYSocket+Protocol.h"

// The basic Socket object.
// Rewrite according to the PYBasicSocket<> in the project plib.
@interface PYSocket : NSObject<PYSocket>
{
	SOCKET_T                    _socket;
	BOOL                        _beBound;
	BOOL                        _beBoundCloseOnDone;
	PYNetworkPeerInfo           *_remotePeerInfo;
	PYNetworkPeerInfo           *_localPeerInfo;
	
	// Status
	PYSocketStatus              _lastSocketStatus;
	PYSocketStatus              _currentSocketStatus;
	
    PYStopWatch                 *_idleTimer;
	NSError                     *_lastError;
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
