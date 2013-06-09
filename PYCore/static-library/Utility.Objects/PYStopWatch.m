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
    gettimeofday(&_startTime, NULL);
    _timePassed = 0.f;
    _timePaused = 0.f;
}
- (void)pause
{
    gettimeofday(&_pausedTime, NULL);
}
- (void)resume
{
    struct timeval _pausedEndTime;
    gettimeofday(&_pausedEndTime, NULL);
    
    double _thisPaused = ((double)(1000000.f * (_pausedEndTime.tv_sec - _pausedTime.tv_sec)) +
                          (double)(_pausedEndTime.tv_usec - _pausedTime.tv_usec));
    _thisPaused /= 1000000.f;
    _timePaused += _thisPaused;
}

- (double)tick
{
	gettimeofday(&_endTime, NULL);
	
	_timePassed = ((double)(1000000.f * (_endTime.tv_sec - _startTime.tv_sec)) +
                   (double)(_endTime.tv_usec - _startTime.tv_usec));
	_timePassed /= 1000000.f;
    
	return [self milleseconds];
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
