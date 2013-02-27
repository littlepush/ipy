//
//  UIView+Responsder.h
//  PYUIKit
//
//  Created by littlepush on 9/2/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Responsder)

/* Search for all sub views to find the first responsder */
-(UIView *) findFirstResponsder;

/* From the subview, to get the frame in specified superview */
-(CGPoint) originInSuperview:(UIView *)specifiedSuperview;

@end
