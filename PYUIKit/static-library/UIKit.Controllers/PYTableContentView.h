//
//  PYTableContentView.h
//  PYUIKit
//
//  Created by Push Chen on 8/15/13.
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

#import "PYView.h"
#import "PYTableView.h"
#import "PYTableViewCell.h"

@interface PYTableContentView : PYView
{
    CGRect                      _visiableContentFrame;
    CGRect                      _visiableBounds;
}

@property (nonatomic, assign)   PYTableView         *tableView;

// Visiable Cells.
@property (nonatomic, readonly) NSArray             *visiableCells;

// Return specified index of cell. if the cell is not visiable, return nil;
- (PYTableViewCell *)cellForRowAtIndex:(NSInteger)index;

// Load new cell to current content view before move to specified distance.
- (void)organizedCellsInContentViewWithMoveDistance:(CGSize)distance;

// Clear out-of-bounds cells in current content view when did move
// to specified distance.
- (void)clearOutOfBoundsCellsWithDistance:(CGSize)distance;

// Clear all cells.
- (void)clearContents;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
