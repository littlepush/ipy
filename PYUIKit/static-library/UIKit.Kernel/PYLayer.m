//
//  PYLayer.m
//  PYUIKit
//
//  Created by Push Chen on 7/24/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import "PYLayer.h"

@implementation PYLayer

@synthesize tag = _layerTag;

- (void)layerJustBeenCreated
{
    self.contentsScale = [UIScreen mainScreen].scale;
}

- (void)layerJustBeenCopyed
{
    self.contentsScale = [UIScreen mainScreen].scale;    
}

- (void)willMoveToSuperLayer:(CALayer *)layer
{
    // Nothing to do, just for override
}

#pragma mark --
#pragma mark Override
- (void)layoutSublayers
{
    [super layoutSublayers];
    self.contentsScale = [UIScreen mainScreen].scale;
}

- (id<CAAction>)actionForKey:(NSString *)event
{
    if ( [event isEqualToString:kCAOnOrderIn] ) {
        [self willMoveToSuperLayer:self.superlayer];
    }
    if ( [event isEqualToString:kCAOnOrderOut] ) {
        [self willMoveToSuperLayer:nil];
    }
    return [super actionForKey:event];
}

#pragma mark --
#pragma mark Init

- (id)init
{
    self = [super init];
    if ( self ) {
        [self layerJustBeenCreated];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self ) {
        [self layerJustBeenCreated];
    }
    return self;
}

- (id)initWithLayer:(id)layer
{
    self = [super initWithLayer:layer];
    if ( self ) {
        [self layerJustBeenCopyed];
    }
    return self;
}

@end
