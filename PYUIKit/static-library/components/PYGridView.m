//
//  PYGridView.m
//  pyutility-uitest
//
//  Created by Push Chen on 6/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PYGridView.h"
#import "PYExtend.h"

#define PYGridPosKey(x, y)					\
	([NSString stringWithFormat:@"%d+%d", x, y])
	
/* Internal Definition of Cell and View */
@interface PYGridViewCell(Internal)

/* Set the information */
-(void) setStaticable:(BOOL)isStatic;
-(void) setGridPosition:(PYGridPosition)position;
-(void) setGridView:(PYGridView *)gridView;

-(void) resetStaticStyle;
-(void) performStaticStyle;

-(BOOL) isUnderStaticCell;
-(PYGridViewCell *) upLayerStaticCell;
-(void) moveCellUnderStaticCell:(PYGridViewCell *)staticCell;
-(void) moveCellOutOfStaticCell;

@end

@interface PYGridView(Internal)
/* Cache */
-(void) enqueueGridViewCell:(PYGridViewCell *)cell;

/* View init */
-(void) _loadEmptyGridView;
-(void) _resetCurrentCell:(NSArray *)currentCells;

/* get cells */
-(NSArray *) getCellsInHorLine:(NSUInteger)lineNum;
-(NSArray *) getCellsInVerLine:(NSUInteger)lineNum;

/* moving cells */
-(void) moveCells:(NSArray *)cell toHorDelta:(CGFloat)delta;
-(void) moveCells:(NSArray *)cell toVerDelta:(CGFloat)delta;

/* re-organize cells */
-(NSArray *) organizeCellsInHorLine:(NSArray *)currentCells toDelta:(CGFloat)delta;
-(NSArray *) organizeCellsInVerLine:(NSArray *)currentCells toDelta:(CGFloat)delta;

/* one touch only */
-(BOOL) _goOnForCellInAction:(PYGridViewCell *)_actCell;
-(BOOL) _isAction;
-(void) _doAction;
-(void) _finishAction;
-(PYGridViewCell *)_inActionCell;

/* Cell Action */
-(void) _cell:(PYGridViewCell *)cell changeSelectedStatues:(BOOL)isSelected;

@end

@implementation PYGridViewCell

/* Properties */
@synthesize autoDisSelect = _autoDisSelect;
-(BOOL) isAutoDisSelect { return _autoDisSelect; }

@synthesize selectionStyle = _selectionStyle;

@synthesize isSelected = _isSelected;

@synthesize gridPosition = _gridPosition;
-(void) setGridPosition:(PYGridPosition)position
{
	_gridPosition = position;
}

@synthesize isStaticCell = _isStaticCell;
-(void) setStaticable:(BOOL)isStatic 
{ 
	_isStaticCell = isStatic;
	if ( isStatic == YES ) {
		if ( [self.backgroundColor isEqual:[UIColor clearColor]] ) {
			[self setBackgroundColor:[UIColor whiteColor]];
		}
	}
	[self resetStaticStyle];
	if ( isStatic == NO ) return;
	[self performStaticStyle];
}

@synthesize gridView = _gridView;
-(void) setGridView:(PYGridView *)gridView
{
	_gridView = [gridView retain];
}

@synthesize reusableIdentify = _reusableIdentify;
@synthesize staticStyle = _staticStyle;
-(void) setStaticStyle:(PYGridViewStaticCellStyle)aStyle
{
	_staticStyle = aStyle;
	if ( _isStaticCell == NO ) return;
	[self performStaticStyle];
}

-(BOOL) isUnderStaticCell { return _isUnderStaticCell; }
-(PYGridViewCell *) upLayerStaticCell { return _upLayerStaticCell; }
-(void) moveCellUnderStaticCell:(PYGridViewCell *)staticCell
{
	_isUnderStaticCell = YES;
	_upLayerStaticCell = [staticCell retain];
}
-(void) moveCellOutOfStaticCell
{
	_isUnderStaticCell = NO;
	_upLayerStaticCell = nil;
}


-(void) resetStaticStyle
{
	PYSetCornorRadius(self, 0);
	self.layer.shadowOffset = CGSizeMake(0, 0);
	self.layer.shadowRadius = 0;
	self.layer.borderWidth = 0.f;
}

-(void) performStaticStyle
{
	switch (_staticStyle)
	{
	case PYGridViewStaticCellStyleNormal:
		break;
	case PYGridViewStaticCellStyleBorder:
		self.layer.borderWidth = 3.f;
		break;
	case PYGridViewStaticCellStyleRounded:
		PYSetCornorRadius(self, 10);
		break;
	case PYGridViewStaticCellStyleShadow:
		self.layer.shadowOffset = CGSizeMake(3, 3);
		self.layer.shadowRadius = 10;
		break;
	};
}

