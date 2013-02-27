//
//  PYStopWatch.m
//  PYCore
//
//  Created by littlepush on 8/28/12.
//  Copyright (c) 2012 PushLab. All rights reserved.
//

#import "PYStopWatch.h"

@implementation PYStopWatch

@synthesize seconds = _timePassed;
@dynamic milleseconds;
-(double) milleseconds { return (double)(_timePassed * 1000); }

-(void) start { gettimeofday(&_startTime, NULL); }
-(double) tick {
	gettimeofday(&_endTime, NULL);
	
	_timePassed = (double)(1000000.f * (_endTime.tv_sec - _startTime.tv_sec)) + 
		(double)(_endTime.tv_usec - _startTime.tv_usec);
	_timePassed /= 1000000.f;

	return [self milleseconds];
}

@end
