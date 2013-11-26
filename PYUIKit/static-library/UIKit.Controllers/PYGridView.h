//
//  PYGridView.h
//  PYUIKit
//
//  Created by Push Chen on 11/14/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

/*
 LISENCE FOR IPY
 COPYRIGHT (c) 2013, Push Chen.
 ALL RIGHTS RESERVED.
 
 REDISTRIBUTION AND USE IN SOURCE AND BINARY
 FORMS, WITH OR WITHOUT MODIFICATION, ARE
 PERMITTED PROVIDED THAT THE FOLLOWING CONDITIONS
 ARE MET:
 
 YOU USE IT, AND YOU JUST USE IT!.
 WHY NOT USE THIS LIBRARY IN YOUR CODE TO MAKE
 THE DEVELOPMENT HAPPIER!
 ENJOY YOUR LIFE AND BE FAR AWAY FROM BUGS.
 */

#import "PYResponderView.h"
#import "PYImageView.h"

// The coordinate of each grid cell item.
// Means the left-top corner position.
typedef struct tagGridCoordinate {
    int32_t         x;
    int32_t         y;
} PYGridCoordinate;

// The scale of each grid cell item.
// As we spilt the whole grid view into row * column cells,
// in default, each cell's scale is 1 * 1.
// When merge some cells in the grid, the result
// cell's scale refers to the grid count it takes.
typedef struct tagGridScale {
    int32_t         row;
    int32_t         column;
} PYGridScale;

// Grid item type.
typedef NS_OPTIONS(NSUInteger, PYGridItemStyle) {
    PYGridItemStyleTitleOnly            = 1 << 0,
    PYGridItemStyleIconOnly             = 1 << 1,
    PYGridItemStyleIconTitleHorizontal  = PYGridItemStyleIconOnly | PYGridItemStyleTitleOnly,
    PYGridItemStyleIconTitleVerticalis  = 0x80000000 | PYGridItemStyleIconTitleHorizontal,
    PYGridItemStyleIconTitleIndicate    = PYGridItemStyleIconTitleHorizontal | (1 << 2)
};

// Pre-define of the GridItem object.
@class PYGridItem;
@protocol PYGridViewDelegate;

// The grid row definition.
typedef PYGridItem *                        _GridNode;
typedef _GridNode __unsafe_unretained*      _GridRow;

// PYGridView class
// Split the view into several cells by set the scale of row and column.
// You can merge two or more cells to re-organize the cells layout.
// Also, the cell support collapse/uncollapse in both directions.
// Notice: the grid view is a static view, it's one-time rending.
// You can not dynamically add or remove a row or column.
@interface PYGridView : PYResponderView <NSFastEnumeration>
{
    // Use vector to store the grid position info, and that's easier to extend later.
    _GridRow                    *_gridConfig;
    UIView                      *_containerView;
    
    CGFloat                     _padding;
    PYImageView                 *_backgroundImageView;
    PYGridScale                 _gridScale;
    
    UIView                      *_headContainer;
    UIView                      *_footContainer;
    
    // Gesture inner object.
    PYGridItem                  *_selectedItem;
    UIControlState              _selectedItemState;
    BOOL                        _supportTouchMoving;
}

// The delegate to receive the event.
@property (nonatomic, assign)   id< PYGridViewDelegate >    delegate;

// The scale of the grid view. it can only be read.
// use [initGridViewWithScale] to set the size.
@property (nonatomic, readonly) PYGridScale         gridScale;

// Add a head view to the grid view.
// The head view will be placed at the top of any other cells.
// Add a nil object to remove the head view.
- (void)addHeadView:(UIView *)headView;
// Add a foot view to the grid view.
// The foot view will be placed at the bottom of the grid view.
// Add a nil object to remove the foot view.
- (void)addFootView:(UIView *)footView;

// Initialzie the grid view and set the scale.
// The function can only be invoked once.
- (void)initGridViewWithScale:(PYGridScale)scale;
// Merge two or more cells.
// It will calculate the minX/minY and the maxX/maxY to select
// a rect range. and all cells inside the range will be merged
// into one bigger cell.
- (void)mergeGridItemFrom:(PYGridCoordinate)from to:(PYGridCoordinate)to;

// Get item at specified coordinate.
// If the cell has already been merged into some bigger item,
// the function will return nil.
- (PYGridItem *)itemAtCoordinate:(PYGridCoordinate)coordinate;

// Padding between cells and the border.
@property (nonatomic, assign)   CGFloat             padding;

// Set if support touch move in the grid view.
// Set to YES will not stop recogernize the tap action when
// receive touch move event.
@property (nonatomic, assign)   BOOL                supportTouchMoving;

// Set the global UI info for different state of the cell item.
- (void)setItemBackgroundColor:(UIColor *)color forState:(UIControlState)state;
- (void)setItemBackgroundImage:(UIImage *)image forState:(UIControlState)state;
- (void)setItemBorderWidth:(CGFloat)width forState:(UIControlState)state;
- (void)setItemBorderColor:(UIColor *)color forState:(UIControlState)state;
- (void)setItemShadowOffset:(CGSize)offset forState:(UIControlState)state;
- (void)setItemShadowColor:(UIColor *)color forState:(UIControlState)state;
- (void)setItemShadowOpacity:(CGFloat)opacity forState:(UIControlState)state;
- (void)setItemShadowRadius:(CGFloat)radius forState:(UIControlState)state;
- (void)setItemTitle:(NSString *)title forState:(UIControlState)state;
- (void)setItemTextColor:(UIColor *)color forState:(UIControlState)state;
- (void)setItemTextFont:(UIFont *)font forState:(UIControlState)state;
- (void)setItemTextShadowOffset:(CGSize)offset forState:(UIControlState)state;
- (void)setItemTextShadowRadius:(CGFloat)radius forState:(UIControlState)state;
- (void)setItemTextShadowColor:(UIColor *)color forState:(UIControlState)state;
- (void)setItemIconImage:(UIImage *)image forState:(UIControlState)state;
- (void)setItemIndicateImage:(UIImage *)image forState:(UIControlState)state;
- (void)setItemInnerShadowColor:(UIColor *)color forState:(UIControlState)state;
- (void)setItemInnerShadowRect:(PYPadding)rect forState:(UIControlState)state;

// Set the item style.
- (void)setItemStyle:(PYGridItemStyle)style;
- (void)setItemCornerRadius:(CGFloat)cornerRaidus;

@end

// Internal function.
@interface PYGridView (Private)

// Clear all cell items.
- (void)_clearAllCache;

@end

// Delegate definition.
@protocol PYGridViewDelegate <NSObject>

@optional

// Selection of a cell.
- (void)pyGridView:(PYGridView *)gridView didSelectItem:(PYGridItem *)item;

// When collapse state change of any cell item, this message will be sent.
- (void)pyGridViewDidChangedFrameForCollapseStateChanged:(PYGridView *)gridView;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
