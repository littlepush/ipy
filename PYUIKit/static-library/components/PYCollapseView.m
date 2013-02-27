//
//  PYCollapseView.m
//  PYUIKit
//
//  Created by littlepush on 8/17/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "PYCollapseView.h"
#import "CALayer+Gradient.h"
#include <memory.h>

#define C(c)	(((float)(c))/255.f)
#define SECTION_HEADER_COLOR_TOP		\
	[UIColor colorWithRed:C(123) green:C(127) blue:C(136) alpha:1.0]
#define SECTION_HEADER_COLOR_BOTTOM		\
	[UIColor colorWithRed:C(78) green:C(83) blue:C(87) alpha:1.0]
	
#define SECTION_ROW_COLOR_TOP			\
	[UIColor colorWithRed:C(255) green:C(255) blue:C(255) alpha:1.0]
#define SECTION_ROW_COLOR_BOTTOM		\
	[UIColor colorWithRed:C(225) green:C(226) blue:C(228) alpha:1.0]
	
#define SECTION_SELECT_COLOR_TOP		\
	[UIColor colorWithRed:C(93) green:C(189) blue:C(227) alpha:1.0]
#define SECTION_SELECT_COLOR_BOTTOM		\
	[UIColor colorWithRed:C(40) green:C(136) blue:C(176) alpha:1.0]


////////////////////////////////////////////////////////////////////////////////////////////
// Internal of cell view
@interface PYCollapseViewCell (Internal)

/* Setting */
-(void) setCollapseView:(PYCollapseView *)collapseView;
-(void) setIndexPath:(NSIndexPath *)indexPath;

/* Clear */
-(void) clearSubviews;

@end

////////////////////////////////////////////////////////////////////////////////////////////
// Internal of collapse view
@interface PYCollapseView (Internal)

/* Row selected action */
-(void) rowTouchUpInsideAction:(id)sender;
-(void) cellDidSelectedAt:(NSIndexPath *)indexPath;

/* Reusable Cell Cache */
-(void) enqueueReusableCell:(PYCollapseViewCell *)cell;

/* Section click */
-(void) sectionHeaderDidTouchAction:(id)sender;

/* Set Collapse Type */
-(void) setTransformForRowCellCollapse:(PYCollapseViewCell *)cell 
	translation:(CGFloat)transloation;
	
-(void) loadRowsOfSection:(NSUInteger)section;

-(void) removeRowsOfSection:(NSUInteger)section;

-(void) clearSections;

@end

////////////////////////////////////////////////////////////////////////////////////////////
// Implementation of collapse view
@implementation PYCollapseView

@synthesize collapseStyle = _collapseStyle;
@synthesize datasource = _datasource;
@dynamic delegate;
-(void) setDelegate:(id<PYCollapseViewDelegate>)delegate
{
	_delegate = nil;
	_delegate = [delegate retain];
	[_contentScrollView setDelegate:delegate];
}
-(id<PYCollapseViewDelegate>)delegate { return _delegate; }

@synthesize sectionCount = _sectionCount;

-(void) internalInitial
{
	[super internalInitial];
	
	
	_contentScrollView = [[UIScrollView object] retain];
	[self addSubview:_contentScrollView];
	
	[_contentScrollView setScrollEnabled:YES];
	[_contentScrollView setAlwaysBounceVertical:YES];
	[_contentScrollView setBounces:YES];
	[_contentScrollView setBackgroundColor:[UIColor clearColor]];
	[_contentScrollView setMultipleTouchEnabled:NO];
	[_contentScrollView setShowsHorizontalScrollIndicator:NO];
	[_contentScrollView setShowsVerticalScrollIndicator:NO];
	
	_cellViewCache = [[NSMutableDictionary dictionary] retain];
		
	_sectionInfos = NULL;
	_sectionCount = 0;
}

-(void) dealloc
{
	_contentScrollView = nil;
	_delegate = nil;
	_datasource = nil;	
	[self clearSections];
	_cellViewCache = nil;
	[super dealloc];
}

