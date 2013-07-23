//
//  PYGridView+Internal.m
//  PYUIKit
//
//  Created by Push Chen on 5/16/13.
//  Copyright (c) 2013 Markphone Culture Media Co.Ltd. All rights reserved.
//

#import "PYGridView+Internal.h"
#import "PYGridViewCell.h"
#import "PYGridViewCell+Parent.h"
#import "UIColor+PYUIKit.h"
#import "PYGridViewSection.h"

#define kPYGridViewDefaultCellIdentify          @"kPYGridViewDefaultCellIdentify"

@implementation PYGridView (Internal)

- (PYGridViewCell *)_loadNewCellAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [self.datasource respondsToSelector:@selector(gridView:cellAtIndex:)] ) {
        PYGridViewCell *_newCell = [self.datasource gridView:self cellAtIndex:indexPath];
        [_newCell setIndexPathForCell:indexPath];
        return _newCell;
    } else {
        PYGridViewCell *_defaultCell = [self dequeueCellForIdentify:kPYGridViewDefaultCellIdentify];
        if ( _defaultCell == nil ) {
            _defaultCell = [[PYGridViewCell alloc]
                            initCellWithReusableIdentify:kPYGridViewDefaultCellIdentify];
            [_defaultCell cellJustBeenCreated];
            [_defaultCell setBackgroundColor:[UIColor randomColor]];
        }
        [_defaultCell setIndexPathForCell:indexPath];
        return _defaultCell;
    }
}

- (void)_addNewSection:(PYGridViewSection *)section
{
    [self insertSubview:section.invisiableView belowSubview:_coverView];
}

- (void)_displayNewCell:(PYGridViewCell *)cell inSection:(PYGridViewSection *)section
{
    // Call the delegate
    if ( [self.delegate respondsToSelector:@selector(gridView:willDisplayCell:atIndex:)] ) {
        [self.delegate gridView:self willDisplayCell:cell atIndex:cell.indexPath];
    }
    //[self insertSubview:cell belowSubview:_coverView];
    [section.invisiableView insertSubview:cell atIndex:0];
    [cell setHidden:NO];
    [cell setNeedsLayout];
}

- (void)_displaySectionView:(UIView *)sectionView
{
    [self insertSubview:sectionView aboveSubview:_coverView];
}

- (void)_removeCell:(PYGridViewCell *)cell
{
    // put into cache.
    @synchronized(self) {
        [cell removeFromSuperview];
        [cell setHidden:YES];
        if ( [cell.reusableIdentify length] == 0 ) {
            return;
        }
        NSMutableSet *_cellCacheForIdentify = [_cellsCache objectForKey:cell.reusableIdentify];
        if ( _cellCacheForIdentify == nil ) {
            _cellCacheForIdentify = [NSMutableSet set];
            [_cellsCache setObject:_cellCacheForIdentify forKey:cell.reusableIdentify];
        }
        [_cellCacheForIdentify addObject:cell];
    }
}

- (UIView *)_sectionViewAtIndex:(int)sectionIndex
{
    if ( sectionIndex == -1 ) return nil;
    if ( [self.datasource respondsToSelector:@selector(gridView:sectionViewAtIndex:)] ) {
        return [self.datasource gridView:self sectionViewAtIndex:sectionIndex];
    } else if ( [self.datasource respondsToSelector:@selector(gridView:sectionTitleAtIndex:)] ) {
//        NSString *_title = [self.datasource gridView:self sectionTitleAtIndex:sectionIndex];
//        PYView *_
    }
    return nil;
}

- (UIView *)_dequeueSectionViewInCacheAtIndex:(int)sectionIndex
{
    if ( sectionIndex == -1 || sectionIndex == _sectionCount ) return nil;
    if (sectionIndex >= [_sectionHeadViewCacheList count]) return nil;
    NSMutableSet *_sectionSet = [_sectionHeadViewCacheList objectAtIndex:sectionIndex];
    if ( [_sectionSet count] == 0 ) {
        return [self _sectionViewAtIndex:sectionIndex];
    } else {
        UIView *_sectionHeadView = [_sectionSet anyObject];
        [_sectionSet removeObject:_sectionHeadView];
        return _sectionHeadView;
    }
}

- (void)_enqueueSectionView:(UIView *)sectionView atIndex:(int)sectionIndex
{
    if ( sectionIndex == -1 || sectionIndex == _sectionCount) return;
    if ( sectionView == nil ) return;
    NSMutableSet *_sectionSet = [_sectionHeadViewCacheList objectAtIndex:sectionIndex];
    [_sectionSet addObject:sectionView];
    [sectionView removeFromSuperview];
}

- (NSUInteger)_cellCountOfSection:(int)sectionIndex
{
    if ( sectionIndex == -1 || sectionIndex == _sectionCount ) return 0;
    if ( [self.datasource respondsToSelector:@selector(gridView:numberOfCellsInSection:)] ) {
        return [self.datasource gridView:self numberOfCellsInSection:sectionIndex];
    }
    return 0;
}

- (CGSize)_cellSizeAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [self.datasource respondsToSelector:@selector(gridView:sizeOfCellAtIndex:)] ) {
        return [self.datasource gridView:self sizeOfCellAtIndex:indexPath];
    } else {
        CGSize _cellSize = CGSizeZero;
        if ( self.scrollType == PYGridViewHorizontal ) {
            _cellSize.width = 60.f;
        } else {
            _cellSize.height = 60.f;
        }
        return _cellSize;
    }
}

