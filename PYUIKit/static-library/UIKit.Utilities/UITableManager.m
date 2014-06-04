//
//  UITableManager.m
//  PYUIKit
//
//  Created by Push Chen on 4/7/13.
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

#import "UITableManager.h"
#import "PYTableCell.h"
#import "PYLayer.h"

const NSUInteger UITableManagerEventGetSectionHeader = PYTableManagerEventUserDefined + 1;
const NSUInteger UITableManagerEventGetHeightOfSectionHeader = PYTableManagerEventUserDefined + 2;
const NSUInteger UITableManagerEventOnRefreshList = PYTableManagerEventUserDefined + 3;
const NSUInteger UITableManagerEventOnLoadMoreList = PYTableManagerEventUserDefined + 4;
const NSUInteger UITableManagerEventCancelUpdating = PYTableManagerEventUserDefined + 5;
const NSUInteger UITableManagerEventWillAllowRefreshList = PYTableManagerEventUserDefined + 6;
const NSUInteger UITableManagerEventWillAllowLoadMoreList = PYTableManagerEventUserDefined + 7;
const NSUInteger UITableManagerEventWillGiveUpRefreshList = PYTableManagerEventUserDefined + 8;
const NSUInteger UITableManagerEventWillGiveUpLoadMoreList = PYTableManagerEventUserDefined + 9;
const NSUInteger UITableManagerEventBeginToRefreshList = PYTableManagerEventUserDefined + 10;
const NSUInteger UITableManagerEventBeginToLoadMoreList = PYTableManagerEventUserDefined + 11;
const NSUInteger UITableManagerEventEndUpdateContent = PYTableManagerEventUserDefined + 12;

@interface UITableManager (KVOExtend)
PYKVO_CHANGED_RESPONSE(_bindTableView, frame);
@end

@implementation UITableManager

+ (void)initialize
{
    // Register default event
    [UITableManager registerEvent(PYTableManagerEventCreateNewCell)];
    [UITableManager registerEvent(PYTableManagerEventTryToGetHeight)];
    [UITableManager registerEvent(PYTableManagerEventWillDisplayCell)];
    [UITableManager registerEvent(PYTableManagerEventSelectCell)];
    [UITableManager registerEvent(PYTableManagerEventUnSelectCell)];
    [UITableManager registerEvent(PYTableManagerEventWillScroll)];
    [UITableManager registerEvent(PYTableManagerEventUserActivityToScroll)];
    [UITableManager registerEvent(PYTableManagerEventScroll)];
    [UITableManager registerEvent(PYTableManagerEventWillEndScroll)];
    [UITableManager registerEvent(PYTableManagerEventEndScroll)];
    [UITableManager registerEvent(PYTableManagerEventDeleteCell)];

    // Register extend event
    [UITableManager registerEvent(UITableManagerEventGetSectionHeader)];
    [UITableManager registerEvent(UITableManagerEventGetHeightOfSectionHeader)];
    [UITableManager registerEvent(UITableManagerEventOnRefreshList)];
    [UITableManager registerEvent(UITableManagerEventOnLoadMoreList)];
    [UITableManager registerEvent(UITableManagerEventCancelUpdating)];
    [UITableManager registerEvent(UITableManagerEventWillAllowRefreshList)];
    [UITableManager registerEvent(UITableManagerEventWillAllowLoadMoreList)];
    [UITableManager registerEvent(UITableManagerEventWillGiveUpRefreshList)];
    [UITableManager registerEvent(UITableManagerEventWillGiveUpLoadMoreList)];
    [UITableManager registerEvent(UITableManagerEventBeginToRefreshList)];
    [UITableManager registerEvent(UITableManagerEventEndUpdateContent)];
}

@synthesize contentDataSource = _contentDataSource;
@synthesize sectionCount = _sectionCount;
@synthesize enableEditing = _isEditing;
@synthesize isMultiSection = _isMultiSection;
@synthesize isUpdating = _isUpdating;

@synthesize pullDownContainerView = _pullDownContainerView;
@synthesize pullUpContainerView = _pullUpContainerView;

- (void)setEnableEditing:(BOOL)enable
{
    _isEditing = enable;
    [_bindTableView setEditing:_isEditing];
}

