//
//  PYStopWatch.m
//  PYCore
//
//  Created by Push Chen on 6/10/13.
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

#import "PYStopWatch.h"
#import "NSObject+PYCore.h"

static PYStopWatch *_gWatch = nil;

@implementation PYStopWatch

+ (PYStopWatch *)globalWatch
{
    @synchronized(self) {
        if ( _gWatch == nil ) {
            _gWatch = [[PYStopWatch object] increaseRC];
        }
        return _gWatch;
    }
}

- (id)init
{
    self = [super init];
    if ( self ) {
        _handle = OS_SPINLOCK_INIT;
    }
    return self;
}

- (void)__lock__
{
    unsigned int _Count;
RE_TRY_LOCK:
    _Count = 0;
    while( _Count <= 2000 && !OSSpinLockTry(&_handle) )
        ++_Count;
    if ( _Count > 2000 ) {
        usleep(1);
        goto RE_TRY_LOCK;
    }
}

- (void)__unlock__
{
    OSSpinLockUnlock(&_handle);
}

@dynamic seconds;
- (double)seconds
{
    return _timePassed - _timePaused;
}

@dynamic milleseconds;
- (double)milleseconds
{
    return (double)(self.seconds * 1000);
}

- (void)start
{
    [self __lock__];
    gettimeofday(&_startTime, NULL);
    _timePassed = 0.f;
    _timePaused = 0.f;
    _paused = NO;
    [self __unlock__];
}
- (void)pause
{
    [self __lock__];
    if ( _paused == YES ) {
        [self __unlock__];
        return;
    }
    _paused = YES;
    gettimeofday(&_pausedTime, NULL);
    [self __unlock__];
}
- (void)resume
{
    [self __lock__];
    if ( _paused == NO ) {
        [self __unlock__];
        return;
    }
    struct timeval _pausedEndTime;
    gettimeofday(&_pausedEndTime, NULL);
    
    double _thisPaused = ((double)(1000000.f * (_pausedEndTime.tv_sec - _pausedTime.tv_sec)) +
                          (double)(_pausedEndTime.tv_usec - _pausedTime.tv_usec));
    _thisPaused /= 1000000.f;
    _timePaused += _thisPaused;
    _paused = NO;
    [self __unlock__];
}

- (double)tick
{
    [self __lock__];
    if ( _paused == YES ) {
        [self __unlock__];
        return [self milleseconds];
    }
	gettimeofday(&_endTime, NULL);
	
	_timePassed = ((double)(1000000.f * (_endTime.tv_sec - _startTime.tv_sec)) +
                   (double)(_endTime.tv_usec - _startTime.tv_usec));
	_timePassed /= 1000000.f;
    [self __unlock__];
	return [self milleseconds];
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
