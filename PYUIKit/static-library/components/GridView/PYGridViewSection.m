//
//  PYGridViewSection.m
//  PYUIKit
//
//  Created by Push Chen on 5/16/13.
//  Copyright (c) 2013 Markphone Culture Media Co.Ltd. All rights reserved.
//

#import "PYGridViewSection.h"
#import "PYGridView+Internal.h"
#import "PYGridViewCell.h"
#import "PYRect.h"
#import "UIView+PYUIKit.h"

@implementation PYGridViewSection

@synthesize invisiableView = _sectionInvisiableView;
@synthesize sectionView = _sectionView;
@synthesize sectionIndex = _sectionIndex;
@synthesize sectionFrame = _sectionFrame;
@synthesize scrollType = _scrollType;
@synthesize sectionType = _sectionType;
@synthesize isCollapsed = _isCollapsed;
@synthesize cellsInSection = _cellsInSection;

// Initialize the section structure.
- (id)initSectionWithGridView:(PYGridView *)gridView
                 sectionIndex:(NSUInteger)index
{
    self = [super init];
    if ( self ) {
        _sectionInvisiableView = [[UIView alloc] init];
        [_sectionInvisiableView setBackgroundColor:[UIColor clearColor]];
        
        _parentGridView = gridView;
        _sectionIndex = index;
        _scrollType = _parentGridView.scrollType;
        _sectionType = _parentGridView.sectionType;
        
        _loadedCellRange = NSMakeRange(0, 0);
        _sectionFrame = CGRectZero;
        _visiableCellFrame = CGRectZero;
        _cellsInSection = [NSMutableArray array];
        _cellFrameCache = [NSMutableArray array];
        
        _sectionView = [_parentGridView _dequeueSectionViewInCacheAtIndex:_sectionIndex];
        _headFrame = (_sectionView == nil) ? CGRectZero : _sectionView.bounds;
        _cellFrameCache = [_parentGridView _cellsSizeCacheInSection:_sectionIndex];
        _cellCount = [_cellFrameCache count];
        _allDataSize = [_parentGridView _allSizeOfSection:_sectionIndex].size;
        _ALONG_SIDE_(_allDataSize.width) -= _ALONG_SIDE_SIZE(_headFrame);
        
        //[self _updateCellSizeCacheInRange:NSMakeRange(0, _cellCount)];
        CGSize _gridSize = _parentGridView.bounds.size;
        _sectionFrame = [_parentGridView _allSizeOfSection:_sectionIndex];
        _STATIC_SIDE_SIZE(_sectionFrame) = _STATIC_SIDE_(_gridSize.width);
        [_sectionInvisiableView setFrame:_sectionFrame];
        _visiableCellFrame.origin.x = _sectionFrame.origin.x;
        _visiableCellFrame.origin.y = _sectionFrame.origin.y;
    }
    return self;
}

- (id)initSectionWithGridView:(PYGridView *)gridView
                 sectionIndex:(NSUInteger)index
                cellSizeCache:(NSArray *)cellCache
                   headerView:(UIView *)headerView
{
    self = [super init];
    if ( self ) {
        _sectionInvisiableView = [[UIView alloc] init];
        [_sectionInvisiableView setBackgroundColor:[UIColor clearColor]];
        _parentGridView = gridView;
        _sectionIndex = index;
        _scrollType = _parentGridView.scrollType;
        _sectionType = _parentGridView.sectionType;
        
        _loadedCellRange = NSMakeRange(0, 0);
        _sectionFrame = CGRectZero;
        _visiableCellFrame = CGRectZero;
        _cellsInSection = [NSMutableArray array];
        _cellFrameCache = [NSMutableArray array];
        
        _sectionView = headerView;
        _headFrame = (_sectionView == nil) ? CGRectZero : _sectionView.bounds;
        _cellFrameCache = [NSMutableArray arrayWithArray:cellCache];
        _cellCount = [_cellFrameCache count];
        _allDataSize = CGSizeZero;
        for ( NSValue *_v in cellCache ) {
            CGSize _s = CGSizeZero;
            [_v getValue:&_s];
            _ALONG_SIDE_(_allDataSize.width) += _ALONG_SIDE_(_s.width);
        }
        
        //[self _updateCellSizeCacheInRange:NSMakeRange(0, _cellCount)];
        CGSize _gridSize = _parentGridView.bounds.size;
        _sectionFrame = CGRectMake(0, 0, _allDataSize.width, _allDataSize.height);
        _ALONG_SIDE_SIZE(_sectionFrame) += _ALONG_SIDE_SIZE(_headFrame);
        _STATIC_SIDE_SIZE(_sectionFrame) = _STATIC_SIDE_(_gridSize.width);
        [_sectionInvisiableView setFrame:_sectionFrame];
        _visiableCellFrame.origin.x = _sectionFrame.origin.x;
        _visiableCellFrame.origin.y = _sectionFrame.origin.y;
    }
    return self;
}

