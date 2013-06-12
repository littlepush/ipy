//
//  PYSocketJobQueue.m
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

#import "PYSocketJobQueue.h"
#import "NSObject+PYCore.h"
#import "PYCoreMacro.h"
#import "PYSemaphore.h"

#define PYSocketJobQueueWorkingThreadStopSem    @"PYSocketJobQueueWorkingThreadStopSem"

static PYSocketJobQueue *__gSocketJobQueue = nil;

@interface PYSocketJobQueue (Internal)

// Working thread
- (void)_startWorkingThread;
- (void)_endWorkingThread;

// Main Working thread.
- (void)_mainThread:(id)sender;

@end

@implementation PYSocketJobQueue

+ (PYSocketJobQueue *)sharedQueue
{
    PYSingletonLock
    if ( __gSocketJobQueue == nil ) {
        __gSocketJobQueue = [[PYSocketJobQueue alloc] init];
    }
    return __gSocketJobQueue;
    PYSingletonUnLock
}
PYSingletonAllocWithZone(__gSocketJobQueue);
PYSingletonDefaultImplementation;

// Internal messages
- (void)_startWorkingThread
{
    NSThread *_newThread = [[NSThread alloc]
                            initWithTarget:self
                            selector:@selector(_mainThread:)
                            object:nil];
    [_newThread.threadDictionary
     setObject:[PYSemaphore object]
     forKey:PYSocketJobQueueWorkingThreadStopSem];
    [_workingThreadsList addObject:_newThread];
    [_newThread start];
}

- (void)_endWorkingThread
{
    NSThread *_lastThread = [_workingThreadsList lastObject];
    [_workingThreadsList removeLastObject];
    PYSemaphore *_stopSem = [_lastThread.threadDictionary
                             objectForKey:PYSocketJobQueueWorkingThreadStopSem];
    [_stopSem give];
}

- (void)_mainThread:(id)sender
{
    
}

- (id)init
{
    self = [super init];
    if ( self ) {
        _socketJobQueueDict = __RETAIN([NSMutableDictionary dictionary]);
        _workingThreadsList = __RETAIN([NSMutableArray array]);
        
        // Start the first working thread
        [self _startWorkingThread];
    }
    return self;
}

// Actions
- (void)addConnectionJob:(PYSocketJob *)job
{
    
}

- (void)addJob:(PYSocketJob *)job
{
    
}

- (void)addCloseJob:(PYSocketJob *)job
{
    
}

- (void)setMaxConcurrentCount:(int)concurrent
{
    // We do not support zero working thread.
    if ( concurrent == 0 ) return;
    
    PYSingletonLock
    // Recount the working thread.
    while (concurrent != [_workingThreadsList count]) {
        if ( concurrent > [_workingThreadsList count] ) {
            [self _endWorkingThread];
        } else {
            [self _startWorkingThread];
        }
    }
    PYSingletonUnLock
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