/* Messages */
-(void) initReusableIndentify
{
	_reusableIdentify = [kPYGridViewCellReusableDefaultIdentify retain];
}

-(void) cellWillAppear
{
	// nothing
}
-(void) cellDidAppear
{
	// nothing
}
-(void) cellWillDisappear
{
	// nothing
}
-(void) cellDidDisappear
{
	// nothing
}

-(void) prepareForReuse
{
	// nothing
}

-(void) disSelectedGridViewCell
{
	if ( !_isSelected ) return;
	
	UIColor *_oldBackgroundColor = [self.layer valueForKey:@"gridViewCellBkgClr"];
	if ( _oldBackgroundColor == nil ) return;
	
	[UIView animateWithDuration:0.12 animations:^{
		[self setBackgroundColor:_oldBackgroundColor];
	} completion:^(BOOL finished) {
		[_gridView _cell:self changeSelectedStatues:NO];
	}];
}
	
-(void) setStaticCellBorderColor:(UIColor *)color width:(CGFloat)width
{
	if ( _isStaticCell == NO || _staticStyle != PYGridViewStaticCellStyleBorder )
		return;
	self.layer.borderColor = color.CGColor;
	self.layer.borderWidth = width;
}

/* Overriden */
-(void) internalInitial
{
	[self initReusableIndentify];
	_isStaticCell = NO;
	_isSelected = NO;
	_isTapping = NO;
	_selectionStyle = PYGridViewCellSelectionStyleGray;
	_autoDisSelect = YES;
	_movingDirection = PYGridViewCellMovingDirectionNone;
	_staticStyle = PYGridViewStaticCellStyleShadow;
	_isUnderStaticCell = NO;
}

-(void) dealloc
{
	_gridView = nil;
	_reusableIdentify = nil;
	
	[super dealloc];
}

-(void) setBackgroundColor:(UIColor *)backgroundColor
{
	if ( [backgroundColor isEqual:[UIColor clearColor]] )
		return;
	[super setBackgroundColor:backgroundColor];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ( NO == [_gridView _goOnForCellInAction:self] ) return;
	_isTapping = YES;
	
	//[self.superview touchesBegan:touches withEvent:event];
	UITouch *_touch = [touches anyObject];
	_lastTouchPoint = [_touch locationInView:_gridView];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ( NO == [_gridView _goOnForCellInAction:self] ){
		if ( [touches count] == 1 ) {
			[[_gridView _inActionCell] touchesMoved:touches withEvent:event];
		}
		return;
	}
	
	_isTapping = NO;
	if ( _isStaticCell == YES ) {
		return;
	}
	//[self.superview touchesMoved:touches withEvent:event];
	UITouch *_touch = [touches anyObject];
	CGPoint _touchPoint = [_touch locationInView:_gridView];
	CGFloat _deltaX = _touchPoint.x - _lastTouchPoint.x;
	CGFloat _deltaY = _touchPoint.y - _lastTouchPoint.y;
	
	_lastTouchPoint = _touchPoint;
	
	if ( _movingDirection == PYGridViewCellMovingDirectionNone )
	{
		_movingDirection = ABS(_deltaX) > ABS(_deltaY) ?
			PYGridViewCellMovingDirectionHor :
			PYGridViewCellMovingDirectionVer;
	}
	
	CGFloat _delta = (_movingDirection == 
		PYGridViewCellMovingDirectionHor ? _deltaX : _deltaY);
		
	NSArray *_movingCells = (_movingDirection == PYGridViewCellMovingDirectionHor) ?
		[_gridView getCellsInHorLine:_gridPosition.y] :
		[_gridView getCellsInVerLine:_gridPosition.x];
	
	_movingDirection == PYGridViewCellMovingDirectionHor ?
		[_gridView moveCells:_movingCells toHorDelta:_delta] :
		[_gridView moveCells:_movingCells toVerDelta:_delta];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ( NO == [_gridView _goOnForCellInAction:self] ) {
		if ( [touches count] == 1 ) {
			[[_gridView _inActionCell] touchesEnded:touches withEvent:event];
		}
		return;
	}
	if ( _isTapping ) {
		_isTapping = NO;
		// todo, cell selected
		_isSelected = YES;
		UIColor *_selectedBackgroundColor = nil;
		UIColor *_currentBackgroundColor = self.backgroundColor;
		[self.layer setValue:_currentBackgroundColor forKey:@"gridViewCellBkgClr"];
		switch ( _selectionStyle ) {
			case PYGridViewCellSelectionStyleNone:
				_selectedBackgroundColor = _currentBackgroundColor;
				break;
			case PYGridViewCellSelectionStyleBlue: 
				_selectedBackgroundColor = [UIColor blueColor];
				break;
			case PYGridViewCellSelectionStyleGray:
				_selectedBackgroundColor = [UIColor grayColor];
				break;
		};
		[UIView animateWithDuration:0.12 animations:^{
			[self setBackgroundColor:_selectedBackgroundColor];
		} completion:^(BOOL finished) {
			[_gridView _cell:self changeSelectedStatues:YES];
			if ( _autoDisSelect ) {
				[self disSelectedGridViewCell];
			}			
		}];
	} else {
		[UIView animateWithDuration:0.35 animations:^{
			[_gridView reloadData];
		}];
	}
	_movingDirection = PYGridViewCellMovingDirectionNone;
	[_gridView _finishAction];
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchesEnded:touches withEvent:event];
}

