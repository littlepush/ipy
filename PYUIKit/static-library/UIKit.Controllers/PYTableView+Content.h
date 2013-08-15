//
//  PYTableView+Content.h
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

#import "PYTableView.h"

@interface PYTableView (Content)

// Clear all content cells.
- (void)clearContents;

// Get the cell at specified index from the datasource.
- (PYTableViewCell *)getCellAtIndexFromDataSource:(NSInteger)index;

// Enqueue & Dequeue the cell.
- (void)enqueueCellForReuse:(PYTableViewCell *)cell;
- (PYTableViewCell *)dequeueCellWithSpecifiedReuseIdentify:(NSString *)identify;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
