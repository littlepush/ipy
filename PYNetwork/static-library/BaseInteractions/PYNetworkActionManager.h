//
//  PYNetworkActionManager.h
//  PYNetwork
//
//  Created by Push Chen on 7/20/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PYNetworkAction.h"

#define PYSHARED_ACTMGR		[PYNetworkActionManager sharedManager]

typedef enum {
	PYNetworkStatusChangingCancelAll,
	PYNetworkStatusChangingPending
} PYNetworkStatusChanging;


@interface PYNetworkActionManager : NSObject
{
	NSMutableDictionary			*_asyncConnectionPool;
	PYNetworkStatusChanging		_netStatusChangingAct;
	NSMutableArray				*_actionQueue;
	NSUInteger					_defaultTimeout;
}
@property (nonatomic, readonly) NSUInteger					actionCount;
@property (nonatomic, assign)	PYNetworkStatusChanging		networkStatusChangingAction;
@property (nonatomic, assign)	NSUInteger					defaultTimeOut;

+(PYNetworkActionManager *) sharedManager;

-(void) addAction:(PYNetworkAction *)action;
-(void) removeAction:(PYNetworkAction *)action;
-(void) removeAllAction;

@end
