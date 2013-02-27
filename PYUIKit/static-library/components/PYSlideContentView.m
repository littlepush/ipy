//
//  PYSlideContentView.m
//  pyutility-uitest
//
//  Created by Push Chen on 6/13/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "PYSlideView.h"
#import "PYSlideContentView.h"
#import "PYSlideView+Internal.h"
#import "PYExtend.h"

//#define __DEBUG

#ifdef __DEBUG
#define	DLOG( _format, ... )	PYLog(@"(%d)"_format, __LINE__, __VA_ARGS__)
#else
#define DLOG( _format, ... )
#endif
/*******************************************************************************************
	Implemention of PYSlideContentView
*******************************************************************************************/
@implementation PYSlideContentView

#define __PYSCV_WIDTH										\
	({ self.superview.clipsToBounds ?						\
		self.superview.bounds.size.width : 320;})
#define __PYSCV_BOUNDLEFT									\
	({self.superview.clipsToBounds ? 0 :					\
		-(self.superview.frame.origin.x);})
		
#define __PYSCV_INRANGE( _frame )							\
	({(_frame).origin.x > -(self.frame.size.width -			\
		__PYSCV_BOUNDLEFT) &&								\
		(_frame).origin.x < __PYSCV_WIDTH; })
#define __PYSCV_CELLX( _cell )								\
	({_cell.frame.origin.x - _cellPadding;})
#define __PYSCV_CELLW( _cell )								\
	({(_cell).frame.size.width + 2 * _cellPadding;})
#define __PYSCV_PADDING		( 2 * _cellPadding )
#define __PYSCV_SELFWIDTH	(self.frame.size.width)

#define __PYSCV_INVALID		((NSUInteger)-1)

@synthesize cellCount = _cellCount;
@synthesize cellPadding = _cellPadding;
@synthesize lingerAnimationTime = _lingerAnimationTime;
@synthesize respondedForSelection = _respondedForSelection;

@synthesize slideView = _slideView;
@synthesize slideType = _slideType;

@synthesize reusableCellCache = _reusableCellCache;
@synthesize delegate = _delegate;
@synthesize datasource = _datasource;
@synthesize bindView = _bindView;

@synthesize isPagingEnable = _isPagingEnable;

@synthesize lastTouchPoint = _lastTouchPoint;

@synthesize cellHeightArray = _cellHeightArray;
@synthesize contentWidth = _contentWidth;

/* Property Setters */
-(void) setCellCount:(NSUInteger)aCount
{
	_cellCount = aCount;
	CGRect _frame = self.frame;
	_frame.size.width = _contentWidth;
	_frame.size.height = self.superview.bounds.size.height;
	
	if ( _slideType == PYSLIDETYPE_MASTER ) {
		if ( [self.visiableCells count] == 0 ) {
			_frame.origin.x = 0;
		}
	} else {
		// self is sliver view, check to move leftside or rightside.
		_frame.origin.x = (_bindView.frame.origin.x >= 0) ?
			(_bindView.frame.origin.x - _frame.size.width) : 
			(_bindView.frame.origin.x + _frame.size.width);
	}
	_frame.origin.y = 0;
	[self setFrame:_frame];
}

-(void) setCellPadding:(CGFloat)aPadding
{
	//_cellPadding = aPadding;
	NSArray * _visiableCellArray = [self visiableCells];
	for ( PYSlideViewCell * _cell in _visiableCellArray ) {
		CGRect _cellFrame = _cell.frame;
		// revert
		_cellFrame.size.width += 2 * _cellPadding;
		_cellFrame.size.height += 2 * _cellPadding;
		_cellFrame.origin.x -= _cellPadding;
		_cellFrame.origin.y -= _cellPadding;
		
		// set new margin
		_cellFrame.size.width -= 2 * aPadding;
		_cellFrame.size.height -= 2 * aPadding;
		_cellFrame.origin.x += aPadding;
		_cellFrame.origin.y += aPadding;
		
		[_cell setFrame:_cellFrame];
	}
	_cellPadding = aPadding;
}

/* init */
-(void) internalInitial
{
	[super internalInitial];
	
	// default is master
	_slideType = PYSLIDETYPE_MASTER;
	_isPagingEnable = YES;
	
	_reusableCellCache = [[NSMutableDictionary dictionary] retain];
	_lingerAnimationTime = 0.25;
	_cellPadding = 0;
	_respondedForSelection = YES;
	
	[self setUserInteractionEnabled:YES];	
}

