//
//  PYNetworkActionManager.m
//  PYNetwork
//
//  Created by Push Chen on 7/20/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import <PYCore/PYCore.h>
#import "PYNetworkActionManager.h"
#import "PYNetworkAction+Internal.h"
#import "PYNetworkActionManager+Internal.h"

static PYNetworkActionManager *_instanceManager;

@implementation PYNetworkActionManager

@synthesize networkStatusChangingAction = _netStatusChangingAct;
@dynamic actionCount;
-(NSUInteger)actionCount { return [_actionQueue count]; }
@synthesize defaultTimeOut = _defaultTimeout;

-(id) init {
	self = [super init];
	if ( self ) {
		_asyncConnectionPool = [[NSMutableDictionary dictionary] retain];
		_netStatusChangingAct = PYNetworkStatusChangingCancelAll;
		_actionQueue = [[NSMutableArray array] retain];
		_defaultTimeout = 3000;
	}
	return self;
}

+(PYNetworkActionManager *) sharedManager
{
	@synchronized(self) {
		if ( _instanceManager == nil ) {
			_instanceManager = [[self alloc] init];
		}
	}
	return _instanceManager;
}

PYSingletonAllocWithZone(_instanceManager);
PYSingletonDefaultImplementation;

// Messages
-(void) addAction:(PYNetworkAction *)action
{
	[action setManager:self];
	if (![action startAction]) return;
	[_actionQueue addObject:action];
}

-(void) removeAction:(PYNetworkAction *)action
{
	if ( ![_actionQueue containsObject:action] )
		return;
	[action retain];
	[_actionQueue removeObject:action];
	[action cancelAction];
	[action release];
}

-(void) removeAllAction
{
	for ( PYNetworkAction *action in _actionQueue ) {
		[action cancelAction];
	}
	[_actionQueue removeAllObjects];
}

// Internal
-(void) getConnectionToPeer:(PYSocketPeerInfo *)peer 
	timedout:(NetworkTimedOut)tblock connected:(NetworkAction)cblock
	error:(NetworkError)eblock
{
	NSMutableSet *_connSet = [_asyncConnectionPool objectForKey:peer];
	PYBaseSocket *_socket = nil;
	if ( _connSet != nil ) {
		_socket = [[_connSet anyObject] retain];
		if ( _socket != nil )
			[_connSet removeObject:_socket]; 
		[_socket autorelease];
	}
	
	if ( _socket == nil ) {
		_socket = [PYBaseSocket object];
	}
	
	if ( ![_socket isSocketConnected] ) {
		[_socket asyncConnectToPeer:peer 
		timedoutAfter:_defaultTimeout 
		completion:^{
			if ( cblock )
				cblock( _socket );
		} timedout:^{
			if ( tblock )
				tblock();
		} error:^(NSError *error) {
			if ( eblock )
				eblock( error );
		}];
	} else {
		if ( cblock )
			cblock( _socket );
	}
}

@end
