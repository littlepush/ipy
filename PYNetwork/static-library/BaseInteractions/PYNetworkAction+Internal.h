//
//  PYNetworkAction_Internal.h
//  PYNetwork
//
//  Created by Push Chen on 7/19/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "PYNetworkAction.h"
#import "PYNetworkActionManager.h"

#define kActionManager		@"kActionManager"
#define _ActionManager		(PYNetworkActionManager *)[self valueForKey:kActionManager]

@interface PYNetworkAction (Internal)

-(BOOL) startAction;
-(BOOL) startActionWithRequest:(PYNetworkRequest *)req owner:(id)owner;

-(void) cancelAction;

-(void) setManager:(PYNetworkActionManager *)manager;

@end
