//
//  PYSlideContentView.h
//  pyutility-uitest
//
//  Created by Push Chen on 6/13/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "PYComponentView.h"

@class PYSlideView;
@class PYSlideViewCell;
@protocol PYSlideViewDelegate;
@protocol PYSlideViewDataSource;

/* The Slide Content View's Type */
typedef enum {
  PYSLIDETYPE_MASTER = 1,
  PYSLIDETYPE_SLIVER = 2
} PYSLIDETYPE;

/*********************************************************************************
 *	PYSlideContentVIew Internal Definition
 *	This is the core object of the SlideView interface.
 *	The View handles the touches event and manage the cell cache.
 *	Powered By Push Chen 2012-06-06
*********************************************************************************/
@interface PYSlideContentView : PYComponentView
{
	CGPoint					_lastTouchPoint;
	NSUInteger				_cellCount;
	CGFloat					_cellPadding;
	CGFloat					_lingerAnimationTime;
	BOOL					_respondedForSelection;
	
	NSMutableDictionary		*_reusableCellCache;
	
	PYSlideView				*_slideView;
	
	PYSLIDETYPE				_slideType;
	
	id<PYSlideViewDelegate>		_delegate;
	id<PYSlideViewDataSource>	_datasource;
	
	PYSlideContentView		*_bindView;
	
	BOOL					_isPagingEnable;
	
	NSTimer					*_animationTimer;
	CGPoint					_animationOffSet;
	
	NSMutableArray			*_cellHeightArray;
	CGFloat					_contentWidth;
}

@property (nonatomic, assign)	NSUInteger		cellCount;
@property (nonatomic, assign)	CGFloat			cellPadding;
@property (nonatomic, assign)	CGFloat			lingerAnimationTime;
@property (nonatomic, retain)	PYSlideView		*slideView;
@property (nonatomic, assign)	PYSLIDETYPE		slideType;

@property (nonatomic, assign)	BOOL			respondedForSelection;

@property (nonatomic, retain)	NSMutableDictionary			*reusableCellCache;
@property (nonatomic, retain)	id<PYSlideViewDelegate>		delegate;
@property (nonatomic, retain)	id<PYSlideViewDataSource>	datasource;
@property (nonatomic, retain)	PYSlideContentView			*bindView;

@property (nonatomic, assign)	BOOL			isPagingEnable;

@property (nonatomic, readonly) NSMutableArray	*cellHeightArray;
@property (nonatomic, readonly) CGFloat			contentWidth;

/*internal property*/
@property (nonatomic, assign)	CGPoint			lastTouchPoint;

/* init */
-(id) initWithSlideView:(PYSlideView *)aSlideView;

-(id) initWithSlideView:(PYSlideView *)aSlideView 
	reusableCache:(NSMutableDictionary *)aCache;

/* Clear the current view and load data from the datasource. */
-(void) clearAndLoadData;

/* load and add the cell to the content view. */
-(PYSlideViewCell *) loadCellAtIndex:(NSUInteger)anIndex;

/* Cell At Index */
-(PYSlideViewCell *) cellAtIndex:(NSUInteger)anIndex;

/* Slide to the left cell */
-(void) slideToLeftCell;
/* Slide to the right cell */
-(void) slideToRightCell;

/* Mark the cell's selection statues */
-(void) markCellAtIndex:(NSUInteger)anIndex selectionStatues:(BOOL)selected;

/* return the visiable cell array. */
-(NSArray *) visiableCells;

/* Cache */
-(PYSlideViewCell *) dequeueReusableSlideViewCellWithIdentify:(NSString *)identify;

-(void) enqueueSlideViewCell:(PYSlideViewCell *)cell;

/* cell's delegate */
-(void) slideViewCellDidSelected:(PYSlideViewCell *)cell;

/* Dynamic */
-(CGFloat)deltaToCellAtIndex:(NSUInteger)anIndex;

/* Organize the cell before the frame change. */
-(void) organizeCellsWithExceptFrame:(CGRect)aFrame;

/* Animation Scroll */
-(void) scrollToOffSet:(CGPoint)offSet animated:(BOOL)animated;

-(void) setAnimationOffSet:(CGPoint)offSet;

-(void) stopStopAnimation;

/* Touch Events */
-(void) touchBeginEvent:(UITouch *)touch;
-(void) touchMoveEvent:(UITouch *)touch;
-(void) touchEndedEvent:(UITouch *)touch;
-(void) touchCanceledEvent:(UITouch *)touch;

@end
