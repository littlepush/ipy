//
//  PYTableViewCell.h
//  PYUIKit
//
//  Created by Push Chen on 8/15/13.
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

#import "PYView.h"
#import "PYLabelLayer.h"

@interface PYTableViewCell : PYView
{
    NSInteger                   _cellIndex;
    NSString                    *_reuseIdentifier;
}

// Cell Index.
@property (nonatomic, readonly)         NSInteger       cellIndex;

// Reuse identify.
@property (nonatomic, readonly, copy)   NSString        *reuseIdentifier;

// Initialize the cell.
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

// When deuque the cell, call this.
- (void)prepareForReuse;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
