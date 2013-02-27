//
//  PYHitCover.h
//  FootPath
//
//  Created by Push Chen on 3/21/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PYComponentView.h"

/* 
	Hit Cover Interface.
	Use this interface to cover a piece of room, then
	any touch event on this view will be considered as
	touch on the cover view.
 */
@interface PYHitCover : PYComponentView {
	// transform cover view.
	UIView		*_coverView;
}

/* Property Transform Cover View. */
@property (nonatomic, retain) IBOutlet UIView *coverView;

@end
