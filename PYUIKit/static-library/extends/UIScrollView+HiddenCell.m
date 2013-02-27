//
//  UIScrollView+HiddenCell.m
//  PYUIKit
//
//  Created by Push Chen on 7/31/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "UIScrollView+HiddenCell.h"

#define kHiddenType			@"kHiddenTypeScroll"
#define kTopHiddenCell		@"kTopHiddenCellScroll"
#define kLeftHiddenCell		@"kLeftHiddenCellScroll"
#define kBottomHiddenCell	@"kBottomHiddenCellScroll"
#define kRightHiddenCell	@"kRightHiddenCellScroll"
#define kShowingHidden		@"kShowingHidden"

@implementation UIScrollView (HiddenCell)

@dynamic hiddenCellType;
@dynamic topHiddenCell;
-(UIView *) topHiddenCell {
	return [self.layer valueForKey:kTopHiddenCell];
}
@dynamic leftHiddenCell;
-(UIView *)leftHiddenCell {
	return [self.layer valueForKey:kLeftHiddenCell];
}
@dynamic bottomHiddenCell;
-(UIView *)bottomHiddenCell {
	return [self.layer valueForKey:kBottomHiddenCell];
}
@dynamic rightHiddenCell;
-(UIView *)rightHiddenCell {
	return [self.layer valueForKey:kRightHiddenCell];
}

-(UIScrollViewHiddenCellType)hiddenCellType {
	NSNumber *_value = [self.layer valueForKey:kHiddenType];
	return (UIScrollViewHiddenCellType)[_value intValue];
}
-(void) setHiddenCellType:(UIScrollViewHiddenCellType)type
{
	NSNumber *_value = [NSNumber numberWithInt:type];
	[self.layer setValue:_value forKey:kHiddenType];
}

-(void) addHiddenCell:(UIView *)hcell atSide:(UIScrollViewHiddenCellSide)side
{
	UIView *_cell;
	CGRect _frame = hcell.bounds;
	switch (side) {
	case UIScrollViewHiddenCellSideTop:
		_cell = [self topHiddenCell];
		if ( _cell != nil ) {
			[_cell removeFromSuperview];
			//[_cell release];
		}
		[self.layer setValue:hcell forKey:kTopHiddenCell];
		[self addSubview:hcell];
		_frame.origin.y = -1 * (_frame.size.height);
		[hcell setFrame:_frame];
		break;
	case UIScrollViewHiddenCellSideLeft:
		_cell = [self leftHiddenCell];
		if ( _cell != nil ) {
			[_cell removeFromSuperview];
			//[_cell release];
		}
		[self.layer setValue:hcell forKey:kLeftHiddenCell];
		[self addSubview:hcell];
		_frame.origin.x = -_frame.size.width;
		[hcell setFrame:_frame];
		break;
	case UIScrollViewHiddenCellSideBottom:
		_cell = [self bottomHiddenCell];
		if ( _cell != nil ) {
			[_cell removeFromSuperview];
			//[_cell release];
		}
		[self.layer setValue:hcell forKey:kBottomHiddenCell];
		[self addSubview:hcell];
		_frame.origin.y = self.contentSize.height;
		[hcell setFrame:_frame];
		break;
	case UIScrollViewHiddenCellSideRight:
		_cell = [self rightHiddenCell];
		if ( _cell != nil ) {
			[_cell removeFromSuperview];
			//[_cell release];
		}
		[self.layer setValue:hcell forKey:kRightHiddenCell];
		[self addSubview:hcell];
		_frame.origin.x = self.contentSize.width;
		[hcell setFrame:_frame];
		break;
	};
}

-(void) didScrollCheckingHiddenCellStates
{
	int _showMask = 0;
	if ( self.topHiddenCell != nil ) {
		CGRect _frame = self.topHiddenCell.frame;
		if ( self.contentOffset.y < 0 ) _showMask |= 0x01;
		if ( self.contentOffset.y <= -_frame.size.height ) {
			_frame.origin.y = self.contentOffset.y;
			[self.topHiddenCell setFrame:_frame];
		}
	}
	
	if ( self.leftHiddenCell != nil ) {
		CGRect _frame = self.leftHiddenCell.frame;
		if ( self.contentOffset.x < 0 ) _showMask |= 0x02;
		if ( self.contentOffset.x <= -_frame.size.width ) {
			_frame.origin.x = self.contentOffset.x;
			[self.leftHiddenCell setFrame:_frame];
		}
	}
	
	if ( self.bottomHiddenCell != nil ) {
		CGRect _frame = self.bottomHiddenCell.frame;
		CGFloat _offY = self.contentOffset.y + self.frame.size.height;
		if ( _offY > self.contentSize.height ) _showMask |= 0x04;
		if ( _offY >= (self.contentSize.height + _frame.size.height) ) {
			_frame.origin.y = _offY - _frame.size.height;
			[self.bottomHiddenCell setFrame:_frame];
		}
	}
	
	if ( self.rightHiddenCell != nil ) {
		CGRect _frame = self.rightHiddenCell.frame;
		CGFloat _offX = self.contentOffset.x + self.frame.size.width;
		if ( _offX > self.contentSize.width ) _showMask |= 0x08;
		if ( _offX >=
			(self.contentSize.width + _frame.size.width) ) {
			_frame.origin.x = _offX - _frame.size.width;
			[self.rightHiddenCell setFrame:_frame];
		}
	}
	
	NSNumber *_showingHidden = [NSNumber numberWithInt:_showMask];
	[self.layer setValue:_showingHidden forKey:kShowingHidden];
}

-(void) endScrollCheckingHiddenCellStates
{
	NSNumber *_showingHiddenValue = [self.layer valueForKey:kShowingHidden];
	if ( _showingHiddenValue == nil ) {
		self.contentInset = UIEdgeInsetsZero;
	} else if ( [_showingHiddenValue intValue] > 0 ) {
		int _maskValue = _showingHiddenValue.intValue;
		UIEdgeInsets _insets = UIEdgeInsetsZero;
		if ( self.hiddenCellType == UIScrollViewHiddenCellForceFull ) {
			if ( _maskValue & 0x01 ) {
				_insets.top = self.topHiddenCell.frame.size.height;
			} else if ( _maskValue & 0x02 ) {
				_insets.left = self.leftHiddenCell.frame.size.width;
			} else if ( _maskValue & 0x04 ) {
				_insets.bottom = self.bottomHiddenCell.frame.size.height;
			} else if ( _maskValue & 0x08 ) {
				_insets.right = self.rightHiddenCell.frame.size.width;
			}
		} else {
			if ( _maskValue & 0x01 ) {
				_insets.top = MIN( 
					-self.contentOffset.y,
					self.topHiddenCell.frame.size.width
				);
			} else if ( _maskValue & 0x02 ) {
				_insets.left = MIN( 
					-(self.contentOffset.x), 
					self.leftHiddenCell.frame.size.width
				);
			} else if ( _maskValue & 0x04 ) {
				_insets.bottom = MIN(
					ABS(self.contentOffset.y - self.contentSize.height),
					self.bottomHiddenCell.frame.size.height
				);
			} else if ( _maskValue & 0x08 ) {
				_insets.right = MIN(
					ABS(self.contentOffset.x - self.contentSize.width),
					self.rightHiddenCell.frame.size.width
				);
			}			
		}
		self.contentInset = _insets;
	} else {
		self.contentInset = UIEdgeInsetsZero;
	}
}

@end
