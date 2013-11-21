//
//  UIBarButtonItem+PYUIKit.m
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

#import "UIBarButtonItem+PYUIKit.h"

@implementation UIBarButtonItem (PYUIKit)

- (id)initWithImage:(UIImage *)normalImage highlightedImage:(UIImage *)highlightedImage
             target:(id)target action:(SEL)action
{
    if ( normalImage == nil ) {
        return [self initWithTitle:@"" style:UIBarButtonItemStylePlain target:target action:action];
    } else {
        UIButton *_cusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cusButton setBackgroundColor:[UIColor clearColor]];
        [_cusButton setImage:normalImage forState:UIControlStateNormal];
        if ( highlightedImage != nil ) {
            [_cusButton setImage:highlightedImage forState:UIControlStateHighlighted];
        }
        [_cusButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        CGFloat _scale = [UIScreen mainScreen].scale;
        [_cusButton setBounds:CGRectMake(0, 0,
                                         normalImage.size.width / _scale,
                                         normalImage.size.height / _scale)];
        return [self initWithCustomView:_cusButton];
    }
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
