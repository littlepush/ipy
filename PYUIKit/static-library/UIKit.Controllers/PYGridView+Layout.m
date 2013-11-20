//
//  PYGridView+Layout.m
//  PYUIKit
//
//  Created by Push Chen on 11/19/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import "PYGridView+Layout.h"
#import "PYGridItem.h"
#import "PYGridItem+GridView.h"

@implementation PYGridView (Layout)

- (void)_relayoutSubviewsAutoSetSelfFrame:(BOOL)changeFrame
{
    
}
- (void)_relayoutSubviews
{
    // Layout the sub cells
    CGRect _selfBounds = self.bounds;
    CGRect _headBounds = _headContainer.bounds;
    CGRect _footBounds = _footContainer.bounds;
    _footBounds.origin.y = (_selfBounds.size.height - _footBounds.size.height);
    [_footContainer setFrame:_footBounds];
    
    CGRect _cellBouds = self.bounds;
    _cellBouds.size.height -= (_headBounds.size.height + _footBounds.size.height);
    _cellBouds.origin.y = _headBounds.size.height;
    _cellBouds = CGRectInset(_cellBouds, _padding, _padding);
    [_containerView setFrame:_cellBouds];
    
    CGFloat _skipColumnPaddingSize = _padding * (_gridScale.column - 1);
    CGFloat _singleCellWidth = ((_cellBouds.size.width - _skipColumnPaddingSize) /
                                _gridScale.column);
    CGFloat _skipRowPaddingSize = _padding * (_gridScale.row - 1);
    CGFloat _singleCellHeight = ((_cellBouds.size.height - _skipRowPaddingSize) /
                                 _gridScale.row);
    
    for ( PYGridItem *_gridItem in self ) {
        CGRect _itemFrame = CGRectZero;
        _itemFrame.origin.x = (_gridItem.coordinate.y * (_singleCellWidth + _padding));
        _itemFrame.origin.y = (_gridItem.coordinate.x * (_singleCellHeight + _padding));
        _itemFrame.size.width = ((_gridItem.scale.column * _singleCellWidth) +
                                 ((_gridItem.scale.column - 1) * _padding));
        _itemFrame.size.height = ((_gridItem.scale.row * _singleCellHeight) +
                                  ((_gridItem.scale.row - 1) * _padding));
        [_gridItem _innerSetFrame:_itemFrame];
    }
}

@end