-(id) initWithSlideView:(PYSlideView *)aSlideView
{
	self = [super init];
	if ( self ) {
		_slideView = [aSlideView retain];
	}
	return self;
}

-(id) initWithSlideView:(PYSlideView *)aSlideView
	reusableCache:(NSMutableDictionary *)aCache
{
	self = [super init];
	if ( self ) {
		_slideView = [aSlideView retain];
		_reusableCellCache = [aCache retain];
	}
	return self;
}

-(void)dealloc
{
	_slideView = nil;
	_datasource = nil;
	_delegate = nil;
	_bindView = nil;
	
	_reusableCellCache = nil;
	_cellHeightArray = nil;
	_animationTimer = nil;
	[super dealloc];
}

/* Messages */
-(void) clearAndLoadData
{
	NSArray *cells = [self subviews];
	// Clear the old data, if any.
	NSMutableArray *_reloadCellIndexArray = [NSMutableArray array];
	for ( PYSlideViewCell * cell in cells ) {
		[_reloadCellIndexArray addObject:
			[NSNumber numberWithUnsignedInteger:cell.cellIndex]];
		[self enqueueSlideViewCell:cell];
	}
	
	// load the new data
	
	// count
	PYASSERT( (_datasource != nil), @"The datasource is nil.");
	NSUInteger _count = 0;
	_cellHeightArray = nil;
	_contentWidth = 0;
	
	if ( _slideType == PYSLIDETYPE_MASTER ) {
		PYASSERT( 
			([_datasource respondsToSelector:@selector(numberOfCellsInSlideView:)]),
			@"Must implement the delegate: numberOfCellsInSlideView:"
		);
		_count = [_datasource numberOfCellsInSlideView:_slideView];
		if ( _count == 1 ) {
			[_slideView setSlideViewCycledEnable:NO];
		}
		
		_cellHeightArray = [[NSMutableArray array] retain];
		if ( [_datasource respondsToSelector:@selector(pySlideView:widthOfCellAtIndex:)] ) {
			for ( unsigned int i = 0; i < _count; ++i ) {
				CGFloat _cellWidth = [_datasource 
					pySlideView:_slideView widthOfCellAtIndex:i];
				PYObjectPair *_cellSizePair = 
					[PYObjectPair pairWithFirst:[NSNumber numberWithFloat:_contentWidth] 
									 Second:[NSNumber numberWithFloat:_cellWidth]];
				[_cellHeightArray addObject:_cellSizePair];
				_contentWidth += _cellWidth;
			}
		} else {
			for ( unsigned int i = 0; i < _count; ++i ) {
				PYObjectPair *_cellSizePair = 
					[PYObjectPair pairWithFirst:[NSNumber numberWithFloat:_contentWidth] 
									 Second:[NSNumber numberWithFloat:__PYSCV_WIDTH]];
				[_cellHeightArray addObject:_cellSizePair];
				_contentWidth += __PYSCV_WIDTH;
			}
		}
	} else {
		_count = _bindView.cellCount;
		_contentWidth = _bindView.contentWidth;
		_cellHeightArray = [_bindView.cellHeightArray retain];
	}
	
	if ( _count == 0 ) return;	// do nothing if no data.
	[self setCellCount:_count];

	// load data
	BOOL _isInRange = __PYSCV_INRANGE(self.frame);
	if ( !_isInRange ) return;
	
	PYASSERT(
		([_datasource respondsToSelector:@selector(pySlideView:cellAtIndex:)]),
		@"Must implement the delegate: pySlideView:cellAtIndex:"
	);
	
	PYSlideViewCell *_lastCell = nil;
	NSUInteger _lastIndex = __PYSCV_INVALID;
	
	while ( [_reloadCellIndexArray count] != 0 ) {
		NSNumber *_lastNumber = [_reloadCellIndexArray objectAtIndex:0];
		_lastIndex = [_lastNumber unsignedIntValue];
		_lastCell = [self loadCellAtIndex:_lastIndex];
		
		PYASSERT((_lastCell != nil), @"failed to load the cell");
		[_reloadCellIndexArray removeObjectAtIndex:0];
	}
	
	int _step = (self.frame.origin.x < 0) ? -1 : 1;
	if ( _lastIndex == __PYSCV_INVALID ) {
		_lastIndex = (_step < 0) ? _cellCount : __PYSCV_INVALID;
	}
	_lastIndex += _step;
	if ( _lastCell != nil ) {
		if ( _lastCell.frame.origin.x + _lastCell.frame.size.width + __PYSCV_PADDING
			+ self.frame.origin.x >= __PYSCV_WIDTH )
			return;
	}
	
	while ( true ) {
		_lastCell = [self loadCellAtIndex:_lastIndex];
		PYASSERT((_lastCell != nil), @"failed to load the cell");
		
		if ( _lastCell.frame.origin.x + _lastCell.frame.size.width + __PYSCV_PADDING
			+ self.frame.origin.x >= __PYSCV_WIDTH )
			break;
			
		CGFloat _leftPos = __PYSCV_CELLX( _lastCell ) + self.frame.origin.x;
		CGFloat _rightPos = __PYSCV_CELLX( _lastCell ) + 
			_lastCell.frame.size.width + __PYSCV_PADDING;
		if ( _step < 0 && _leftPos < __PYSCV_BOUNDLEFT ) break;
		if ( _step > 0 && _rightPos > __PYSCV_WIDTH ) break;
		
		_lastIndex += _step;
		if ( _lastIndex >= _cellCount ) break;
	}
}

