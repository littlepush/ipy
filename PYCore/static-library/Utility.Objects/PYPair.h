//
//  PYPair.h
//  PYCore
//
//  Created by Push Chen on 7/26/13.
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

@interface PYPair : NSObject

// Pair item first and second item.
@property (nonatomic, assign)   id              first;
@property (nonatomic, copy)     NSString        *firstValue;
@property (nonatomic, assign)   id              second;
@property (nonatomic, copy)     NSString        *secondValue;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