// Default Cell Class
@dynamic cellClass;
- (Class)cellClass
{
    if ( _cellClassCount == 0 ) return [UITableView class];
    return _cellClassCList[_cellClassCount - 1];
}
- (void)setCellClass:(Class)cellClass
{
    [self setCellClassList:@[NSStringFromClass(cellClass)]];
}

- (Class)cellClassAtIndex:(NSInteger)index
{
    if (index >= _cellClassCount ) {
        return _cellClassCList[_cellClassCount - 1];
    }
    return _cellClassCList[index];
}

- (void)setCellClassList:(NSArray *)cellClassList
{
    if ( _cellClassCount > 0 && _cellClassCList != NULL ) {
        free(_cellClassCList);
    }
    
    _cellClassCount = [cellClassList count];
    _cellClassCList = (Class *)malloc(sizeof(Class) * _cellClassCount);
    NSInteger i = 0;
    for ( NSString *_className in cellClassList ) {
        _cellClassCList[i] = NSClassFromString(_className);
        ++i;
    }
}

- (id)init
{
    self = [super init];
    if ( self ) {
        _sectionCount = 1;
        _cellClassCount = 0;
        _cellClassCList = NULL;
        [self setCellClassList:@[NSStringFromClass([UITableViewCell class])]];
        _pullDownContainerView = [UIView object];
        _pullUpContainerView = [UIView object];
        [_pullDownContainerView setBackgroundColor:[UIColor clearColor]];
        [_pullUpContainerView setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)dealloc
{
    if ( _cellClassCount > 0 && _cellClassCList != NULL ) {
        free(_cellClassCList);
    }
    if ( _bindTableView != nil ) {
        PYRemoveObserve(_bindTableView, @"frame");
    }
    if ( [PYLayer isDebugEnabled] ) {
        __formatLogLine(__FILE__, __FUNCTION__, __LINE__,
                        [NSString stringWithFormat:@"***[%@:%p] Dealloced***",
                         NSStringFromClass([self class]), self]);
    }
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

- (void)reloadTableData
{
    @synchronized( self ) {
        // Clear
        PYASSERT(_contentDataSource != nil, @"Content data source for scroll view cannot be null");
        PYASSERT(([_contentDataSource isKindOfClass:[NSArray class]]),
                 @"Hey! Why you give me an identify which does not point to an array object?");
        [_bindTableView reloadData];
        // Resize the up/down container
        [self _resizePullContainer];
        [self finishUpdateContent];
    }
}

// Bind the table view, reload data with specified datasource.
- (void)bindTableView:(UITableView *)tableView withDataSource:(NSArray *)dataSource
{
    [self bindTableView:tableView withDataSource:dataSource sectionCount:1 isMultiSection:NO];
}

- (void)reloadTableDataWithDataSource:(NSArray *)dataSource
{
    [self reloadTableDataWithDataSource:dataSource sectionCount:1 isMultiSection:NO];
}

- (void)bindTableView:(id)tableView withDataSource:(NSArray *)dataSource
         sectionCount:(NSUInteger)count DEPRECATED_ATTRIBUTE
{
    @synchronized( self ) {
        if ( _bindTableView != nil ) {
            // Remove from old view
            [_pullDownContainerView removeFromSuperview];
            [_pullUpContainerView removeFromSuperview];
            _bindTableView.delegate = nil;
            _bindTableView.dataSource = nil;
            // Remove the kvo of old bind table view.
            PYRemoveObserve(_bindTableView, @"frame");
        }
        _bindTableView = tableView;
        if ( _bindTableView == nil ) return;
        [_bindTableView addSubview:_pullDownContainerView];
        [_bindTableView addSubview:_pullUpContainerView];
        
        // Add KVO for bindtable view's frame
        PYObserve(_bindTableView, @"frame");
        
        if ( dataSource == nil ) {
            // We load an empty data source.
            _contentDataSource = [NSArray array];
        } else {
            // Copy the data source.
            _contentDataSource = [NSArray arrayWithArray:dataSource];
        }
        _bindTableView = tableView;
        _bindTableView.delegate = self;
        _bindTableView.dataSource = self;
        
        if ( dataSource == nil ) {
            _contentDataSource = [NSArray array];
        } else {
            _contentDataSource = [NSArray arrayWithArray:dataSource];
        }
        _sectionCount = count;
        if ( _sectionCount == 1 ) {
            for ( NSObject *obj in dataSource ) {
                if ( [obj isKindOfClass:[NSArray class]] ) {
                    _isMultiSection = YES;
                } else {
                    // If has only one not array data, multisection is no and return.
                    _isMultiSection = NO;
                    break;
                }
            }
        }
        
        [_bindTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_bindTableView setShowsVerticalScrollIndicator:NO];
        [_bindTableView setShowsHorizontalScrollIndicator:NO];
        
        // Reload data.
        [self reloadTableData];
    }
}

- (void)_resizePullContainer
{
    PYLog(@"Resizing the pull container");
    CGRect _btFrame = _bindTableView.frame;
    CGRect _pullDownFrame = CGRectMake(0, -44, _btFrame.size.width, 44);
    CGRect _pullUpFrame = CGRectMake(0, _bindTableView.contentSize.height, _btFrame.size.width, 44);
    [_pullDownContainerView setFrame:_pullDownFrame];
    [_pullUpContainerView setFrame:_pullUpFrame];
}

PYKVO_CHANGED_RESPONSE(_bindTableView, frame)
{
    PYLog(@"The _bindTableView did changed the frame, will resize the pull container.");
    [self _resizePullContainer];
}

- (void)reloadTableDataWithDataSource:(NSArray *)dataSource
                         sectionCount:(NSUInteger)count DEPRECATED_ATTRIBUTE
{
    @synchronized( self ) {
        if ( dataSource == nil ) {
            // We load en empty data source.
            _contentDataSource = [NSArray array];
        } else {
            // Copy the data source.
            _contentDataSource = [NSArray arrayWithArray:dataSource];
        }
        _sectionCount = count;
        if ( _sectionCount == 1 ) {
            for ( NSObject *obj in dataSource ) {
                if ( [obj isKindOfClass:[NSArray class]] ) {
                    _isMultiSection = YES;
                } else {
                    // If has only one not array data, multisection is no and return.
                    _isMultiSection = NO;
                    break;
                }
            }
        }
        [self reloadTableData];
    }
}

- (void)bindTableView:(id)tableView withDataSource:(NSArray *)dataSource
         sectionCount:(NSUInteger)count isMultiSection:(BOOL)isMultiSection
{
    @synchronized( self ) {
        if ( _bindTableView != nil ) {
            _bindTableView.delegate = nil;
            _bindTableView.dataSource = nil;
            // Remove from old view
            [_pullDownContainerView removeFromSuperview];
            [_pullUpContainerView removeFromSuperview];
            // Remove the kvo of old bind table view.
            PYRemoveObserve(_bindTableView, @"frame");
        }
        _bindTableView = tableView;
        if ( _bindTableView == nil ) return;
        [_bindTableView addSubview:_pullDownContainerView];
        [_bindTableView addSubview:_pullUpContainerView];
        // Resize the up/down container
        [self _resizePullContainer];
        
        // Add KVO for bindtable view's frame
        PYObserve(_bindTableView, @"frame");

        if ( dataSource == nil ) {
            // We load en empty data source.
            _contentDataSource = [NSArray array];
        } else {
            // Copy the data source.
            _contentDataSource = [NSArray arrayWithArray:dataSource];
        }
        _bindTableView = tableView;
        _bindTableView.delegate = self;
        _bindTableView.dataSource = self;
        
        if ( dataSource == nil ) {
            _contentDataSource = [NSArray array];
        } else {
            _contentDataSource = [NSArray arrayWithArray:dataSource];
        }
        _sectionCount = count;
        _isMultiSection = isMultiSection;
        
        [_bindTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_bindTableView setShowsVerticalScrollIndicator:NO];
        [_bindTableView setShowsHorizontalScrollIndicator:NO];
        
        // Reload data.
        [self reloadTableData];
    }
}
- (void)reloadTableDataWithDataSource:(NSArray *)dataSource
                         sectionCount:(NSUInteger)count
                       isMultiSection:(BOOL)isMultiSection
{
    @synchronized( self ) {
        if ( dataSource == nil ) {
            // We load en empty data source.
            _contentDataSource = [NSArray array];
        } else {
            // Copy the data source.
            _contentDataSource = [NSArray arrayWithArray:dataSource];
        }
        _sectionCount = count;
        _isMultiSection = isMultiSection;
        [self reloadTableData];
    }
}

- (id)dataItemAtIndex:(NSUInteger)index
{
    if ( _contentDataSource == nil ) return nil;
    if ( _isMultiSection ) return nil;
    return [_contentDataSource safeObjectAtIndex:index];
}

- (id)_itemAtIndexPath:(NSIndexPath *)indexPath
{
    if ( !_isMultiSection ) return [_contentDataSource safeObjectAtIndex:indexPath.row];
    NSArray *_sectionData = [_contentDataSource safeObjectAtIndex:indexPath.section];
    if ( _sectionData == nil ) return nil;
    if ( [_sectionData isKindOfClass:[NSArray class]] == NO ) return nil;
    return [_sectionData safeObjectAtIndex:indexPath.row];
}

#pragma mark --
#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( [_contentDataSource count] == 0 ) return 0;
    // More than one section.
    if ( _isMultiSection ) {
        NSArray *_sectionData = [_contentDataSource safeObjectAtIndex:section];
        if ( _sectionData == nil ) return 0;
        [_sectionData mustBeTypeOrFailed:[NSArray class]];
        return [_sectionData count];
    }
    return [_contentDataSource count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ( !_isMultiSection ) return nil;
    return [self invokeTargetWithEvent:UITableManagerEventGetSectionHeader
                                exInfo:PYIntToObject(section)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ( !_isMultiSection ) return 0;
    NSNumber *_result = [self invokeTargetWithEvent:UITableManagerEventGetHeightOfSectionHeader
                                             exInfo:PYIntToObject(section)];
    if ( _result == nil ) return 32.f;
    return [_result floatValue];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id _item = [self _itemAtIndexPath:indexPath];
    if ( _item == nil ) return 0;
    NSNumber *_result = [self
                         invokeTargetWithEvent:PYTableManagerEventTryToGetHeight
                         exInfo:indexPath];
    if ( _result == nil ) {
        //_result =
        Class _cc = [self cellClassAtIndex:indexPath.section];
        if ( [_cc respondsToSelector:@selector(heightOfCellWithSpecifiedContentItem:)] ) {
            _result = [_cc heightOfCellWithSpecifiedContentItem:_item];
        }
    }
    if ( _result == nil ) return 0.f;
    return [_result floatValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Create the cell.
    NSString *_cellIdentify = NSStringFromClass([self cellClassAtIndex:indexPath.section]);
    UITableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentify];
    if ( _cell == nil ) {
        _cell = [[[self cellClassAtIndex:indexPath.section] alloc]
                 initWithStyle:UITableViewCellStyleDefault
                 reuseIdentifier:_cellIdentify];
        if ( [_cell respondsToSelector:@selector(setDeleteEventCallback:)] ) {
            __weak UITableManager *_wss = self;
            [(id<PYTableCell>)_cell setDeleteEventCallback:^(id cell, NSIndexPath *indexPath) {
                [_wss _deleteBlockInvoked:cell indexPath:indexPath];
            }];
        }
        [self invokeTargetWithEvent:PYTableManagerEventCreateNewCell exInfo:_cell];
    }
    return _cell;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    id _item = [self _itemAtIndexPath:indexPath];
    [cell tryPerformSelector:@selector(rendCellWithSpecifiedContentItem:) withObject:_item];
    [self invokeTargetWithEvent:PYTableManagerEventWillDisplayCell
                         exInfo:cell
                         exInfo:indexPath];
    [cell setNeedsLayout];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Nothing... not support tap.
    if ( _contentDataSource == nil ) return;
    id _cell = [tableView cellForRowAtIndexPath:indexPath];
    if ( _cell == nil ) return;
    [self invokeTargetWithEvent:PYTableManagerEventSelectCell
                         exInfo:_cell
                         exInfo:indexPath];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Nothing... not support tap.
    if ( _contentDataSource == nil ) return;
    id _cell = [tableView cellForRowAtIndexPath:indexPath];
    if ( _cell == nil ) return;
    [self invokeTargetWithEvent:PYTableManagerEventUnSelectCell
                         exInfo:_cell
                         exInfo:indexPath];
}

- (NSString *)tableView:(UITableView *)tableView
titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    id _cell = [tableView cellForRowAtIndexPath:indexPath];
    [self invokeTargetWithEvent:PYTableManagerEventDeleteCell exInfo:_cell exInfo:indexPath];
    NSMutableArray *_copiedDS = [NSMutableArray arrayWithArray:_contentDataSource];
    [_copiedDS removeObjectAtIndex:indexPath.row];
    _contentDataSource = _copiedDS;
    [_bindTableView deleteRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationFade];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Detemine if it's in editing mode
    if ( _isEditing ) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // The user is going to scroll the table view.
    [self invokeTargetWithEvent:PYTableManagerEventUserActivityToScroll];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ( _isUpdating == NO ) {
        if ( scrollView.contentOffset.y < 0 ) { // Will display the pull-down refresh view
            if ( scrollView.contentOffset.y < -44 ) {
                // Show: "Release to refresh"
                if ( _canUpdateContent == NO ) {
                    _canUpdateContent = YES;
                    [self invokeTargetWithEvent:UITableManagerEventWillAllowRefreshList];
                }
            } else {
                // Show: "Pull down to refresh"
                if ( _canUpdateContent == YES ) {
                    _canUpdateContent = NO;
                    [self invokeTargetWithEvent:UITableManagerEventWillGiveUpRefreshList];
                }
            }
        } else if ( scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.frame.size.height) ) {
            if ( scrollView.contentOffset.y > (scrollView.contentSize.height + 44 - scrollView.frame.size.height) ) {
                // Show: "Release to load more"
                if ( _canUpdateContent == NO ) {
                    _canUpdateContent = YES;
                    [self invokeTargetWithEvent:UITableManagerEventWillAllowLoadMoreList];
                }
            } else {
                // Show: "Pull up to load more"
                if ( _canUpdateContent == YES ) {
                    _canUpdateContent = NO;
                    [self invokeTargetWithEvent:UITableManagerEventWillGiveUpLoadMoreList];
                }
            }
        }
    }
    [self invokeTargetWithEvent:PYTableManagerEventScroll exInfo:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ( _canUpdateContent ) {
        if ( _isUpdating == NO ) {
            NSNumber *_result = nil;
            if ( scrollView.contentOffset.y < 0 ) {
                // Refresh
                _result = [self invokeTargetWithEvent:UITableManagerEventOnRefreshList];
                if ( _result != nil && [_result boolValue] ) {
                    [self invokeTargetWithEvent:UITableManagerEventBeginToRefreshList];
                }
            } else {
                // Load More
                _result = [self invokeTargetWithEvent:UITableManagerEventOnLoadMoreList];
                if ( _result != nil && [_result boolValue] ) {
                    [self invokeTargetWithEvent:UITableManagerEventBeginToLoadMoreList];
                }
            }
            _isUpdating = (_result == nil ? NO : [_result boolValue]);
        }
    }
    _canUpdateContent = NO;
    if ( decelerate == NO ) {
        [self invokeTargetWithEvent:PYTableManagerEventEndScroll exInfo:scrollView];
    } else {
        [self invokeTargetWithEvent:PYTableManagerEventWillEndScroll exInfo:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self invokeTargetWithEvent:PYTableManagerEventEndScroll exInfo:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self invokeTargetWithEvent:PYTableManagerEventEndScroll exInfo:scrollView];
}

- (void)_deleteBlockInvoked:(id)cell indexPath:(NSIndexPath *)indexPath
{
    [self invokeTargetWithEvent:PYTableManagerEventDeleteCell exInfo:cell exInfo:indexPath];
    NSMutableArray *_copiedDS = [NSMutableArray arrayWithArray:_contentDataSource];
    [_copiedDS removeObjectAtIndex:indexPath.row];
    _contentDataSource = _copiedDS;
    [_bindTableView deleteRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationFade];
}

- (void)finishUpdateContent
{
    @synchronized( self ) {
        _isUpdating = NO;
        [self invokeTargetWithEvent:UITableManagerEventEndUpdateContent];
    }
}

- (void)cancelUpdateContent
{
    @synchronized( self ) {
        _isUpdating = NO;
        [self invokeTargetWithEvent:UITableManagerEventCancelUpdating];
    }
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
