//
//  PYGridViewSection.h
//  PYUIKit
//
//  Created by Push Chen on 5/16/13.
//  Copyright (c) 2013 Markphone Culture Media Co.Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PYGridView.h"

/* This is an internal object, should not explod to end-user. */

// The section of the grid view.
// It maintains a section header view and its cells.
// The section frame is current full-type section frame.
// Which means when the section is not collapsed,
// the frame is combined with section header bound and
// all cells' bounds.
// And when the section is collapsed, the section frame
// is the frame of the section header view's frame.
// When user drag the view and need to move the whole
// section with specified offset, which the offset must
// contain only one direction, the section itself will
// check current visiable cells' frame and calculate if
// if can fill the will-visiable frame.
@interface PYGridViewSection : NSObject
{
    PYGridView                      *_parentGridView;
    NSUInteger                      _sectionIndex;
    PYGridViewScrollType            _scrollType;
    PYGridViewSectionType           _sectionType;

    UIView                          *_sectionView;
    UIView                          *_sectionInvisiableView;

    // The count of all cells
    NSUInteger                      _cellCount;
    // Current visiable cells in the section
    NSMutableArray                  *_cellsInSection;
    // All cells' frame's cache.
    NSMutableArray                  *_cellFrameCache;
    // Loaded cells' range
    NSRange                         _loadedCellRange;
    
    // The frame of current type section
    CGRect                          _sectionFrame;
    // All size of the full-type section.
    CGSize                          _allDataSize;
    // Visiable cells's frame
    CGRect                          _visiableCellFrame;
    // Section Header Frame
    CGRect                          _headFrame;
        
    BOOL                            _isCollapsed;
}

@property (nonatomic, strong)   UIView                      *invisiableView;
@property (nonatomic, strong)   UIView                      *sectionView;
@property (nonatomic, assign)   NSUInteger                  sectionIndex;
@property (nonatomic, readonly) CGRect                      sectionFrame;
@property (nonatomic, assign)   PYGridViewScrollType        scrollType;
@property (nonatomic, assign)   PYGridViewSectionType       sectionType;
@property (nonatomic, readonly) BOOL                        isCollapsed;
@property (nonatomic, readonly) NSArray                     *cellsInSection;

// Initialize the section structure.
- (id)initSectionWithGridView:(PYGridView *)gridView
                 sectionIndex:(NSUInteger)index;
- (id)initSectionWithGridView:(PYGridView *)gridView
                 sectionIndex:(NSUInteger)index
                cellSizeCache:(NSArray *)cellCache
                   headerView:(UIView *)headerView;

// Update current visiable cells' frame.
- (void)updateVisiableCells;

// Initialize the internal datas
- (void)loadCellsWithinVisiableFrame:(CGRect)visiableFrame fromTop:(BOOL)loadFromTop;

// Move the section group
- (void)visiableSectionMoveToOffset:(CGSize)offset withVisiableFrame:(CGRect)visiableFrame;

// Remove the section.
- (void)removeSectionFromGridView;

- (void)collapseSection;
- (void)unCollapseSection;

@end
