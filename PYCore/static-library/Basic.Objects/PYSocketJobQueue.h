//
//  PYSocketJobQueue.h
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

#import <Foundation/Foundation.h>
#import "PYSocketJob.h"
#import "PYMutex.h"
#import "PYSemaphore.h"

@interface PYSocketJobQueue : NSObject
{
    // Working thread
    NSMutableArray                      *_workingThreadsList;
    
    // Socket job cache
    NSMutableDictionary                 *_socketJobQueueDict;
    PYMutex                             *_socketMutex;
    
    // Global Socket job sequence
    NSMutableArray                      *_jobsSequence;
    PYSemaphore                         *_jobSemaphore;
    PYMutex                             *_jobMutex;
}

// Singleton instance
+ (PYSocketJobQueue *)sharedQueue;

// Add connection job, which should be insert at the top of the queue.
- (void)addConnectionJob:(PYSocketJob *)job;

// The job will be added to the tail of the queue.
- (void)addJob:(PYSocketJob *)job;

// The specified socket will be closed and all jobs remained will be removed.
- (void)addCloseJob:(PYSocketJob *)job;

// The Queue's settings.
// Concurrent count, default is 1.
- (void)setMaxConcurrentCount:(int)concurrent;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
