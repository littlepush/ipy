//
//  PYInnerGlowLayer.h
//  PYUIKit
//
//  Created by Chen Push on 3/14/13.
//  Copyright (c) 2013 Markphone Culture Media Co.Ltd. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PYInnerShadowLayer.h"

@interface PYInnerGlowLayer : CALayer

@property (nonatomic, assign)   CGFloat         outCornerRadius;
@property (nonatomic, assign)   PYShadowRect    glowRect;
@property (nonatomic, strong)   UIColor         *innerGlowColor;

@end
