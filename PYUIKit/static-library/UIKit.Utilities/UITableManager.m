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
    [UITableManager registerEvent(UITableManagerEventSectionIndexTitle)];
    [UITableManager registerEvent(UITableManagerEventCanDeleteCell)];
    [UITableManager registerEvent(UITableManagerEventGetCellClass)];
}

- (Class)classOfCellAtIndex:(NSIndexPath *)index
{
    Class _cell_class = [self invokeTargetWithEvent:UITableManagerEventGetCellClass exInfo:index];
    if ( _cell_class != NULL ) return _cell_class;
    _cell_class = (Class)[_cellClassForSection objectForKey:@(index.section)];
    if ( _cell_class != NULL ) return _cell_class;
    return _defaultCellClass;
}
@synthesize defaultCellClass = _defaultCellClass;
- (void)setCellClass:(Class)cellClass forSection:(NSUInteger)section
{
    if ( _cellClassForSection == nil ) {
        _cellClassForSection = [NSMutableDictionary dictionary];
    }
    [_cellClassForSection setObject:cellClass forKey:@(section)];
}

@dynamic enableEditing;
- (BOOL)enableEditing { return _flags._isEditing; }
- (void)setEnableEditing:(BOOL)enableEditing {
    _flags._isEditing = enableEditing;
    [_bindTableView setEditing:enableEditing];
}

@dynamic isUpdating;
- (BOOL)isUpdating { return _flags._isUpdating; }

@synthesize contentDataSource = _contentDataSource;

@dynamic sectionCount;
- (NSUInteger)sectionCount { return _flags._sectionCount; }
@dynamic isShowSectionHeader;
- (BOOL)isShowSectionHeader { return _flags._isShowSectionHeader; }
- (void)setIsShowSectionHeader:(BOOL)isShowSectionHeader { _flags._isShowSectionHeader = isShowSectionHeader; }

@dynamic isMultiSection;
- (BOOL)isMultiSection { return _flags._sectionCount > 1; }

@synthesize pullDownContainerView = _pullDownContainerView;
@synthesize pullUpContainerView = _pullUpContainerView;

- (id)init
{
    self = [super init];
    if ( self ) {
        memset(&_flags, 0, sizeof(_flags));
        _defaultCellClass = [UITableViewCell class];
        
        _pullDownContainerView = [UIView object];
        _pullUpContainerView = [UIView object];
        [_pullDownContainerView setBackgroundColor:[UIColor clearColor]];
        [_pullUpContainerView setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)dealloc
{
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

- (void)_resizePullContainer
{
    CGRect _btFrame = _bindTableView.frame;
    CGFloat _headViewHeight = (_bindTableView.tableHeaderView ?
                               _bindTableView.tableHeaderView.frame.size.height : 0);
    CGFloat _footViewHeight = (_bindTableView.tableFooterView ?
                               _bindTableView.tableFooterView.frame.size.height : 0);
    CGRect _pullDownFrame = CGRectMake(0, -44, _btFrame.size.width, 44);
    CGRect _pullUpFrame = CGRectMake(0,
                                     (_bindTableView.contentSize.height + _headViewHeight + _footViewHeight),
                                     _btFrame.size.width, 44);
    [_pullDownContainerView setFrame:_pullDownFrame];
    [_pullUpContainerView setFrame:_pullUpFrame];
}

PYKVO_CHANGED_RESPONSE(_bindTableView, frame)
{
    PYLog(@"The _bindTableView did changed the frame, will resize the pull container.");
    [self _resizePullContainer];
}

- (void)bindTableView:(id)tableView
{
    [self bindTableView:tableView
         withDataSource:nil
           sectionCount:1
      showSectionHeader:NO];
}

- (void)bindTableView:(id)tableView withDataSource:(NSArray *)dataSource
{
    [self bindTableView:tableView
         withDataSource:dataSource
           sectionCount:1
      showSectionHeader:NO];
}
- (void)bindTableView:(id)tableView
       withDataSource:(NSArray *)dataSource
         sectionCount:(NSUInteger)count
{
    [self bindTableView:tableView
         withDataSource:dataSource
           sectionCount:count
      showSectionHeader:(count > 1)];
}

- (void)tableView:(UITableView *)tableView
didEndDisplayingCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( (indexPath.section != tableView.numberOfSections - 1 ) ) return;
    NSArray *_dataItems = [self dataItemsForSection:indexPath.section];
    if ( indexPath.row != _dataItems.count - 1 ) return;    // Not last one
    [self _resizePullContainer];
}

- (void)bindTableView:(id)tableView
withMultipleSectionDataSource:(NSArray *)datasource
{
    [self bindTableView:tableView withMultipleSectionDataSource:datasource showSectionHeader:YES];
}
- (void)bindTableView:(id)tableView
withMultipleSectionDataSource:(NSArray *)datasource
    showSectionHeader:(BOOL)showHeader
{
    [self bindTableView:tableView
         withDataSource:datasource
           sectionCount:[datasource count]
      isMultipleSection:YES
      showSectionHeader:showHeader];
}

- (void)bindTableView:(id)tableView
       withDataSource:(NSArray *)dataSource
         sectionCount:(NSUInteger)count
    showSectionHeader:(BOOL)showHeader
{
    [self bindTableView:tableView
         withDataSource:dataSource
           sectionCount:count
      isMultipleSection:(count > 1)
      showSectionHeader:showHeader];
}

- (void)bindTableView:(id)tableView
       withDataSource:(NSArray *)dataSource
         sectionCount:(NSUInteger)count
    isMultipleSection:(BOOL)isMultipleSection
    showSectionHeader:(BOOL)showHeader
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
        
        _flags._sectionCount = count;
        _flags._isShowSectionHeader = showHeader;
        _flags._isMultipleSection = isMultipleSection;
        
        // Reload data.
        [self reloadTableData];
    }
}

