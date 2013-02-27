//
//  UIScrollView+KeyboardExtended.h
//  PYUIKit
//
//  Created by Wang Pei(tsubasa) on 8/31/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (KeyboardExtended)

// Register the scroll view to handle keyboard event
- (void)resgisterScrollKeyboardEvent;

// Unegister the scroll view to handle keyboard event
- (void)unresgisterScrollKeyboardEvent;

@end
