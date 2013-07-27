//
//  PYView.h
//  PYUIKit
//
//  Created by Push Chen on 7/24/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PYInnerShadowLayer.h"

@interface PYView : UIView
{
    PYInnerShadowLayer                              *_shadowLayer;
}

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