-(void) _justRemoveFromSuperview:(NSTimer *)timer
{
	[UIView animateWithDuration:0.35 animations:^{
		[_gridView reloadData];
	}];
}

-(void) removeFromSuperview
{
	[super removeFromSuperview];

	if ( YES == [_gridView _goOnForCellInAction:self] ) 
	{
		_movingDirection = PYGridViewCellMovingDirectionNone;
		[_gridView _finishAction];
		
		[NSTimer scheduledTimerWithTimeInterval:0.005 
			target:self selector:@selector(_justRemoveFromSuperview:) 
			userInfo:nil repeats:NO];
	}
}

@end

@implementation PYGridView

/* Properties */
@synthesize horCount = _horCount, verCount = _verCount;
@synthesize cellWidth = _cellWidth, cellHeight = _cellHeight;
@synthesize autoDisSelect = _autoDisSelect;
-(BOOL) isAutoDisSelect { return _autoDisSelect; }

@synthesize delegate = _delegate, datasource = _datasource;
-(void) setDatasource:(id<PYGridViewDataSrouce>)aDataSource
{
	_datasource = nil;
	_datasource = [aDataSource retain];
	[self reloadData];
}

@synthesize staticCellStyle = _staticCellStyle;

/* Internal - one touch only */
-(BOOL)_isAction { return _inAction; }
-(void)_doAction { if ( _inAction ) return; _inAction = YES; }
-(void)_finishAction { _inAction = NO; _actionCell = nil; }
-(BOOL)_goOnForCellInAction:(PYGridViewCell *)_actCell
{
	if ( _inAction == NO ) {
		_actionCell = [_actCell retain];
		_inAction = YES;
		return YES;
	}
	
	if ( [_actCell isEqual:_actionCell] ) return YES;
	return NO;
}
-(PYGridViewCell *)_inActionCell
{
	return _actionCell;
}

-(void) internalInitial
{
	[super internalInitial];
	_reusableCellCache = [[NSMutableDictionary dictionary] retain];
	//_staticCellsInGridView = [[NSMutableDictionary dictionary] retain];
	_staticCellKeys = [[NSMutableDictionary dictionary] retain];
	_autoDisSelect = YES;
	_cellsInGridView = [[NSMutableDictionary dictionary] retain];
	self.clipsToBounds = YES;
	_staticCellStyle = PYGridViewStaticCellStyleRounded;
}

-(void) dealloc
{
	_reusableCellCache = nil;
	//_staticCellsInGridView = nil;
	_staticCellKeys = nil;
	_cellsInGridView = nil;
	_actionCell = nil;
	_delegate = nil;
	_datasource = nil;
	
	[super dealloc];
}

-(void) setFrame:(CGRect)frame
{
	_initialed = NO;
	[super setFrame:frame];
}

-(void) addSubview:(UIView *)view
{
	PYGridViewCell *_cell = nil;
	if ( [view isKindOfClass:[PYGridViewCell class]] ) {
		_cell = (PYGridViewCell *)view;
		if ( [_delegate respondsToSelector:@selector(pyGridView:willShowCell:)] ) {
			[_delegate pyGridView:self willShowCell:_cell];
		}
		[_cell cellWillAppear];
	}
	
	[super addSubview:view];
	
	if ( _cell != nil ) {
		[_cell cellDidAppear];
	}
}

-(void) insertSubview:(UIView *)view atIndex:(NSInteger)index {
	PYGridViewCell *_cell = nil;
	if ( [view isKindOfClass:[PYGridViewCell class]] ) {
		_cell = (PYGridViewCell *)view;
		if ( [_delegate respondsToSelector:@selector(pyGridView:willShowCell:)] ) {
			[_delegate pyGridView:self willShowCell:_cell];
		}
		[_cell cellWillAppear];
	}
	
	[super insertSubview:view atIndex:index];
	
	if ( _cell != nil ) {
		[_cell cellDidAppear];
	}
}

