//
//  PYGridItem.h
//  PYUIKit
//
//  Created by Push Chen on 11/18/13.
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

#import "PYGridView.h"
#import "PYLabelLayer.h"
#import "PYImageLayer.h"

typedef NS_ENUM(NSUInteger, PYGridItemCollapseDirection) {
    PYGridItemCollapseDirectionHorizontal,
    PYGridItemCollapseDirectionVerticalis
};

@class _PYGridItemUIInfo;

// Grid Item Class
// The item is inside the GridView
@interface PYGridItem : PYView
{
    PYGridCoordinate            _coordinate;
    PYGridScale                 _scale;
    
    PYImageLayer                *_backgroundImageLayer;
    PYImageLayer                *_iconLayer;
    PYLabelLayer                *_titleLayer;
    PYImageLayer                *_indicateLayer;
    
    // The frame of the item which not been collapsed.
    CGRect                      _itemFrame;
    
    // Style
    PYGridItemStyle             _itemStyle;
    
    PYView                      *_collapseView;
    CGFloat                     _collapseRate;
    BOOL                        _isCollapsed;
    PYGridItemCollapseDirection _collapseDirection;
    
    // State
    BOOL                        _isEnable;
    UIControlState              _state;
    NSMutableArray              *_stateSettingInfo;
    
    // Parent info
    // Assign object.
    PYGridView __unsafe_unretained *_parentView;
    
    struct {
        BOOL    backgroundColor:1;
        BOOL    backgroundImage:1;
        BOOL    borderWidth:1;
        BOOL    borderColor:1;
        BOOL    shadowOffset:1;
        BOOL    shadowColor:1;
        BOOL    shadowOpacity:1;
        BOOL    shadowRadius:1;
        BOOL    title:1;
        BOOL    textColor:1;
        BOOL    textFont:1;
        BOOL    textShadowOffset:1;
        BOOL    textShadowRadius:1;
        BOOL    textShadowColor:1;
        BOOL    iconImage:1;
        BOOL    indicateImage:1;
    }                           _uiflag[4];
}

@property (nonatomic, readonly) PYGridCoordinate            coordinate;
@property (nonatomic, readonly) PYGridScale                 scale;

@property (nonatomic, readonly) UIImage                     *itemIcon;
@property (nonatomic, readonly) NSString                    *title;
@property (nonatomic, readonly) UIImage                     *indicateIcon;

@property (nonatomic, assign)   BOOL                        isEnabled;
@property (nonatomic, assign)   UIControlState              state;

// Collapse Flag
@property (nonatomic, readonly) PYView                      *collapseView;
@property (nonatomic, assign)   CGFloat                     collapseRate;
@property (nonatomic, readonly) BOOL                        isCollapsed;
@property (nonatomic, assign)   PYGridItemCollapseDirection collapseDirection;

- (void)collapse;
- (void)uncollapse;

// Set the style of current item.
- (void)setGridItemStyle:(PYGridItemStyle)style;

// Overrided properties.
- (void)setItemTitle:(NSString *)title; // This title will override all state's title
- (void)setTitleFont:(UIFont *)font;    // This font will override all state's font

@end

@interface PYGridItem (State)

// Set the UI info for different state of the cell item.
- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state;
- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state;
- (void)setBorderWidth:(CGFloat)width forState:(UIControlState)state;
- (void)setBorderColor:(UIColor *)color forState:(UIControlState)state;
- (void)setShadowOffset:(CGSize)offset forState:(UIControlState)state;
- (void)setShadowColor:(UIColor *)color forState:(UIControlState)state;
- (void)setShadowOpacity:(CGFloat)opacity forState:(UIControlState)state;
- (void)setShadowRadius:(CGFloat)radius forState:(UIControlState)state;
- (void)setTitle:(NSString *)title forState:(UIControlState)state;
- (void)setTextColor:(UIColor *)color forState:(UIControlState)state;
- (void)setTextFont:(UIFont *)font forState:(UIControlState)state;
- (void)setTextShadowOffset:(CGSize)offset forState:(UIControlState)state;
- (void)setTextShadowRadius:(CGFloat)radius forState:(UIControlState)state;
- (void)setTextShadowColor:(UIColor *)color forState:(UIControlState)state;
- (void)setIconImage:(UIImage *)image forState:(UIControlState)state;
- (void)setIndicateImage:(UIImage *)image forState:(UIControlState)state;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
