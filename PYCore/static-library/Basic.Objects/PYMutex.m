//
//  PYMutex.m
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

#import "PYMutex.h"
#import "NSObject+PYCore.h"
#import "PYCoreMacro.h"

@implementation PYMutex

- (id)init
{
    self = [super init];
    if ( self ) {
        pthread_mutex_init(&_mutex, NULL);
    }
    return self;
}

- (void)dealloc
{
    pthread_mutex_destroy(&_mutex);
#if __has_feature(objc_arc)
#else
    [super dealloc];
#endif
}

- (void)lock
{
    pthread_mutex_lock(&_mutex);
}

- (id)lockAndDo:(PYMutexAction)action
{
    [self lock];
    id result = action( );
    [self unlock];
    return result;
}

- (void)unlock
{
    pthread_mutex_unlock(&_mutex);
}

- (BOOL)tryLock
{
    return pthread_mutex_trylock(&_mutex) != 0;
}

@end
// @littlepush
// littlepush@gmail.com
// PYLab
