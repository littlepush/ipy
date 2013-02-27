//
//  PYNetworkAction.m
//  PYNetwork
//
//  Created by Push Chen on 7/19/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "PYNetworkAction.h"
#import "PYNetworkAction+Internal.h"
#import "PYNetworkActionManager.h"
#import "PYNetworkActionManager+Internal.h"

@implementation PYNetworkAction

@synthesize request = _request;
@synthesize response = _response;
@synthesize owner = _owner;
@synthesize name = _name;

@dynamic peerInfo;
-(PYPeerInfo *)peerInfo {
	return _request.peerInfo;
	//return _asyncConnection.remotePeerInfo;
}

+(PYNetworkAction *)actionWithRequest:(PYNetworkRequest *)req 
	owner:(id)owner name:(NSString *)name
{
	PYNetworkAction *_action = [[[PYNetworkAction alloc]
		initWithRequest:req owner:owner name:name] autorelease];
	return _action;
}

-(id) initWithRequest:(PYNetworkRequest *)req owner:(id)owner name:(NSString *)name
{
	self = [super init];
	if ( self ) {
		_request = [req retain];
		_owner = [owner retain];
		_name = [[name copy] retain];
	}
	return self;
}

-(BOOL) startAction {
	if ( _request == nil || [_request isEqual:[NSNull null]] )
		return NO;
	// get socket connection
	[_ActionManager getConnectionToPeer:_request.peerInfo 
		timedout:^{
			// connection timed out
			[_owner action:self didTimedoutOnStage:PYNetworkProcessStageConnecting];
		} connected:^(PYBaseSocket * asyncConnection) {
			// write data
			[asyncConnection asyncWriteData:[_request serializedData] 
			completion:^(int writenBytes) {
				// write data success
				// ready for receiving data
				[asyncConnection asyncReceiveWithTimeout:[_request timeOut] 
				data:^PYSocketReceiveStatus(NSData *partialData) {
					if ( _response == nil ) {
						_response = [[PYNetworkResponse object] retain];
					}
					PYSocketReceiveStatus _rstatus = [_response combineData:partialData];
					if ( _rstatus == PYSocketReceiveStatusDone ) {
						[_owner action:self didFinishWithResponse:_response];
					}
					return _rstatus;
				} timedout:^{
					// receive data timed out
					[_owner action:self didTimedoutOnStage:PYNetworkProcessStageReceive];
				} error:^(NSError *error) {
					[_owner action:self didFailedWithError:error];
				}];
			} error:^(NSError *error) {
				[_owner action:self didFailedWithError:error];
			}];
		} error:^(NSError *error) {
			[_owner action:self didFailedWithError:error];
		}
	];
	return YES;
}

-(BOOL) startActionWithRequest:(PYNetworkRequest *)req owner:(id)owner {
	if ( _request != nil ) {
		[_request release];
	}
	_request = [req retain];
	_owner = [owner retain];
	
	return [self startAction];
}

-(void) cancelAction {
	// close the socket connection;
	// update queue status
}

#pragma mark - override
-(void) setValue:(id)value forKey:(NSString *)key 
{
	if ( _userInfo == nil ) {
		_userInfo = [[NSMutableDictionary dictionary] retain];
	}
	[_userInfo setValue:value forKey:key];
}

-(id) valueForKey:(NSString *)key
{
	if ( _userInfo == nil ) {
		return nil;
	}
	return [_userInfo valueForKey:key];
}

-(void) dealloc {
	[_request release]; _request = nil;
	[_response release]; _response = nil;
	[_name release]; _name = nil;
	[_userInfo release]; _userInfo = nil;
	[_owner release]; _owner = nil;
	[_asyncConnection release]; _asyncConnection = nil;
	
	[super dealloc];
}

-(void) setManager:(PYNetworkActionManager *)manager
{
	[self setValue:manager forKey:kActionManager];
}

@end
