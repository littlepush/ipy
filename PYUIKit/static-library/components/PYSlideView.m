//
//  PYSlideView.m
//  pyutility-uitest
//
//  Created by Push Chen on 6/4/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "PYSlideView.h"
#import "PYSlideContentView.h"
#import "PYSlideView+Internal.h"
#import "PYExtend.h"

/* PYSlideView Cell Implementations */

@implementation PYSlideViewCell

#define __PYSVC_OLDBACKGROUNDCLR		@"kPYSVCOldBackgroundColor"

@synthesize reusableIdentify = _reusableIdentify;
@synthesize slideView = _slideView;
@synthesize cellIndex = _cellIndexInContainer;
@synthesize isSelected = _selectStatues;
@synthesize respondedForSelection = _respondedForSelection;
@synthesize selectionStyle = _selectionStyle;
@synthesize autoDisSelected = _autoDisSelected;
@dynamic	text;

/* Properties Setter */
-(void) setSlideView:(PYSlideView *)aSlide
{
	// internal usage to set the slide view.
	_slideView = [aSlide retain];
}

-(void) setCellIndex:(NSUInteger)anIndex
{
	_cellIndexInContainer = anIndex;
}

-(void) setRespondedForSelection:(BOOL)aMark
{
	_respondedForSelection = aMark;
}

-(NSString *)text
{
	if ( _textLabel == nil ) return @"";
	return _textLabel.text;
}

-(void) setText:(NSString *)aText
{
	if ( _textLabel == nil ) {
		CGRect _frame = self.frame;
		_frame.origin.x = _frame.origin.y = 0;
		_textLabel = [[[UILabel alloc] initWithFrame:_frame] retain];
		[self addSubview:_textLabel];
		[_textLabel setBackgroundColor:[UIColor clearColor]];
		[_textLabel setTextAlignment:UITextAlignmentCenter];
	}
	[_textLabel setText:aText];
}

/* Reusable Identify Overriden */
-(void) initSetReusableIdentify
{
	// Set the default reusable identify
	_reusableIdentify = PYSLIDEVIEWCELL_REIDENTIFY;
}

/* Reusable Method Overriden */
-(void) prepareForReuse
{
	// this method should be overriden.
}

-(void) cellWillAppear
{
	// this method should be overriden.
}

-(void) cellDidAppear
{
	// this method should be overriden.
}

-(void) cellWillDisappear
{
	// this method should be overriden.
}

-(void) cellDidDisappear
{
	// this method should be overriden.
}

-(void) layoutSubviews
{
	if ( _textLabel != nil && 
		(_textLabel.frame.size.width == 0.f) && 
		(_textLabel.frame.size.height == 0.f)
		) 
	{
		CGRect _frame = self.frame;
		_frame.origin.x = _frame.origin.y = 0;
		[_textLabel setFrame:_frame];
	}
}

/* Dis-select the cell. */
-(void) disSelectSlideViewCell
{
	if ( _selectStatues == NO || !_respondedForSelection ) return;
	_selectStatues = NO;
	UIColor *_oldbackgroundColor = [self.layer valueForKey:__PYSVC_OLDBACKGROUNDCLR];
	if ( _oldbackgroundColor == nil ) 
		_oldbackgroundColor = [UIColor clearColor];
	[UIView animateWithDuration:0.12 animations:^{
		[self setBackgroundColor:_oldbackgroundColor];
	}];
}

/* Internal methods */
-(void) _tapGestureAction
{
	if ( [self.superview respondsToSelector:@selector(slideViewCellDidSelected:)] ) {
		[self.superview performSelector:
			@selector(slideViewCellDidSelected:) withObject:self];
	}
	if ( _selectStatues || !_respondedForSelection ) return;
	_selectStatues = YES;
	
	UIColor *_currentBkgClr = self.backgroundColor;
	[self.layer setValue:_currentBkgClr forKey:__PYSVC_OLDBACKGROUNDCLR];
	UIColor *_nowBkgClr = nil;
	switch (_selectionStyle) {
	case PYSlideViewCellSelectionStyleNone:
		_nowBkgClr = _currentBkgClr; break;
	case PYSlideViewCellSelectionStyleBlue:
		_nowBkgClr = [UIColor blueColor]; break;
	case PYSlideViewCellSelectionStyleGray:
		_nowBkgClr = [UIColor grayColor]; break;
	};
	
	[UIView animateWithDuration:0.12 animations:^{
		[self setBackgroundColor:_nowBkgClr];
	} completion:^(BOOL finished) {
		if ( _autoDisSelected ) [self disSelectSlideViewCell];
	}];
	//[self.layer setValue:self.backgroundColor forKey:__PYSVC_OLDBACKGROUNDCLR];
	//[self setBackgroundColor:[UIColor blueColor]];
}

