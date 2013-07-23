//
//  PYInnerShadowLayer.h
//  PYUIKit
//
//  Created by Push Chen on 7/24/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import "PYStaticLayer.h"
#import "PYRectangleCalc.h"

@interface PYInnerShadowLayer : PYStaticLayer
{
    PYPadding                           _shadowPadding;
    UIColor                             *_innerShadowColor;
    
    // Cached shadow path.
    CGFloat                             _maxPadding;
    UIBezierPath                        *_innerShadowPath;
    UIBezierPath                        *_outterBorderPath;
}

// The shadow layer's properties
@property (nonatomic, assign)   PYPadding               shadowPadding;
@property (nonatomic, strong)   UIColor                 *innerShadowColor;

@end
