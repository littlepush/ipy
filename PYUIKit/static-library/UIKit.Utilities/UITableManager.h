//
//  UITableManager.h
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

#import <Foundation/Foundation.h>
#import "PYTableManagerProtocol.h"

typedef NS_OPTIONS(NSUInteger, UITableManagerEvent) {
    UITableManagerEventGetSectionHeader         = PYTableManagerEventUserDefined + 1,
    UITableManagerEventGetHeightOfSectionHeader = PYTableManagerEventUserDefined + 2,
    UITableManagerEventOnRefreshList            = PYTableManagerEventUserDefined + 3,
    UITableManagerEventOnLoadMoreList           = PYTableManagerEventUserDefined + 4,
    UITableManagerEventCancelUpdating           = PYTableManagerEventUserDefined + 5,
    UITableManagerEventWillAllowRefreshList     = PYTableManagerEventUserDefined + 6,
    UITableManagerEventWillAllowLoadMoreList    = PYTableManagerEventUserDefined + 7,
    UITableManagerEventWillGiveUpRefreshList    = PYTableManagerEventUserDefined + 8,
    UITableManagerEventWillGiveUpLoadMoreList   = PYTableManagerEventUserDefined + 9,
    UITableManagerEventBeginToRefreshList       = PYTableManagerEventUserDefined + 10,
    UITableManagerEventBeginToLoadMoreList      = PYTableManagerEventUserDefined + 11,
    UITableManagerEventEndUpdateContent         = PYTableManagerEventUserDefined + 12,
    UITableManagerEventSectionIndexTitle        = PYTableManagerEventUserDefined + 13,
    UITableManagerEventCanDeleteCell            = PYTableManagerEventUserDefined + 14,
    UITableManagerEventGetCellClass             = PYTableManagerEventUserDefined + 15,
    UITableManagerEventGetSectionTitle          = PYTableManagerEventUserDefined + 16,
};

@interface UITableManager : PYActionDispatcher
    <PYTableManagerProtocol, UITableViewDataSource, UITableViewDelegate>
{
    UITableView             *_bindTableView;
    NSArray                 *_contentDataSource;
    UIView                  *_pullDownContainerView;
    UIView                  *_pullUpContainerView;
    
    struct {
        //NSInteger               _cellClassCount;
        NSUInteger              _sectionCount;
        BOOL                    _isShowSectionHeader:1; // if show section header.
        BOOL                    _isEditing:1;           // is current table view in editing mode
        BOOL                    _isShowSectionIndexTitle:1; // if show section index title
        BOOL                    _isUpdating:1;          // is updating content data source
        BOOL                    _canUpdateContent:1;    // can update the data source
        BOOL                    _isMultipleSection:1;   // the datasource is a 2D array
    }                       _flags;
    
    // Cell class specified
    Class                   _defaultCellClass;
    NSMutableDictionary     *_cellClassForSection;
}

// The cell class
- (Class)classOfCellAtIndex:(NSIndexPath *)index;

// Set the cell class
@property (nonatomic, assign)   Class           defaultCellClass;
- (void)setCellClass:(Class)cellClass forSection:(NSUInteger)section;

// Enable editing for every cell.
@property (nonatomic, assign)   BOOL            enableEditing;

// Is current table view updating is content data source.
@property (nonatomic, readonly) BOOL            isUpdating;

// The datasource.
@property (nonatomic, readonly) NSArray         *contentDataSource;

// Get the section count
@property (nonatomic, readonly) NSUInteger      sectionCount;
@property (nonatomic, assign)   BOOL            isShowSectionHeader;

// If current data source is multiple section
@property (nonatomic, readonly) BOOL            isMultiSection;

@property (nonatomic, readonly) UIView          *pullDownContainerView;
@property (nonatomic, readonly) UIView          *pullUpContainerView;

// Multiple Section Table Manager.
// The Data Source must be a double-level array.
- (void)bindTableView:(id)tableView
       withDataSource:(NSArray *)dataSource
         sectionCount:(NSUInteger)count;
- (void)bindTableView:(id)tableView
       withDataSource:(NSArray *)dataSource
         sectionCount:(NSUInteger)count
    showSectionHeader:(BOOL)showHeader;
- (void)bindTableView:(id)tableView
withMultipleSectionDataSource:(NSArray *)datasource;
- (void)bindTableView:(id)tableView
withMultipleSectionDataSource:(NSArray *)datasource
    showSectionHeader:(BOOL)showHeader;
- (void)reloadTableDataWithDataSource:(NSArray *)dataSource
                         sectionCount:(NSUInteger)count;
- (void)reloadTableDataWithDataSource:(NSArray *)dataSource
                         sectionCount:(NSUInteger)count
                    showSectionHeader:(BOOL)showHeader;
- (void)reloadTableDataWithMultipleSectionDataSource:(NSArray *)dataSource;
- (void)reloadTableDataWithMultipleSectionDataSource:(NSArray *)dataSource
                                   showSectionHeader:(BOOL)showHeader;

// Finish Updating Content
- (void)finishUpdateContent;
- (void)cancelUpdateContent;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