-(PYGridViewCell *) cellAtGridPosition:(PYGridPosition)position
					   cellWillMoveOut:(PYGridViewCell *)outCell
{
	// load the cell from the datasource.
	// now just create it.
	PYASSERT([_datasource respondsToSelector:@selector(
			pyGridView:loadCellAtPosition:willSwitchOutCell:)], 
		@"datasource is nil or not implemention the selector.");
	
	PYGridViewCell *_cell = [_datasource pyGridView:self 
		loadCellAtPosition:position willSwitchOutCell:outCell];
	PYASSERT(_cell != nil, @"_cell <nil> is not allowed.");
	
	NSString *_cellKey = PYGridPosKey(position.x, position.y);
	
	[_cell setGridView:self];
	[_cell setGridPosition:position];
	[_cell setAutoDisSelect:_autoDisSelect];
	
	// add new cell
	[_cellsInGridView setValue:_cell forKey:_cellKey];
	id _staticKey = [_staticCellKeys objectForKey:_cellKey];
	if ( _staticKey != nil ) {
		[self cellAtPosition:position beStaticed:YES];
	}
	
	return _cell;
}

// all cells
-(NSArray *) visiableCells
{
	return [self subviews];
}

-(PYGridViewCell *) dequeueReusableGridViewCellWithIdentify:(NSString *)identify
{
	NSMutableSet *_setOfCellKey = [_reusableCellCache objectForKey:identify];
	if ( _setOfCellKey == nil ) return nil;
	
	if ( [_setOfCellKey count] == 0 ) return nil;
	PYGridViewCell *_cell = [[[_setOfCellKey anyObject] retain] autorelease];
	[_setOfCellKey removeObject:_cell];
	[_cell prepareForReuse];
	[_cell moveCellOutOfStaticCell];
	return _cell;
}

-(void) enqueueGridViewCell:(PYGridViewCell *)cell
{
	PYASSERT([cell respondsToSelector:@selector(reusableIdentify)], 
		([NSString stringWithFormat:@"cell: %p is not a PYGridViewCell", cell]));
	NSMutableSet *_setOfCellKey = [_reusableCellCache 
		objectForKey:cell.reusableIdentify];
	if ( _setOfCellKey == nil ) {
		_setOfCellKey = [NSMutableSet set];
		[_reusableCellCache setValue:_setOfCellKey forKey:cell.reusableIdentify];
	}
	[_setOfCellKey addObject:cell];
	
	[_cellsInGridView removeObjectForKey:
		PYGridPosKey(cell.gridPosition.x, cell.gridPosition.y)];
		
	// remove the cell from grid view.
	[cell cellWillDisappear];
	[cell removeFromSuperview];
	[cell cellDidDisappear];
}

-(void) resetAllCellsPosition
{
	_cellWidth = self.frame.size.width / _horCount;
	_cellHeight = self.frame.size.height / _verCount;
	
	for ( int _hor = -1; _hor <= _horCount; ++_hor )
	{
		for ( int _ver = -1; _ver <= _verCount; ++_ver )
		{
			NSString *_cellKey = PYGridPosKey(_hor, _ver);
			PYGridViewCell *_cell = [_cellsInGridView objectForKey:_cellKey];
			if ( _cell == nil ) continue;
			
			CGRect _cellFrame;
			if ( [_cell isUnderStaticCell] ) {
				PYGridPosition _staticPosition = [_cell upLayerStaticCell].gridPosition;
				_cellFrame = CGRectMake(
					_staticPosition.x * _cellWidth, 
					_staticPosition.y * _cellHeight, 
					_cellWidth, _cellHeight);
			} else {
				_cellFrame = CGRectMake(
					_hor * _cellWidth, _ver * _cellHeight, 
					_cellWidth, _cellHeight);
			}
			[_cell setFrame:_cellFrame];
		}
	}
}

-(void) fillCellsInEmptyGrid
{
	PYASSERT([_datasource respondsToSelector:@selector(pyGridView:countInDirection:)], 
		@"datasource is nil or not implemtion the selector to get count");
	_horCount = [_datasource pyGridView:self countInDirection:PYGridViewDataDirectionHor];
	_verCount = [_datasource pyGridView:self countInDirection:PYGridViewDataDirectionVer];

	if ( _horCount == 0 || _verCount == 0 ) {
		// remove all subviews		
		return;
	}
	
	_cellWidth = self.frame.size.width / _horCount;
	_cellHeight = self.frame.size.height / _verCount;
	
	for ( int _hor = 0; _hor < _horCount; ++_hor )
	{
		for ( int _ver = 0; _ver < _verCount; ++_ver )
		{
			PYGridViewCell *_cell = [self 
				cellAtGridPosition:PYGridPositionMake(_hor, _ver)
				   cellWillMoveOut:nil];
				   
			CGRect _cellFrame = CGRectMake(
				_hor * _cellWidth, _ver * _cellHeight, 
				_cellWidth, _cellHeight);
			[_cell setFrame:_cellFrame];
			[self insertSubview:_cell atIndex:0];
		}
	}
}

