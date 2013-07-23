//
//  PYLayer.h
//  PYUIKit
//
//  Created by Push Chen on 7/24/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface PYLayer : CALayer
{
    // Add tag info for layer.
    int                             _layerTag;
}

// Properties
@property (nonatomic, assign)   int         tag;

// After initialize the layer from super init function, invoke
// this message.
// On default, will set the content scale same as the main screen.
- (void)layerJustBeenCreated;

// The layer is created with other layer.
- (void)layerJustBeenCopyed;

// Will be add to/remove from super layer
- (void)willMoveToSuperLayer:(CALayer *)layer;

@end
