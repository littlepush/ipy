//
//  PYSemaphore.m
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

#import "PYSemaphore.h"
#import "NSObject+PYCore.h"

@interface PYSemaphore (Internal)

// Internal
- (void)_initSemaphoreWith:(int)initCount max:(NSUInteger)maxCount;
- (void)_trySetStatue:(BOOL)statue;

@end

@implementation PYSemaphore

@dynamic count;
- (NSUInteger)count
{
    if ( _mutex == nil ) return 0;
    NSNumber *_count = [_mutex lockAndDo:^id{
        return PYIntToObject(_current);
    }];
    return [_count unsignedIntValue];
}

@dynamic isAvailable;
- (BOOL)isAvailable
{
    if ( _mutex == nil ) return NO;
    NSNumber *_av = [_mutex lockAndDo:^id{
        return PYBoolToObject(_available);
    }];
    return [_av boolValue];
}

- (id)init
{
    self = [super init];
    if ( self ) {
        [self _initSemaphoreWith:0 max:SEM_MAXCOUNT];
    }
    return self;
}
- (id)initWithCount:(int)initCount
{
    self = [super init];
    if ( self ) {
        [self _initSemaphoreWith:initCount max:SEM_MAXCOUNT];
    }
    return self;
}
- (id)initWithCount:(int)initCount maxCount:(int)max
{
    self = [super init];
    if ( self ) {
        [self _initSemaphoreWith:initCount max:max];
    }
    return self;
}

// Get the semaphore with specified timeout
- (BOOL)get
{
    return [self getUntil:SEM_MAXTIMEOUT];
}
- (BOOL)getUntil:(NSUInteger)timedout
{
    if ( [self isAvailable] == NO ) return NO;
    NSNumber *_result = [_mutex lockAndDo:^id{
        if ( _current > 0 ) {
            _current -= 1;
            return PYBoolToObject(YES);
        }
        int _err;
        if ( timedout == SEM_MAXTIMEOUT ) {
            while ( _current == 0 ) {
                if ( pthread_cond_wait(&_sem, &_mutex->_mutex) == EINVAL ) {
                    return PYBoolToObject(NO);
                }
            }
            _current -= 1;
            return PYBoolToObject(YES);
        } else {
            struct timespec ts;
            struct timeval  tv;
            
            gettimeofday(&tv, NULL);
            ts.tv_nsec = tv.tv_usec * 1000 + (timedout % 1000) * 1000000;
            int _OP = (ts.tv_nsec / 1000000000);
            if ( _OP ) ts.tv_nsec %= 1000000000;
            ts.tv_sec = tv.tv_sec + timedout / 1000 + _OP;
            while ( _current == 0 ) {
                _err = pthread_cond_timedwait(&_sem, &_mutex->_mutex, &ts);
                // On time out or invalidate object
                if ( _err == ETIMEDOUT || _err == EINVAL ) {
                    return PYBoolToObject(NO);
                }
            }
            _current -= 1;
            return PYBoolToObject(YES);
        }        
    }];
    return [_result boolValue];
}

// Release a semaphore
- (BOOL)give
{
    if ( [self isAvailable] == NO ) return NO;
    NSNumber *_result = [_mutex lockAndDo:^id{
        if ( _current == _max ) {
            return PYBoolToObject(NO);
        }
        ++_current;
        pthread_cond_signal(&_sem);
        return PYBoolToObject(YES);
    }];
    return [_result boolValue];
}

// Destroy the semaphore
- (void)destroy
{
    if ( self.isAvailable == NO ) return;
    pthread_condattr_destroy(&_condAttr);
    pthread_cond_destroy(&_sem);
    [self _trySetStatue:NO];
    _current = 0;
}

// Init the semaphore.
- (void)_initSemaphoreWith:(int)initCount max:(NSUInteger)maxCount
{
    [self destroy];
    if ( _mutex != nil ) {
        __RELEASE(_mutex);
        _mutex = nil;
    }
    _mutex = __RETAIN([[PYMutex alloc] init]);
    pthread_condattr_init(&_condAttr);
    pthread_cond_init(&_sem, &_condAttr);
    _current = initCount;
    _max = maxCount;
    [self _trySetStatue:YES];
}

- (void)_trySetStatue:(BOOL)statue
{
    [_mutex lockAndDo:^id{
        if ( _available == statue ) {
            return nil;
        }
        _available = statue;
        return nil;
    }];
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
