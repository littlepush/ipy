//
//  PYApiResponse.h
//  PYNetwork
//
//  Created by Push Chen on 7/24/14.
//  Copyright (c) 2014 PushLab. All rights reserved.
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

@interface PYApiResponse : NSObject

@property (nonatomic, assign)   NSInteger       errorCode;
@property (nonatomic, copy)     NSString        *errorMessage;
@property (nonatomic, readonly) NSError         *error;

// Parse the body.
- (BOOL)parseBodyWithData:(NSData *)data;

@end

@interface PYApiJSONResponse : PYApiResponse

// The body must be in JSON format.
- (BOOL)parseBodyWithJSON:(id)jsonObject;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
