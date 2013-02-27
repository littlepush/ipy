//
//  UIScrollView+HiddenCell.h
//  PYUIKit
//
//  Created by Push Chen on 7/31/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	UIScrollViewHiddenCellSideTop,
	UIScrollViewHiddenCellSideLeft,
	UIScrollViewHiddenCellSideBottom,
	UIScrollViewHiddenCellSideRight
} UIScrollViewHiddenCellSide;

typedef enum {
	UIScrollViewHiddenCellParitical,
	UIScrollViewHiddenCellForceFull
} UIScrollViewHiddenCellType;

/*
	UIScrollView Hidden Cell Extend Catalog
	
	in the delegate, do like this:
	
	-(void)scrollViewDidScroll:(UIScrollView *)sender 
	{   
		[sender didScrollCheckingHiddenCellStates];
	}

	-(void) scrollViewDidEndDragging:(UIScrollView *)sender willDecelerate:(BOOL)decelerate
	{
		[sender didScrollCheckingHiddenCellStates];
		[sender endScrollCheckingHiddenCellStates];
	}
 */
@interface UIScrollView (HiddenCell)

@property (nonatomic, readonly) UIScrollViewHiddenCellType hiddenCellType;
@property (nonatomic, readonly)	UIView		*topHiddenCell;
@property (nonatomic, readonly)	UIView		*leftHiddenCell;
@property (nonatomic, readonly)	UIView		*bottomHiddenCell;
@property (nonatomic, readonly)	UIView		*rightHiddenCell;

/* add hidden cell to any side of the scroll view */
-(void) addHiddenCell:(UIView *)hcell atSide:(UIScrollViewHiddenCellSide)side;

/* set the hidden type, default is paritical */
-(void) setHiddenCellType:(UIScrollViewHiddenCellType)type;

/* invoking this message when receive the delegate message: 
	scrollViewDidScroll: 
		and
	scrollViewDidEndDragging:willDecelerate 
*/
-(void) didScrollCheckingHiddenCellStates;

/* invoking this message when receive the delegate message: 
	scrollViewDidEndDragging:willDecelerate 
*/
-(void) endScrollCheckingHiddenCellStates;

@end
