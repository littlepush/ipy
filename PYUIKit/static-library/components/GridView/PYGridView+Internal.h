//
//  PYGridView+Internal.h
//  PYUIKit
//
//  Created by Push Chen on 5/16/13.
//  Copyright (c) 2013 Markphone Culture Media Co.Ltd. All rights reserved.
//

#import "PYGridView.h"

#define _ALONG_SIDE_(r)                         *(&(r) + _scrollType)
#define _ALONG_SIDE_SIZE(r)                     _ALONG_SIDE_((r).size.width)
#define _ALONG_SIDE_ORIGIN(r)                   _ALONG_SIDE_((r).origin.x)
#define _STATIC_SIDE_(r)                        *(&(r) + 1 - _scrollType)
#define _STATIC_SIDE_SIZE(r)                    _STATIC_SIDE_((r).size.width)
#define _STATIC_SIDE_ORIGIN(r)                  _STATIC_SIDE_((r).origin.x)

@interface PYGridView (Internal)

- (PYGridViewCell *)_loadNewCellAtIndexPath:(NSIndexPath *)indexPath;

- (void)_addNewSection:(PYGridViewSection *)section;

- (void)_displayNewCell:(PYGridViewCell *)cell inSection:(PYGridViewSection *)section;

- (void)_displaySectionView:(UIView *)sectionView;

- (void)_removeCell:(PYGridViewCell *)cell;

- (UIView *)_sectionViewAtIndex:(int)sectionIndex;

- (UIView *)_dequeueSectionViewInCacheAtIndex:(int)sectionIndex;

- (void)_enqueueSectionView:(UIView *)sectionView atIndex:(int)sectionIndex;

- (NSUInteger)_cellCountOfSection:(int)sectionIndex;

- (CGSize)_cellSizeAtIndexPath:(NSIndexPath *)indexPath;

- (NSMutableArray *)_cellsSizeCacheInSection:(int)sectionIndex;

- (CGRect)_allSizeOfSection:(int)sectionIndex;

- (CGSize)_sectionHeadFrameAtIndex:(int)sectionIndex;

- (void)_setSectionCollapseStatus:(BOOL)collapsed ofSection:(int)sectionIndex;

- (BOOL)_sectionCollapseStatusOfSection:(int)sectionIndex;

- (CGFloat)_sectionRealtimeSizeAtIndex:(int)sectionIndex;

- (void)_didSelectedCell:(PYGridViewCell *)cell atIndex:(NSIndexPath *)indexPath;

- (BOOL)_cellSelectedStatusAtIndex:(NSIndexPath *)indexPath;

@end