-(PYSlideViewCell *) loadCellAtIndex:(NSUInteger)anIndex
{
	if ( anIndex == __PYSCV_INVALID ) return nil;
	if ( anIndex >= _cellCount ) return nil;
	
	PYSlideViewCell *_cell = [_datasource 
		pySlideView:_slideView cellAtIndex:anIndex];
	PYASSERT( (_cell != nil), @"the cell can not be nil." );
	
	[_cell setCellIndex:anIndex];
	[_cell setSlideView:_slideView];
	[_cell setRespondedForSelection:_respondedForSelection];
	
	PYObjectPair *_cellPosDataPair = [_cellHeightArray objectAtIndex:anIndex];
	CGRect _cellFrame = CGRectMake( 
		[(NSNumber *)_cellPosDataPair.first floatValue] + _cellPadding,
		_cellPadding, 
		[(NSNumber *)_cellPosDataPair.second floatValue] - __PYSCV_PADDING, 
		_slideView.frame.size.height - __PYSCV_PADDING);
	[_cell setFrame:_cellFrame];
	

	if ( [_delegate respondsToSelector:@selector(pySlideView:willShowCell:atIndex:)] ){
		[_delegate pySlideView:_slideView willShowCell:_cell atIndex:anIndex];
	}
	
	[_cell cellWillAppear];
	[self addSubview:_cell];
	[_cell cellDidAppear];
	
	return _cell;
}

-(void) slideToLeftCell
{
	PYSlideViewCell *_currentCell = (PYSlideViewCell *)[self.subviews objectAtIndex:0];
	NSUInteger _index = _currentCell.cellIndex;
	if ( _index == 0 ) return;	// do nothing if the current cell is already the frist one.
	CGRect _frame = [self frame];
	_frame.origin.x = 0 - (_currentCell.frame.origin.x);
	[self setFrame:_frame];
}

-(void) slideToRightCell
{
	PYSlideViewCell *_currentCell = (PYSlideViewCell *)[self.subviews lastObject];
	NSUInteger _index = _currentCell.cellIndex;
	if ( _index == _cellCount - 1 ) return; // do nothing if the current cell is alredy the last one.
	CGRect _frame = [self frame];
	_frame.origin.x = 0 - (_currentCell.frame.origin.x);
	[self setFrame:_frame];
}

-(void) markCellAtIndex:(NSUInteger)anIndex selectionStatues:(BOOL)selected
{
	if ( _respondedForSelection == NO ) return;
	NSArray *_cells = [self visiableCells];
	for ( PYSlideViewCell *_cell in _cells ) {
		if ( _cell.cellIndex == anIndex ) {
			selected ? [_cell _tapGestureAction] : 
				[_cell disSelectSlideViewCell];
			break;
		}
	}
}

-(NSArray *)visiableCells
{
	//return nil;
	return [self subviews];
}