- (void)_updateCellSizeCacheInRange:(NSRange)cellRange
{
    // Assertion.
    assert((cellRange.location == 0 && cellRange.length <= _cellCount) ||
           (cellRange.location < _cellCount - 1 &&
            cellRange.location + cellRange.length <= _cellCount));
    
    int _maxCount = cellRange.location + cellRange.length;
    for ( NSUInteger i = cellRange.location; i < _maxCount; ++i ) {
        CGSize _sizeOfCell = [_parentGridView
                              _cellSizeAtIndexPath:
                              [NSIndexPath indexPathForRow:i
                                                 inSection:_sectionIndex]];
        if ( i >= [_cellFrameCache count] ) {
            [_cellFrameCache addObject:[NSValue valueWithCGSize:_sizeOfCell]];
        } else {
            NSValue *_oldValue = [_cellFrameCache objectAtIndex:i];
            CGSize _oldSize;
            [_oldValue getValue:&_oldSize];
            _allDataSize.width -= _oldSize.width;
            _allDataSize.height -= _oldSize.height;
            [_cellFrameCache removeObjectAtIndex:i];
            [_cellFrameCache insertObject:[NSValue valueWithCGSize:_sizeOfCell] atIndex:i];
        }
        _allDataSize.width += _sizeOfCell.width;
        _allDataSize.height += _sizeOfCell.height;
    }
    
    // update the section frame
    if ( _isCollapsed ) return;
    //_sectionFrame.size.width
    CGSize _gridSize = _parentGridView.bounds.size;
    CGRect _headerFrame = (_sectionView == nil) ? CGRectZero : _sectionView.bounds;
    _sectionFrame.size.width = (_allDataSize.width + _headerFrame.size.width);
    _sectionFrame.size.height = (_allDataSize.height + _headerFrame.size.height);
    if ( _scrollType == PYGridViewHorizontal ) {
        _sectionFrame.size.height = _gridSize.height;
    } else {
        _sectionFrame.size.width = _gridSize.width;
    }
    [_sectionInvisiableView setFrame:_sectionFrame];
}

- (void)loadCellsWithinVisiableFrame:(CGRect)visiableFrame fromTop:(BOOL)loadFromTop
{
    CGSize _offset = CGSizeZero;
    if ( _scrollType == PYGridViewHorizontal ) {
        if ( loadFromTop ) {
            _offset.width = -CGRectGetWidth(visiableFrame);
            _sectionFrame.origin.x = visiableFrame.origin.x + CGRectGetWidth(visiableFrame);
            _visiableCellFrame.origin.x = _sectionFrame.origin.x;
        }
        else {
            _offset.width = CGRectGetWidth(visiableFrame);
            _sectionFrame.origin.x = visiableFrame.origin.x - CGRectGetWidth(_sectionFrame);
            _visiableCellFrame.origin.x = _sectionFrame.origin.x + _sectionFrame.size.width;
        }
    } else {
        if ( loadFromTop ) {
            _offset.height = -CGRectGetHeight(visiableFrame);
            _sectionFrame.origin.y = visiableFrame.origin.y + CGRectGetHeight(visiableFrame);
            _visiableCellFrame.origin.y = _sectionFrame.origin.y;
        }
        else {
            _offset.height = CGRectGetHeight(visiableFrame);
            _sectionFrame.origin.y = visiableFrame.origin.y - CGRectGetHeight(_sectionFrame);
            _visiableCellFrame.origin.y = _sectionFrame.origin.y + _sectionFrame.size.height;
        }
    }
    
    if ( _sectionView != nil ) {
        [_parentGridView _displaySectionView:_sectionView];
    }

    [_sectionInvisiableView setFrame:_sectionFrame];
    [_parentGridView _addNewSection:self];
    // Move with offset.
    //_loadedCellRange = NSMakeRange( (loadFromTop ? 0 : _cellCount), 0);
    _loadedCellRange.location = (loadFromTop ? 0 : _cellCount);
    [self visiableSectionMoveToOffset:_offset withVisiableFrame:visiableFrame];
}

