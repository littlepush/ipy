//
//  PYTableContentView.m
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

#import "PYTableContentView.h"
#import "PYTableView+Content.h"

#define _SIDE_ITEM_C(_item)                                                     \
    ((float *)(&(_item)))[(int)((self.tableView.scrollSide & PYScrollHorizontal) == 0)]
#define _VSIDE_ITEM_C(_item)                                                    \
    ((float *)(&(_item)))[(int)((self.tableView.scrollSide & PYScrollHorizontal) != 0)]

@interface PYTableViewCell (Content)
// Set the cell's index after loading
- (void)setCellIndex:(NSInteger)index;
@end

@implementation PYTableViewCell (Content)
- (void)setCellIndex:(NSInteger)index
{
    _cellIndex = index;
}
@end

// Content Implementation
@implementation PYTableContentView

@synthesize tableView;
@dynamic visiableCells;
- (NSArray *)visiableCells
{
    return [self.subviews copy];
}

- (void)viewJustBeenCreated
{
    [super viewJustBeenCreated];
    _visiableContentFrame = CGRectZero;
    _visiableBounds = CGRectZero;
}

- (CGRect)tableViewBoundsToContentOffset
{
    CGRect _tableBounds = self.tableView.bounds;
    CGRect _myFrame = self.frame;
    _tableBounds.origin.x = -_myFrame.origin.x;
    _tableBounds.origin.y = -_myFrame.origin.y;
    return _tableBounds;
}

// Return specified index of cell. if the cell is not visiable, return nil;
- (PYTableViewCell *)cellForRowAtIndex:(NSInteger)index
{
    for ( PYTableViewCell *_cell in self.subviews ) {
        if ( ![_cell isKindOfClass:[PYTableViewCell class]] ) continue;
        if ( _cell.cellIndex == index ) return _cell;
    }
    return nil;
}

// Load new cell to current content view before move to specified distance.
- (void)organizedCellsInContentViewWithMoveDistance:(CGSize)distance
{
    if ( self.tableView == nil ) return;
    CGRect _tableViewOffset = [self tableViewBoundsToContentOffset];
    _tableViewOffset.origin.x -= distance.width;
    _tableViewOffset.origin.y -= distance.height;
    PYRectCrop(self.bounds, _tableViewOffset, &_visiableBounds);
    while ( !PYIsRectInside(_visiableBounds, _visiableContentFrame) ) {
        // Load new cell.
        if ( _SIDE_ITEM_C(distance) > 0 ) {
            // Load previous
            PYTableViewCell *_topCell = [self.subviews safeObjectAtIndex:0];
            int _currentIndex = self.tableView.cellCount;
            if ( _topCell != nil ) {
                _currentIndex = _topCell.cellIndex;
            }
            if ( _currentIndex == 0 ) return;
            PYTableViewCell *_newCell = [self.tableView getCellAtIndexFromDataSource:_currentIndex - 1];
            if ( _newCell == nil ) return;
            [_newCell setCellIndex:(_currentIndex - 1)];
            // Tell the delegate.
            [self insertSubview:_newCell atIndex:0];
            CGRect _cFrame = _newCell.frame;
            _SIDE_ITEM_C(_visiableContentFrame.origin) -= _SIDE_ITEM_C(_cFrame.size);
            _SIDE_ITEM_C(_visiableContentFrame.size) += _SIDE_ITEM_C(_cFrame.size);
            _VSIDE_ITEM_C(_visiableContentFrame.size) = _VSIDE_ITEM_C(_cFrame.size);
        } else {
            // Load more
            PYTableViewCell *_lastCell = [self.subviews lastObject];
            int _currentIndex = -1;
            if ( _lastCell != nil ) {
                _currentIndex = _lastCell.cellIndex;
            }
            if ( _currentIndex == (self.tableView.cellCount - 1) ) return;
            PYTableViewCell *_newCell = [self.tableView getCellAtIndexFromDataSource:_currentIndex + 1];
            if ( _newCell == nil ) return;
            [_newCell setCellIndex:(_currentIndex + 1)];
            // Tell the delegate;
            [self addSubview:_newCell];
            CGRect _cFrame = _newCell.frame;
            _SIDE_ITEM_C(_visiableContentFrame.size) += _SIDE_ITEM_C(_cFrame.size);
            _VSIDE_ITEM_C(_visiableContentFrame.size) = _VSIDE_ITEM_C(_cFrame.size);
        }
    }
}

// Clear out-of-bounds cells in current content view when did move
// to specified distance.
- (void)clearOutOfBoundsCellsWithDistance:(CGSize)distance
{
    if ( self.tableView == nil ) return;
    CGRect _tableViewOffset = [self tableViewBoundsToContentOffset];
    PYRectCrop(self.bounds, _tableViewOffset, &_visiableBounds);
    NSMutableArray *_outOfBoundsArray = [NSMutableArray array];
    for ( PYTableViewCell *_cell in self.subviews ) {
        if ( ![_cell isKindOfClass:[PYTableViewCell class]] ) continue;
        if ( !PYIsRectJoined(_cell.frame, _visiableBounds) ) {
            [_outOfBoundsArray addObject:_cell];
            CGRect _sFrame = _cell.frame;
            if ( _SIDE_ITEM_C(distance) < 0 ) {
                // remove top
                _SIDE_ITEM_C(_visiableContentFrame.origin) += _SIDE_ITEM_C(_sFrame.size);
            } else {
                // remove bottom
            }
            _SIDE_ITEM_C(_visiableContentFrame.size) -= _SIDE_ITEM_C(_sFrame.size);
        }
    }
    if ( [_outOfBoundsArray count] == 0 ) return;
    for ( PYTableViewCell *_cell in _outOfBoundsArray ) {
        [self.tableView enqueueCellForReuse:_cell];
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if ( newSuperview != nil ) return;
    [self clearContents];
}

// Clear all cells.
- (void)clearContents
{
    if ( self.tableView == nil ) return;
    NSArray *_subViews = [self.subviews copy];
    for ( PYTableViewCell *_cell in _subViews ) {
        if ( [_cell isKindOfClass:[PYTableViewCell class]] == NO ) continue;
        [self.tableView enqueueCellForReuse:_cell];
    }
    _visiableContentFrame = CGRectZero;
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
