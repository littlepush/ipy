//
//  PYView.h
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

#import <UIKit/UIKit.h>
#import "PYInnerShadowLayer.h"

@interface PYView : UIView
{
    PYInnerShadowLayer                              *_shadowLayer;
    BOOL                                            _hasInvokeInit;
}

// Make PYView to support debug
+ (void)setDebugEnabled:(BOOL)enableDebug;

// Override the layer property.
@property (nonatomic, readonly) PYLayer             *coreLayer;
// Test
@property (nonatomic, readonly) PYLayer             *layer;

// Corner Radius
@property (nonatomic, assign)   CGFloat             cornerRadius;

// Inner Shadow Setting
@property (nonatomic, strong)   UIColor             *innerShadowColor;
@property (nonatomic, assign)   PYPadding           innerShadowRect;

// Border
@property (nonatomic, assign)   CGFloat             borderWidth;
@property (nonatomic, strong)   UIColor             *borderColor;

// Drop Shadow
@property (nonatomic, strong)   UIColor             *dropShadowColor;
@property (nonatomic, assign)   CGFloat             dropShadowRadius;
@property (nonatomic, assign)   CGFloat             dropShadowOpacity;
@property (nonatomic, assign)   CGSize              dropShadowOffset;
@property (nonatomic, assign)   UIBezierPath        *dropShadowPath;

// Add sub layer or sub view.
- (void)addChild:(id)child;

// Default Messages
- (void)viewJustBeenCreated;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
