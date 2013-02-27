//
//  PYSlideView.h
//  pyutility-uitest
//
//  Created by Push Chen on 6/4/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PYComponentView.h"

#define PYSLIDEVIEWCELL_REIDENTIFY	@"_PYSlideViewCellIdentifyKey"

@class PYSlideView;
@class PYSlideContentView;

typedef enum {
	PYSlideViewCellSelectionStyleNone = 0,
	PYSlideViewCellSelectionStyleBlue = 1,
	PYSlideViewCellSelectionStyleGray = 2
} PYSlideViewCellSelectionStyle;

/* 
	PYSlide View Cell Base interface
	The Cell contains the basic reusable identify definition.
	Also, the cell offers a serious of methods to be invoked
	by the cache.
	Any customized cell of PYSlideView should inhiert this
	interface. 
 */
@interface PYSlideViewCell : PYComponentView
{
	NSString			*_reusableIdentify;
	PYSlideView			*_slideView;
	
	UILabel				*_textLabel;
	
	/* internal statues */
	NSUInteger			_cellIndexInContainer;
	BOOL				_selectStatues;
	BOOL				_respondedForSelection;
	BOOL				_beginToTap;
	
	PYSlideViewCellSelectionStyle	_selectionStyle;
	BOOL							_autoDisSelected;
}

/* The Reusable Identify, deafult for PYSlideViewCell is "_PYSlideViewCellIdentifyKey" */
@property (nonatomic, assign)	NSString		*reusableIdentify;

/* A point to the container slide view */
@property (nonatomic, readonly) PYSlideView		*slideView;

/* If the cell is been selected */
@property (nonatomic, readonly) BOOL			isSelected;

/* The index of the cell in the container */
@property (nonatomic, readonly) NSUInteger		cellIndex;

/* If the cell is responsed for the selection */
@property (nonatomic, readonly)	BOOL			respondedForSelection;

/* Text on the view */
@property (nonatomic, readonly) NSString		*text;

/* Selection Style */
@property (nonatomic, assign)	PYSlideViewCellSelectionStyle	selectionStyle;

/* is the cell auto dis-selected */
@property (nonatomic, assign)	BOOL			autoDisSelected;

/* 
 When the cell is ready to be reuse, 
 the father container will invoke this message.
 Rewrite this message if you need to 
 do something customized.
 */
-(void) prepareForReuse;

/*
 This message will be invoked to set the reusable identify
 when the view is initialized.
 */
-(void) initSetReusableIdentify;

/*
 Dis-Select the cell, change the cell's selection to NO.
 */
-(void) disSelectSlideViewCell;

/* Cell View Statues Call Back, can overriden */
-(void) cellWillAppear;

-(void) cellDidAppear;

-(void) cellWillDisappear;

-(void) cellDidDisappear;

/* Set the text */
-(void) setText:(NSString *)aText;

@end

/* Pre-defined PYSlideView's data protocol. */
@protocol PYSlideViewDataSource;
@protocol PYSlideViewDelegate;

/*
	PYSlideView.
	This interface is juet a shell for the content view.
	This Slide View just set the bounds and tell the real
	content view to scroll inside this one.
	The datasource and delegate will all resigned to
	the real content view.
 */
@interface PYSlideView : PYComponentView
{
	// the content view
	PYSlideContentView		*_contentView[2];
	NSMutableDictionary		*_reusableCache;
	PYSlideContentView		*_currentMasterView;
	PYSlideContentView		*_currentSliverView;
}

/* The delegate is not necessery, but the data source must be assigned and well implemented. */
/* Data Source */
@property (nonatomic, retain) IBOutlet id<PYSlideViewDataSource>	datasource;
/* Delegate of the slide view */
@property (nonatomic, retain) IBOutlet id<PYSlideViewDelegate>		delegate;

/* A readonly value to tell how many cells the slide view contains. */
@property (nonatomic, readonly) NSUInteger							cellCount;
/* A readonly value to tell the margin size around the cell */
@property (nonatomic, readonly) CGFloat								padding;

/* The linger animation's time, defautl is 0.3s */
@property (nonatomic, readonly) CGFloat								lingerAnimationTime;

/* Mark if the cells of slide view responsed to the selection event */
@property (nonatomic, assign)	BOOL								respondedForSelection;

/* Mark the slide view to be cycled */
@property (nonatomic, readonly)	BOOL								isCycled;

/* If the paging is enabled. */
@property (nonatomic, getter = isPagingEnable)	BOOL				pageEnable;

/* Reload the  Slide View's data, can invoke manually. */
-(void) reload;

/* Slide the view to the first cell. */
-(void) slideToFirstCell;
/* Slide the view to the last cell. */
-(void) slideToLastCell;
/* Slide to the specified cell according to the index. if the index is out of range, the slide view will do nothing */
-(void) slideToCellAtIndex:(NSUInteger)anIndex;

/* Animated Scroll */
-(void) scrollToOffSet:(CGPoint)offSet animated:(BOOL)animated;

/* Attributes Settings */
/* Set the Cell's margin value, must be smaller than half of the cellWidth */
-(void) setCellPadding:(CGFloat)aPadding;
/* Set the linger animation time. this value default is 0.25. */
-(void) setLingerAnimationTime:(CGFloat)aLingerTime;

/* get if the paging is enabled */
-(BOOL) isPagingEnable;

/* Set the slide to be cycled. */
-(void) setSlideViewCycledEnable:(BOOL)enable;

/* Change tht cell specified by the index to Selected mode. */
-(void) selectCellAtIndex:(NSUInteger)anIndex;
/* Change the cell specified by the index to Dis-Selected mode. */
-(void) disselectCellAtIndex:(NSUInteger)anIndex;
/* Check if the cell specified by the index is Selected. */
-(BOOL) isCellShownAtIndex:(NSUInteger)anIndex;
/* Get the cell in visiable cells speicified by the index. */
-(PYSlideViewCell *)visiableCellAtIndex:(NSUInteger)anIndex;

/* Get an array of the cells current visible in the slide view. */
-(NSArray *) visiableCells;

/* Cache */
-(PYSlideViewCell *)dequeueReusableSlideViewCellWithIdentify:(NSString *)identify;

@end

/* DataSource Protocol, the SlideView will load data by invoke the following methods of the DataSource object. */
@protocol PYSlideViewDataSource <NSObject>

@required
/* return the number of cells count. */
-(NSUInteger) numberOfCellsInSlideView:(PYSlideView *)slideView;

/* return the cell at specified index. */
-(PYSlideViewCell *) pySlideView:(PYSlideView *)slideView cellAtIndex:(NSUInteger)anIndex;

@optional
/* get the width of each cell in the slide view. default is the width of the slide view. */
-(CGFloat) pySlideView:(PYSlideView *)slideView widthOfCellAtIndex:(NSUInteger)anIndex;

@end

/* Operation of Slide View's Call back delegate. */
@protocol PYSlideViewDelegate <NSObject>

@optional
/* the cell at specified index is being selected. */
-(void) pySlideView:(PYSlideView *)slideView selectCellAtIndex:(NSUInteger)anIndex;

/* the slide view will show a cell */
-(void) pySlideView:(PYSlideView *)slideView 
	willShowCell:(PYSlideViewCell *)cell 
	atIndex:(NSUInteger)anIndex;

@end
