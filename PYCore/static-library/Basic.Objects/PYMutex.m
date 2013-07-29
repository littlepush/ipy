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

@synthesize enableDebug = _enableDebug;

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
    if ( _enableDebug ) {
        @try {
            [self raiseExceptionWithMessage:@"Try to lock"];
        } @catch ( NSException *ex ) {
            NSRange _stRange = NSMakeRange(5, MIN([ex.callStackSymbols count] - 5, 5));
            NSLog(@"%@[%d, %p]\n%@", ex.reason, (int)pthread_self(), self,
                  [ex.callStackSymbols subarrayWithRange:_stRange]);
        }
    }
    pthread_mutex_lock(&_mutex);
    if ( _enableDebug ) {
        @try {
            [self raiseExceptionWithMessage:@"Did locked"];
        } @catch ( NSException *ex ) {
            NSRange _stRange = NSMakeRange(5, MIN([ex.callStackSymbols count] - 5, 5));
            NSLog(@"%@[%d, %p]\n%@", ex.reason, (int)pthread_self(), self,
                  [ex.callStackSymbols subarrayWithRange:_stRange]);
        }
    }
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
    if ( _enableDebug ) {
        @try {
            [self raiseExceptionWithMessage:@"Try to unlock"];
        } @catch ( NSException *ex ) {
            NSRange _stRange = NSMakeRange(5, MIN([ex.callStackSymbols count] - 5, 5));
            NSLog(@"%@[%d, %p]\n%@", ex.reason, (int)pthread_self(), self,
                  [ex.callStackSymbols subarrayWithRange:_stRange]);
        }
    }
    pthread_mutex_unlock(&_mutex);
    if ( _enableDebug ) {
        @try {
            [self raiseExceptionWithMessage:@"Did unlock"];
        } @catch ( NSException *ex ) {
            NSRange _stRange = NSMakeRange(5, MIN([ex.callStackSymbols count] - 5, 5));
            NSLog(@"%@[%d, %p]\n%@", ex.reason, (int)pthread_self(), self,
                  [ex.callStackSymbols subarrayWithRange:_stRange]);
        }
    }
}

- (BOOL)tryLock
{
    return pthread_mutex_trylock(&_mutex) != 0;
}

@end
// @littlepush
// littlepush@gmail.com
// PYLab
