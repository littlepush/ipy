//
//  PYStaticLayer.m
//  PYUIKit
//
//  Created by Push Chen on 7/24/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
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

#import "PYStaticLayer.h"

@implementation PYStaticLayer

// Override this two functions to make the static layer action nothing
// when the contents changed.
- (void)layerJustBeenCreated
{
    [super layerJustBeenCreated];
    
    self.actions = @{
                     kCAOnOrderIn:[NSNull null],
                     kCAOnOrderOut:[NSNull null],
                     @"contents":[NSNull null],
                     @"frame":[NSNull null],
                     @"bounds":[NSNull null]
                     };
}

- (void)layerJustBeenCopyed
{
    [super layerJustBeenCopyed];
    
    self.actions = @{
                     kCAOnOrderIn:[NSNull null],
                     kCAOnOrderOut:[NSNull null],
                     @"contents":[NSNull null],
                     @"frame":[NSNull null],
                     @"bounds":[NSNull null]
                     };
}

- (id<CAAction>)actionForKey:(NSString *)event
{
    id<CAAction> _action = [super actionForKey:event];
    if ( [event isEqualToString:kCAOnOrderIn] ) return nil;
    if ( [event isEqualToString:kCAOnOrderOut] ) return nil;
    if ( [event isEqualToString:@"contents"] ) return nil;
    if ( [event isEqualToString:@"frame"] ) return nil;
    if ( [event isEqualToString:@"bounds"] ) return nil;
    return _action;
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
