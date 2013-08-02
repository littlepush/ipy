//
//  PYInnerShadowLayer.h
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

// @littlepush
// littlepush@gmail.com
// PYLab
