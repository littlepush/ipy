//
//  PYSocketJobList.h
//  PYCore
//
//  Created by Push Chen on 7/18/13.
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
#import "PYMutex.h"
#import "PYSocketJob.h"

// Pre-define of the job dispatcher.
// The dispatcher should be the observer of the job list
@class PYSocketJobDispatcher;

typedef enum {
    PYSocketJobListStatusFrozen,
    PYSocketJobListStatusWaiting,
    PYSocketJobListStatusPending,
    PYSocketJobListStatusClosed,
    PYSocketJobListStatusUrgent
} PYSocketJobListStatus;

@interface PYSocketJobList : NSObject
{
    NSMutableArray                  *_urgentEventList;
    NSMutableArray                  *_pendingEventList;
    PYSocketJobListStatus           _listStatus;
}

#pragma mark --
#pragma mark List Functions

// Add a urgent job, which will change the list status to PYSocketJobListStatusUrgent.
- (void)addUrgentJob:(PYSocketJob *)urgentJob;

// Add a normal job, if the list's status current is waiting, then it will
// be changed to PYSocketJobListStatusPending. Otherwise, the status will
// remined no change.
- (void)addJob:(PYSocketJob *)job;

// Freeze the list. When the socket 

@end

// @littlepush
// littlepush@gmail.com
// PYLab
