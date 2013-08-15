//
//  PYTableView.m
//  PYUIKit
//
//  Created by Push Chen on 7/30/13.
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
#import "PYScrollView+SideAnimation.h"
#import "PYTableContentView.h"
#import "PYTableView+Content.h"

#define __PY_DEFAULT_CELL_HEIGHT_       60.f

@implementation PYTableView

@dynamic rowHeight;
- (CGFloat)rowHeight
{
    return __PY_DEFAULT_CELL_HEIGHT_;
}

@dynamic visiableCells;
- (NSArray *)visiableCells
{
    NSMutableArray *_vCells = [NSMutableArray array];
    NSArray *_subContents = self.subContentViews;
    for ( PYTableContentView *_ctntView in _subContents ) {
        [_vCells addObjectsFromArray:_ctntView.visiableCells];
    }
    return _vCells;
}

@dynamic loopEnabled;
- (BOOL)loopEnabled
{
    return self.isLoopEnabled;
}
- (void)setLoopEnabled:(BOOL)loopEnabled
{
    [self setSupportLoop:loopEnabled];
}

@synthesize cellCount = _cellCount;

+ (Class)contentViewClass
{
    return [PYTableContentView class];
}

- (void)viewJustBeenCreated
{
    [super viewJustBeenCreated];
    self.scrollSide = PYScrollVerticalis;
    self.alwaysBounceHorizontal = NO;
    self.alwaysBounceVertical = YES;
    
    // Initialize the cache.
    _cachedCells = [NSMutableDictionary dictionary];
}

- (void)dealloc
{
    [self clearContents];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if ( newSuperview == nil ) {
        // Self clear
    } else {
        [self reloadData];
    }
}

- (void)reloadData
{
    if ( self.dataSource == nil ) return;
    [self clearContents];
    if ( ![self.dataSource respondsToSelector:@selector(pytableViewNumberOfRows:)] ) {
        PYLog(@"Must implemente the numberofrows selector");
        return;
    }
    _cellCount = [self.dataSource pytableViewNumberOfRows:self];
    if ( _cellCount == 0 ) return;
    _pCellFrame = (CGRect *)malloc(sizeof(CGRect) * _cellCount);
    CGRect _myBounds = self.bounds;
    CGFloat _allSize = 0;
    if ( ![self.dataSource respondsToSelector:@selector(pytableView:heightForRowAtIndex:)] ) {
        // Use default cell height.
        CGSize _cellSize = CGSizeZero;
        _SIDE_ITEM(_cellSize) = __PY_DEFAULT_CELL_HEIGHT_;
        _VSIDE_ITEM(_cellSize) = _VSIDE_ITEM(_myBounds.size);
        
        for ( int i = 0; i < _cellCount; ++i ) {
            _pCellFrame[i] = CGRectZero;
            _SIDE_ITEM(_pCellFrame[i].origin) = i * __PY_DEFAULT_CELL_HEIGHT_;
            _pCellFrame[i].size = _cellSize;
        }
        _allSize = _cellCount * __PY_DEFAULT_CELL_HEIGHT_;
    } else {
        for ( int i = 0; i < _cellCount; ++i ) {
            CGFloat _size = [self.dataSource pytableView:self heightForRowAtIndex:i];
            CGSize _cellSize = CGSizeZero;
            _SIDE_ITEM(_cellSize) = _size;
            _VSIDE_ITEM(_cellSize) = _VSIDE_ITEM(_myBounds.size);
            _pCellFrame[i] = CGRectZero;
            _SIDE_ITEM(_pCellFrame[i].origin) =_allSize;
            _pCellFrame[i].size = _cellSize;
            _allSize += _size;
        }
    }
    
    CGSize _ctntSize = CGSizeZero;
    _SIDE_ITEM(_ctntSize) = _allSize;
    _VSIDE_ITEM(_ctntSize) = _VSIDE_ITEM(_myBounds.size);
    [self setContentSize:_ctntSize animated:NO];
    // Try to move.
    [self setContentOffset:self.contentOffset animated:NO];
}

- (PYTableViewCell *)cellForRowAtIndex:(NSInteger)index
{
    NSArray *_subContents = self.subContentViews;
    for ( PYTableContentView *_ctntView in _subContents ) {
        PYTableViewCell *_cell = [_ctntView cellForRowAtIndex:index];
        if ( _cell == nil ) continue;
        return _cell;
    }
    return nil;
}

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    return [self dequeueCellWithSpecifiedReuseIdentify:identifier];
}

- (void)willMoveToOffsetWithDistance:(CGSize)distance
{
    [super willMoveToOffsetWithDistance:distance];
    NSArray *_subContents = self.subContentViews;
    for ( PYTableContentView *_ctntView in _subContents ) {
        _ctntView.tableView = self;
        [_ctntView organizedCellsInContentViewWithMoveDistance:distance];
    }
}

- (void)didMoveToOffsetWithDistance:(CGSize)distance
{
    NSArray *_subContents = self.subContentViews;
    for ( PYTableContentView *_ctntView in _subContents ) {
        [_ctntView clearOutOfBoundsCellsWithDistance:distance];
    }
    [super didMoveToOffsetWithDistance:distance];
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
