//
//  PYLayer.m
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

#import "PYLayer.h"
#import "UIColor+PYUIKit.h"

static BOOL _gEnableDebug = NO;

@implementation PYLayer

+ (void)setDebugEnabled:(BOOL)enableDebug
{
    _gEnableDebug = enableDebug;
}

+ (BOOL)isDebugEnabled
{
    return _gEnableDebug;
}

@synthesize tag = _layerTag;

- (void)layerJustBeenCreated
{
    self.contentsScale = [UIScreen mainScreen].scale;
    if ( _gEnableDebug == YES ) {
        self.borderWidth = 1.f;
        self.borderColor = [UIColor randomColor].CGColor;
    }
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

- (void)dealloc
{
    if ( _gEnableDebug ) {
        __formatLogLine(__FILE__, __FUNCTION__, __LINE__,
                        [NSString stringWithFormat:@"***[%@:%p] Dealloced***",
                         NSStringFromClass([self class]), self]);
    }
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
