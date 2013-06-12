//
//  PYMutex.h
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

#ifndef _PYCORE_PYMUTEX_HEADER_H_
#define _PYCORE_PYMUTEX_HEADER_H_

#import <Foundation/Foundation.h>
#include <pthread.h>

typedef id (^PYMutexAction)();

typedef pthread_mutex_t     PYMutexHandleT;

@interface PYMutex : NSObject
{
    @public
    PYMutexHandleT              _mutex;
}

// Mutex Actions
- (void)lock;
- (id)lockAndDo:(PYMutexAction)action;
- (void)unlock;
- (BOOL)tryLock;

@end

#endif

// @littlepush
// littlepush@gmail.com
// PYLab
