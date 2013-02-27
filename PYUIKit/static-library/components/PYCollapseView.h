//
//  PYCollapseView.h
//  PYUIKit
//
//  Created by littlepush on 8/17/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "PYComponentView.h"

@protocol PYCollapseViewDataSource;
@protocol PYCollapseViewDelegate;

@class PYCollapseViewCell;

typedef enum {
	PYCollapseStyleFade,
	PYCollapseStyleFold
} PYCollapseStyle;

@interface PYCollapseView : PYComponentView
{
	@private
	UIScrollView			*_contentScrollView;
	
	NSUInteger				_sectionCount;
	struct PYCollapseSectionInfo {
		BOOL				isSectionCollapsed;
		BOOL				dynamicLoadRows;
		UIView				*sectionContentView;
		PYCollapseViewCell	*sectionHeaderView;
		NSString			*sectionTitle;
		CGFloat				sectionHeaderHeight;
		CGFloat				sectionContentHeight;
		int					rowCount;
		CGFloat				*rowHeightList;
		NSMutableArray		*rowsInSection;
	}						*_sectionInfos;
	
	PYCollapseStyle			_collapseStyle;
	
	NSMutableDictionary		*_cellViewCache;
	PYCollapseViewCell		*lastSelectedRow;
	
	id< PYCollapseViewDataSource >	_datasource;
	id< PYCollapseViewDelegate >	_delegate;
}

@property (nonatomic, assign)	PYCollapseStyle					collapseStyle;
@property (nonatomic, retain)	IBOutlet id< PYCollapseViewDataSource >	datasource;
@property (nonatomic, retain)	IBOutlet id< PYCollapseViewDelegate >	delegate;

@property (nonatomic, readonly)	NSUInteger						sectionCount;

/* Get default objects */
+(NSString *) defaultCollaspeViewCellIdentifyKey;
+(PYCollapseViewCell *) defaultCollapseViewCellOf:(PYCollapseView *)collapseView;
+(PYCollapseViewCell *) defaultCollapseViewSectionView;

/* Reload the data */
-(void) reloadData;

-(PYCollapseViewCell *)dequeueReusableCellWithIdentify:(NSString *)identify;

/* Get section view */
-(PYCollapseViewCell *) headerViewOfSection:(NSUInteger)section;
-(PYCollapseViewCell *) rowViewInSection:(NSIndexPath *)indexPath;

/* collapse section */
-(void) collapseSection:(NSUInteger)section animated:(BOOL)animated;
-(void) unCollapseSection:(NSUInteger)section animated:(BOOL)animated;

/* Seth content Inset */
-(void) setContentInset:(UIEdgeInsets)edgeInsets;
-(void) setContentOffset:(CGPoint)offset;

// ScrollView
-(void) scrollToTop;
-(void) scrollToBottom;

@end

/* Datasource */
@protocol PYCollapseViewDataSource <NSObject>

@required
-(int) numberOfSectionsInPYCollapseView:(PYCollapseView *)collapseView;

-(int) pyCollapseView:(PYCollapseView *)collapseView 
	numberOfRowInSection:(NSUInteger)section;

-(PYCollapseViewCell *)pyCollapseView:(PYCollapseView *)collapseView
	cellOfRowInSection:(NSIndexPath *)indexPath;
	
@optional
-(CGFloat) pyCollapseView:(PYCollapseView *)collapseView
	heightOfSection:(NSUInteger)section;

-(CGFloat) pyCollapseView:(PYCollapseView *)collapseView
	heightOfRowInSection:(NSIndexPath *)indexPath;
	
-(NSString *) pyCollapseView:(PYCollapseView *)collapseView 
	titleOfSection:(NSUInteger)section;
	
-(BOOL) pyCollapseView:(PYCollapseView *)collapseView
	isDynamicLoadRowsInSection:(NSUInteger)section;
-(BOOL) pyCollapseView:(PYCollapseView *)collapseView
	isInitSectionCollapsed:(NSUInteger)section;
	
@end

/* Delegate */
@protocol PYCollapseViewDelegate <UIScrollViewDelegate>

@optional

-(UIView *) pyCollapseView:(PYCollapseView *)collapseView
	viewForSection:(NSUInteger)section;
-(void) pyCollapseView:(PYCollapseView *)collapseView
	willDisplaySectionHeaderView:(PYCollapseViewCell *)sectionHeader
	ofSection:(NSUInteger)section;
-(void) pyCollapseView:(PYCollapseView *)collapseView
	willDisplayCell:(PYCollapseViewCell *)cell
	ofRowInSection:(NSIndexPath *)indexPath;
	
-(void) pyCollapseView:(PYCollapseView *)collapseView
	willCollapseSection:(NSUInteger)section;
-(void) pyCollapseView:(PYCollapseView *)collapseView
	didCollapsedSection:(NSUInteger)section;

-(void) pyCollapseView:(PYCollapseView *)collapseView 
	willUncollapseSection:(NSUInteger)section;
-(void) pyCollapseView:(PYCollapseView *)collapseView 
	didUncollapsedSection:(NSUInteger)section;

-(void) pyCollapseView:(PYCollapseView *)collapseView
	didSelectedRowInSection:(NSIndexPath *)indexPath;
-(void) pyCollapseView:(PYCollapseView *)collapseView
	didUnselectedRowInSection:(NSIndexPath *)indexPath;

@end

typedef enum {
	PYCollapseViewCellSelectedStyleBlue,
	PYCollapseViewCellSelectedStyleNone,
} PYCollapseViewCellSelectedStyle;
typedef PYCollapseViewCellSelectedStyle _SelStyle;

/* Collapse View Cell */
@interface PYCollapseViewCell : PYTouchView
{
	@private
	NSString		*_reusableIdentify;
	UILabel			*_textLabel;
	UIImageView		*_iconView;
	UIView			*_rightView;
	BOOL			_isSelected;
	_SelStyle		_selectStyle;
	NSIndexPath		*_indexPath;
	CGFloat			_padding;
	
	PYCollapseView	*_collapseView;
}

@property (nonatomic, copy)		NSString		*reusableIdentify;
@property (nonatomic, retain)	UILabel			*textLabel;
@property (nonatomic, retain)	UIImageView		*iconView;
@property (nonatomic, retain)	UIView			*rightView;
@property (nonatomic, assign)	BOOL			isSelected;
@property (nonatomic, readonly)	PYCollapseView	*collapseView;
@property (nonatomic, readonly)	NSIndexPath		*indexPath;
@property (nonatomic, assign)	_SelStyle		selectedStyle;
@property (nonatomic, assign)	CGFloat			padding;

-(id) initWithReusableIdentify:(NSString *)identify;

-(void) setText:(NSString *)text;
-(void) setIcon:(UIImage *)icon;

@end