- (void)reloadTableDataWithDataSource:(NSArray *)dataSource
{
    [self reloadTableDataWithDataSource:dataSource
                           sectionCount:_flags._sectionCount
                      showSectionHeader:_flags._isShowSectionHeader];
}
- (void)reloadTableDataWithDataSource:(NSArray *)dataSource
                         sectionCount:(NSUInteger)count
{
    [self reloadTableDataWithDataSource:dataSource
                           sectionCount:count
                      showSectionHeader:(count > 1)];
}
- (void)reloadTableDataWithMultipleSectionDataSource:(NSArray *)dataSource
{
    [self reloadTableDataWithMultipleSectionDataSource:dataSource showSectionHeader:YES];
}
- (void)reloadTableDataWithMultipleSectionDataSource:(NSArray *)dataSource
                                   showSectionHeader:(BOOL)showHeader
{
    [self reloadTableDataWithDataSource:dataSource
                           sectionCount:[dataSource count]
                      isMultipleSection:YES
                      showSectionHeader:showHeader];
}
- (void)reloadTableDataWithDataSource:(NSArray *)dataSource
                         sectionCount:(NSUInteger)count
                    showSectionHeader:(BOOL)showHeader
{
    [self reloadTableDataWithDataSource:dataSource
                           sectionCount:count
                      isMultipleSection:(count > 1)
                      showSectionHeader:showHeader];
}

- (void)reloadTableDataWithDataSource:(NSArray *)dataSource
                         sectionCount:(NSUInteger)count
                    isMultipleSection:(BOOL)isMultipleSection
                    showSectionHeader:(BOOL)showHeader
{
    @synchronized( self ) {
        if ( dataSource == nil ) {
            // We load en empty data source.
            _contentDataSource = [NSArray array];
        } else {
            // Copy the data source.
            _contentDataSource = [NSArray arrayWithArray:dataSource];
        }
        
        _flags._sectionCount = count;
        _flags._isShowSectionHeader = showHeader;
        _flags._isMultipleSection = isMultipleSection;
        
        [self reloadTableData];
    }
}

- (NSArray *)dataItemsForSection:(NSUInteger)section
{
    if ( section >= _flags._sectionCount ) return nil;
    if ( _flags._sectionCount == 1 ) return _contentDataSource;
    return [_contentDataSource safeObjectAtIndex:section];
}

- (id)dataItemAtIndex:(NSUInteger)index
{
    return [self dataItemAtIndex:index section:0];
}

- (id)dataItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self dataItemAtIndex:indexPath.row section:indexPath.section];
}

- (id)dataItemAtIndex:(NSUInteger)index section:(NSUInteger)section
{
    if ( _flags._isMultipleSection == NO ) return [_contentDataSource safeObjectAtIndex:index];
    NSArray *_sectionData = [_contentDataSource safeObjectAtIndex:section];
    if ( _sectionData == nil ) return nil;
    if ( [_sectionData isKindOfClass:[NSArray class]] == NO ) return nil;
    return [_sectionData safeObjectAtIndex:index];
}

