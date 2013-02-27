//
//  PYStopWatch.h
//  PYCore
//
//  Created by littlepush on 8/28/12.
//  Copyright (c) 2012 PushLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/time.h>
#include <sys/timeb.h>

@interface PYStopWatch : NSObject
{
	struct timeval _startTime, _endTime;
	double _timePassed;
}

@property (nonatomic, readonly)	double	seconds;
@property (nonatomic, readonly) double	milleseconds;

-(void) start;
-(double) tick;

@end
