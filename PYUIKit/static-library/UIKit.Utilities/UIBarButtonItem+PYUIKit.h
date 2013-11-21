//
//  UIBarButtonItem+PYUIKit.h
//  PYUIKit
//
//  Created by Push Chen on 11/21/13.
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

@interface UIBarButtonItem (PYUIKit)

// Initialize the button item with specified image, button size is set by the image.
- (id)initWithImage:(UIImage *)normalImage
   highlightedImage:(UIImage *)highlightedImage
             target:(id)target
             action:(SEL)action;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
