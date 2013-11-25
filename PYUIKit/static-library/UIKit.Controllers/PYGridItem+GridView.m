//
//  PYGridItem+GridView.m
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

#import "PYGridItem+GridView.h"
#import "_PYGridItemUIInfo.h"

@implementation PYGridItem (GridView)

@dynamic _innerFrame;
- (CGRect)_innerFrame
{
    return _itemFrame;
}
- (void)_initNodeAtIndex:(PYGridCoordinate)coordinate
{
    _coordinate = coordinate;
    _scale = (PYGridScale){1, 1};
}

- (void)_setScale:(PYGridScale)scale
{
    _scale = scale;
}

- (void)_innerSetFrame:(CGRect)frame
{
    _itemFrame = frame;
    if ( _isCollapsed ) {
        if ( _collapseDirection == PYGridItemCollapseDirectionHorizontal ) {
            frame.size.width += (frame.size.width * _collapseRate);
            CGRect _collapseFrame = CGRectZero;
            _collapseFrame.origin.x = _itemFrame.size.width;
            _collapseFrame.size.width = (_itemFrame.size.width * _collapseRate);
            _collapseFrame.size.height = _itemFrame.size.height;
            [_collapseView setFrame:_collapseFrame];
        } else {
            frame.size.height += (frame.size.height * _collapseRate);
            CGRect _collapseFrame = CGRectZero;
            _collapseFrame.origin.y = _itemFrame.size.height;
            _collapseFrame.size.height = (_itemFrame.size.height * _collapseRate);
            _collapseFrame.size.width = _itemFrame.size.width;
            [_collapseView setFrame:_collapseFrame];
        }
    }
    [super setFrame:frame];
    CGRect _bounds = _itemFrame;
    _bounds.origin = CGPointZero;
    [_backgroundImageLayer setFrame:_bounds];
    [self _relayoutSubItems];
}

- (void)_setParentGridView:(PYGridView __unsafe_unretained*)parent
{
    _parentView = parent;
}

- (CGSize)_recalculateImageSize:(CGSize)imageSize inBounds:(CGSize)boundSize
{
    float (^__fit)(float, float) = ^(float max, float value) {
        if ( max < 10.f ) return MIN(max, value);
        return MIN(max - 10, value);
    };
    float _kb = boundSize.width / boundSize.height;
    float _ib = imageSize.width / imageSize.height;
    if ( _kb > _ib ) {
        float _fh = __fit(boundSize.height, imageSize.height);
        return CGSizeMake(_fh * _ib, _fh);
    } else {
        float _fw = __fit(boundSize.width, imageSize.width);
        return CGSizeMake(_fw, _fw / _ib);
    }
}
- (void)_relayoutSubItems
{
    static float __p = 5.f;
    [self _updateUIStateAccordingToCurrentState];
    BOOL _isVerticalis = ((_itemStyle & 0x80000000) != 0);
    CGSize _iconSize = CGSizeZero;
    if ( _iconLayer.isHidden == NO && _iconLayer.image != nil ) {
        _iconSize = [self _recalculateImageSize:_iconLayer.image.size
                                       inBounds:self.bounds.size];
    }
    CGSize _indicateSize = CGSizeZero;
    if ( _indicateLayer.isHidden == NO && _indicateLayer.image != nil ) {
        _indicateSize = _indicateLayer.image.size;
    }
    CGRect _bounds = _itemFrame;
    _bounds.origin = CGPointZero;
    if ( _isVerticalis ) {
        // icon up
        CGFloat _iconX = (_bounds.size.width - _iconSize.width) / 2;
        if ( (_itemStyle & PYGridItemStyleTitleOnly) > 0 ) {
            CGRect _iconFrame = CGRectMake(_iconX, __p, _iconSize.width, _iconSize.height);
            [_iconLayer setFrame:_iconFrame];
            // title down
            CGFloat _titleHeight = _bounds.size.height - _iconSize.height - __p;
            CGRect _titleFrame = CGRectMake(0, _iconSize.height + __p, _bounds.size.width, _titleHeight);
            [_titleLayer setFrame:_titleFrame];
        } else {
            CGFloat _iconY = (_bounds.size.height - _iconSize.height) / 2;
            CGRect _iconFrame = CGRectMake(_iconX, _iconY, _iconSize.width, _iconSize.height);
            [_iconLayer setFrame:_iconFrame];
        }
        // no indicate
    } else {
        // title middle
        [_titleLayer setFrame:_bounds];
        if ( [_iconLayer isHidden] == NO ) {
            // icon left
            CGFloat _iconY = (_bounds.size.height - _iconSize.height) / 2;
            CGRect _iconFrame = CGRectMake(__p, _iconY, _iconSize.width, _iconSize.height);
            [_iconLayer setFrame:_iconFrame];
        }
        
        if ( [_indicateLayer isHidden] == NO ) {
            // indicate right
            CGFloat _indicateX = (_bounds.size.width - _indicateSize.width);
            CGFloat _indicateY = (_bounds.size.height - _indicateSize.height) / 2;
            CGRect _indicateFrame = CGRectMake(_indicateX, _indicateY,
                                               _indicateSize.width, _indicateSize.height);
            [_indicateLayer setFrame:_indicateFrame];
        }
    }
}

