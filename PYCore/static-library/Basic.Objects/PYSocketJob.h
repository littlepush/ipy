//
//  PYSocketJob.h
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

#import <Foundation/Foundation.h>
#import "PYSocket+Protocol.h"

@class PYSocketJob;
typedef void (^PYSocketMain)(PYSocketJob *);

@interface PYSocketJob : NSObject

// The socket bound with the job
@property (nonatomic, strong)   NSObject<PYSocket>          *socket;
// The parameters of this job
@property (nonatomic, strong)   NSArray                     *params;
// The job block
@property (nonatomic, strong)   PYSocketMain                main;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
