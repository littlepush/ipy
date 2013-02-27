//
//  PYViewController.m
//  PYNetwork
//
//  Created by Push Chen on 7/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PYViewController.h"
#import "PYBaseSocket.h"

@interface PYViewController ()

@end

@implementation PYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	PYBaseSocket *socket = [[[PYBaseSocket alloc] init] autorelease];
	socket.delegate = self;
	
	[socket asyncConnectToPeer:
			[PYSocketPeerInfo peerInfoWithAddress:@"127.0.0.1" port:80] 
		timedoutAfter:4000 
		completion:^(PYSocketProcessStatus status) {
			if ( status == PYSocketProcessStatusError ) {
				NSLog(@"connect error");
				return;
			}
			if ( status == PYSocketProcessStatusTimeOut ) {
				NSLog(@"connect timeout");
				return;
			}
			NSString *_httpReq = @"GET /~littlepush/ HTTP/1.1\r\n"
								 @"HOST: localhost\r\n"
							 	 @"\r\n";
			[socket asyncWriteData:[_httpReq dataUsingEncoding:NSUTF8StringEncoding]
			 completion:^(BOOL success) {
				[socket asyncReceiveWithTimeout:1000 
				data:^BOOL(NSData *paritialData) {
					NSString *_string = [[[NSString alloc]
						initWithData:paritialData encoding:NSUTF8StringEncoding]
						autorelease];
					NSLog(@"%@", _string);
					return paritialData.length == 1024;
				} timeout:^{
					NSLog(@"time out");
				}];
			}];
		}
	];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - socket delegate
-(void) socket:(PYBaseSocket *)socket 
	statusChangedTo:(PYSocketStatus)newStatus 
	from:(PYSocketStatus)oldStatus
{
	NSLog(@"the socket: %@ change statue from %@ to %@", 
		socket, PYSocketStatusDescription(oldStatus), 
		PYSocketStatusDescription(newStatus));
}

-(void) socket:(PYBaseSocket *)socket
	occurredError:(NSError *)error
{
	NSLog(@"the socket: %@ occurred error:(%d)%@", 
		socket, error.code, error.localizedDescription);
}
	
-(void) socket:(PYBaseSocket *)socket
	willConnectToPeer:(PYSocketPeerInfo *)peerInfo
{
	NSLog(@"the socket: %@ will connect to: %@", socket, peerInfo);
}
	
-(void) socket:(PYBaseSocket *)socket 
	didConnectToPeer:(PYSocketPeerInfo *)peerInfo
{
	NSLog(@"the socket: %@ has connected to: %@", socket, peerInfo);
}

-(void) socket:(PYBaseSocket *)socket
	didCloseConnectionToPeer:(PYSocketPeerInfo *)peerInfo
{
	NSLog(@"the socket: %@ disconnected from: %@", socket, peerInfo);
}


@end
