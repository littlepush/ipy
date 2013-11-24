//
//  PYGridView+Layout.m
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

#import "PYGridView+Layout.h"
#import "PYGridItem.h"
#import "PYGridItem+GridView.h"

@implementation PYGridView (Layout)

- (void)_reformCellsWithFixedOutbounds
{
    // Set head and foot bounds
    CGRect _selfBounds = self.bounds;
    CGRect _headBounds = _headContainer.bounds;
    CGRect _footBounds = _footContainer.bounds;
    _footBounds.origin.y = (_selfBounds.size.height - _footBounds.size.height);
    [_footContainer setFrame:_footBounds];
    
    // Set container bounds
    CGRect _cellBouds = self.bounds;
    _cellBouds.size.height -= (_headBounds.size.height + _footBounds.size.height);
    _cellBouds.origin.y = _headBounds.size.height;
    _cellBouds = CGRectInset(_cellBouds, _padding, _padding);
    [_containerView setFrame:_cellBouds];
    
    CGFloat *_rowRate = (CGFloat *)malloc(sizeof(CGFloat) * _gridScale.row);
    CGFloat *_columnRate = (CGFloat *)malloc(sizeof(CGFloat) * _gridScale.column);
    for ( int i = 0; i < _gridScale.row; ++i ) _rowRate[i] = 1.f;
    for ( int i = 0; i < _gridScale.column; ++i ) _columnRate[i] = 1.f;
    for ( PYGridItem *_gridItem in self ) {
        // Try to find the collapsed item.
        if ( _gridItem.isCollapsed == NO ) continue;
        if ( _gridItem.collapseDirection == PYGridItemCollapseDirectionHorizontal ) {
            if ( _columnRate[_gridItem.coordinate.y] > (_gridItem.collapseRate + 1) ) continue;
            _columnRate[_gridItem.coordinate.y] = (_gridItem.collapseRate + 1);
        } else {
            if ( _rowRate[_gridItem.coordinate.x] > (_gridItem.collapseRate + 1) ) continue;
            _rowRate[_gridItem.coordinate.x] = (_gridItem.collapseRate + 1);
        }
    }
    CGFloat _rowSize = 0;
    for ( int i = 0; i < _gridScale.row; ++i ) _rowSize += _rowRate[i];
    CGFloat _columnSize = 0;
    for ( int i = 0; i < _gridScale.column; ++i ) _columnSize += _columnRate[i];
    
    CGFloat _skipColumnPaddingSize = _padding * (_gridScale.column - 1);
    CGFloat _singleCellWidth = ((_cellBouds.size.width - _skipColumnPaddingSize) /
                                _columnSize);
    CGFloat _skipRowPaddingSize = _padding * (_gridScale.row - 1);
    CGFloat _singleCellHeight = ((_cellBouds.size.height - _skipRowPaddingSize) /
                                 _rowSize);

    for ( PYGridItem *_gridItem in self ) {
        CGRect _itemFrame = CGRectZero;
        // Try to calculate the item frame.
        CGFloat _f_column = 0.f;
        CGFloat _f_row = 0.f;
        
        for ( int i = 0; i < _gridItem.coordinate.y; ++ i ) _f_column += _columnRate[i];
        for ( int i = 0; i < _gridItem.coordinate.x; ++i ) _f_row += _rowRate[i];
        _itemFrame.origin.x = (_f_column * _singleCellWidth +
                               _gridItem.coordinate.y * _padding);
        _itemFrame.origin.y = (_f_row * _singleCellHeight +
                               (_gridItem.coordinate.x * _padding));
        _itemFrame.size.width = ((_gridItem.scale.column * _singleCellWidth) +
                                 ((_gridItem.scale.column - 1) * _padding));
        _itemFrame.size.height = ((_gridItem.scale.row * _singleCellHeight) +
                                  ((_gridItem.scale.row - 1) * _padding));
        [_gridItem _innerSetFrame:_itemFrame];
    }

    // Free the temp data.
    free( _rowRate );
    free( _columnRate );
}

