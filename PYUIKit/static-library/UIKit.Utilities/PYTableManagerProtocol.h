//
//  PYTableManagerProtocol.h
//  PYUIKit
//
//  Created by Push Chen on 11/29/13.
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
#import <UIKit/UIKit.h>

// Selection Changed Callback
typedef void (^PYTableManagerCellEvent)(id cell, NSIndexPath *indexPath);
// Get height of specified cell
typedef NSNumber* (^PYTableManagerGetCellHeight)(NSIndexPath *indexPath);
// Get cell's class
typedef Class (^PYTableManagerClassForCell)(NSIndexPath *indexPath);

typedef NS_ENUM(NSInteger, PYTableManagerEvent) {
    PYTableManagerEventCreateNewCell,       // PYActionGet
    PYTableManagerEventTryToGetHeight,      // PYTableManagerGetCellHeight
    PYTableManagerEventWillDisplayCell,     // PYTableManagerCellEvent
    PYTableManagerEventSelectCell,          // PYTableManagerCellEvent
    PYTableManagerEventUnSelectCell,        // PYTableManagerCellEvent
    PYTableManagerEventWillScroll,          // PYActionGet
    PYTableManagerEventUserActivityToScroll,// PYActionDone
    PYTableManagerEventScroll,              // PYActionGet
    PYTableManagerEventWillEndScroll,       // PYActionGet
    PYTableManagerEventEndScroll,           // PYActionGet
    PYTableManagerEventDeleteCell,          // PYTableManagerCellEvent
    PYTableManagerEventClassForCell,        // PYTableManagerClassForCell
    PYTableManagerEventUserDefined  = 0x00F0// User Defined Event start from the next value.
};

@protocol PYTableManagerProtocol <NSObject>

@optional
// The cell class
- (Class)classOfCellAtIndex:(NSIndexPath *)index;

// The datasource.
@property (nonatomic, readonly) NSArray     *contentDataSource;

@required

// Reload table's data.
- (void)reloadTableData;

// Bind the table with specified data source
- (void)bindTableView:(id)tableView;
- (void)bindTableView:(id)tableView withDataSource:(NSArray *)dataSource;

// Reload the table with new data source
- (void)reloadTableDataWithDataSource:(NSArray *)dataSource;

// Get item at specified index
- (id)dataItemAtIndex:(NSUInteger)index;    // section 0
- (id)dataItemAtIndex:(NSUInteger)index section:(NSUInteger)section;
- (id)dataItemAtIndexPath:(NSIndexPath *)indexPath;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