-(void)internalInitial
{
	_respondedForSelection = YES;
	_beginToTap = NO;
	_autoDisSelected = YES;
	_selectionStyle = PYSlideViewCellSelectionStyleGray;
	[self setUserInteractionEnabled:YES];
}

-(void)dealloc
{
	_slideView = nil;
	_reusableIdentify = nil;
	_textLabel = nil;
	[super dealloc];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	_beginToTap = YES;
	[((PYSlideContentView *)[self superview]) touchBeginEvent:[touches anyObject]];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	_beginToTap = NO;
	[((PYSlideContentView *)[self superview]) touchMoveEvent:[touches anyObject]];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ( _beginToTap == YES ) {
		[self _tapGestureAction];
		
	} else { 
		[((PYSlideContentView *)[self superview]) touchEndedEvent:[touches anyObject]];
	}
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchesEnded:touches withEvent:event];
}

@end


/*********************************************************************************
 * PYSlideView, the Shell of PYSlideContentView
*********************************************************************************/
@implementation PYSlideView

/* Enable Paging */
@dynamic pageEnable;
-(void)setPageEnable:(BOOL)aValue
{
	[_contentView[0] setIsPagingEnable:aValue];
	[_contentView[1] setIsPagingEnable:aValue];
}

-(BOOL)isPagingEnable
{
	return _currentMasterView.isPagingEnable;
}

/* Properties */

// data source
@dynamic datasource;
-(id<PYSlideViewDataSource>)datasource { return _contentView[0].datasource; }
-(void) setDatasource:(id<PYSlideViewDataSource>)aDataSource
{
	[_contentView[0] setDatasource:aDataSource];
	[_contentView[1] setDatasource:aDataSource];
}

// delegate
@dynamic delegate;
-(id<PYSlideViewDelegate>)delegate { return _contentView[0].delegate; }
-(void) setDelegate:(id<PYSlideViewDelegate>)aDelegate
{
	[_contentView[0] setDelegate:aDelegate];
	[_contentView[1] setDelegate:aDelegate];
}

// cell count
@dynamic cellCount;
-(NSUInteger)cellCount { return _currentMasterView.cellCount; }


// padding
@dynamic padding;
-(CGFloat)padding { return _contentView[0].cellPadding; }
-(void)setCellPadding:(CGFloat)aPadding
{
	[_contentView[0] setCellPadding:aPadding];
	[_contentView[1] setCellPadding:aPadding];
}

@dynamic isCycled;
-(BOOL) isCycled { return _currentSliverView != nil; }
// set the slide view to be cycled.
-(void) setSlideViewCycledEnable:(BOOL)enable
{
	// To do
	if ( enable ) {
		if ( _currentSliverView != nil ) return;
		_currentSliverView = (_currentMasterView == _contentView[0]) ?
			_contentView[1] : _contentView[0];
		
		[_currentSliverView setBindView:_currentMasterView];
		[_currentMasterView setBindView:_currentSliverView];
		[_currentSliverView setSlideType:PYSLIDETYPE_SLIVER];
		
		[_currentSliverView clearAndLoadData];
		[self addSubview:_currentSliverView];
		
	} else {
		if ( _currentSliverView == nil ) return;
		[_currentMasterView setBindView:nil];
		
		[_currentSliverView removeFromSuperview];
		_currentSliverView = nil;
	}
}

// linger animation time
@dynamic lingerAnimationTime;
-(CGFloat)lingerAnimationTime { return _contentView[0].lingerAnimationTime; }
-(void) setLingerAnimationTime:(CGFloat)aLingerTime
{
	[_contentView[0] setLingerAnimationTime:aLingerTime];
	[_contentView[1] setLingerAnimationTime:aLingerTime];
}

// responded for selection
@dynamic respondedForSelection;
-(BOOL) respondedForSelection { return _contentView[0].respondedForSelection; }
-(void) setRespondedForSelection:(BOOL)aValue
{
	[_contentView[0] setRespondedForSelection:aValue];
	[_contentView[1] setRespondedForSelection:aValue];
}

