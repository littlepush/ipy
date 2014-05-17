//
//  PYStopWatch.h
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

#import <Foundation/Foundation.h>
#include <sys/time.h>
#include <sys/timeb.h>
#include <libkern/OSAtomic.h>

@interface PYStopWatch : NSObject
{
	struct timeval _startTime, _endTime;
    struct timeval _pausedTime;
	double _timePassed;
    double _timePaused;
    
    OSSpinLock _handle;
    BOOL _paused;
}

// Get the global watch instance
+ (PYStopWatch *)globalWatch;

// Last tick second.
@property (nonatomic, readonly)	double	seconds;
// Last tick millesecond.
@property (nonatomic, readonly) double	milleseconds;

// Initialize the start time, and start to calculate the time passed.
- (void)start;
// Pause the timer
- (void)pause;
// Resume the stop watch to calculate the time passed.
- (void)resume;
// Get current tick time.
- (double)tick;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
