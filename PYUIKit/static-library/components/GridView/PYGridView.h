//
//  PYGridView.h
//  PYUIKit
//
//  Created by Push Chen on 5/15/13.
//  Copyright (c) 2013 Markphone Culture Media Co.Ltd. All rights reserved.
//

#import "PYView.h"
#include <sys/time.h>
#include <sys/timeb.h>

@class PYGridViewCell;
@class PYGridViewSection;

@protocol PYGridViewDelegate;
@protocol PYGridViewDataSource;

typedef enum {
    PYGridViewDecelerateLower           = 250,
    PYGridViewDecelerateLow             = 200,
    PYGridViewDecelerateNormal          = 100,
    PYGridViewDecelerateFast            = 50,
    PYGridViewDecelerateFaster          = 20
} PYGridViewDecelerateSpeed;

// The scroll type of the grid view.
typedef enum {
    PYGridViewHorizontal,
    PYGridViewVerticalis
} PYGridViewScrollType;

// The stick type when the grid view is in page mode.
typedef enum {
    PYGridViewStickTop,
    PYGridViewStickCenter,
    PYGridViewStickBottom,
    PYGridViewStickNearby
} PYGridViewStickType;

// Section type, default is float
typedef enum {
    PYGridViewSectionFloat,
    PYGridViewSectionBlock
} PYGridViewSectionType;

// The GridView is a substitute of UITableView.
// It support both horizontal and verticalis scrolling, and also support
// paged content.
// When in paged mode, the end of decelerate animation will stop at
// one cell's bound(x or y) stick to the side.
// We use a Geometric series to calculate each step offset.
// The algorithm is like the following
/*
 Assuming that:
 f(0) = ∂
 l(0) = ∂ • ç
 (∂ & ç all know as constant value)
 And we get the following equality:
 f(n) = l(n) / ç
 l(n) = l(n - 1) - f(n - 1)
 The n end when:
 l(n) <= ß ( ß is very much equal to 0 )
 
 So we can get:
 f(n) • ç = f(n - 1) • ç - f(n - 1)
 f(n) = f(n - 1) • ((ç - 1)/ç)
 f(n) = f(0) • ((ç - 1)/ç)^n
 
 And:
 f(n) = ∂ • ((ç - 1)/ç)^n
 l(n) = ∂ • ç • ((ç - 1)/ç)^n < ß
 ((ç - 1)/ç)^n < (ß/(∂•ç))
 n•lg((ç - 1)/ç) < lg(ß/(∂•ç))
 n < lg(ß/(∂•ç)) / lg((ç - 1)/ç)
 n = [lg(ß/(∂•ç)) / lg((ç - 1)/ç)]
 
 But acturally, we do not need to know n...
 */
@interface PYGridView : PYView
{
    NSMutableArray                  *_visiableSections;
    NSMutableArray                  *_willRemoveSections;
    CGRect                          _visiableSectionRect;
    NSUInteger                      _sectionCount;
    int                             _topSection;
    NSUInteger                      _bottomSection;
    
    CGPoint                         _lastTouchPoint;
    BOOL                            _userDraging;
    
    // Animation Testing
    BOOL                            _canAnimateToNextOffset;
    // Gesture testing.
    BOOL                            _moved;
    // The following parameters are used for the decelerate animation.
    // Moving Speed testing.
    CGPoint                         _touchBeginPoint;
    CGFloat                         _movingSpeed;
    struct timeval                  _startTime;
    struct timeval                  _endTime;
    NSTimer                         *_animateScrollTimer;
    
    // Scroll step
    int                             _scrollMaxStep;
    int                             _scrollCurrentStep;
    // All distance to move.
    CGFloat                         _animateOffset;
    
    // Time space, should be .1 in default
    CGFloat                         _animateTimeSpace;
    // All moving distance
    CGFloat                         _allMovingDistance;
    // All moved distance
    CGFloat                         _allMovedDistance;
    // Animation Step Rate
    CGFloat                         _animateStep;
    // Jelly Effective On
    BOOL                            _jellyEffectiveOn;
    CGSize                          _jellyBackOffset;
    CGFloat                         _jellyAllTime;
    
    PYGridViewScrollType            _scrollType;
    PYGridViewSectionType           _sectionType;
    
    /* The following paremters are used for datasource */
    BOOL                            _cycleEnabled;
    BOOL                            _pageEnabled;
    
    PYGridViewSection               *_headSection;
    PYGridViewSection               *_footSection;
    // This view is between all sections and all cells.
    // Which can not be operated. No user inactracted.
    PYView                          *_coverView;
    
    // Cache of cells
    NSMutableDictionary             *_cellsCache;
    NSUInteger                      _numberOfCells;
    NSMutableArray                  *_sectionCellHeightCacheList;
    NSMutableArray                  *_sectionHeadViewCacheList;
    NSMutableArray                  *_sectionHeadFrameCacheList;
    NSMutableArray                  *_sectionCellsFrameCacheList;
    NSMutableArray                  *_sectionCollapseStatusList;
    NSMutableDictionary             *_cellSelectedStatus;
    NSIndexPath                     *_lastSelectedItem;
    CGSize                          _maxSectionSize;
    
    CGPoint                         _contentTopSide;
    CGPoint                         _contentBottomSide;
}

// The decelerate speed, default is normal.
@property (nonatomic, assign)   PYGridViewDecelerateSpeed       decelerateSpeed;

// Datasource and delegate, which provide the cell infomations and the receive the
// action occurred by the grid view.
@property (nonatomic, assign)   IBOutlet id<PYGridViewDataSource>   datasource;
@property (nonatomic, assign)   IBOutlet id<PYGridViewDelegate>     delegate;