/* Init */
-(void) internalInitial
{
	[super internalInitial];
	
	_reusableCache = [[NSMutableDictionary dictionary] retain];
	
	_contentView[0] = [[[PYSlideContentView alloc] 
		initWithSlideView:self reusableCache:_reusableCache] retain];
	[self addSubview:_contentView[0]];
	
	_contentView[1] = [[[PYSlideContentView alloc] 
		initWithSlideView:self reusableCache:_reusableCache] retain];
	[self addSubview:_contentView[1]];
	
	// default one master and the other sliver.
	_contentView[0].slideType = PYSLIDETYPE_MASTER;
	_contentView[1].slideType = PYSLIDETYPE_SLIVER;
	
	_contentView[0].bindView = _contentView[1];
	_contentView[1].bindView = _contentView[0];
	
	_currentMasterView = _contentView[0];
	_currentSliverView = _contentView[1];
	
	[self setClipsToBounds:YES];
	[self setUserInteractionEnabled:YES];
}

-(void) dealloc
{
	_currentSliverView = nil;
	_currentMasterView = nil;
	_contentView[0] = nil;
	_contentView[1] = nil;
	_reusableCache = nil;
	[super dealloc];
}

/* Messages */
-(void) reload { 
	[_currentMasterView clearAndLoadData];
	if ( _currentSliverView != nil ) {
		[_currentSliverView clearAndLoadData];
	}
}

-(void) slideToFirstCell
{
	if ( _currentSliverView == nil ) {
		while( _currentMasterView.frame.origin.x != 0 ) {
			[_currentMasterView slideToLeftCell];
		}
		return;
	}
	CGFloat _masterDelta = [_currentMasterView deltaToCellAtIndex:0];
	CGFloat _sliverDelta = [_currentSliverView deltaToCellAtIndex:0];

	if ( _masterDelta < _sliverDelta ) {
		while( _currentMasterView.frame.origin.x != 0 ) {
			( _currentMasterView.frame.origin.x < 0 ) ?
				[_currentMasterView slideToLeftCell] :
				[_currentMasterView slideToRightCell];
		}
	} else {
		while ( _currentSliverView.frame.origin.x != 0 ) {
			( _currentSliverView.frame.origin.x < 0 ) ?
				[_currentSliverView slideToLeftCell] : 
				[_currentSliverView slideToRightCell];
		}
	}
}

-(void) slideToLastCell
{
	CGFloat _stopOriginX = -(_currentMasterView.frame.size.width - self.frame.size.width);
	if ( _currentSliverView == nil ) {
		while ( _currentMasterView.frame.origin.x != _stopOriginX ) {
			[_currentMasterView slideToRightCell];
		}
		return;
	}
	CGFloat _masterDelta = [_currentMasterView 
		deltaToCellAtIndex:([self cellCount] - 1)];
	CGFloat _sliverDelta = [_currentSliverView
		deltaToCellAtIndex:([self cellCount] - 1)];
		
	if ( _masterDelta < _sliverDelta ) {
		while ( _currentMasterView.frame.origin.x != _stopOriginX ) {
			CGFloat _originRightOffsetX = (_currentMasterView.frame.origin.x - 
				self.frame.size.width) + _currentMasterView.frame.size.width;
			( _originRightOffsetX < 0 ) ?
				[_currentMasterView slideToLeftCell] : 
				[_currentMasterView slideToRightCell];
		}
	} else {
		while ( _currentSliverView.frame.origin.x != _stopOriginX ) {
			CGFloat _originRightOffsetX = (_currentSliverView.frame.origin.x - 
				self.frame.size.width) + _currentSliverView.frame.size.width;
			( _originRightOffsetX < 0 ) ?
				[_currentSliverView slideToLeftCell] :
				[_currentSliverView slideToRightCell];
		}
	}
}

-(void) slideToCellAtIndex:(NSUInteger)anIndex
{
	CGFloat _exceptXposition = -(anIndex * self.frame.size.width);
	if ( _currentSliverView == nil ) {
		while ( _currentMasterView.frame.origin.x != _exceptXposition ) {
			( _currentMasterView.frame.origin.x < _exceptXposition ) ?
				[_currentMasterView slideToRightCell] : 
				[_currentMasterView slideToLeftCell];
		}
		return;
	}
	
	CGFloat _masterDelta = [_currentMasterView deltaToCellAtIndex:anIndex];
	CGFloat _sliverDelta = [_currentSliverView deltaToCellAtIndex:anIndex];
	
	if ( _masterDelta < _sliverDelta ) {
		while ( _currentMasterView.frame.origin.x != _exceptXposition ) {
			( _currentMasterView.frame.origin.x < _exceptXposition ) ?
				[_currentMasterView slideToRightCell] : 
				[_currentMasterView slideToLeftCell];
		}
	} else {
		while (_currentSliverView.frame.origin.x != _exceptXposition ) {
			( _currentSliverView.frame.origin.x < _exceptXposition ) ?
				[_currentSliverView slideToRightCell] : 
				[_currentSliverView slideToLeftCell];
		}
	}
}

