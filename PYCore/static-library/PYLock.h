//
//  PYLock.h
//  SdAccountKeyM
//
//  Created by Push Chen on 12/13/12.
//  Copyright (c) 2012 snda. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <libkern/OSAtomic.h>
#include <unistd.h>

@interface PYLock : NSObject
{
	OSSpinLock _handle;
}

// Get the thread id of current lock.
@property (nonatomic, readonly)		long int		threadId;

-(void) lock;
-(void) unlock;

@end

/* Automatic Locker Container. */
@interface PYAutoLocker : NSObject
{
	PYLock		*_innerLock;
}

+(PYAutoLocker *) initWithLock:(PYLock *)lockObj;

@end