-( PYSlideViewCell *) dequeueReusableSlideViewCellWithIdentify:(NSString *)identify
{
	NSMutableSet *_cache = [_reusableCellCache objectForKey:identify];
	// no cache with such identify
	if ( _cache == nil ) return nil;
	PYSlideViewCell * _cell = [(PYSlideViewCell *)[_cache anyObject] retain];
	// the cache is empty
	if ( _cell == nil ) return nil;
	[_cache removeObject:_cell];
	[_cell prepareForReuse];
	[_cell autorelease];
	return _cell;
}

-(void) enqueueSlideViewCell:(PYSlideViewCell *)cell
{
	if ( cell == nil ) return;	// nil cell
	if ( cell.reusableIdentify == nil ) return; // nil identify

	NSMutableSet *_cache = [_reusableCellCache objectForKey:cell.reusableIdentify];
	if ( _cache == nil ) {
		_cache = [NSMutableSet set];
		[_reusableCellCache setValue:_cache forKey:cell.reusableIdentify];
	}
	[_cache addObject:cell];

	[cell cellWillDisappear];
	[cell removeFromSuperview];
	[cell cellDidDisappear];
}

/* Cell Delegate */
-(void) slideViewCellDidSelected:(PYSlideViewCell *)cell
{
	if ( _respondedForSelection == YES ) {
		if ( [_delegate respondsToSelector:@selector(pySlideView:selectCellAtIndex:)] ) {
			[_delegate pySlideView:_slideView selectCellAtIndex:cell.cellIndex];
		}
	}
}

/* Dynamic */
-(CGFloat) deltaToCellAtIndex:(NSUInteger)anIndex
{
	CGFloat _cellOriginX = anIndex * __PYSCV_WIDTH;
	CGFloat _frameOriginX = ABS(self.frame.origin.x);
	return ABS( _cellOriginX - _frameOriginX );
}

-(PYSlideViewCell *)cellAtIndex:(NSUInteger)anIndex
{
	for ( PYSlideViewCell *_cell in self.subviews ) {
		if ( _cell.cellIndex == anIndex ) return _cell;
	}
	return nil;
}

-(void) organizeCellsWithExceptFrame:(CGRect)aFrame
{
	// check the frame change effect.
	// nothing has been changed.
	if ( CGRectCompare(self.frame, aFrame) ) return;
	
	BOOL _isSlideLeft = aFrame.origin.x < self.frame.origin.x;
	NSMutableArray *_removeCells = [NSMutableArray array];
	PYSlideViewCell *_leftCell = nil;
	PYSlideViewCell *_rightCell = nil;
		
	#define _Delta			\
		({_isSlideLeft ? -_deltaSize : _deltaSize;})
	#define _LeftPointInSlideView( cell )	\
		({__PYSCV_CELLX( cell ) + aFrame.origin.x;})
		
	for ( PYSlideViewCell *cell in self.subviews ) {
		CGFloat _exceptLeftPosition = _LeftPointInSlideView(cell);
		CGFloat _exceptRightPosition = 
			_exceptLeftPosition + cell.frame.size.width + __PYSCV_PADDING;
		if ( _exceptLeftPosition > __PYSCV_WIDTH &&	
			( (_slideType == PYSLIDETYPE_SLIVER) ||
			(cell.cellIndex != 0 && _slideType == PYSLIDETYPE_MASTER))
			) 
		{
			[_removeCells addObject:cell];
			continue;
		}
		
		if ( _exceptRightPosition < __PYSCV_BOUNDLEFT && 
			( (_slideType == PYSLIDETYPE_SLIVER) ||
			(cell.cellIndex != (_cellCount - 1) && _slideType == PYSLIDETYPE_MASTER) )
			) 
		{
			[_removeCells addObject:cell];
			continue;
		}
		
		if ( _leftCell == nil || _leftCell.cellIndex > cell.cellIndex ) 
			_leftCell = cell;
		
		if ( _rightCell == nil || _rightCell.cellIndex < cell.cellIndex ) 
			_rightCell = cell;
	}
		
	// remove the out of range cell	
	while ([_removeCells count] > 0) {
		PYSlideViewCell *_cell = [[(PYSlideViewCell *)
			[_removeCells lastObject] retain] autorelease];			
		[_removeCells removeLastObject];
		[self enqueueSlideViewCell:_cell];
	}

	BOOL _isMoveInRange = __PYSCV_INRANGE(aFrame);
	if ( !_isMoveInRange ) return;

	CGFloat _leftPos = 0;
	CGFloat _rightPos = 0;
	if ( _leftCell != nil ) {
		_leftPos = _LeftPointInSlideView(_leftCell);
		_rightPos = _LeftPointInSlideView(_rightCell) + 
			_rightCell.frame.size.width + __PYSCV_PADDING;

		if ( [self.subviews count] != 0 && 
			(_leftPos <= __PYSCV_BOUNDLEFT && _rightPos >= __PYSCV_WIDTH)
			) return;
	}

	int _step = (_isSlideLeft ? 1 : -1);
	
	NSUInteger _lastIndex = (_leftCell == nil) ? 
		(aFrame.origin.x < 0 ? _cellCount - 1 : 0) : 
		(_step < 0 ? 
			(_leftPos > __PYSCV_BOUNDLEFT ?
				_leftCell.cellIndex - 1 : __PYSCV_INVALID) : 
			(_rightPos < __PYSCV_WIDTH ? 
				_rightCell.cellIndex + 1 : __PYSCV_INVALID)
		);
		
	do {
		if ( _lastIndex == __PYSCV_INVALID || _lastIndex >= _cellCount ) return;
		PYSlideViewCell *_lastCell = [self loadCellAtIndex:_lastIndex];
		if ( _lastCell == nil ) break;
		
		if ( _leftCell == nil || _leftCell.cellIndex > _lastIndex ) {
			_leftCell = _lastCell;
		}
		if ( _rightCell == nil || _rightCell.cellIndex < _lastIndex ) {
			_rightCell = _lastCell;
		}
				
		_leftPos = _LeftPointInSlideView(_leftCell);
		_rightPos = _LeftPointInSlideView(_rightCell) + 
			_rightCell.frame.size.width + __PYSCV_PADDING;
		if ( _step < 0 && _leftPos < __PYSCV_BOUNDLEFT ) break;
		if ( _step > 0 && _rightPos > __PYSCV_WIDTH ) break;
		_lastIndex += _step;
	} while(_leftPos > __PYSCV_BOUNDLEFT && _rightPos < __PYSCV_WIDTH);
}

