//
//  PYTableCell.h
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
#import "PYTableManagerProtocol.h"

@protocol PYTableCell <NSObject>

@required

// Calculate the height of a cell
+ (NSNumber *)heightOfCellWithSpecifiedContentItem:(id)contentItem;

// Rend the cell with specified item.
- (void)rendCellWithSpecifiedContentItem:(id)contentItem;

@optional
// When the cell want to delete itself, the container should
// suppor this delete event to modify the content datasource.
@property (nonatomic, copy, setter = setDeleteEventCallback:)   PYTableManagerCellEvent deleteEvent;
// Bind the delete event call back block
- (void)setDeleteEventCallback:(PYTableManagerCellEvent)deleteBlock;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
