//
//  PYTableView+Content.m
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

#import "PYTableView+Content.h"
#import "PYScrollView+SideAnimation.h"
#import "PYTableContentView.h"
#import "PYTableViewCell.h"

@implementation PYTableView (Content)

// Clear all content cells.
- (void)clearContents
{
    [self cancelAllAnimation];
    [self resetContentData];
    if ( _pCellFrame == NULL ) return;
    free( _pCellFrame );
    _pCellFrame = NULL;
    NSArray *_subContents = self.subContentViews;
    for ( PYTableContentView *_sView in _subContents ) {
        [_sView clearContents];
    }
}

// Get the cell at specified index from the datasource.
- (PYTableViewCell *)getCellAtIndexFromDataSource:(NSInteger)index
{
    if ( ![self.dataSource respondsToSelector:@selector(pytableView:cellForRowAtIndex:)] ) {
        PYLog(@"Must impelemente the cell for row at index selector");
        return nil;
    }
    PYTableViewCell *_cell = [self.dataSource pytableView:self cellForRowAtIndex:index];
    [_cell setFrame:_pCellFrame[index]];
    return _cell;
}

// Enqueue & Dequeue the cell.
- (void)enqueueCellForReuse:(PYTableViewCell *)cell
{
    [cell removeFromSuperview];
    
    // Drop this cell if it contains no reuse identifier.
    if ( [cell.reuseIdentifier length] == 0 ) return;
    NSMutableSet *_cellSets = [_cachedCells objectForKey:cell.reuseIdentifier];
    if ( _cellSets == nil ) {
        _cellSets = [NSMutableSet set];
        [_cachedCells setValue:_cellSets forKey:cell.reuseIdentifier];
    }
    [_cellSets addObject:cell];
}

- (PYTableViewCell *)dequeueCellWithSpecifiedReuseIdentify:(NSString *)identify
{
    if ( [identify length] == 0 ) return nil;
    NSMutableSet *_cellSets = [_cachedCells objectForKey:identify];
    if  ( _cellSets == nil ) return nil;
    if ( [_cellSets count] == 0 ) return nil;
    PYTableViewCell *_cell = [_cellSets anyObject];
    [_cellSets removeObject:_cell];
    [_cell prepareForReuse];
    return _cell;
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