- (void)_updateUIStateAccordingToCurrentState
{
    int _sIndex = (_state == UIControlStateNormal ? 0 : (PYLAST1INDEX(_state) + 1));
    _PYGridItemUIInfo *_stateInfo = [_stateSettingInfo objectAtIndex:_sIndex];
    
    // update item style according to the ui info
    // Background Color
    if ( _stateInfo.backgroundColor != nil ) {
        [_backgroundImageLayer setBackgroundColor:_stateInfo.backgroundColor.CGColor];
    }
    // Background Image
    if ( _stateInfo.backgroundImage != nil ) {
        [_backgroundImageLayer setImage:_stateInfo.backgroundImage];
    }
    // Border Width
    if ( isnan(_stateInfo.borderWidth) == NO ) {
        [super setBorderWidth:_stateInfo.borderWidth];
    }
    // Border Color
    if ( _stateInfo.borderColor != nil ) {
        [super setBorderColor:_stateInfo.borderColor];
    }
    // Icon image
    if ( _stateInfo.iconImage != nil ) {
        [_iconLayer setImage:_stateInfo.iconImage];
    }
    // Indicate image
    if ( _stateInfo.indicateImage != nil ) {
        [_indicateLayer setImage:_stateInfo.indicateImage];
    }
    // Shadow - offset
    if ( (isnan(_stateInfo.shadowOffset.width) == NO) &&
        (isnan(_stateInfo.shadowOffset.height) == NO) ) {
        [super setDropShadowOffset:_stateInfo.shadowOffset];
    }
    // Shadow - opacity
    if ( isnan(_stateInfo.shadowOpacity) == NO ) {
        [super setDropShadowOpacity:_stateInfo.shadowOpacity];
    }
    // Shadow - radius
    if ( isnan(_stateInfo.shadowRadius) == NO ) {
        [super setDropShadowRadius:_stateInfo.shadowRadius];
    }
    // Shadow - color
    if ( _stateInfo.shadowColor != nil ) {
        [super setDropShadowColor:_stateInfo.shadowColor];
    }
    // Text - text
    if ( [_stateInfo.titleText length] > 0 ) {
        [_titleLayer setText:_stateInfo.titleText];
    }
    // Text - color
    if ( _stateInfo.textColor != nil ) {
        [_titleLayer setTextColor:_stateInfo.textColor];
    }
    // Text - font
    if ( _stateInfo.textFont != nil ) {
        [_titleLayer setTextFont:_stateInfo.textFont];
    }
    // Text - Shadow - Offset
    if ( (isnan(_stateInfo.textShadowOffset.width) == NO &&
          isnan(_stateInfo.textShadowOffset.height) == NO) ) {
        [_titleLayer setTextShadowOffset:_stateInfo.textShadowOffset];
    }
    // Text - Shadow - Raidus
    if ( isnan(_stateInfo.textShadowRadius) == NO ) {
        [_titleLayer setTextShadowRadius:_stateInfo.textShadowRadius];
    }
    // Text - Shadow - Color
    if ( _stateInfo.textShadowColor != nil ) {
        [_titleLayer setTextShadowColor:_stateInfo.textShadowColor];
    }
}

