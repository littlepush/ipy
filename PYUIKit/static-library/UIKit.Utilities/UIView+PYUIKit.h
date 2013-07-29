//
//  UIView+PYUIKit.h
//  PYUIKit
//
//  Created by Push Chen on 7/30/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
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