@property (nonatomic, readonly) NSArray                         *visiableCells;
@property (nonatomic, readonly) CGRect                          visiableRect;
@property (nonatomic, readonly) CGPoint                         contentOffset;
@property (nonatomic, readonly) CGSize                          contentSize;

// All cell count
@property (nonatomic, readonly) NSUInteger                      numberOfCells;

@property (nonatomic, strong)   UIView                          *headView;
@property (nonatomic, strong)   UIView                          *footView;

// Enable cycle
@property (nonatomic, assign)   BOOL                            cycleEnabled;
@property (nonatomic, readonly) BOOL                            isCycleEnabled;

// Enable page
/*
 Then what to do?
 I dont konw...maybe need to check all cells in the section
 but the section may have an section header view or
 even the section is uncollapsed.
 then I just need to check the section header view's frame.
 But how to do this?
 Do I need to think different when the view is collapsed or uncollapsed?
 Ok, let's try it.
 If the section is collapsed, which means I need to check from the
 section header view to the last cell in the section.
 So before the loop to check the cell's frame, check the header view first.
 then loop to check the cell frame just as check the section frame before.
 If the section is collapsed and has no section header view, what should I do?
 just skip the first step, make the default temp data unchanged.
 If the section is uncollapsed, I just need to check the section frame. And has
 no loop coding.
 
 So, I need a default temp rect, then check if the section contains a section
 header view, then the loop will end when current cell is out of real time section
 bounds of find the cell which contains the check point.
 
 How to get the finally result?
 So as I find the section or cell whose frame contains the check point,
 Then I need to tell the offset to increase/decrease according to the side
 of this frame.
 I just need to caclulate the temp rect's position!
 */
@property (nonatomic, assign)   BOOL                            pageEnabled;
@property (nonatomic, readonly) BOOL                            isPageEnabled;

// Section type
@property (nonatomic, assign)   PYGridViewSectionType           sectionType;

// Scroll Type, default is Vericial
@property (nonatomic, assign)   PYGridViewScrollType            scrollType;

// Update current visiable area
// Any code between these two messages will be operated animated.
//#warning todo
- (void)beginUpdate;
- (void)endUpdate;

// Reload all cells in grid view.
- (void)reloadData;

// Scroll to a cell at specified indexset and stick type.
//#warning Todo
- (void)scrollToCellAtIndexPath:(NSIndexPath *)indexSet
                      stickType:(PYGridViewStickType)stick
                       animated:(BOOL)animated;
// Scroll to specified offset
- (void)scrollToOffset:(CGFloat)offset animated:(BOOL)animated;

// Scroll to top
- (void)scrollToTop;
- (void)scrollToBottom;

// Get the cell
- (PYGridViewCell *)cellAtIndexPath:(NSIndexPath *)indexPath;

// Get section view
- (UIView *)sectionViewAtIndex:(NSUInteger)index;

// Collapse & Uncollapse section.
// If use collapse function, will force the section type
// switch to Block.
//#warning todo
- (void)collapseSectionAtIndex:(NSUInteger)index;
- (void)unCollapseSectionAtIndex:(NSUInteger)index;

// Dequeue a cell from the cache.
- (PYGridViewCell *)dequeueCellForIdentify:(NSString *)identify;

// Cover View's sub view.
@property (nonatomic, readonly) PYView                          *coverView;
- (void)coverViewAddSubView:(UIView *)subview;

@end

@protocol PYGridViewDataSource <NSObject>

@required
// Section cell count
- (NSUInteger)gridView:(PYGridView *)gridView numberOfCellsInSection:(NSUInteger)section;

@optional
// Get the cell object.
- (PYGridViewCell *)gridView:(PYGridView *)gridView cellAtIndex:(NSIndexPath *)indexPath;

// Get the size, only need to specified the x or y.
- (CGSize)gridView:(PYGridView *)gridView sizeOfCellAtIndex:(NSIndexPath *)indexPath;

// Default is 1.
- (NSUInteger)numberOfSectionInGridView:(PYGridView *)gridView;

// Get the customized section view.
- (UIView *)gridView:(PYGridView *)gridView sectionViewAtIndex:(NSUInteger)section;

// If has mutiple section and not return a customize section view, need
// this title to add to the default section view.
- (NSString *)gridView:(PYGridView *)gridView sectionTitleAtIndex:(NSUInteger)section;

@end

@protocol PYGridViewDelegate <NSObject>

@optional
// The last callback before display a cell.
- (void)gridView:(PYGridView *)gridView willDisplayCell:(PYGridViewCell *)cell atIndex:(NSIndexPath *)indexPath;

// Select a cell
- (void)gridView:(PYGridView *)gridView didSelectedCellAtIndex:(NSIndexPath *)indexPath;

// Unselect a cell
- (void)gridView:(PYGridView *)gridView didUnselectedCellAtIndex:(NSIndexPath *)indexPath;

#pragma mark --
#pragma mark Scroll

// Did finish a scroll operation.
- (void)gridViewDidScroll:(PYGridView *)gridView;

// Begin to drag
- (void)gridViewDidBeginDraging:(PYGridView *)gridView;

// After stop draging, give the decelerate offset, if the
// offset is zero, means not decelerate.
- (void)gridViewDidEndDrag:(PYGridView *)gridView willDecelerateOffset:(CGSize)offset;

// Did end decelerate animation.
- (void)gridViewDidEndDecelerate:(PYGridView *)gridView;

@end
