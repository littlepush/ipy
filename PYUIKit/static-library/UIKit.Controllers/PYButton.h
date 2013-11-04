//
//  PYButton.h
//  PYUIKit
//
//  Created by Push Chen on 7/30/13.
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

#import "PYResponderView.h"
#import "PYLabelLayer.h"
#import "PYImageLayer.h"

@interface PYButton : PYResponderView
{
    PYImageLayer                    *_imageLayer;
    PYImageLayer                    *_bkgImageLayer;
    PYLabelLayer                    *_labelLayer;
    
    BOOL                            _isEnabled;
    NSMutableArray                  *_btnTargetActions[9];
    
    /*
     UIControlEventTouchDown
     UIControlEventTouchDownRepeat
     UIControlEventTouchDragInside
     UIControlEventTouchDragOutside
     UIControlEventTouchDragEnter
     UIControlEventTouchDragExit
     UIControlEventTouchUpInside
     UIControlEventTouchUpOutside
     UIControlEventTouchCancel
     */
}

// Add event target
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

// A button can change the image/title/background-image info according to the state.
- (void)setTitle:(NSString *)title forState:(UIControlState)state;
- (void)setImage:(UIImage *)image forState:(UIControlState)state;
- (void)setImageUrl:(NSString *)imageUrl forState:(UIControlState)state;
- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state;
- (void)setBackgroundImageUrl:(UIImage *)imageUrl forState:(UIControlState)state;

// Get the title label.
@property (nonatomic, readonly) PYLabelLayer        *titleLabel;

@property (nonatomic, assign)   BOOL                isEnabled;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