-(void) reloadData
{
	if ( [self.subviews count] == 0 ) {
		[self fillCellsInEmptyGrid];
	} else {
		[self resetAllCellsPosition];
	}
}

-(NSArray *)getCellsInHorLine:(NSUInteger)lineNum
{
	NSMutableArray *_cellArray = [NSMutableArray array];
	for ( int i = -1; i <= _horCount; ++i ) {
		PYGridViewCell *_cell = [_cellsInGridView 
			objectForKey:PYGridPosKey(i, lineNum)];
		if ( _cell == nil ) continue;
		[_cellArray addObject:_cell];
	}
	return _cellArray;
}

-(NSArray *)getCellsInVerLine:(NSUInteger)lineNum
{
	NSMutableArray *_cellArray = [NSMutableArray array];
	for ( int i = -1; i <= _verCount; ++i ) {
		PYGridViewCell *_cell = [_cellsInGridView
			objectForKey:PYGridPosKey(lineNum, i)];
		if ( _cell == nil ) continue;
		[_cellArray addObject:_cell];
	}
	return _cellArray;
}

-(void) moveCells:(NSArray *)cell toHorDelta:(CGFloat)delta
{
	NSArray *_organizedCell = 
		[self organizeCellsInHorLine:cell toDelta:delta];
	for ( PYObjectPair *_data in _organizedCell )
	{
		PYGridViewCell *_cell = (PYGridViewCell *)_data.first;
		PYRect *_rect = (PYRect *)_data.second;
		[_cell setFrame:[_rect convertToCGRect]];
	}
}

-(void) moveCells:(NSArray *)cell toVerDelta:(CGFloat)delta
{
	NSArray *_organizedCell = 
		[self organizeCellsInVerLine:cell toDelta:delta];
	for ( PYObjectPair *_data in _organizedCell )
	{
		PYGridViewCell *_cell = (PYGridViewCell *)_data.first;
		PYRect *_rect = (PYRect *)_data.second;
		[_cell setFrame:[_rect convertToCGRect]];
	}
}

