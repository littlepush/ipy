//
//  PYLock.m
//  SdAccountKeyM
//
//  Created by Push Chen on 12/13/12.
//  Copyright (c) 2012 snda. All rights reserved.
//

#import "PYLock.h"
#import <sys/syscall.h>

@implementation PYLock

@dynamic threadId;
-(long int) threadId { return (long int)syscall(SYS_gettid); }

-(id) init
{
	self = [super init];
	if ( !self ) return nil;
	
	// Init the handle
	_handle = OS_SPINLOCK_INIT;
	return self;
}

-(void) dealloc
{
	[self unlock];
	[super dealloc];
}

-(void) lock
{
	int _count;
	
	// Try to lock, until locked or tried more than 2000 times.
RE_TRY_LOCK:
	_count = 0;
	while( _count <= 2000 && !OSSpinLockTry(&_handle) )
		++_count;
	if ( _count > 2000 ) {
		usleep(1);
		goto RE_TRY_LOCK;
	}
}

-(void) unlock
{
	OSSpinLockUnlock(&_handle);
}

@end


@implementation PYAutoLocker

+(PYAutoLocker *) initWithLock:(PYLock *)lockObj
{
	PYAutoLocker *_locker = [[[PYAutoLocker alloc] init] autorelease];
	
	_locker->_innerLock = [lockObj retain];
	[_locker->_innerLock lock];
	
	return _locker;
}

-(void) dealloc
{
	[_innerLock unlock];
	[_innerLock release];
	[super dealloc];
}

@end