+(NSString *) defaultCollaspeViewCellIdentifyKey
{
	static NSString *_key = @"kDefaultCollaspeViewCellIdentifyKey";
	return _key;
}
+(PYCollapseViewCell *) defaultCollapseViewCellOf:(PYCollapseView *)collapseView
{
	PYCollapseViewCell *_cell = [collapseView dequeueReusableCellWithIdentify:
		[PYCollapseView defaultCollaspeViewCellIdentifyKey]];
	if ( _cell == nil ) {
		_cell = [PYCollapseViewCell object];
		[_cell setReusableIdentify:[PYCollapseView defaultCollaspeViewCellIdentifyKey]];
	}
	_cell.selectedStyle = PYCollapseViewCellSelectedStyleBlue;
	return _cell;
}
+(PYCollapseViewCell *) defaultCollapseViewSectionView
{
	PYCollapseViewCell * _sectionCell = [PYCollapseViewCell object];
	[_sectionCell setReusableIdentify:[PYCollapseView 
		defaultCollaspeViewCellIdentifyKey]];
	//[_sectionCell setIsSectionTitle:YES];
	[_sectionCell.layer 
		setGradientColorFrom:SECTION_HEADER_COLOR_TOP
		to:SECTION_HEADER_COLOR_BOTTOM];
	return _sectionCell;
}

/* Reload the data */
-(void) reloadData
{
	// Clear all sections
	[self clearSections];
	_sectionCount = 0;
	
	// reload data from datasource
	if ( _datasource == nil ) return;
	
	_sectionCount = [_datasource numberOfSectionsInPYCollapseView:self];
	if ( _sectionCount == 0 ) return;
	_sectionInfos = (struct PYCollapseSectionInfo *)calloc(
		_sectionCount, sizeof(struct PYCollapseSectionInfo));
		
	BOOL _isResponseToHeightOfSection = [_datasource respondsToSelector:
		@selector(pyCollapseView:heightOfSection:)];
	BOOL _isResponseToTitleOfSection = [_datasource respondsToSelector:
		@selector(pyCollapseView:titleOfSection:)];
	BOOL _isResponseToDynamicLoading = [_datasource respondsToSelector:
		@selector(pyCollapseView:isDynamicLoadRowsInSection:)];
	BOOL _isResponseToInitCollapseStyle = [_datasource respondsToSelector:
		@selector(pyCollapseView:isInitSectionCollapsed:)];
	// scroll view content size
	CGFloat _contentHeight = 0.f;

	for ( int i = 0; i < _sectionCount; ++i ) 
	{
		// section height
		_sectionInfos[i].sectionHeaderHeight = (_isResponseToHeightOfSection ?
			[_datasource pyCollapseView:self heightOfSection:i] : 44.f);
		// dynamic loading
		_sectionInfos[i].dynamicLoadRows = (_isResponseToDynamicLoading ?
			[_datasource pyCollapseView:self isDynamicLoadRowsInSection:i] : NO);
		// init collapsed
		_sectionInfos[i].isSectionCollapsed = (_isResponseToInitCollapseStyle ?
			[_datasource pyCollapseView:self isInitSectionCollapsed:i] : NO);
		// add sub content view
		_sectionInfos[i].sectionContentView = [[UIView object] retain];
		[_contentScrollView addSubview:_sectionInfos[i].sectionContentView];
				
		// create section header
		_sectionInfos[i].sectionHeaderView = [[PYCollapseView 
			defaultCollapseViewSectionView] retain];
		[_sectionInfos[i].sectionContentView addSubview:_sectionInfos[i].sectionHeaderView];
			
		// init section header view
		[_sectionInfos[i].sectionHeaderView setFrame:CGRectMake(0, 0, 
			self.frame.size.width, _sectionInfos[i].sectionHeaderHeight)];
		[_sectionInfos[i].sectionHeaderView setCollapseView:self];
		[_sectionInfos[i].sectionHeaderView setIndexPath:[NSIndexPath indexPathForRow:-1 inSection:i]];
		[_sectionInfos[i].sectionHeaderView.layer 
			setGradientColorFrom:SECTION_HEADER_COLOR_TOP 
			to:SECTION_HEADER_COLOR_BOTTOM];
		
		// add action target
		[_sectionInfos[i].sectionHeaderView addTarget:self 
			action:@selector(sectionHeaderDidTouchAction:) 
			forControlEvents:UIControlEventTouchUpInside];
		
		// section titles
		if ( _isResponseToTitleOfSection )
		{
			_sectionInfos[i].sectionTitle = [_datasource pyCollapseView:self titleOfSection:i];
			[_sectionInfos[i].sectionHeaderView setText:_sectionInfos[i].sectionTitle];
			[_sectionInfos[i].sectionHeaderView.textLabel setTextColor:[UIColor whiteColor]];
		}
		
		// view for section
		if ( [_delegate respondsToSelector:@selector(pyCollapseView:viewForSection:)] )
		{
			UIView *_sectionSubView = [_delegate pyCollapseView:self viewForSection:i];
			[_sectionSubView setFrame:_sectionInfos[i].sectionHeaderView.bounds];
			[_sectionInfos[i].sectionHeaderView addSubview:_sectionSubView];
		}
		
		// will display
		if ( [_delegate respondsToSelector:@selector(
			pyCollapseView:willDisplaySectionHeaderView:ofSection:)] )
		{
			[_delegate pyCollapseView:self 
				willDisplaySectionHeaderView:_sectionInfos[i].sectionHeaderView 
				ofSection:i];
		}
		
		if ( _sectionInfos[i].dynamicLoadRows == NO ) 
			[self loadRowsOfSection:i];
		CGFloat _allHeight = _sectionInfos[i].sectionHeaderHeight;
		CGFloat _lastContentHeight = _contentHeight;
		_contentHeight += _sectionInfos[i].sectionHeaderHeight;
		if ( _sectionInfos[i].isSectionCollapsed ) {
			_contentHeight += _sectionInfos[i].sectionContentHeight;
			_allHeight += _sectionInfos[i].sectionContentHeight;
		}
		[_sectionInfos[i].sectionContentView setFrame:CGRectMake(0, _lastContentHeight, 
			self.bounds.size.width, _allHeight)];
	}
	
	// set content size
	[_contentScrollView setFrame:self.bounds];
	[_contentScrollView setContentSize:CGSizeMake(
		self.bounds.size.width, _contentHeight)];
}

