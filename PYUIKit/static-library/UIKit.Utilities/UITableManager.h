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

//typedef void (^PYTableCellClick)(NSString *identify, UITableViewCell *cell);
typedef UIView * (^PYTableManagerSection)(NSNumber *);
extern const NSUInteger UITableManagerEventGetSectionHeader;            // User Defined + 1
typedef NSNumber *(^PYTableManagerHeightOfSection)(NSNumber *);
extern const NSUInteger UITableManagerEventGetHeightOfSectionHeader;    // User Defined + 2
typedef NSNumber *(^PYTableManagerUpdatingHandler)( void );
extern const NSUInteger UITableManagerEventOnRefreshList;               // User Defined + 3
extern const NSUInteger UITableManagerEventOnLoadMoreList;              // User Defined + 4
extern const NSUInteger UITableManagerEventCancelUpdating;              // User Defined + 5
extern const NSUInteger UITableManagerEventWillAllowRefreshList;        // User Defined + 6
extern const NSUInteger UITableManagerEventWillAllowLoadMoreList;       // User Defined + 7
extern const NSUInteger UITableManagerEventWillGiveUpRefreshList;       // User Defined + 8
extern const NSUInteger UITableManagerEventWillGiveUpLoadMoreList;      // User Defined + 9
extern const NSUInteger UITableManagerEventBeginToRefreshList;          // User Defined + 10
extern const NSUInteger UITableManagerEventBeginToLoadMoreList;         // User Defined + 11
extern const NSUInteger UITableManagerEventEndUpdateContent;            // User Defined + 12

@interface UITableManager : PYActionDispatcher
    <PYTableManagerProtocol, UITableViewDataSource, UITableViewDelegate>
{
    UITableView             *_bindTableView;
    NSArray                 *_contentDataSource;
    Class                   *_cellClassCList;
    NSInteger               _cellClassCount;
    BOOL                    _isEditing;
    NSUInteger              _sectionCount;
    BOOL                    _isMultiSection;
    
    BOOL                    _isUpdating;
    BOOL                    _canUpdateContent;
    
    UIView                  *_pullDownContainerView;
    UIView                  *_pullUpContainerView;
}

// Set the customized cell class, default is PYTableViewCell
@property (nonatomic, assign)   Class           cellClass;
@property (nonatomic, readonly) NSArray         *cellClassList;

@property (nonatomic, assign)   BOOL            enableEditing;

// Is current table view updating is content data source.
@property (nonatomic, readonly) BOOL            isUpdating;

// Set different class for each section.
// if the class list count is lest than the section count,
// follower section will all use the last class to generate the cell.
- (void)setCellClassList:(NSArray *)cellClassList;

// The datasource.
@property (nonatomic, readonly) NSArray         *contentDataSource;

// Get the section count
@property (nonatomic, readonly) NSUInteger      sectionCount;

// If current data source is multiple section
@property (nonatomic, readonly) BOOL            isMultiSection;

@property (nonatomic, readonly) UIView          *pullDownContainerView;
@property (nonatomic, readonly) UIView          *pullUpContainerView;

// Multiple Section Table Manager.
// The Data Source must be a double-level array.
- (void)bindTableView:(id)tableView withDataSource:(NSArray *)dataSource
         sectionCount:(NSUInteger)count DEPRECATED_ATTRIBUTE;
- (void)reloadTableDataWithDataSource:(NSArray *)dataSource
                         sectionCount:(NSUInteger)count DEPRECATED_ATTRIBUTE;

- (void)bindTableView:(id)tableView withDataSource:(NSArray *)dataSource
         sectionCount:(NSUInteger)count isMultiSection:(BOOL)isMultiSection;
- (void)reloadTableDataWithDataSource:(NSArray *)dataSource
                         sectionCount:(NSUInteger)count
                       isMultiSection:(BOOL)isMultiSection;

// Finish Updating Content
- (void)finishUpdateContent;
- (void)cancelUpdateContent;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