-(NSArray *) organizeCellsInHorLine:(NSArray *)currentCells toDelta:(CGFloat)delta
{
	NSMutableArray *_reorganizedCell = [NSMutableArray array];
	PYGridViewCell *_staticCellOfLeft = nil, *_staticCellOfRight = nil;
	CGFloat _limitOfLeft = 0.f, _limitOfRight = self.frame.size.width;
	CGFloat _currentLeft = _limitOfRight + 1, _currentRight = _limitOfLeft - 1;
	BOOL _needResetKey = NO;
	
	int _lineNum = ((PYGridViewCell *)[currentCells lastObject]).gridPosition.y;
	PYGridViewCell *_tempCell = [_cellsInGridView 
		objectForKey:PYGridPosKey(0, _lineNum)];
	if ( _tempCell.isStaticCell == YES ) {
		_staticCellOfLeft = _tempCell;
		_limitOfLeft += _cellWidth;
	}
	
	_tempCell = [_cellsInGridView objectForKey:PYGridPosKey((_horCount - 1), _lineNum)];
	if ( _tempCell.isStaticCell == YES ) {
		_staticCellOfRight = _tempCell;
		_limitOfRight -= _cellWidth;
	}
	
	for ( PYGridViewCell *_cell in currentCells ) {
		if ( _cell.isStaticCell == YES ) continue;
		
		CGFloat _cellLeftX = _cell.frame.origin.x + delta;
		CGFloat _cellRightX = _cellLeftX + _cellWidth;
		
		if ( _cellLeftX > _limitOfRight || _cellRightX < _limitOfLeft ) {
			[self enqueueGridViewCell:_cell];
			continue;
		}
		
		if ( _currentLeft > _cellLeftX ) {
			_currentLeft = _cellLeftX;
		}
		
		if ( _currentRight < _cellRightX ) {
			_currentRight = _cellRightX;
		}
		
		CGFloat _allDelta = ABS(_cellLeftX - (_cell.gridPosition.x * _cellWidth));
		CGFloat _realDelta = (_cellLeftX - (_cell.gridPosition.x * _cellWidth));
		BOOL _moveUnderStaticOverHalf = 
			_allDelta > _cellWidth ? (_allDelta - _cellWidth) > (_cellWidth / 2) : YES;
		if ( _allDelta > (_cellWidth / 2) && (delta * _realDelta) > 0 
			&& _moveUnderStaticOverHalf) 
		{
			_needResetKey = YES;
			
			// remove key from the cache
			[_cell retain];
			[_cellsInGridView removeObjectForKey:
				PYGridPosKey(_cell.gridPosition.x, _cell.gridPosition.y)];
			[_cell autorelease];
			
			BOOL _isNextToStaticCell = (delta > 0 ?
				(_staticCellOfRight == nil ? NO : 
					((_cell.gridPosition.x + 1 == _staticCellOfRight.gridPosition.x) ? 
						YES : NO)) :
				(_staticCellOfLeft == nil ? NO :
					((_cell.gridPosition.x - 1 == _staticCellOfLeft.gridPosition.x) ?
						YES : NO))
			);
			
			if ( _isNextToStaticCell == YES ) {
				[_cell moveCellUnderStaticCell:(delta > 0 ? 
					_staticCellOfRight : _staticCellOfLeft)];
			} else if ( _isNextToStaticCell == NO && [_cell isUnderStaticCell] ) {
				[_cell moveCellOutOfStaticCell];
			}
			
			int _step = (delta > 0 ? 
				(_allDelta > _cellWidth ? 2 : (_isNextToStaticCell ? 2 : 1)) : 
				(_allDelta > _cellWidth ? -2 : (_isNextToStaticCell ? -2 : -1)) 
			);
						
			PYGridPosition _newPosition = PYGridPositionMake(
				_cell.gridPosition.x + _step, _cell.gridPosition.y);
			[_cell setGridPosition:_newPosition];
		}
		
		PYRect *_cellExceptRect = [PYRect 
			rectWithx:_cellLeftX 
					y:_cell.frame.origin.y 
				width:_cellWidth 
			   height:_cellHeight];
		PYObjectPair *_reOrganizeData = [PYObjectPair 
			pairWithFirst:_cell Second:_cellExceptRect];
		[_reorganizedCell addObject:_reOrganizeData];
	}
	
	if ( _needResetKey == YES ) {
		for ( PYObjectPair *_dataPair in _reorganizedCell ) {
			PYGridViewCell *_cell = (PYGridViewCell *)_dataPair.first;
			NSString *_cellKey = PYGridPosKey(_cell.gridPosition.x, _cell.gridPosition.y);
			[_cellsInGridView setValue:_cell forKey:_cellKey];
		}
	}
	
	if ( _currentLeft <= _limitOfLeft && _currentRight >= _limitOfRight )
		return _reorganizedCell;
	
	int _lastId = 0;
	PYGridPosition _loadingPosition;
	CGFloat _exceptX;
	CGFloat _exceptY = _tempCell.frame.origin.y;
	
	if ( _currentLeft > _limitOfLeft )
	{
		_lastId = _horCount - (_staticCellOfRight == nil ? 1 : 2);
		int _loadingId = -1;
		_loadingPosition = PYGridPositionMake(_loadingId, _lineNum);
		
		_exceptX = _currentLeft - _cellWidth;		
	} else {
		_lastId = 0 + (_staticCellOfLeft == nil ? 0 : 1);
		int _loadingId = _horCount;
		_loadingPosition = PYGridPositionMake(_loadingId, _lineNum);
		
		_exceptX = _currentRight;
	}
	
	NSString *_switchOutCellKey = PYGridPosKey(_lastId, _lineNum);
	PYGridViewCell *_switchOutCell = 
		[_cellsInGridView objectForKey:_switchOutCellKey];
	PYGridViewCell *_loadingCell = [self 
		cellAtGridPosition:_loadingPosition cellWillMoveOut:_switchOutCell];
	if ( _staticCellOfLeft != nil && delta > 0 ) {
		[_loadingCell moveCellUnderStaticCell:_staticCellOfLeft];
	}
	
	if ( _staticCellOfRight != nil && delta < 0 ) {
		[_loadingCell moveCellUnderStaticCell:_staticCellOfRight];
	}
	
	CGRect _nowRect = CGRectMake((delta > 0 ? -_cellWidth : self.frame.size.width), 
		_exceptY, 
		_cellWidth, _cellHeight);
	[_loadingCell setFrame:_nowRect];
	[self insertSubview:_loadingCell atIndex:0];
	
	PYRect *_cellExceptRect = [PYRect 
		rectWithx:_exceptX 
				y:_exceptY 
			width:_cellWidth 
		   height:_cellHeight];
	PYObjectPair *_reOrganizeData = [PYObjectPair 
		pairWithFirst:_loadingCell Second:_cellExceptRect];
	[_reorganizedCell addObject:_reOrganizeData];
	return _reorganizedCell;
}

