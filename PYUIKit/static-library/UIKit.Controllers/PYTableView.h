//
//  PYTableView.h
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

#import "PYScrollView.h"

// Pre-define class.
@class PYTableView;
@class PYTableViewCell;
@class PYTableContentView;

// Data Source.
@protocol PYTableViewDatasource;
// View Delegate.
@protocol PYTableViewDelegate<NSObject, PYScrollViewDelegate>
@optional
- (void)pytableView:(PYTableView *)tableView willDisplayCell:(PYTableViewCell *)cell atIndex:(NSInteger)index;
- (void)pytableView:(PYTableView *)tableView didSelectCellAtIndex:(NSInteger)index;
- (void)pytableView:(PYTableView *)tableView unSelectCellAtIndex:(NSInteger)index;

@end

@interface PYTableView : PYScrollView
{
    NSMutableDictionary                 *_cachedCells;
    CGRect                              *_pCellFrame;
    
    NSInteger                           _cellCount;
}

@property (nonatomic, assign)   id<PYTableViewDatasource>   dataSource;
@property (nonatomic, assign)   id<PYTableViewDelegate>     delegate;

@property (nonatomic, readonly) int                         cellCount;
// Default row height.
@property (nonatomic, assign)   CGFloat                     rowHeight;
@property (nonatomic, readonly) NSArray                     *visiableCells;

// Set the tableview loop statue.
@property (nonatomic, assign)   BOOL                        loopEnabled;

// reload the content data.
- (void)reloadData;

- (PYTableViewCell *)cellForRowAtIndex:(NSInteger)index;

// Dequeue the cache cell.
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;

@end

@protocol PYTableViewDatasource <NSObject>

@required
- (NSInteger)pytableViewNumberOfRows:(PYTableView *)tableView;
- (PYTableViewCell *)pytableView:(PYTableView *)tableView cellForRowAtIndex:(NSInteger)index;
@optional
- (CGFloat)pytableView:(PYTableView *)tableView heightForRowAtIndex:(NSInteger)index;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