// bindView offset check
-(CGRect) bindViewResetSideWithDelta:(CGFloat)delta selfExceptFrame:(CGRect)selfFrame
{
	CGRect _bindViewFrame = PYGETDEFAULT(_bindView, frame, CGRectEmpty);
	if ( !_bindView ) return _bindViewFrame;
	
	BOOL _needResetSide = NO;
	if ( _bindViewFrame.origin.x < -(self.frame.size.width - 
			__PYSCV_BOUNDLEFT) && delta > 0 ) {
		_bindViewFrame.origin.x = self.frame.origin.x + self.frame.size.width;
		_needResetSide = YES;
	} else if ( _bindViewFrame.origin.x > __PYSCV_WIDTH && delta < 0 ) {
		_bindViewFrame.origin.x = self.frame.origin.x - self.frame.size.width;
		_needResetSide = YES;
	} else if ( _bindViewFrame.origin.x > __PYSCV_WIDTH && delta > 0 &&
		(selfFrame.origin.x + self.frame.size.width) < __PYSCV_WIDTH
		) {
		_bindViewFrame.origin.x = self.frame.origin.x + self.frame.size.width;
		_needResetSide = YES;
	}
	
	if ( _needResetSide ) [_bindView setFrame:_bindViewFrame];
	_bindViewFrame.origin.x = ( _bindViewFrame.origin.x - delta );
	return _bindViewFrame;
}

-(void) scrollToOffSet:(NSTimer *)aTimer
{
	if ( _bindView == nil ) {
		if ( _animationOffSet.x > 0 ) _animationOffSet.x = 0;
		if ( _animationOffSet.x < -(__PYSCV_SELFWIDTH - __PYSCV_WIDTH) ) {
			_animationOffSet.x = -(__PYSCV_SELFWIDTH - __PYSCV_WIDTH);
		}
	}
	CGFloat _delta = (self.frame.origin.x - _animationOffSet.x) / 40;
	CGRect _frame = CGRectMake(self.frame.origin.x - _delta, 0, 
		self.frame.size.width, self.frame.size.height);

	CGRect _bindViewFrame = PYGETDEFAULT(_bindView, frame, CGRectEmpty);
	if ( _bindView != nil ) {
		_bindViewFrame = [self 
			bindViewResetSideWithDelta:_delta 
					   selfExceptFrame:_frame];
	}
	
	if ( ABS(_delta) < 0.015 ) {
		_frame.origin.x = _animationOffSet.x;
		[self organizeCellsWithExceptFrame:_frame];
		[_bindView organizeCellsWithExceptFrame:_bindViewFrame];
		
		[_bindView setFrame:_bindViewFrame];
		[self setFrame:_frame];
		
		[_animationTimer invalidate];
		_animationTimer = nil;
		return;
	}	
	
	[UIView animateWithDuration:0.01 delay:0.0 
		options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear
	 animations:^{
		[self organizeCellsWithExceptFrame:_frame];
		if ( _bindView != nil ) {
			[_bindView organizeCellsWithExceptFrame:_bindViewFrame];
			[_bindView setFrame:_bindViewFrame];
		}
		[self setFrame:_frame];
	 } completion:^(BOOL finished) {
		[self setUserInteractionEnabled:YES];
	 }];
}

