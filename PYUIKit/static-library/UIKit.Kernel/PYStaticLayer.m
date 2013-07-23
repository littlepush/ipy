//
//  PYStaticLayer.m
//  PYUIKit
//
//  Created by Push Chen on 7/24/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

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
                     @"frame":[NSNull null]
                     };
}

- (void)layerJustBeenCopyed
{
    [super layerJustBeenCopyed];
    
    self.actions = @{
                     kCAOnOrderIn:[NSNull null],
                     kCAOnOrderOut:[NSNull null],
                     @"contents":[NSNull null],
                     @"frame":[NSNull null]
                     };
}

@end
