//
//  PYGridItem.m
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

#import "PYGridItem.h"
#import "UIColor+PYUIKit.h"
#import "_PYGridItemUIInfo.h"
#import "PYGridItem+GridView.h"
#import "PYGridView+Layout.h"

@implementation PYGridItem

@synthesize coordinate = _coordinate;
@synthesize scale = _scale;

@dynamic itemIcon;
- (UIImage *)itemIcon
{
    return _iconLayer.image;
}
@dynamic title;
- (NSString *)title
{
    return _titleLayer.text;
}
@dynamic indicateIcon;
- (UIImage *)indicateIcon
{
    return _indicateLayer.image;
}

@synthesize isEnabled = _isEnable;
- (void)setIsEnabled:(BOOL)enabled
{
    @synchronized( self ) {
        _isEnable = enabled;
        if ( _isEnable ) {
            self.state = UIControlStateNormal;
        } else {
            self.state = UIControlStateDisabled;
        }
    }
}
@synthesize state = _state;
- (void)setState:(UIControlState)st
{
    @synchronized( self ) {
        _state = st;
        [self _updateUIStateAccordingToCurrentState];
    }
}

// Collapse info.
@synthesize collapseView = _collapseView;
@synthesize collapseRate = _collapseRate;
@synthesize isCollapsed = _isCollapsed;
@synthesize collapseDirection = _collapseDirection;

- (void)viewJustBeenCreated
{
    [super viewJustBeenCreated];
    
    _backgroundImageLayer = [PYImageLayer layer];
    [_backgroundImageLayer setBackgroundColor:[UIColor clearColor].CGColor];
    [self.layer addSublayer:_backgroundImageLayer];
    
    _iconLayer = [PYImageLayer layer];
    _titleLayer = [PYLabelLayer layer];
    _indicateLayer = [PYImageLayer layer];
    [self.layer addSublayer:_iconLayer];
    [self.layer addSublayer:_titleLayer];
    [self.layer addSublayer:_indicateLayer];
    
    _collapseView = [PYView object];
    [self addSubview:_collapseView];
    [_collapseView setAlpha:0.f];
    [_collapseView setBackgroundColor:[UIColor clearColor]];
    
    // Not support collapse.
    _collapseRate = 0.f;
    _collapseDirection = PYGridItemCollapseDirectionVerticalis;
    
    _stateSettingInfo = [NSMutableArray array];
    // Initialize the state info dict.
    for ( int i = 0; i < 4; ++i ) {
        [_stateSettingInfo addObject:[_PYGridItemUIInfo object]];
        memset(_uiflag + i, 0, sizeof(_uiflag[i]));
    }
    
    _state = UIControlStateNormal;
    // For default
    [_iconLayer setHidden:YES];
    [_indicateLayer setHidden:YES];
    _itemStyle = PYGridItemStyleTitleOnly;
    [_titleLayer setTextAlignment:NSTextAlignmentCenter];
    [_titleLayer setLineBreakMode:NSLineBreakByTruncatingTail];
}

- (void)collapse
{
    if ( _collapseRate == 0 ) return;
    _isCollapsed = YES;
    [PYView animateWithDuration:.175 animations:^{
        // Tell the parent to resize.
        [_collapseView setAlpha:1.f];
        [_parentView _reformCellsWithFixedCellbounds];
    }];
}

- (void)uncollapse
{
    if ( _collapseRate == 0 ) return;
    _isCollapsed = NO;
    [PYView animateWithDuration:.175 animations:^{
        // Tell the parent to resize.
        [_collapseView setAlpha:0.f];
        [_parentView _reformCellsWithFixedCellbounds];
    }];
}

#pragma mark -
#pragma mark Sytle