-(PYCollapseViewCell *)dequeueReusableCellWithIdentify:(NSString *)identify
{
	if ( [identify length] == 0 ) return nil;
	
	NSMutableSet *_set = [_cellViewCache objectForKey:identify];
	if ( _set == nil ) return nil;
	PYCollapseViewCell *_cell = [[[_set anyObject] retain] autorelease];
	if ( _cell != nil ) {
		[_set removeObject:_cell];
	}
	
	return _cell;
}

-(PYCollapseViewCell *) headerViewOfSection:(NSUInteger)section
{
	if ( section >= _sectionCount ) return nil;
	return _sectionInfos[section].sectionHeaderView;
}
-(PYCollapseViewCell *) rowViewInSection:(NSIndexPath *)indexPath
{
	if ( indexPath.section >= _sectionCount ) return nil;
	if ( indexPath.row >= [_sectionInfos[indexPath.section].rowsInSection count] ) return nil;
	return [_sectionInfos[indexPath.section].rowsInSection objectAtIndex:indexPath.row];
}

-(void) collapseSection:(NSUInteger)section animated:(BOOL)animated
{
	if ( _sectionInfos == NULL ) return;
	if ( _sectionInfos[section].isSectionCollapsed ) return;
	if ( [_delegate respondsToSelector:@selector(pyCollapseView:willCollapseSection:)] )
	{
		[_delegate pyCollapseView:self willCollapseSection:section];
	}
	PYActionDone _coreBlock = ^{
		// set scroll view content size.
		CGSize _ctntSize = _contentScrollView.contentSize;
		_ctntSize.height += _sectionInfos[section].sectionContentHeight;
		[_contentScrollView setContentSize:_ctntSize];
		
		// set content view size
		CGRect _contentFrame = _sectionInfos[section].sectionContentView.frame;
		_contentFrame.size.height += _sectionInfos[section].sectionContentHeight;
		[_sectionInfos[section].sectionContentView setFrame:_contentFrame];
		
		CGFloat _deltaHeight = _sectionInfos[section].sectionContentHeight;
		// move all sections below
		for ( int i = section + 1; i < _sectionCount; ++i )
		{
			[_sectionInfos[i].sectionContentView setFrame:CGRectOffset(
				_sectionInfos[i].sectionContentView.frame, 0, _deltaHeight)];
		}
		
		// move cells
		for ( PYCollapseViewCell *cell in _sectionInfos[section].rowsInSection )
		{
			[cell setTransform:CGAffineTransformIdentity];
			[cell.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
			[cell.layer setTransform:CATransform3DIdentity];
			[cell setAlpha:1.0];
		}
	};
	
	PYActionDone _completionBlock = ^{
		_sectionInfos[section].isSectionCollapsed = YES;
		if ( [_delegate respondsToSelector:@selector(pyCollapseView:didCollapsedSection:)] )
		{
			[_delegate pyCollapseView:self didCollapsedSection:section];
		}
	};
	
	if ( _sectionInfos[section].dynamicLoadRows ) {
		[self loadRowsOfSection:section];
	}
	
	// animated
	if ( animated ) {
	[UIView animateWithDuration:.35 animations:^{
		_coreBlock();
	} completion:^(BOOL finished) {
		_completionBlock();
	}];
	} else {
		_coreBlock();
		_completionBlock();
	}
}

-(void) unCollapseSection:(NSUInteger)section animated:(BOOL)animated
{
	if ( _sectionInfos == NULL ) return;
	if ( !_sectionInfos[section].isSectionCollapsed ) return;
	if ( [_delegate respondsToSelector:@selector(pyCollapseView:willUncollapseSection:)] )
	{
		[_delegate pyCollapseView:self willUncollapseSection:section];
	}

	PYActionDone _coreBlock = ^{
		CGSize _ctntSize = _contentScrollView.contentSize;
		_ctntSize.height -= _sectionInfos[section].sectionContentHeight;
		[_contentScrollView setContentSize:_ctntSize];

		// set content size
		CGRect _subRect = _sectionInfos[section].sectionContentView.frame;
		_subRect.size.height -= _sectionInfos[section].sectionContentHeight;
		[_sectionInfos[section].sectionContentView setFrame:_subRect];
		
		CGFloat _deltaHeight = _sectionInfos[section].sectionContentHeight;
		for ( int i = section + 1; i < _sectionCount; ++i )
		{
			CGRect _frame = _sectionInfos[i].sectionContentView.frame;
			_frame.origin.y -= _deltaHeight;
			[_sectionInfos[i].sectionContentView setFrame:_frame];
		}
		// rows
		CGFloat _contentHeight = _sectionInfos[section].sectionHeaderHeight;
		int rowId = 0;
		for ( PYCollapseViewCell *cell in _sectionInfos[section].rowsInSection )
		{
			[self setTransformForRowCellCollapse:cell translation:-_contentHeight];
			_contentHeight += _sectionInfos[section].rowHeightList[rowId];
			rowId += 1;
		}
		
		// check last selected
		if ( lastSelectedRow != nil ){
		NSIndexPath *_lastSelected = lastSelectedRow.indexPath;
		if ( _lastSelected.section == section ) {
			[lastSelectedRow setIsSelected:NO];
			if ( [_delegate respondsToSelector:@selector(pyCollapseView:didUnselectedRowInSection:)] )
				[_delegate pyCollapseView:self didUnselectedRowInSection:_lastSelected];
			lastSelectedRow = nil;
		}
		}
	};
	
	PYActionDone _completionBlock = ^{
		_sectionInfos[section].isSectionCollapsed = NO;
		if ( [_delegate respondsToSelector:@selector(pyCollapseView:didUncollapsedSection:)] )
		{
			[_delegate pyCollapseView:self didUncollapsedSection:section];
		}
		if ( _sectionInfos[section].dynamicLoadRows ) 
			[self removeRowsOfSection:section];
	};
	if ( animated ) {
	[UIView animateWithDuration:.35 animations:^{
		_coreBlock();
	} completion:^(BOOL finished) {
		_completionBlock();
	}];
	} else {
		_coreBlock();
		_completionBlock();
	}
}

-(void) setContentInset:(UIEdgeInsets)edgeInsets
{
	[_contentScrollView setContentInset:edgeInsets];
}
-(void) setContentOffset:(CGPoint)offset
{
	[_contentScrollView setContentOffset:offset];
}

-(void) scrollToTop
{
	[_contentScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

-(void) scrollToBottom
{
	CGFloat _y = _contentScrollView.contentSize.height - 
		_contentScrollView.bounds.size.height;
	//if ( _y > 0 ) _y = 0;
	[_contentScrollView setContentOffset:CGPointMake(0, _y) animated:YES];
}

/* Internal */

-(void) clearSections
{
	if ( _sectionInfos != NULL )
	{
		for ( int i = 0; i < _sectionCount; ++i ) {
			for ( PYCollapseViewCell *rowCell in _sectionInfos[i].rowsInSection )
			{
				[rowCell clearSubviews];
				[self enqueueReusableCell:rowCell];
			}
			[_sectionInfos[i].sectionHeaderView clearSubviews];
			[self enqueueReusableCell:_sectionInfos[i].sectionHeaderView];
			
			free( _sectionInfos[i].rowHeightList );
			_sectionInfos[i].sectionTitle = nil;
			_sectionInfos[i].rowsInSection = nil;
			_sectionInfos[i].sectionContentView = nil;
			_sectionInfos[i].sectionHeaderView = nil;
		}
		free(_sectionInfos);
		_sectionInfos = NULL;
	}
}

-(void) loadRowsOfSection:(NSUInteger)section
{
	BOOL _isResponseToHeightOfRow = [_datasource respondsToSelector:
		@selector(pyCollapseView:heightOfRowInSection:)];
		
	[self removeRowsOfSection:section];
	// row count
	_sectionInfos[section].rowCount = [_datasource 
		pyCollapseView:self numberOfRowInSection:section];
		
	// reset the height cache
	_sectionInfos[section].rowHeightList = (CGFloat *)calloc(
		_sectionInfos[section].rowCount, sizeof(CGFloat));
	
	// reset the rows in section cache
	if ( _sectionInfos[section].rowsInSection == nil ) {
	_sectionInfos[section].rowsInSection = [[NSMutableArray array] retain];
	}
	
	// get all row heights
	_sectionInfos[section].sectionContentHeight = 0.f;
	CGFloat _contentHeight = _sectionInfos[section].sectionHeaderHeight;
	for ( int rowId = 0; rowId < _sectionInfos[section].rowCount; ++rowId )
	{
		_sectionInfos[section].rowHeightList[rowId] = (_isResponseToHeightOfRow ?
			[_datasource pyCollapseView:self heightOfRowInSection:[
				NSIndexPath indexPathForRow:rowId inSection:section]] : 44.f);
				
		NSIndexPath *_rowIndex = [NSIndexPath indexPathForRow:rowId inSection:section];
		PYCollapseViewCell *_cell = [_datasource
			pyCollapseView:self cellOfRowInSection:_rowIndex];
		PYASSERT(_cell != nil, @"Collapse View Cell cannot be nil");
		[_cell setCollapseView:self];
		[_cell setIndexPath:_rowIndex];
		
		// set frame
		[_cell setFrame:CGRectMake(0, _contentHeight, 
			self.bounds.size.width, 
			_sectionInfos[section].rowHeightList[rowId])];
			
		if ( [_delegate respondsToSelector:@selector(
			pyCollapseView:willDisplayCell:ofRowInSection:)] )
			[_delegate pyCollapseView:self willDisplayCell:_cell ofRowInSection:_rowIndex];
			
		// set transform
		if ( !_sectionInfos[section].isSectionCollapsed ) {
		[self setTransformForRowCellCollapse:_cell translation:-_contentHeight];
		}
		[_sectionInfos[section].sectionContentView insertSubview:_cell atIndex:0];
		
		// target
		[_cell.layer setGradientColorFrom:SECTION_ROW_COLOR_TOP 
			to:SECTION_ROW_COLOR_BOTTOM];
		[_cell addTarget:self  
			action:@selector(rowTouchUpInsideAction:) 
			forControlEvents:UIControlEventTouchUpInside];

		// cache
		[_sectionInfos[section].rowsInSection addObject:_cell];
		_sectionInfos[section].sectionContentHeight +=
			_sectionInfos[section].rowHeightList[rowId];
		_contentHeight += _sectionInfos[section].rowHeightList[rowId];
	}	
}

-(void) removeRowsOfSection:(NSUInteger)section
{
	if ( _sectionInfos[section].rowHeightList != NULL )
		free(_sectionInfos[section].rowHeightList);
	_sectionInfos[section].rowHeightList = NULL;
	if ( _sectionInfos[section].rowsInSection != nil ) {
	for ( PYCollapseViewCell *_cell in _sectionInfos[section].rowsInSection ) {
		[_cell clearSubviews];
		[self enqueueReusableCell:_cell];
	}
	[_sectionInfos[section].rowsInSection removeAllObjects];
	}
	_sectionInfos[section].sectionContentHeight = 0.f;
	_sectionInfos[section].rowCount = 0;
}

-(void) sectionHeaderDidTouchAction:(id)sender
{
	PYCollapseViewCell *_section = (PYCollapseViewCell *)sender;
	int sectionId = [[_section indexPath] section];
	if ( _sectionInfos[sectionId].isSectionCollapsed )
	{
		[self unCollapseSection:sectionId animated:YES];
	}
	else
	{
		[self collapseSection:sectionId animated:YES];
	}
}

-(void) rowTouchUpInsideAction:(id)sender
{
	PYCollapseViewCell *cell = (PYCollapseViewCell *)sender;
	NSIndexPath *indexPath = cell.indexPath;
	// check last selected
	if ( lastSelectedRow != nil ){
	NSIndexPath *_lastSelected = lastSelectedRow.indexPath;
	if ( _lastSelected.section != indexPath.section || _lastSelected.row != indexPath.row ) {
		[lastSelectedRow setIsSelected:NO];
		if ( [_delegate respondsToSelector:@selector(pyCollapseView:didUnselectedRowInSection:)] )
			[_delegate pyCollapseView:self didUnselectedRowInSection:_lastSelected];
		lastSelectedRow = nil;
	}
	}
	[cell setIsSelected:YES];	
	[self cellDidSelectedAt:indexPath];
	lastSelectedRow = [cell retain];
}

-(void) cellDidSelectedAt:(NSIndexPath *)indexPath
{
	if ( [_delegate respondsToSelector:@selector(pyCollapseView:didSelectedRowInSection:)] )
	{
		[_delegate pyCollapseView:self didSelectedRowInSection:indexPath];
	}
}

-(void) enqueueReusableCell:(PYCollapseViewCell *)cell
{
	if ( cell == nil ) return;
	[cell removeTarget:self action:@selector(rowTouchUpInsideAction:) 
		forControlEvents:UIControlEventTouchUpInside];
	[cell removeTarget:self action:@selector(sectionHeaderDidTouchAction:) 
		forControlEvents:UIControlEventTouchUpInside];
	[cell removeFromSuperview];
	
	if ( [[cell reusableIdentify] length] == 0 ) return;
	/* Reset set statue */
	[cell setAlpha:1.];
	[cell setTransform:CGAffineTransformIdentity];
	[cell.layer setTransform:CATransform3DIdentity];
	NSMutableSet *_set = [_cellViewCache objectForKey:cell.reusableIdentify];
	if ( _set == nil ) {
		_set = [NSMutableSet set];
		[_cellViewCache setValue:_set forKey:cell.reusableIdentify];
	}
	[_set addObject:cell];
}

-(void) setTransformForRowCellCollapse:(PYCollapseViewCell *)cell
	translation:(CGFloat)transloation
{
	if ( _collapseStyle == PYCollapseStyleFade ) {
		[cell setAlpha:0.0];
		[cell setTransform:CGAffineTransformMakeTranslation(0, transloation)];
	} else if ( _collapseStyle == PYCollapseStyleFold ) {
		NSInteger row = cell.indexPath.row;
		NSInteger section = cell.indexPath.section;
		
		CATransform3D transform3D = CATransform3DIdentity;
		transform3D.m34 = 0.005;
		transloation += _sectionInfos[section].sectionHeaderHeight / 2;
		CATransform3D rotate = CATransform3DRotate(transform3D, 
			M_PI_2, ((row % 2) ? -1 : 1), 0, 0);
		CATransform3D trans = CATransform3DMakeTranslation(0, transloation, 0);
		CATransform3D transform = CATransform3DConcat(rotate, trans);
		//CATransform3D transform = CATransform3DTranslate(rotate, 0, transloation, 0);
		[cell.layer setTransform:transform];
	}
}

/* Overwrite */
-(void) layoutSubviews
{
	PYComponentViewInitChecking;
	[self reloadData];
}

-(void) setClipsToBounds:(BOOL)clipsToBounds
{
	[super setClipsToBounds:clipsToBounds];
	[_contentScrollView setClipsToBounds:clipsToBounds];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////
// Implementation of collapse cell view
@implementation PYCollapseViewCell

@synthesize reusableIdentify = _reusableIdentify;
@synthesize rightView = _rightView;
-(void) setRightView:(UIView *)rightView
{
	if ( _rightView ) {
		[_rightView removeFromSuperview];
		[_rightView release];
		_rightView = nil;
	}
	_rightView = [rightView retain];
	if ( _rightView == nil ) return;
	[self addSubview:_rightView];
	[self setNeedsDisplay];
}

@dynamic textLabel;
-(void) setTextLabel:(UILabel *)textLabel
{
	if ( _textLabel != nil ) [_textLabel removeFromSuperview];
	_textLabel = nil;
	_textLabel = [textLabel retain];
	[self addSubview:_textLabel];
	[self setNeedsDisplay];
}
-(UILabel *)textLabel { return _textLabel; }
@dynamic iconView;
-(void) setIconView:(UIImageView *)iconView
{
	if ( _iconView != nil ) [_iconView removeFromSuperview];
	_iconView = nil;
	_iconView = [iconView retain];
	[self addSubview:_iconView];
	[self setNeedsDisplay];
}
-(UIImageView *)iconView { return _iconView; }
@dynamic isSelected;
-(BOOL)isSelected { return _isSelected; }
-(void) setIsSelected:(BOOL)selected
{
	if ( _selectStyle == PYCollapseViewCellSelectedStyleNone ) return;
	if ( selected )
		[self.layer setGradientColorFrom:SECTION_SELECT_COLOR_TOP 
			to:SECTION_SELECT_COLOR_BOTTOM];
	else 
		[self.layer setGradientColorFrom:SECTION_ROW_COLOR_TOP 
			to:SECTION_ROW_COLOR_BOTTOM];
	_isSelected = selected;
}
@synthesize collapseView = _collapseView;
@synthesize indexPath = _indexPath;
@synthesize selectedStyle = _selectStyle;
@dynamic padding;
-(void) setPadding:(CGFloat)padding
{
	_padding = padding;
	[self setNeedsDisplay];
}
-(CGFloat)padding { return _padding; }

-(id) initWithReusableIdentify:(NSString *)identify
{
	self = [super init];
	if ( self ) {
		self.reusableIdentify = [identify retain];
	}
	return self;
}

-(void) setText:(NSString *)text
{
	if ( _textLabel == nil ) {
		[self setTextLabel:[UILabel object]];
		[_textLabel setBackgroundColor:[UIColor clearColor]];
	}
	[_textLabel setText:text];
}

-(void) setIcon:(UIImage *)icon
{
	if ( _iconView == nil ) {
		[self setIconView:[UIImageView object]];
	}
	[_iconView setImage:icon];
}

/* Internal */
/* Setting */
-(void) setCollapseView:(PYCollapseView *)collapseView
{
	_collapseView = nil;
	_collapseView = [collapseView retain];
}
-(void) setIndexPath:(NSIndexPath *)indexPath
{
	_indexPath = nil;
	_indexPath = [indexPath retain];
}

/* Clear */
-(void) clearSubviews
{
	if ( ![NSStringFromClass([self class]) isEqualToString:@"PYCollapseViewCell"] ) {
		return;
	}
	
	NSArray *subCopy = [[self.subviews copy] autorelease];
	for ( UIView *subview in subCopy )
	{
		if ( subview == _textLabel || subview == _iconView )
			continue;
		[subview removeFromSuperview];
	}
}

/* Over write */
-(void) internalInitial
{
	[super internalInitial];
	
	[self setBackgroundColor:[UIColor whiteColor]];
	[self.layer setGradientColorFrom:SECTION_ROW_COLOR_TOP 
		to:SECTION_ROW_COLOR_BOTTOM];
		
//	[self.layer setBorderColor:[UIColor blackColor].CGColor];
//	[self.layer setBorderWidth:3.f];
}

-(void) dealloc
{
	[_reusableIdentify release];
	[_textLabel release];
	[_iconView release];
	[_indexPath release];
	[_collapseView release];
	[_rightView release];
	
	[super dealloc];
}

-(void) layoutSubviews
{
	PYComponentViewInitChecking;
	CGSize size = self.bounds.size;
	if ( _iconView != nil )
	{
		CGRect _rect = CGRectMake(_padding, _padding, 
			size.height - 2 * _padding, size.height - 2 * _padding);
		[_iconView setFrame:_rect];
	}
	
	if ( _textLabel != nil )
	{
		CGFloat _x = (_iconView == nil) ? _padding : size.height;
		CGFloat _w = size.width - _x - _padding;
		CGRect _rect = CGRectMake(_x, _padding, _w, size.height - 2 * _padding);
		[_textLabel setFrame:_rect];
	}
	
	if ( _rightView != nil )
	{
		CGFloat _w = 2 *_padding;
		CGRect _rect = CGRectMake(size.width - _w - _padding, _padding, _w, _w);
		[_rightView setFrame:_rect];
	}
	
	[super layoutSubviews];
}

@end

