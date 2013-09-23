//
//  PYSemaphore.h
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
#import "PYCoreMacro.h"
#import "PYMutex.h"

typedef pthread_cond_t  PYSemHandleT;

enum { SEM_MAXCOUNT = 0x0FFFF, SEM_MAXTIMEOUT = 0xFFFFFFFF };

@interface PYSemaphore : NSObject
{
    PYSemHandleT                    _sem;
    Int32                           _max;
    volatile Int32                  _current;
    volatile bool                   _available;
    
    // Mutex to lock the m_Current.
    PYMutex                         *_mutex;
    pthread_condattr_t              _condAttr;
}

// Signal count
@property (nonatomic, readonly) NSUInteger              count;
@property (nonatomic, readonly) BOOL                    isAvailable;
@property (nonatomic, readonly) Int32                   maxCount;

- (id)initWithCount:(int)initCount;
- (id)initWithCount:(int)initCount maxCount:(int)max;

// Get the semaphore with specified timeout
- (BOOL)get;
- (BOOL)getUntil:(NSUInteger)timedout;
- (BOOL)tryGet;

// Release a semaphore
- (BOOL)give;

// Destroy the semaphore
- (void)destroy;

// Clear all signal.
- (void)clear;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