/* Sroll to offset animated */
-(void) scrollToOffSet:(CGPoint)offSet animated:(BOOL)animated
{
	if ( offSet.x == self.frame.origin.x ) return;
	if ( animated == NO ) {
		CGRect _frame = CGRectMake(offSet.x, offSet.y, 
			self.frame.size.width, self.frame.size.height);
		[self organizeCellsWithExceptFrame:_frame];
		
		if ( _bindView ) {
			CGRect _bindViewFrame = [self 
				bindViewResetSideWithDelta:(self.frame.origin.x - _animationOffSet.x) 
						   selfExceptFrame:_frame];
			[_bindView organizeCellsWithExceptFrame:_bindViewFrame];
			[_bindView setFrame:_bindViewFrame];
		}
		
		[self setFrame:_frame];
	} else {
		if ( _animationTimer != nil ) {
			[_animationTimer invalidate];
			_animationTimer = nil;
		}
		_animationOffSet = offSet;
		_animationTimer = [[NSTimer 
			scheduledTimerWithTimeInterval:0.01 
									target:self 
								  selector:@selector(scrollToOffSet:) 
								  userInfo:nil 
								   repeats:YES] retain];
	}
}
-(void) setAnimationOffSet:(CGPoint)offSet
{
	_animationOffSet = offSet;
}

-(void) stopStopAnimation
{
	if ( _animationTimer == nil ) return;
	[_animationTimer invalidate];
	_animationTimer = nil;
}

/* Overriden */
-(void) setFrame:(CGRect)frame
{
	BOOL _widthChanged = self.frame.size.width != frame.size.width;
	[super setFrame:frame];
	
	// check if self is totoally out
	if ( _slideType == PYSLIDETYPE_MASTER && _bindView != nil ) {
		if ( _widthChanged ) {
			CGRect _bindFrame = _bindView.frame;
			_bindFrame.size.width = frame.size.width;
			_bindFrame.origin.x = frame.origin.x + frame.size.width;
			[_bindView setFrame:_bindFrame];
		}
	
		BOOL _isContentinRange = __PYSCV_INRANGE(self.frame);
		if ( _isContentinRange == YES ) return;
		// switch master and sliver
		[_slideView exchangeMasterContentView:self withSliverView:_bindView];
	}
}

-(void) touchBeginEvent:(UITouch *)touch
{
	_lastTouchPoint = [touch locationInView:_slideView];
	
	[self stopStopAnimation];
	if ( _bindView != nil ) [_bindView stopStopAnimation];
}

-(void) touchMoveEvent:(UITouch *)touch
{
	CGRect _frame = [self frame];
	CGPoint _directPoint = [touch locationInView:_slideView];
	CGFloat _delta = _lastTouchPoint.x - _directPoint.x;
	_frame.origin.x -= _delta;
	_lastTouchPoint.x = _directPoint.x;
	[self organizeCellsWithExceptFrame:_frame];

	if ( /*_slideType == PYSLIDETYPE_MASTER &&*/ _bindView != nil ) {
		CGRect _bindViewFrame = [self 
			bindViewResetSideWithDelta:_delta 
					   selfExceptFrame:_frame];
		[_bindView organizeCellsWithExceptFrame:_bindViewFrame];
		[_bindView setFrame:_bindViewFrame];
	}
	[self setFrame:_frame];
}