-(NSArray *) organizeCellsInVerLine:(NSArray *)currentCells toDelta:(CGFloat)delta
{
	NSMutableArray *_reorganizedCell = [NSMutableArray array];
	PYGridViewCell *_staticCellOfTop = nil, *_staticCellOfBottom = nil;
	CGFloat _limitOfTop = 0.f, _limitOfBottom = self.frame.size.height;
	CGFloat _currentTop = _limitOfBottom + 1, _currentBottom = _limitOfTop - 1;
	BOOL _needResetKey = NO;
	
	int _columnNum = ((PYGridViewCell *)[currentCells lastObject]).gridPosition.x;
	PYGridViewCell *_tempCell = [_cellsInGridView 
		objectForKey:PYGridPosKey(_columnNum, 0)];
	if ( _tempCell.isStaticCell == YES ) {
		_staticCellOfTop = _tempCell;
		_limitOfTop += _cellHeight;
	}
	
	_tempCell = [_cellsInGridView objectForKey:PYGridPosKey(_columnNum, (_verCount - 1))];
	if ( _tempCell.isStaticCell == YES ) {
		_staticCellOfBottom = _tempCell;
		_limitOfBottom -= _cellHeight;
	}
	
	for ( PYGridViewCell *_cell in currentCells ) {
		if ( _cell.isStaticCell == YES ) continue;
		
		CGFloat _cellTopY = _cell.frame.origin.y + delta;
		CGFloat _cellBottomY = _cellTopY + _cellHeight;
		
		if ( _cellTopY > _limitOfBottom || _cellBottomY < _limitOfTop ) {
			[self enqueueGridViewCell:_cell];
			continue;
		}
		
		if ( _currentTop > _cellTopY ) {
			_currentTop = _cellTopY;
		}
		
		if ( _currentBottom < _cellBottomY ) {
			_currentBottom = _cellBottomY;
		}
		
		CGFloat _allDelta = ABS(_cellTopY - (_cell.gridPosition.y * _cellHeight));
		CGFloat _realDelta = (_cellTopY - (_cell.gridPosition.y * _cellHeight));
		BOOL _moveUnderStaticOverHalf = 
			_allDelta > _cellHeight ? (_allDelta - _cellHeight) > (_cellHeight / 2) : YES;
		if ( _allDelta > (_cellHeight / 2) && (delta * _realDelta) > 0 
			&& _moveUnderStaticOverHalf) 
		{
			_needResetKey = YES;
			
			// remove key from the cache
			[_cell retain];
			[_cellsInGridView removeObjectForKey:
				PYGridPosKey(_cell.gridPosition.x, _cell.gridPosition.y)];
			[_cell autorelease];
			
			BOOL _isNextToStaticCell = (delta > 0 ?
				(_staticCellOfBottom == nil ? NO : 
					((_cell.gridPosition.y + 1 == _staticCellOfBottom.gridPosition.y) ? 
						YES : NO)) :
				(_staticCellOfTop == nil ? NO :
					((_cell.gridPosition.y - 1 == _staticCellOfTop.gridPosition.y) ?
						YES : NO))
			);
			
			if ( _isNextToStaticCell == YES ) {
				[_cell moveCellUnderStaticCell:(delta > 0 ? 
					_staticCellOfBottom : _staticCellOfTop)];
			} else if ( _isNextToStaticCell == NO && [_cell isUnderStaticCell] ) {
				[_cell moveCellOutOfStaticCell];
			}
			
			int _step = (delta > 0 ? 
				(_allDelta > _cellHeight ? 2 : (_isNextToStaticCell ? 2 : 1)) : 
				(_allDelta > _cellHeight ? -2 : (_isNextToStaticCell ? -2 : -1)) 
			);						
			
			PYGridPosition _newPosition = PYGridPositionMake(
				_cell.gridPosition.x, _cell.gridPosition.y + _step);
			[_cell setGridPosition:_newPosition];
		}
		
		PYRect *_cellExceptRect = [PYRect 
			rectWithx:_cell.frame.origin.x 
					y:_cellTopY 
				width:_cellWidth 
			   height:_cellHeight];
		PYObjectPair *_reOrganizeData = [PYObjectPair 
			pairWithFirst:_cell Second:_cellExceptRect];
		[_reorganizedCell addObject:_reOrganizeData];
	}
	
	if ( _needResetKey == YES ) {
		for ( PYObjectPair *_dataPair in _reorganizedCell ) {
			PYGridViewCell *_cell = (PYGridViewCell *)_dataPair.first;
			NSString *_cellKey = PYGridPosKey(_cell.gridPosition.x, _cell.gridPosition.y);
			[_cellsInGridView setValue:_cell forKey:_cellKey];
		}
	}
	
	if ( _currentTop <= _limitOfTop && _currentBottom >= _limitOfBottom )
		return _reorganizedCell;
	
	int _lastId = 0;
	PYGridPosition _loadingPosition;
	CGFloat _exceptY;
	CGFloat _exceptX = _tempCell.frame.origin.x;
	
	if ( _currentTop > _limitOfTop )
	{
		_lastId = _verCount - (_staticCellOfBottom == nil ? 1 : 2);
		int _loadingId = -1;
		_loadingPosition = PYGridPositionMake(_columnNum, _loadingId);
		
		_exceptY = _currentTop - _cellHeight;		
	} else {
		_lastId = 0 + (_staticCellOfTop == nil ? 0 : 1);
		int _loadingId = _verCount;
		_loadingPosition = PYGridPositionMake(_columnNum, _loadingId);
		
		_exceptY = _currentBottom;
	}
	
	NSString *_switchOutCellKey = PYGridPosKey(_columnNum, _lastId);
	PYGridViewCell *_switchOutCell = 
		[_cellsInGridView objectForKey:_switchOutCellKey];
	PYGridViewCell *_loadingCell = [self 
		cellAtGridPosition:_loadingPosition cellWillMoveOut:_switchOutCell];
	
	if ( _staticCellOfTop != nil && delta > 0 ) {
		[_loadingCell moveCellUnderStaticCell:_staticCellOfTop];
	}
	
	if ( _staticCellOfBottom != nil && delta < 0 ) {
		[_loadingCell moveCellUnderStaticCell:_staticCellOfBottom];
	}
	
	CGRect _nowRect = CGRectMake(_exceptX, 
		(delta > 0 ? -_cellHeight : self.frame.size.height), 
		_cellWidth, _cellHeight);
	[_loadingCell setFrame:_nowRect];
	[self insertSubview:_loadingCell atIndex:0];
	
	PYRect *_cellExceptRect = [PYRect 
		rectWithx:_exceptX 
				y:_exceptY 
			width:_cellWidth 
		   height:_cellHeight];
	PYObjectPair *_reOrganizeData = [PYObjectPair 
		pairWithFirst:_loadingCell Second:_cellExceptRect];
	[_reorganizedCell addObject:_reOrganizeData];
	return _reorganizedCell;
}