-(void) scrollToOffSet:(CGPoint)offSet animated:(BOOL)animated
{
	CGPoint _offSet = CGPointMake(-offSet.x, 0);
	[_currentMasterView scrollToOffSet:_offSet animated:animated];
}

-(void) selectCellAtIndex:(NSUInteger)anIndex
{
	[_currentMasterView markCellAtIndex:anIndex selectionStatues:YES];
	if ( _currentSliverView != nil ) {
		[_currentSliverView markCellAtIndex:anIndex selectionStatues:YES];
	}
}

-(void) disselectCellAtIndex:(NSUInteger)anIndex
{
	[_currentMasterView markCellAtIndex:anIndex selectionStatues:NO];
	if ( _currentSliverView != nil ) {
		[_currentSliverView markCellAtIndex:anIndex selectionStatues:NO];
	}
}

-(BOOL) isCellShownAtIndex:(NSUInteger)anIndex
{
	NSArray *_cells = [_currentMasterView visiableCells];
	for ( PYSlideViewCell *_cell in _cells ) {
		if (_cell.cellIndex == anIndex) return YES;
	}
	if ( _currentSliverView == nil ) return NO;
	_cells = [_currentSliverView visiableCells];
	for ( PYSlideViewCell *_cell in _cells ) {
		if (_cell.cellIndex == anIndex) return YES;
	} 
	return NO;
}

-(PYSlideViewCell *)visiableCellAtIndex:(NSUInteger)anIndex
{
	NSArray *_cells = [_currentMasterView visiableCells];
	PYSlideViewCell * visibleCell = nil;
	for ( PYSlideViewCell * _cell in _cells ) {
		if ( _cell.cellIndex == anIndex ) {
			visibleCell = _cell;
			break;
		}
	}
	if ( visibleCell != nil ) return visibleCell;
	if ( _currentSliverView == nil ) return visibleCell;
	_cells = [_currentSliverView visiableCells];
	for ( PYSlideViewCell * _cell in _cells ) {
		if ( _cell.cellIndex == anIndex ) {
			visibleCell = _cell;
			break;
		}
	}
	return visibleCell;
}

-(NSArray *)visiableCells { return [_contentView[0] visiableCells]; }

-(PYSlideViewCell *)dequeueReusableSlideViewCellWithIdentify:(NSString *)identify
{
	return [_currentMasterView dequeueReusableSlideViewCellWithIdentify:identify];
}

/* Overriden */
-(void) layoutSubviews
{
	if ( _initialed ) return;
	_initialed = YES;
	[_currentMasterView clearAndLoadData];
	if ( _currentSliverView != nil ) {
		[_currentSliverView clearAndLoadData];
	}
}

-(void) exchangeMasterContentView:(PYSlideContentView *)master 
	withSliverView:(PYSlideContentView *)sliver
{
	if ( _currentMasterView != master || _currentSliverView != sliver ) return;
	_currentMasterView = sliver;
	_currentSliverView = master;
	
	_currentMasterView.slideType = PYSLIDETYPE_MASTER;
	_currentSliverView.slideType = PYSLIDETYPE_SLIVER;
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	UIView *_hitView = [super hitTest:point withEvent:event];
	if ( _hitView == self ) return _currentMasterView;
	return _hitView;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint _touchPoint = [[touches anyObject] locationInView:_currentMasterView];
	if ( CGRectContainsPoint(_currentMasterView.bounds, _touchPoint) )
		[_currentMasterView touchesBegan:touches withEvent:event];
	else
		[_currentSliverView touchesBegan:touches withEvent:event];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint _touchPoint = [[touches anyObject] locationInView:_currentMasterView];
	if ( CGRectContainsPoint(_currentMasterView.bounds, _touchPoint) )
		[_currentMasterView touchesEnded:touches withEvent:event];
	else
		[_currentSliverView touchesEnded:touches withEvent:event];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint _touchPoint = [[touches anyObject] locationInView:_currentMasterView];
	if ( CGRectContainsPoint(_currentMasterView.bounds, _touchPoint) )
		[_currentMasterView touchesMoved:touches withEvent:event];
	else
		[_currentSliverView touchesMoved:touches withEvent:event];
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint _touchPoint = [[touches anyObject] locationInView:_currentMasterView];
	if ( CGRectContainsPoint(_currentMasterView.bounds, _touchPoint) )
		[_currentMasterView touchesEnded:touches withEvent:event];
	else
		[_currentSliverView touchesEnded:touches withEvent:event];
}

@end