-(void) touchEndedEvent:(UITouch *)touch
{
	if ( _slideType == PYSLIDETYPE_SLIVER ) {
		_bindView.lastTouchPoint = _lastTouchPoint;
		[_bindView touchEndedEvent:touch];
		return;
	}
	if ( !_isPagingEnable ) {
		CGPoint _directPoint = [touch locationInView:_slideView];
		CGFloat _delta = _lastTouchPoint.x - _directPoint.x;
		//if ( ABS(_delta) <= 1.5 ) return;
		CGPoint _currentOffset = self.frame.origin;
		_currentOffset.x -= (30 * _delta);
		[self scrollToOffSet:_currentOffset animated:YES];
		return;
	}
	
	/* default frames*/
	CGRect _frame = self.frame;

	/* flags */
	BOOL _slideToSliverView = NO;
	
	/* subviews */
	NSArray *_cells = [self visiableCells];
	NSArray *_sliverCells = PYGETNIL(_bindView, visiableCells);
	
	PYSlideViewCell *_showCell = [_cells lastObject];
		
	for ( PYSlideViewCell *_cell in _cells ) {
		CGFloat _leftPoint = __PYSCV_CELLX(_cell) + self.frame.origin.x;
		CGFloat _rightPoint = _leftPoint + _cell.frame.size.width + _cellPadding;
		
		if ( _leftPoint >= 0 && _leftPoint < (__PYSCV_WIDTH / 2) ) {
			_showCell = _cell;
			break;
		}
		if ( _rightPoint < __PYSCV_WIDTH && _rightPoint > (__PYSCV_WIDTH / 2) ) {
			_showCell = _cell;
			break;
		}
	}
	
	if ( _bindView != nil ) {
		
		for ( PYSlideViewCell *_cell in _sliverCells ) {
			CGFloat _leftPoint = __PYSCV_CELLX(_cell) + _bindView.frame.origin.x;
			CGFloat _rightPoint = _leftPoint + _cell.frame.size.width + _cellPadding;
			
			if ( _leftPoint >= 0 && _leftPoint < (__PYSCV_WIDTH / 2) ) {
				_slideToSliverView = YES;
				break;
			}
			if ( _rightPoint < __PYSCV_WIDTH && _rightPoint > (__PYSCV_WIDTH / 2) ) {
				_slideToSliverView = YES;
				break;
			}
		}
	}
	
	// if the current cell is full cover the slide view, do nothing
	if ( _bindView == nil ) {
		if ( _frame.origin.x == (0 - _showCell.frame.origin.x) ) return;
		_frame.origin.x = (0 - _showCell.frame.origin.x + _cellPadding);
	} else {
		if ( _slideToSliverView ) {
			_frame.origin.x = -__PYSCV_CELLX(_showCell) + 
				( _showCell.cellIndex == 0 ? __PYSCV_WIDTH : -__PYSCV_WIDTH);
		} else {
			_frame.origin.x = -__PYSCV_CELLX(_showCell);
		}
	}
	[self organizeCellsWithExceptFrame:_frame];
	[self scrollToOffSet:_frame.origin animated:YES];
}

-(void) touchCanceledEvent:(UITouch *)touch
{
	[self touchEndedEvent:touch];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint _touchPoint = [[touches anyObject] locationInView:self];
	for ( PYSlideViewCell *_cell in self.subviews ) {
		if ( CGRectContainsPoint(_cell.frame, _touchPoint) ) {
			[_cell touchesBegan:touches withEvent:event];
			return;
		}
	}
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ( [touches count] == 0 ) return;
	CGPoint _touchPoint = [[touches anyObject] locationInView:self];
	for ( PYSlideViewCell *_cell in self.subviews ) {
		if ( CGRectContainsPoint(_cell.frame, _touchPoint) ) {
			[_cell touchesEnded:touches withEvent:event];
			return;
		}
	}
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint _touchPoint = [[touches anyObject] locationInView:self];
	for ( PYSlideViewCell *_cell in self.subviews ) {
		if ( CGRectContainsPoint(_cell.frame, _touchPoint) ) {
			[_cell touchesMoved:touches withEvent:event];
			return;
		}
	}
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ( [touches count] == 0 ) return;
	CGPoint _touchPoint = [[touches anyObject] locationInView:self];
	for ( PYSlideViewCell *_cell in self.subviews ) {
		if ( CGRectContainsPoint(_cell.frame, _touchPoint) ) {
			[_cell touchesEnded:touches withEvent:event];
			return;
		}
	}
}

@end