- (NSMutableArray *)_cellsSizeCacheInSection:(int)sectionIndex
{
    if ( sectionIndex == -1 || sectionIndex == _sectionCount ) return [NSMutableArray array];
    if ( sectionIndex >= [_sectionCellHeightCacheList count] )
        return [NSMutableArray array];
    return [_sectionCellHeightCacheList objectAtIndex:sectionIndex];
}

- (CGRect)_allSizeOfSection:(int)sectionIndex
{
    if ( sectionIndex == -1 || sectionIndex == _sectionCount ) return CGRectZero;
    if ( sectionIndex >= [_sectionCellsFrameCacheList count] )
        return CGRectZero;
    NSValue *_cachedValue = [_sectionCellsFrameCacheList objectAtIndex:sectionIndex];
    CGSize _cachedSize = CGSizeZero;
    [_cachedValue getValue:&_cachedSize];
    CGRect _sectionFrame = CGRectZero;
    _sectionFrame.size = _cachedSize;
    return _sectionFrame;
}

- (CGSize)_sectionHeadFrameAtIndex:(int)sectionIndex
{
    if ( sectionIndex == -1 || sectionIndex == _sectionCount ) {
        CGSize _s = CGSizeZero;
        if ( _cycleEnabled == NO && _headSection != nil ) {
            _s = _headSection.sectionView.frame.size;
            _STATIC_SIDE_(_s.width) = 0.f;
        }
        return _s;
    }
    if ( sectionIndex >= [_sectionHeadFrameCacheList count] ) {
        return CGSizeZero;
    }
    NSValue *_cachedValue = [_sectionHeadFrameCacheList objectAtIndex:sectionIndex];
    CGSize _cachedSize = CGSizeZero;
    [_cachedValue getValue:&_cachedSize];
    return _cachedSize;
}

- (void)_setSectionCollapseStatus:(BOOL)collapsed ofSection:(int)sectionIndex
{
    if ( sectionIndex == -1 || sectionIndex == _sectionCount ) return;
    if ( sectionIndex >= [_sectionCollapseStatusList count] ) return;
    [_sectionCollapseStatusList removeObjectAtIndex:sectionIndex];
    [_sectionCollapseStatusList insertObject:[NSNumber numberWithBool:collapsed]
                                     atIndex:sectionIndex];
}

- (BOOL)_sectionCollapseStatusOfSection:(int)sectionIndex
{
    if ( sectionIndex == -1 || sectionIndex == _sectionCount ) return YES;
    if ( sectionIndex >= [_sectionCollapseStatusList count] ) return YES;
    return [((NSNumber *)[_sectionCollapseStatusList
                          objectAtIndex:sectionIndex]) boolValue];
}

- (CGFloat)_sectionRealtimeSizeAtIndex:(int)sectionIndex
{
    if ( sectionIndex == -1 && _cycleEnabled == NO && _headSection != nil ) {
        CGRect _f = _headSection.sectionView.frame;
        return _ALONG_SIDE_SIZE(_f);
    }
    if ( sectionIndex == _sectionCount && _cycleEnabled == NO && _footSection != nil ) {
        CGRect _f = _footSection.sectionView.frame;
        return _ALONG_SIDE_SIZE(_f);
    }
    if ( sectionIndex == -1 || sectionIndex == _sectionCount ) return 0.f;
    BOOL _isCollapsed = [self _sectionCollapseStatusOfSection:sectionIndex];
    CGSize _nowSize = CGSizeZero;
    if ( _isCollapsed ) {
        CGRect _nowFrame = [self _allSizeOfSection:sectionIndex];
        _nowSize = _nowFrame.size;
    } else {
        _nowSize = [self _sectionHeadFrameAtIndex:sectionIndex];
    }
    return _ALONG_SIDE_(_nowSize.width);
}

- (void)_didSelectedCell:(PYGridViewCell *)cell atIndex:(NSIndexPath *)indexPath
{
    [_cellSelectedStatus setObject:[NSNumber numberWithBool:YES] forKey:indexPath];
    [cell setSelected:YES animated:YES];
    
    if ( _lastSelectedItem != nil ) {
        [_cellSelectedStatus setObject:[NSNumber numberWithBool:NO] forKey:_lastSelectedItem];
        int _sidx = _lastSelectedItem.section;
        for ( PYGridViewSection *_section in _visiableSections ) {
            if ( _section.sectionIndex == _sidx ) {
                NSArray *_cells = [_section cellsInSection];
                int _ridx = _lastSelectedItem.row;
                for ( PYGridViewCell *_lcell in _cells ) {
                    if (_lcell.indexPath.row == _ridx) {
                        [_lcell setSelected:NO animated:YES];
                        if ( [self.delegate respondsToSelector:@selector(gridView:didUnselectedCellAtIndex:)]) {
                            [self.delegate gridView:self didUnselectedCellAtIndex:_lastSelectedItem];
                        }
                        break;
                    }
                }
                break;
            }
        }
    }
    
    _lastSelectedItem = indexPath;
    
    if ( [self.delegate respondsToSelector:@selector(gridView:didSelectedCellAtIndex:)] ) {
        [self.delegate gridView:self didSelectedCellAtIndex:indexPath];
    }
}

- (BOOL)_cellSelectedStatusAtIndex:(NSIndexPath *)indexPath
{
    NSNumber *_status = [_cellSelectedStatus objectForKey:indexPath];
    if ( _status == nil ) return NO;
    return [_status boolValue];
}

@end