#pragma mark --
#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _flags._sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( [_contentDataSource count] == 0 ) return 0;
    // More than one section.
    if ( _flags._isMultipleSection ) {
        NSArray *_sectionData = [_contentDataSource safeObjectAtIndex:section];
        if ( _sectionData == nil ) return 0;
        [_sectionData mustBeTypeOrFailed:[NSArray class]];
        return [_sectionData count];
    }
    return [_contentDataSource count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ( _flags._isShowSectionHeader == NO ) return nil;
    return [self invokeTargetWithEvent:UITableManagerEventGetSectionHeader
                                exInfo:PYIntToObject(section)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ( _flags._isShowSectionHeader == NO ) return 0;
    NSNumber *_result = [self invokeTargetWithEvent:UITableManagerEventGetHeightOfSectionHeader
                                             exInfo:PYIntToObject(section)];
    if ( _result == nil ) return 32.f;
    return [_result floatValue];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if ( _flags._sectionCount <= 0 ) return nil;
    return [self invokeTargetWithEvent:UITableManagerEventSectionIndexTitle];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id _item = [self dataItemAtIndexPath:indexPath];
    if ( _item == nil ) return 0;
    NSNumber *_result = [self
                         invokeTargetWithEvent:PYTableManagerEventTryToGetHeight
                         exInfo:indexPath];
    if ( _result == nil ) {
        //_result =
        Class _cc = [self classOfCellAtIndex:indexPath];
        if ( [_cc respondsToSelector:@selector(heightOfCellWithSpecifiedContentItem:)] ) {
            _result = [_cc heightOfCellWithSpecifiedContentItem:_item];
        }
    }
    if ( _result == nil ) return 44.f;
    return [_result floatValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Create the cell.
    Class _cell_class = [self classOfCellAtIndex:indexPath];
    NSString *_cellIdentify = NSStringFromClass(_cell_class);
    UITableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentify];
    if ( _cell == nil ) {
        _cell = [[_cell_class alloc]
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
    id _item = [self dataItemAtIndexPath:indexPath];
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
    if ( _flags._sectionCount > 1 ) {
        NSMutableArray *_sectionSource =
        [NSMutableArray arrayWithArray:
         [_copiedDS safeObjectAtIndex:indexPath.section]];
        [_sectionSource removeObjectAtIndex:indexPath.row];
        [_copiedDS removeObjectAtIndex:indexPath.section];
        [_copiedDS insertObject:_sectionSource atIndex:indexPath.section];
    } else {
        [_copiedDS removeObjectAtIndex:indexPath.row];
    }
    _contentDataSource = _copiedDS;
    [_bindTableView deleteRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationFade];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Detemine if it's in editing mode
    if ( _flags._isEditing ) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *_canDeleteFlag = [self invokeTargetWithEvent:UITableManagerEventCanDeleteCell exInfo:indexPath];
    if ( _canDeleteFlag != nil ) {
        return [_canDeleteFlag boolValue];
    }
    return NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // The user is going to scroll the table view.
    [self invokeTargetWithEvent:PYTableManagerEventUserActivityToScroll];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ( _flags._isUpdating == NO ) {
        if ( scrollView.contentOffset.y < 0 ) { // Will display the pull-down refresh view
            if ( scrollView.contentOffset.y < -44 ) {
                // Show: "Release to refresh"
                if ( _flags._canUpdateContent == NO ) {
                    _flags._canUpdateContent = YES;
                    [self invokeTargetWithEvent:UITableManagerEventWillAllowRefreshList];
                }
            } else {
                // Show: "Pull down to refresh"
                if ( _flags._canUpdateContent == YES ) {
                    _flags._canUpdateContent = NO;
                    [self invokeTargetWithEvent:UITableManagerEventWillGiveUpRefreshList];
                }
            }
        } else if ( scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.frame.size.height) ) {
            if ( scrollView.contentOffset.y > (scrollView.contentSize.height + 44 - scrollView.frame.size.height) ) {
                // Show: "Release to load more"
                if ( _flags._canUpdateContent == NO ) {
                    _flags._canUpdateContent = YES;
                    [self invokeTargetWithEvent:UITableManagerEventWillAllowLoadMoreList];
                }
            } else {
                // Show: "Pull up to load more"
                if ( _flags._canUpdateContent == YES ) {
                    _flags._canUpdateContent = NO;
                    [self invokeTargetWithEvent:UITableManagerEventWillGiveUpLoadMoreList];
                }
            }
        }
    }
    [self invokeTargetWithEvent:PYTableManagerEventScroll exInfo:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ( _flags._canUpdateContent ) {
        if ( _flags._isUpdating == NO ) {
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
            _flags._isUpdating = (_result == nil ? NO : [_result boolValue]);
        }
    }
    _flags._canUpdateContent = NO;
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
        _flags._isUpdating = NO;
        [self invokeTargetWithEvent:UITableManagerEventEndUpdateContent];
    }
}

- (void)cancelUpdateContent
{
    @synchronized( self ) {
        _flags._isUpdating = NO;
        [self invokeTargetWithEvent:UITableManagerEventCancelUpdating];
    }
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