-(void) layoutSubviews
{
	if ( _initialed ) return;
	_initialed = YES;
	
	[self reloadData];
}

-(void) cellAtPosition:(PYGridPosition)position beStaticed:(BOOL)isStatic
{
	NSString *_cellKey = PYGridPosKey(position.x, position.y);
	
	id _staticKey = [_staticCellKeys objectForKey:_cellKey];
	if ( isStatic == YES && _staticKey == nil ) {
		[_staticCellKeys setValue:_cellKey forKey:_cellKey];
	} else if ( isStatic == NO && _staticKey != nil ) {
		[_staticCellKeys removeObjectForKey:_cellKey];
	}
	
	PYGridViewCell *_staticCell = 
		[_cellsInGridView objectForKey:_cellKey];
	if ( _staticCell == nil ) return;
	//PYTHROW(_staticCell == nil, @"Fatal Error, missing the cell");
	if ( isStatic == YES ) {
		[self bringSubviewToFront:_staticCell];
		[_staticCell setStaticStyle:_staticCellStyle];
	} else {
		[self sendSubviewToBack:_staticCell];
	}
		
	[_staticCell setStaticable:isStatic];
}

-(void) cellAtCorner:(PYGridViewCorner)corner beStaticed:(BOOL)isStatic
{
	PYGridPosition _position = PYGridPositionMake(0, 0);
	switch (corner)
	{
	case PYGridViewCornerTopLeft:
		_position.x = 0, _position.y = 0; break;
	case PYGridViewCornerTopRight:
		_position.x = _horCount - 1, _position.y = 0; break;
	case PYGridViewCornerBottomLeft:
		_position.x = 0, _position.y = _verCount - 1; break;
	case PYGridViewCornerBottomRight:
		_position.x = _horCount - 1, _position.y = _verCount - 1; break;
	};
	[self cellAtPosition:_position beStaticed:isStatic];
}

-(void) _cell:(PYGridViewCell *)cell changeSelectedStatues:(BOOL)isSelected
{
	if ( isSelected == YES ) {
		if ( [_delegate respondsToSelector:@selector(pyGridView:didSelectedCell:)] ) {
			[_delegate pyGridView:self didSelectedCell:cell];
		}
	}
	else {
		if ( [_delegate respondsToSelector:@selector(pyGridView:disSelectedCell:)] ) {
			[_delegate pyGridView:self disSelectedCell:cell];
		}
	}
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	UIView *_hitView = [super hitTest:point withEvent:event];
	if ( [_hitView isKindOfClass:[PYGridViewCell class]] ) {
		if ( _actionCell != nil ) return _actionCell;
		return _hitView;
	}
	return _hitView;
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
}

@end