// Internal setting
// Set the UI info for different state of the cell item.
- (void)_setBackgroundColor:(UIColor *)color forState:(UIControlState)state
{
    int _sIndex = ((state == UIControlStateNormal) ? 0 : ((PYLAST1INDEX(state) + 1)));
    if ( _uiflag[_sIndex].backgroundColor ) return;
    _PYGridItemUIInfo *_stateInfo = [_stateSettingInfo objectAtIndex:_sIndex];
    _stateInfo.backgroundColor = color;
}
- (void)_setBackgroundImage:(UIImage *)image forState:(UIControlState)state
{
    int _sIndex = ((state == UIControlStateNormal) ? 0 : ((PYLAST1INDEX(state) + 1)));
    if ( _uiflag[_sIndex].backgroundImage ) return;
    _PYGridItemUIInfo *_stateInfo = [_stateSettingInfo objectAtIndex:_sIndex];
    _stateInfo.backgroundImage = image;
}
- (void)_setBorderWidth:(CGFloat)width forState:(UIControlState)state
{
    int _sIndex = ((state == UIControlStateNormal) ? 0 : ((PYLAST1INDEX(state) + 1)));
    if ( _uiflag[_sIndex].borderWidth ) return;
    _PYGridItemUIInfo *_stateInfo = [_stateSettingInfo objectAtIndex:_sIndex];
    _stateInfo.borderWidth = width;
}
- (void)_setBorderColor:(UIColor *)color forState:(UIControlState)state
{
    int _sIndex = ((state == UIControlStateNormal) ? 0 : ((PYLAST1INDEX(state) + 1)));
    if ( _uiflag[_sIndex].borderColor ) return;
    _PYGridItemUIInfo *_stateInfo = [_stateSettingInfo objectAtIndex:_sIndex];
    _stateInfo.borderColor = color;
}
- (void)_setShadowOffset:(CGSize)offset forState:(UIControlState)state
{
    int _sIndex = ((state == UIControlStateNormal) ? 0 : ((PYLAST1INDEX(state) + 1)));
    if ( _uiflag[_sIndex].shadowOffset ) return;
    _PYGridItemUIInfo *_stateInfo = [_stateSettingInfo objectAtIndex:_sIndex];
    _stateInfo.shadowOffset = offset;
}
- (void)_setShadowColor:(UIColor *)color forState:(UIControlState)state
{
    int _sIndex = ((state == UIControlStateNormal) ? 0 : ((PYLAST1INDEX(state) + 1)));
    if ( _uiflag[_sIndex].shadowColor ) return;
    _PYGridItemUIInfo *_stateInfo = [_stateSettingInfo objectAtIndex:_sIndex];
    _stateInfo.shadowColor = color;
}
- (void)_setShadowOpacity:(CGFloat)opacity forState:(UIControlState)state
{
    int _sIndex = ((state == UIControlStateNormal) ? 0 : ((PYLAST1INDEX(state) + 1)));
    if ( _uiflag[_sIndex].shadowOpacity ) return;
    _PYGridItemUIInfo *_stateInfo = [_stateSettingInfo objectAtIndex:_sIndex];
    _stateInfo.shadowOpacity = opacity;
}
- (void)_setShadowRadius:(CGFloat)radius forState:(UIControlState)state
{
    int _sIndex = ((state == UIControlStateNormal) ? 0 : ((PYLAST1INDEX(state) + 1)));
    if ( _uiflag[_sIndex].shadowRadius ) return;
    _PYGridItemUIInfo *_stateInfo = [_stateSettingInfo objectAtIndex:_sIndex];
    _stateInfo.shadowRadius = radius;
}
- (void)_setTitle:(NSString *)title forState:(UIControlState)state
{
    int _sIndex = ((state == UIControlStateNormal) ? 0 : ((PYLAST1INDEX(state) + 1)));
    if ( _uiflag[_sIndex].title ) return;
    _PYGridItemUIInfo *_stateInfo = [_stateSettingInfo objectAtIndex:_sIndex];
    _stateInfo.titleText = title;
}
- (void)_setTextColor:(UIColor *)color forState:(UIControlState)state
{
    int _sIndex = ((state == UIControlStateNormal) ? 0 : ((PYLAST1INDEX(state) + 1)));
    if ( _uiflag[_sIndex].textColor ) return;
    _PYGridItemUIInfo *_stateInfo = [_stateSettingInfo objectAtIndex:_sIndex];
    _stateInfo.textColor = color;
}
- (void)_setTextFont:(UIFont *)font forState:(UIControlState)state
{
    int _sIndex = ((state == UIControlStateNormal) ? 0 : ((PYLAST1INDEX(state) + 1)));
    if ( _uiflag[_sIndex].textFont ) return;
    _PYGridItemUIInfo *_stateInfo = [_stateSettingInfo objectAtIndex:_sIndex];
    _stateInfo.textFont = font;
}
- (void)_setTextShadowOffset:(CGSize)offset forState:(UIControlState)state
{
    int _sIndex = ((state == UIControlStateNormal) ? 0 : ((PYLAST1INDEX(state) + 1)));
    if ( _uiflag[_sIndex].textShadowOffset ) return;
    _PYGridItemUIInfo *_stateInfo = [_stateSettingInfo objectAtIndex:_sIndex];
    _stateInfo.textShadowOffset = offset;
}
- (void)_setTextShadowRadius:(CGFloat)radius forState:(UIControlState)state
{
    int _sIndex = ((state == UIControlStateNormal) ? 0 : ((PYLAST1INDEX(state) + 1)));
    if ( _uiflag[_sIndex].textShadowRadius ) return;
    _PYGridItemUIInfo *_stateInfo = [_stateSettingInfo objectAtIndex:_sIndex];
    _stateInfo.textShadowRadius = radius;
}
- (void)_setTextShadowColor:(UIColor *)color forState:(UIControlState)state
{
    int _sIndex = ((state == UIControlStateNormal) ? 0 : ((PYLAST1INDEX(state) + 1)));
    if ( _uiflag[_sIndex].textShadowColor ) return;
    _PYGridItemUIInfo *_stateInfo = [_stateSettingInfo objectAtIndex:_sIndex];
    _stateInfo.textShadowColor = color;
}
- (void)_setIconImage:(UIImage *)image forState:(UIControlState)state
{
    int _sIndex = ((state == UIControlStateNormal) ? 0 : ((PYLAST1INDEX(state) + 1)));
    if ( _uiflag[_sIndex].iconImage ) return;
    _PYGridItemUIInfo *_stateInfo = [_stateSettingInfo objectAtIndex:_sIndex];
    _stateInfo.iconImage = image;
}
- (void)_setIndicateImage:(UIImage *)image forState:(UIControlState)state
{
    int _sIndex = ((state == UIControlStateNormal) ? 0 : ((PYLAST1INDEX(state) + 1)));
    if ( _uiflag[_sIndex].indicateImage ) return;
    _PYGridItemUIInfo *_stateInfo = [_stateSettingInfo objectAtIndex:_sIndex];
    _stateInfo.indicateImage = image;
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