- (void)updateVisiableCells
{
    [self _updateCellSizeCacheInRange:_loadedCellRange];
    int _maxCount = _loadedCellRange.location + _loadedCellRange.length;
    CGFloat _startPoint = 0.f;
    for ( NSUInteger i = _loadedCellRange.location; i < _maxCount; ++i ) {
        PYGridViewCell *_cell = [_cellsInSection objectAtIndex:(i - _loadedCellRange.location)];
        NSValue *_cellSizeV = [_cellFrameCache objectAtIndex:i];
        CGSize _cellSize = CGSizeZero;
        [_cellSizeV getValue:&_cellSize];
        CGRect _cellFrame = _cell.realFrame;
        if ( _scrollType == PYGridViewHorizontal ) {
            _cellFrame.size.width = _cellSize.width;
            if ( i == _loadedCellRange.location ) {
                _startPoint = _cell.realFrame.origin.x + _cellSize.width;
            } else {
                _cellFrame.origin.x = _startPoint;
                _startPoint += _cellSize.width;
            }
        } else {
            _cellFrame.size.height = _cellSize.height;
            if ( i == _loadedCellRange.location ) {
                _startPoint = _cell.realFrame.origin.y + _cellSize.height;
            } else {
                _cellFrame.origin.y = _startPoint;
                _startPoint += _cellSize.height;
            }
        }
        [_cell setFrame:_cellFrame];
    }
}