- (void)setGridItemStyle:(PYGridItemStyle)style
{
    @synchronized( self ) {
        _itemStyle = style;
        
        [_iconLayer setHidden:((style & PYGridItemStyleIconOnly) == 0)];
        [_titleLayer setHidden:((style & PYGridItemStyleTitleOnly) == 0)];
        [_indicateLayer setHidden:((style & PYGridItemStyleIconTitleIndicate) == 0)];
        
        [self _relayoutSubItems];
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if ( newSuperview == nil ) return;
    
    [self _relayoutSubItems];
}

#pragma mark -
#pragma mark Global Properties

- (void)setItemTitle:(NSString *)title
{
    @synchronized ( self ) {
        [_titleLayer setText:title];
        [self setTitle:title forState:UIControlStateNormal];
        [self setTitle:title forState:UIControlStateHighlighted];
        [self setTitle:title forState:UIControlStateSelected];
        [self setTitle:title forState:UIControlStateDisabled];
    }
}

- (void)setTitleFont:(UIFont *)font
{
    @synchronized( self ) {
        [_titleLayer setTextFont:font];
        [self setTextFont:font forState:UIControlStateNormal];
        [self setTextFont:font forState:UIControlStateHighlighted];
        [self setTextFont:font forState:UIControlStateSelected];
        [self setTextFont:font forState:UIControlStateDisabled];
    }
}

#pragma mark -
#pragma mark Override Empty
- (void)setFrame:(CGRect)frame
{
    // Do nothing...
}
- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [self setBackgroundColor:backgroundColor forState:UIControlStateNormal];
}
- (void)setBorderColor:(UIColor *)borderColor
{
    [self setBorderColor:borderColor forState:UIControlStateNormal];
}
- (void)setBorderWidth:(CGFloat)borderWidth
{
    [self setBorderWidth:borderWidth forState:UIControlStateNormal];
}
- (void)setDropShadowColor:(UIColor *)dropShadowColor
{
    [self setShadowColor:dropShadowColor forState:UIControlStateNormal];
}
- (void)setDropShadowOffset:(CGSize)dropShadowOffset
{
    [self setShadowOffset:dropShadowOffset forState:UIControlStateNormal];
}
- (void)setDropShadowOpacity:(CGFloat)dropShadowOpacity
{
    [self setShadowOpacity:dropShadowOpacity forState:UIControlStateNormal];
}
- (void)setDropShadowRadius:(CGFloat)dropShadowRadius
{
    [self setShadowRadius:dropShadowRadius forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark Properties for State

// Set the UI info for different state of the cell item.
- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state
{
    int _sIndex = ((state == UIControlStateNormal) ? 0 : ((PYLAST1INDEX(state) + 1)));
    _PYGridItemUIInfo *_stateInfo = [_stateSettingInfo objectAtIndex:_sIndex];
    _stateInfo.backgroundColor = color;
    _uiflag[_sIndex].backgroundColor = YES;
}
- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state
{
    int _sIndex = ((state == UIControlStateNormal) ? 0 : ((PYLAST1INDEX(state) + 1)));
    _PYGridItemUIInfo *_stateInfo = [_stateSettingInfo objectAtIndex:_sIndex];
    _stateInfo.backgroundImage = image;
    _uiflag[_sIndex].backgroundImage = YES;
}
- (void)setBorderWidth:(CGFloat)width forState:(UIControlState)state
{
    int _sIndex = ((state == UIControlStateNormal) ? 0 : ((PYLAST1INDEX(state) + 1)));
    _PYGridItemUIInfo *_stateInfo = [_stateSettingInfo objectAtIndex:_sIndex];
    _stateInfo.borderWidth = width;
    _uiflag[_sIndex].borderWidth = YES;
}
- (void)setBorderColor:(UIColor *)color forState:(UIControlState)state
{
    int _sIndex = ((state == UIControlStateNormal) ? 0 : ((PYLAST1INDEX(state) + 1)));
    _PYGridItemUIInfo *_stateInfo = [_stateSettingInfo objectAtIndex:_sIndex];
    _stateInfo.borderColor = color;
    _uiflag[_sIndex].borderColor = YES;
}
- (void)setShadowOffset:(CGSize)offset forState:(UIControlState)state
{
    int _sIndex = ((state == UIControlStateNormal) ? 0 : ((PYLAST1INDEX(state) + 1)));
    _PYGridItemUIInfo *_stateInfo = [_stateSettingInfo objectAtIndex:_sIndex];
    _stateInfo.shadowOffset = offset;
    _uiflag[_sIndex].shadowOffset = YES;
}
- (void)setShadowColor:(UIColor *)color forState:(UIControlState)state
{
    int _sIndex = ((state == UIControlStateNormal) ? 0 : ((PYLAST1INDEX(state) + 1)));
    _PYGridItemUIInfo *_stateInfo = [_stateSettingInfo objectAtIndex:_sIndex];
    _stateInfo.shadowColor = color;
    _uiflag[_sIndex].shadowColor = YES;
}
- (void)setShadowOpacity:(CGFloat)opacity forState:(UIControlState)state
{
    int _sIndex = ((state == UIControlStateNormal) ? 0 : ((PYLAST1INDEX(state) + 1)));
    _PYGridItemUIInfo *_stateInfo = [_stateSettingInfo objectAtIndex:_sIndex];
    _stateInfo.shadowOpacity = opacity;
    _uiflag[_sIndex].shadowOpacity = YES;
}
- (void)setShadowRadius:(CGFloat)radius forState:(UIControlState)state
{
    int _sIndex = ((state == UIControlStateNormal) ? 0 : ((PYLAST1INDEX(state) + 1)));
    _PYGridItemUIInfo *_stateInfo = [_stateSettingInfo objectAtIndex:_sIndex];
    _stateInfo.shadowRadius = radius;
    _uiflag[_sIndex].shadowRadius = YES;
}
- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    int _sIndex = ((state == UIControlStateNormal) ? 0 : ((PYLAST1INDEX(state) + 1)));
    _PYGridItemUIInfo *_stateInfo = [_stateSettingInfo objectAtIndex:_sIndex];
    _stateInfo.titleText = title;
    _uiflag[_sIndex].title = YES;
}
- (void)setTextColor:(UIColor *)color forState:(UIControlState)state
{
    int _sIndex = ((state == UIControlStateNormal) ? 0 : ((PYLAST1INDEX(state) + 1)));
    _PYGridItemUIInfo *_stateInfo = [_stateSettingInfo objectAtIndex:_sIndex];
    _stateInfo.textColor = color;
    _uiflag[_sIndex].textColor = YES;
}
- (void)setTextFont:(UIFont *)font forState:(UIControlState)state
{
    int _sIndex = ((state == UIControlStateNormal) ? 0 : ((PYLAST1INDEX(state) + 1)));
    _PYGridItemUIInfo *_stateInfo = [_stateSettingInfo objectAtIndex:_sIndex];
    _stateInfo.textFont = font;
    _uiflag[_sIndex].textFont = YES;
}
- (void)setTextShadowOffset:(CGSize)offset forState:(UIControlState)state
{
    int _sIndex = ((state == UIControlStateNormal) ? 0 : ((PYLAST1INDEX(state) + 1)));
    _PYGridItemUIInfo *_stateInfo = [_stateSettingInfo objectAtIndex:_sIndex];
    _stateInfo.textShadowOffset = offset;
    _uiflag[_sIndex].textShadowOffset = YES;
}
- (void)setTextShadowRadius:(CGFloat)radius forState:(UIControlState)state
{
    int _sIndex = ((state == UIControlStateNormal) ? 0 : ((PYLAST1INDEX(state) + 1)));
    _PYGridItemUIInfo *_stateInfo = [_stateSettingInfo objectAtIndex:_sIndex];
    _stateInfo.textShadowRadius = radius;
    _uiflag[_sIndex].textShadowRadius = YES;
}
- (void)setTextShadowColor:(UIColor *)color forState:(UIControlState)state
{
    int _sIndex = ((state == UIControlStateNormal) ? 0 : ((PYLAST1INDEX(state) + 1)));
    _PYGridItemUIInfo *_stateInfo = [_stateSettingInfo objectAtIndex:_sIndex];
    _stateInfo.textShadowColor = color;
    _uiflag[_sIndex].textShadowColor = YES;
}
- (void)setIconImage:(UIImage *)image forState:(UIControlState)state
{
    int _sIndex = ((state == UIControlStateNormal) ? 0 : ((PYLAST1INDEX(state) + 1)));
    _PYGridItemUIInfo *_stateInfo = [_stateSettingInfo objectAtIndex:_sIndex];
    [_iconLayer setImage:_stateInfo.iconImage];
    _uiflag[_sIndex].iconImage = YES;
}
- (void)setIndicateImage:(UIImage *)image forState:(UIControlState)state
{
    int _sIndex = ((state == UIControlStateNormal) ? 0 : ((PYLAST1INDEX(state) + 1)));
    _PYGridItemUIInfo *_stateInfo = [_stateSettingInfo objectAtIndex:_sIndex];
    [_indicateLayer setImage:_stateInfo.indicateImage];
    _uiflag[_sIndex].indicateImage = YES;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    [super setCornerRadius:cornerRadius];
    [_backgroundImageLayer setCornerRadius:cornerRadius];
    [_collapseView setCornerRadius:cornerRadius];
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
