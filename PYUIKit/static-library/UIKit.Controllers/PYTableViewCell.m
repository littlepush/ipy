//
//  PYTableViewCell.m
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

#import "PYTableViewCell.h"

@implementation PYTableViewCell

@synthesize cellIndex = _cellIndex;
@synthesize reuseIdentifier = _reuseIdentifier;

// Initialize the cell.
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super init];
    if ( self ) {
        _reuseIdentifier = [reuseIdentifier copy];
        _testTitleLayer = [PYLabelLayer layer];
        [_testTitleLayer setFrame:CGRectMake(0, 0, 320.f, 120.f)];
        [_testTitleLayer setTextAlignment:NSTextAlignmentCenter];
        [_testTitleLayer setTextFont:[UIFont systemFontOfSize:18.f]];
        [self addChild:_testTitleLayer];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    [_testTitleLayer setText:title];
}

// When deuque the cell, call this.
- (void)prepareForReuse
{
    // nothing to do...
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