// Move the section group
- (void)visiableSectionMoveToOffset:(CGSize)offset withVisiableFrame:(CGRect)visiableFrame
{
    _ALONG_SIDE_ORIGIN(_sectionFrame) += _ALONG_SIDE_(offset.width);
    [_sectionInvisiableView setFrame:_sectionFrame];
    
    BOOL _needMore = _ALONG_SIDE_(offset.width) <= 0;
    CGFloat _offset = _ALONG_SIDE_(offset.width);
    
    CGRect _mappedVisiableFrame = visiableFrame;
    // Check and load new cells
    // Need to fake the visiable cell frame if is from bottom to top
    //visiableFrame = CGRectCrop(visiableFrame, _sectionFrame, NO);
    _ALONG_SIDE_ORIGIN(_mappedVisiableFrame) = (_ALONG_SIDE_ORIGIN(visiableFrame) -
                                                _ALONG_SIDE_ORIGIN(_sectionFrame));
        
    if ( [_cellsInSection count] == 0 ) {
        _visiableCellFrame = CGRectZero;
        _ALONG_SIDE_SIZE(_visiableCellFrame) = 0;
        if ( _needMore == YES ) {
            //_ALONG_SIDE_ORIGIN(_visiableCellFrame) -= _offset;
            _ALONG_SIDE_ORIGIN(_visiableCellFrame) += _ALONG_SIDE_SIZE(_headFrame);
        } else {
            _ALONG_SIDE_ORIGIN(_visiableCellFrame) = _ALONG_SIDE_SIZE(_sectionFrame);
        }
    } else {
        int _c = [_cellsInSection count];
        _visiableCellFrame = ((PYGridViewCell *)[_cellsInSection objectAtIndex:0]).realFrame;
        for ( int i = 1; i < _c; ++i ) {
            PYGridViewCell *_ = [_cellsInSection objectAtIndex:i];
            _visiableCellFrame = CGRectCombine(_visiableCellFrame, _.realFrame);
        }
    }
    
    if ( _sectionView != nil ) {
        // Stick to the top of visiableFrame
        _STATIC_SIDE_ORIGIN(_headFrame) = 0.f;
        if ( _sectionType == PYGridViewSectionFloat ) {
            if ( _ALONG_SIDE_SIZE(_headFrame) <= _ALONG_SIDE_SIZE(visiableFrame)) {
                // Stick to top
                _ALONG_SIDE_ORIGIN(_headFrame) = _ALONG_SIDE_ORIGIN(visiableFrame);
            } else {
                CGFloat _alongOrigin = _ALONG_SIDE_ORIGIN(visiableFrame);
                if ( _alongOrigin == 0 ) {
                    // top side
                    // stick to bottom
                    _ALONG_SIDE_ORIGIN(_headFrame) = (_ALONG_SIDE_ORIGIN(visiableFrame) +
                                                      _ALONG_SIDE_SIZE(visiableFrame) -
                                                      _ALONG_SIDE_SIZE(_headFrame));
                } else {
                    // stick to top
                    _ALONG_SIDE_ORIGIN(_headFrame) = _ALONG_SIDE_ORIGIN(visiableFrame);
                }
            }
        } else {
            _ALONG_SIDE_ORIGIN(_headFrame) = _ALONG_SIDE_ORIGIN(_sectionFrame);
        }
        [_sectionView setFrame:_headFrame];
    }
    
    CGSize _gridSize = _parentGridView.bounds.size;
    
    // Initialize
    CGRect _nowHeadFrame = _headFrame;
    _ALONG_SIDE_ORIGIN(_nowHeadFrame) -= _ALONG_SIDE_ORIGIN(_sectionFrame);
    
    CGRect _willVisiableRect = _visiableCellFrame;
    _ALONG_SIDE_ORIGIN(_willVisiableRect) += _offset;
    if ( CGRectJoined(_willVisiableRect, _nowHeadFrame) ) {
        _willVisiableRect = CGRectCombine(_willVisiableRect, _nowHeadFrame);
    }
    while ( !CGRectInside(_mappedVisiableFrame, _willVisiableRect) ) {
        int _cellIndex = (_needMore ?
                          _loadedCellRange.length + _loadedCellRange.location :
                          _loadedCellRange.location - 1);
        if ( _cellIndex < 0 || _cellIndex >= _cellCount ) break;
        PYGridViewCell *_newCell = [_parentGridView
                                    _loadNewCellAtIndexPath:
                                    [NSIndexPath indexPathForRow:_cellIndex
                                                       inSection:_sectionIndex]];
        
        assert(_newCell != nil);
        NSValue *_cellSizeV = [_cellFrameCache objectAtIndex:_cellIndex];
        CGSize _cellSize = CGSizeZero;
        [_cellSizeV getValue:&_cellSize];
        CGRect _cellFrame = CGRectMake(0, 0, _cellSize.width, _cellSize.height);
        
        //*(&_cellFrame.origin.x + _opType) = 0;
        _STATIC_SIDE_SIZE(_cellFrame) = _STATIC_SIDE_(_gridSize.width);
        
        if ( _needMore ) {
            _ALONG_SIDE_ORIGIN(_cellFrame) = (_ALONG_SIDE_SIZE(_visiableCellFrame) +
                                              _ALONG_SIDE_ORIGIN(_visiableCellFrame));
            [_cellsInSection addObject:_newCell];
            _loadedCellRange.length += 1;
        } else {
            _ALONG_SIDE_ORIGIN(_cellFrame) = (_ALONG_SIDE_ORIGIN(_visiableCellFrame) -
                                              _ALONG_SIDE_(_cellSize.width));
            _ALONG_SIDE_ORIGIN(_visiableCellFrame) -= _ALONG_SIDE_(_cellSize.width);
            [_cellsInSection insertObject:_newCell atIndex:0];
            _loadedCellRange.location -= 1;
            _loadedCellRange.length += 1;
        }
        
        _ALONG_SIDE_SIZE(_visiableCellFrame) += _ALONG_SIDE_(_cellSize.width);
        _STATIC_SIDE_SIZE(_visiableCellFrame) = _STATIC_SIDE_(_gridSize.width);
        
        [_newCell setFrame:_cellFrame];
        [_parentGridView _displayNewCell:_newCell inSection:self];
        _willVisiableRect = _visiableCellFrame;
        _ALONG_SIDE_ORIGIN(_willVisiableRect) += _offset;
        if ( CGRectJoined(_willVisiableRect, _nowHeadFrame) ) {
            _willVisiableRect = CGRectCombine(_willVisiableRect, _nowHeadFrame);
        }
    }
    
    NSMutableArray *_removeList = [NSMutableArray array];
    for ( PYGridViewCell *_cell in _cellsInSection ) {
        CGRect _cellFrame = _cell.realFrame;
        if ( ! CGRectJoined(_cellFrame, _mappedVisiableFrame) ) {
            [_removeList addObject:_cell];
        }
    }
    
    for ( PYGridViewCell *_cell in _removeList ) {
        [_cellsInSection removeObject:_cell];
        [_parentGridView _removeCell:_cell];
    }
    
    // Update the loaded range
    _loadedCellRange.length = [_cellsInSection count];
    if ( _loadedCellRange.length > 0 ) {
        PYGridViewCell *_firstCell = [_cellsInSection objectAtIndex:0];
        _loadedCellRange.location = _firstCell.indexPath.row;
    }
}

// Remove the section.
- (void)removeSectionFromGridView
{
    [_parentGridView _enqueueSectionView:_sectionView atIndex:_sectionIndex];
    for ( PYGridViewCell *_cell in _cellsInSection ) {
        [_parentGridView _removeCell:_cell];
    }
    
    [_cellsInSection removeAllObjects];
    [_sectionInvisiableView removeFromSuperview];
    _sectionInvisiableView = nil;
}

- (void)collapseSection
{
    // If section view is emtpy, cannot collapse.
    if ( _sectionView == nil ) return;
    
}
- (void)unCollapseSection
{
    if ( _sectionView == nil ) return;
}

@end
