//
//  PYNetworkResponse.h
//  PYNetwork
//
//  Created by Push Chen on 7/19/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PYNetworkResponse <NSObject>

-(BOOL) combineData:(NSData *)partialData;

@end

@interface PYNetworkResponse : NSObject< PYNetworkResponse >

@end
