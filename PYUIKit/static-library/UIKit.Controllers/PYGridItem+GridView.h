//
//  PYGridItem+GridView.h
//  PYUIKit
//
//  Created by Push Chen on 11/18/13.
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

#import "PYGridItem.h"

@interface PYGridItem (GridView)

// When create the cell node, set the initial coordinate info.
// And inside, automatically set the scale to {1, 1}
- (void)_initNodeAtIndex:(PYGridCoordinate)coordinate;

// When merge several cell nodes, update the scale of the node item.
- (void)_setScale:(PYGridScale)scale;

// Cause the cell's frame is calculated by the grid view, so the
// common [-setFrame] method is not available for invoking by
// end-user. We provide this method to change the frame of
// the cell, and the method can only be invoked by the parent grid view.
- (void)_innerSetFrame:(CGRect)frame;

// Bind the parent grid view object.
// The object is __unsafe_unretained. Be care to use _parentView.
- (void)_setParentGridView:(PYGridView __unsafe_unretained*)parent;

// Layout the subviews in the grid item.
- (void)_relayoutSubItems;

// Refresh all ui item state according to current state.
- (void)_updateUIStateAccordingToCurrentState;

// Internal Cell body frame (not contains the collapse view)
@property (nonatomic, readonly) CGRect      _innerFrame;

// Internal setting
// Set the UI info for different state of the cell item.
- (void)_setBackgroundColor:(UIColor *)color forState:(UIControlState)state;
- (void)_setBackgroundImage:(UIImage *)image forState:(UIControlState)state;
- (void)_setBorderWidth:(CGFloat)width forState:(UIControlState)state;
- (void)_setBorderColor:(UIColor *)color forState:(UIControlState)state;
- (void)_setShadowOffset:(CGSize)offset forState:(UIControlState)state;
- (void)_setShadowColor:(UIColor *)color forState:(UIControlState)state;
- (void)_setShadowOpacity:(CGFloat)opacity forState:(UIControlState)state;
- (void)_setShadowRadius:(CGFloat)radius forState:(UIControlState)state;
- (void)_setTitle:(NSString *)title forState:(UIControlState)state;
- (void)_setTextColor:(UIColor *)color forState:(UIControlState)state;
- (void)_setTextFont:(UIFont *)font forState:(UIControlState)state;
- (void)_setTextShadowOffset:(CGSize)offset forState:(UIControlState)state;
- (void)_setTextShadowRadius:(CGFloat)radius forState:(UIControlState)state;
- (void)_setTextShadowColor:(UIColor *)color forState:(UIControlState)state;
- (void)_setIconImage:(UIImage *)image forState:(UIControlState)state;
- (void)_setIndicateImage:(UIImage *)image forState:(UIControlState)state;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
