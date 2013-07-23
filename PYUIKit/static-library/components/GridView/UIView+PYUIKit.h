//
//  UIView+PYUIKit.h
//  PYUIKit
//
//  Created by Chen Push on 3/11/13.
//  Copyright (c) 2013 Markphone Culture Media Co.Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (PYUIKit)

/* Search for all sub views to find the first responsder */
- (UIView *)findFirstResponsder;

/* From the subview, to get the frame in specified superview */
- (CGPoint)originInSuperview:(UIView *)specifiedSuperview;

/* Capture the screen */
+ (UIImage *)captureScreen;

@end
