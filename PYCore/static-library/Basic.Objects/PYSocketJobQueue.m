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
#import "NSArray+PYCore.h"
#import "PYCoreMacro.h"

#define PYSocketJobQueueWorkingThreadStatus     @"PYSocketJobQueueWorkingThreadStatus"
#define PYSocketJobQueueWorkingThreadMutex      @"PYSocketJobQueueWorkingThreadMutex"

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
     setObject:PYBoolToObject(YES)
     forKey:PYSocketJobQueueWorkingThreadStatus];
    [_newThread.threadDictionary
     setObject:[PYMutex object]
     forKey:PYSocketJobQueueWorkingThreadMutex];
    
    [_workingThreadsList addObject:_newThread];
    [_newThread start];
}

- (void)_endWorkingThread
{
    NSThread *_lastThread = [_workingThreadsList lastObject];
    [_workingThreadsList removeLastObject];
    PYMutex *_mutex = [_lastThread.threadDictionary
                       objectForKey:PYSocketJobQueueWorkingThreadMutex];
    [_mutex lockAndDo:^id{
        [_lastThread.threadDictionary
         setObject:PYBoolToObject(NO)
         forKey:PYSocketJobQueueWorkingThreadStatus];
        return nil;
    }];
}

- (void)_mainThread:(id)sender
{
    @autoreleasepool {
        PYMutex *_mutex = [[NSThread currentThread].threadDictionary
                           objectForKey:PYSocketJobQueueWorkingThreadMutex];
        NSThread *_self = [NSThread currentThread];
        NSMutableDictionary *_userInfo = _self.threadDictionary;
        
        while (
               [[_mutex
                 lockAndDo:^id{
                     return [_userInfo objectForKey:PYSocketJobQueueWorkingThreadStatus];
                }] boolValue]
               ) {
            if ( ![_jobSemaphore getUntil:1000] ) continue;
            PYSocketJob *_firstJob = [_jobMutex lockAndDo:^id{
                PYSocketJob *_f = [_jobsSequence safeObjectAtIndex:0];
                if ( [_jobsSequence count] > 0 ) {
                    [_jobsSequence removeObjectAtIndex:0];
                }
                return _f;
            }];
            if ( _firstJob == nil ) continue;
            // Execute the job
            _firstJob.main( _firstJob );
            [_socketMutex lockAndDo:^id{
                NSMutableArray *_socketJobSequence = [_socketJobQueueDict
                                                      objectForKey:_firstJob.socket.sockIdentify];
                if ([_socketJobSequence count] == 0) return nil;
                [_socketJobSequence removeObject:_firstJob];
                return nil;
            }];
        }
        PYLog(@"The Socket Job Queue Working Thread has been terminated.");
    };
}

- (id)init
{
    self = [super init];
    if ( self ) {
        _socketJobQueueDict = __RETAIN([NSMutableDictionary dictionary]);
        _workingThreadsList = __RETAIN([NSMutableArray array]);
        _jobsSequence = __RETAIN([NSMutableArray array]);
        
        _socketMutex = [PYMutex object];
        _jobMutex = [PYMutex object];
        _jobSemaphore = [PYSemaphore object];
        
        // Start the first two working thread
        [self setMaxConcurrentCount:2];
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
