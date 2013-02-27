//
//  PYGridView.h
//  pyutility-uitest
//
//  Created by Push Chen on 6/22/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
/*
 PYGridView, a container display cells in grid. Each line and column in the
 grid can scroll, the grid view will scroll to an end.
 In logic, it's more like a magic cube.
 Up to now, I just support the four corner as static cell. ( A Static Cell is a
 cell that cannot be moved, and always on the top of other cells)
 */

#import "PYComponentView.h"

@class PYGridView;

// Cell's reusable key by default.
#define kPYGridViewCellReusableDefaultIdentify		\
	@"kPYGridViewCellReusableDefaultIdentify"

/* The Key of a grid view's cell */
typedef struct {
	int	x;
	int	y;
} PYGridPosition;

static inline PYGridPosition 
PYGridPositionMake( int Xpos, int Ypos )
{
	PYGridPosition position = (PYGridPosition){Xpos, Ypos};
	return position;
}

/* Selection Style of a cell */
typedef enum {
	PYGridViewCellSelectionStyleNone = 0,
	PYGridViewCellSelectionStyleBlue = 1,
	PYGridViewCellSelectionStyleGray = 2
} PYGridViewCellSelectionStyle;

/* Moving direction of a cell */
typedef enum {
	PYGridViewCellMovingDirectionNone = 0,
	PYGridViewCellMovingDirectionHor = 1,
	PYGridViewCellMovingDirectionVer = 2
} PYGridViewCellMovingDirection;

/* Data direction */
typedef enum {
	PYGridViewDataDirectionHor,
	PYGridViewDataDirectionVer
} PYGridViewDataDirection;

/* Corner definition */
typedef enum {
	PYGridViewCornerTopLeft,
	PYGridViewCornerTopRight,
	PYGridViewCornerBottomLeft,
	PYGridViewCornerBottomRight
} PYGridViewCorner;

/* the static cell's style */
typedef enum {
	PYGridViewStaticCellStyleNormal,
	PYGridViewStaticCellStyleShadow,
	PYGridViewStaticCellStyleBorder,
	PYGridViewStaticCellStyleRounded
} PYGridViewStaticCellStyle;

/* Grid View Cell base interface */
@interface PYGridViewCell : PYComponentView
{
	NSString						*_reusableIdentify;
	PYGridView						*_gridView;
	
	BOOL							_autoDisSelect;
	PYGridViewCellSelectionStyle	_selectionStyle;
	
	BOOL							_isSelected;
	BOOL							_isTapping;
	
	PYGridPosition					_gridPosition;
	
	BOOL							_isStaticCell;
	BOOL							_isUnderStaticCell;
	PYGridViewCell					*_upLayerStaticCell;
	
	CGPoint							_lastTouchPoint;
	PYGridViewCellMovingDirection	_movingDirection;
	PYGridViewStaticCellStyle		_staticStyle;
}

@property (nonatomic, assign, getter = isAutoDisSelect) BOOL	autoDisSelect;
@property (nonatomic, assign) PYGridViewCellSelectionStyle		selectionStyle;
@property (nonatomic, readonly) BOOL							isSelected;
@property (nonatomic, readonly) PYGridPosition					gridPosition;
@property (nonatomic, readonly) BOOL							isStaticCell;
@property (nonatomic, readonly) PYGridView						*gridView;
@property (nonatomic, retain) NSString							*reusableIdentify;
@property (nonatomic, assign) PYGridViewStaticCellStyle			staticStyle;

-(void) initReusableIndentify;

/* Cell's Display workflow */
-(void) cellWillAppear;
-(void) cellDidAppear;
-(void) cellWillDisappear;
-(void) cellDidDisappear;

/* 
 When the cell is ready to be reuse, 
 the father container will invoke this message.
 Rewrite this message if you need to 
 do something customized.
 */
-(void) prepareForReuse;

/* Setting if the cell will auto return to the normal statues after a tap action */
-(BOOL) isAutoDisSelect;

/* Dis-select the cell */
-(void) disSelectedGridViewCell;

/* When a cell is assigned to be static cell, the following message can be used to set the border style */
-(void) setStaticCellBorderColor:(UIColor *)color width:(CGFloat)width;

@end

/* Data soruce, get new cell */
@protocol PYGridViewDataSrouce;

/* Delegate, cell action */
@protocol PYGridViewDelegate;

/* The Grid View */
@interface PYGridView : PYComponentView
{
	NSMutableDictionary			*_reusableCellCache;
	NSMutableDictionary			*_staticCellKeys;
	
	CGFloat						_cellWidth;
	CGFloat						_cellHeight;
	
	int							_horCount;
	int							_verCount;

	BOOL						_autoDisSelect;
	
	NSMutableDictionary			*_cellsInGridView;
	BOOL						_inAction;
	PYGridViewCell				*_actionCell;
	
	id< PYGridViewDataSrouce >	_datasource;
	id< PYGridViewDelegate>		_delegate;
	
	PYGridViewStaticCellStyle	_staticCellStyle;
}

@property (nonatomic, readonly)	CGFloat							cellWidth, cellHeight;
@property (nonatomic, readonly) int								horCount, verCount;
@property (nonatomic, assign, getter = isAutoDisSelect)	BOOL	autoDisSelect;
@property (nonatomic, retain) IBOutlet id<PYGridViewDataSrouce>	datasource;
@property (nonatomic, retain) IBOutlet id<PYGridViewDelegate>	delegate;
@property (nonatomic, assign) PYGridViewStaticCellStyle			staticCellStyle;

/* get the cell at specified position */
-(PYGridViewCell *) cellAtGridPosition:(PYGridPosition)position 
					   cellWillMoveOut:(PYGridViewCell *)outCell;

/* all visiable cells */
-(NSArray *) visiableCells;

/* Cache */
-(PYGridViewCell *)dequeueReusableGridViewCellWithIdentify:(NSString *)identify;

/* reload the cells */
-(void) reloadData;

/* set the cell at position to be static or not */
-(void) cellAtPosition:(PYGridPosition)position beStaticed:(BOOL)isStatic;

/* set the corner to be static or not */
-(void) cellAtCorner:(PYGridViewCorner)corner beStaticed:(BOOL)isStatic;

@end

/*
 Grid View's Datasource
 */
@protocol PYGridViewDataSrouce <NSObject>

@required
-(PYGridViewCell *) pyGridView:(PYGridView *)gridView 
			loadCellAtPosition:(PYGridPosition)position
			 willSwitchOutCell:(PYGridViewCell *)outCell;

-(int) pyGridView:(PYGridView *)gridView 
	countInDirection:(PYGridViewDataDirection)direction;

@end

/* Grid View's Delegate */
@protocol PYGridViewDelegate <NSObject>

-(void) pyGridView:(PYGridView *)gridView didSelectedCell:(PYGridViewCell *)cell;
-(void) pyGridView:(PYGridView *)gridView disSelectedCell:(PYGridViewCell *)cell;
-(void) pyGridView:(PYGridView *)gridView willShowCell:(PYGridViewCell *)cell;

@end