- (void)_reformCellsWithFixedCellbounds
{
    // Because the first item must be 0,0, so it's fixed.
    PYGridItem *_fixedItem = _gridConfig[0][0];
    CGSize _cellSize = _fixedItem._innerFrame.size;
    _cellSize.width -= (_padding * (_fixedItem.scale.column - 1));
    _cellSize.height -= (_padding * (_fixedItem.scale.row - 1));
    
    CGSize _allSize = CGSizeZero;
    _allSize.height += (_headContainer.bounds.size.height + _footContainer.bounds.size.height);
    _allSize.height += (_padding * 2);
    _allSize.width += (_padding * 2);
    
    // Calculate the container's frame
    CGFloat *_rowRate = (CGFloat *)malloc(sizeof(CGFloat) * _gridScale.row);
    CGFloat *_columnRate = (CGFloat *)malloc(sizeof(CGFloat) * _gridScale.column);
    for ( int i = 0; i < _gridScale.row; ++i ) _rowRate[i] = 1.f;
    for ( int i = 0; i < _gridScale.column; ++i ) _columnRate[i] = 1.f;
    for ( PYGridItem *_gridItem in self ) {
        // Try to find the collapsed item.
        if ( _gridItem.isCollapsed == NO ) continue;
        if ( _gridItem.collapseDirection == PYGridItemCollapseDirectionHorizontal ) {
            if ( _columnRate[_gridItem.coordinate.y] > (_gridItem.collapseRate + 1) ) continue;
            _columnRate[_gridItem.coordinate.y] = (_gridItem.collapseRate + 1);
        } else {
            if ( _rowRate[_gridItem.coordinate.x] > (_gridItem.collapseRate + 1) ) continue;
            _rowRate[_gridItem.coordinate.x] = (_gridItem.collapseRate + 1);
        }
    }
    CGFloat _rowSize = 0;
    for ( int i = 0; i < _gridScale.row; ++i ) _rowSize += _rowRate[i];
    CGFloat _columnSize = 0;
    for ( int i = 0; i < _gridScale.column; ++i ) _columnSize += _columnRate[i];
    
    // Update the container frame.
    CGFloat _width = (_columnSize * _cellSize.width + (_gridScale.column - 1) * _padding);
    CGFloat _height = (_rowSize * _cellSize.height + (_gridScale.row - 1) * _padding);
    CGRect _ctntFrame = CGRectMake(_padding, _headContainer.bounds.size.height + _padding,
                                   _width, _height);
    [_containerView setFrame:_ctntFrame];
    
    // Update self frame
    _allSize.height += _height;
    _allSize.width += _width;
    CGRect _myFrame = self.frame;
    _myFrame.size = _allSize;
    [super setFrame:_myFrame];
    
    // Update the foot frame
    CGRect _footFrame = _footContainer.frame;
    _footFrame.origin.y = _allSize.height - _footFrame.size.height;
    _footFrame.size.width = _allSize.width;
    [_footContainer setFrame:_footFrame];
    
    // Update the head frame
    CGRect _headFrame = _headContainer.frame;
    _headFrame.size.width = _allSize.width;
    [_headContainer setFrame:_headFrame];
    
    // Update cells frame
    for ( PYGridItem *_gridItem in self ) {
        CGRect _itemFrame = CGRectZero;
        // Try to calculate the item frame.
        CGFloat _f_column = 0.f;
        CGFloat _f_row = 0.f;
        
        for ( int i = 0; i < _gridItem.coordinate.y; ++ i ) _f_column += _columnRate[i];
        for ( int i = 0; i < _gridItem.coordinate.x; ++i ) _f_row += _rowRate[i];
        _itemFrame.origin.x = (_f_column * _cellSize.width +
                               _gridItem.coordinate.y * _padding);
        _itemFrame.origin.y = (_f_row * _cellSize.height +
                               (_gridItem.coordinate.x * _padding));
        _itemFrame.size.width = ((_gridItem.scale.column * _cellSize.width) +
                                 ((_gridItem.scale.column - 1) * _padding));
        _itemFrame.size.height = ((_gridItem.scale.row * _cellSize.height) +
                                  ((_gridItem.scale.row - 1) * _padding));
        [_gridItem _innerSetFrame:_itemFrame];
    }
   
    // Free the temp data.
    free( _rowRate );
    free( _columnRate );
    
    if ( [self.delegate respondsToSelector:@selector(pyGridViewDidChangedFrameForCollapseStateChanged:)] ) {
        [self.delegate pyGridViewDidChangedFrameForCollapseStateChanged:self];
    }
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
