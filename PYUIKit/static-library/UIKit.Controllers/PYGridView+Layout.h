//
//  PYGridView+Layout.h
//  PYUIKit
//
//  Created by Push Chen on 11/19/13.
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

#import "PYGridView.h"

@interface PYGridView (Layout)

// Reform all cells inside current grid view with fixed outbounds of the grid view.
// When invoked [-setFrame] of the grid view, will force to update the cells inside
// it. The function will re-calculate the cell width and height.
- (void)_reformCellsWithFixedOutbounds;

// Reform current grid view's bound according to the fixed cell's size.
// When a cell collapsed, tell the container grid view to update its bounds
// and then reform the rest cells.
- (void)_reformCellsWithFixedCellbounds;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
