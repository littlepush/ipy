//
//  PYGridView.m
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

#import "PYGridView.h"
#import "PYGridItem.h"
#import "PYGridItem+GridView.h"
#import "UIColor+PYUIKit.h"
#import "PYView+Animation.h"
#import "PYGridView+Layout.h"

#define ANIMATION_TIME      .15f

@implementation PYGridView (Private)

- (void)_clearAllCache
{
    if ( _gridConfig == NULL ) return;
    for ( int32_t r = 0; r < _gridScale.row; ++r ) {
        for ( int32_t c = 0; c < _gridScale.column; ++c ) {
            [_gridConfig[r][c] removeFromSuperview];
            _gridConfig[r][c] = nil;
        }
        free( _gridConfig[r] );
    }
    free( _gridConfig );
    _gridConfig = NULL;
}

@end

@implementation PYGridView

@synthesize delegate;
@synthesize gridScale = _gridScale;

@synthesize padding = _padding;
- (void)setPadding:(CGFloat)cellPadding
{
    _padding = cellPadding;
    if ( self.superview != nil ) [self _reformCellsWithFixedOutbounds];
}

@dynamic backgroundImage;
- (UIImage *)backgroundImage
{
    return _backgroundImageView.image;
}
- (void)setBackgroundImage:(UIImage *)image
{
    [_backgroundImageView setImage:image];
}
@synthesize supportTouchMoving = _supportTouchMoving;
- (void)setSupportTouchMoving:(BOOL)supportTMing
{
    @synchronized( self ) {
        _supportTouchMoving = supportTMing;
        if ( _supportTouchMoving == YES ) {
            [self addTarget:self action:@selector(_actionPanHandler:event:)
          forResponderEvent:PYResponderEventPan];
            [self setEvent:PYResponderEventPan withRestraint:PYResponderRestraintPanFreedom];
        } else {
            [self removeTarget:self action:@selector(_actionPanHandler:event:)
             forResponderEvent:PYResponderEventPan];
        }
    }
}

@synthesize seperatorStyle = _seperatorStyle;
- (void)setSeperatorStyle:(PYGridSeperatorStyle)seperatorStyle
{
    [self willChangeValueForKey:@"seperatorStyle"];
    _seperatorStyle = seperatorStyle;
    [self setNeedsDisplay];
    [self didChangeValueForKey:@"seperatorStyle"];
}

- (void)viewJustBeenCreated
{
    [super viewJustBeenCreated];
    [self setAutoresizesSubviews:NO];
    
    _gridConfig = NULL;
    _gridScale = (PYGridScale){0, 0};
    
    // Initialize the container view
    _containerView = [UIView object];
    [_containerView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_containerView];
    [_containerView setClipsToBounds:NO];
    
    // Initialize the background image view
    _backgroundImageView = [PYImageView object];
    [_backgroundImageView setBackgroundColor:[UIColor clearColor]];
    [self insertSubview:_backgroundImageView belowSubview:_containerView];
    
    // Initialize the head container
    _headContainer = [UIView object];
    [_headContainer setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_headContainer];
    [_headContainer setFrame:CGRectZero];
    
    // Initialize the foot container
    _footContainer = [UIView object];
    [_footContainer setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_footContainer];
    [_footContainer setFrame:CGRectZero];
    
    // Add event
    [self addTarget:self action:@selector(_actionTapHander:event:)
  forResponderEvent:PYResponderEventTap];
    [self setEvent:PYResponderEventTap withRestraint:PYResponderRestraintSingleTap];
    
    [self addTarget:self action:@selector(_actionTouchBegin:event:)
  forResponderEvent:PYResponderEventTouchBegin];
    [self addTarget:self action:@selector(_actionTouchMove:event:)
  forResponderEvent:PYResponderEventTouchMove];
    [self addTarget:self action:@selector(_actionTouchEnd:event:)
  forResponderEvent:PYResponderEventTouchEnd];
    [self addTarget:self action:@selector(_actionTouchCancel:event:)
  forResponderEvent:PYResponderEventTouchCancel];
}

#pragma mark -
#pragma mark Actions

- (void)_actionTouchBegin:(id)sender event:(PYViewEvent *)event
{
    _selectedItem = nil;
    UITouch *_touch = [event.touches anyObject];
    CGPoint _touchPoint = [_touch locationInView:_containerView];
    if ( CGRectContainsPoint(_containerView.bounds, _touchPoint) == NO ) return;
    for ( PYGridItem *_item in self ) {
        if ( CGRectContainsPoint(_item._innerFrame, _touchPoint) == NO ) continue;
        _selectedItem = _item;
        break;
    }
    if ( _selectedItem == nil ) return;
    // Store the selected state.
    if ( _selectedItem.state == UIControlStateDisabled ) {
        _selectedItem = nil;
        return;
    }
    _selectedItemState = _selectedItem.state;
    [_selectedItem setState:UIControlStateHighlighted];
}

- (void)_actionTouchMove:(id)sender event:(PYViewEvent *)event
{
    if ( _selectedItem == nil ) return;
    UITouch *_touch = [event.touches anyObject];
    CGPoint _touchPoint = [_touch locationInView:_containerView];
    if ( CGRectContainsPoint(_selectedItem.frame, _touchPoint) ) return;
    [_selectedItem setState:_selectedItemState];
    // Cancel the selection.
    _selectedItem = nil;
}

- (void)_actionTouchEnd:(id)sender event:(PYViewEvent *)event
{
    if ( _selectedItem == nil ) return;
    [_selectedItem setState:_selectedItemState];
    if ( _responderGesture.state != UIGestureRecognizerStateRecognized ) {
        if ( _selectedItem.collapseRate > 0 ) {
            [PYView animateWithDuration:ANIMATION_TIME animations:^{
                if ( _selectedItem.isCollapsed ) {
                    [_selectedItem uncollapse];
                } else {
                    [_selectedItem collapse];
                }
            }];
        } else {
            if ( [self.delegate respondsToSelector:@selector(pyGridView:didSelectItem:)] ) {
                [self.delegate pyGridView:self didSelectItem:_selectedItem];
            }
        }
    }
    _selectedItem = nil;
}
- (void)_actionTouchCancel:(id)sender event:(PYViewEvent *)event
{
    if ( _selectedItem == nil ) return;
    [_selectedItem setState:_selectedItemState];
    _selectedItem = nil;
}

- (void)_actionTapHander:(id)sender event:(PYViewEvent *)event
{
    if ( _responderGesture.state != UIGestureRecognizerStateRecognized ) return;
    
    if ( _selectedItem == nil ) return;
    [_selectedItem setState:_selectedItemState];
    if ( _selectedItem.collapseRate > 0 ) {
        [PYView animateWithDuration:ANIMATION_TIME animations:^{
            if ( _selectedItem.isCollapsed ) {
                [_selectedItem uncollapse];
            } else {
                [_selectedItem collapse];
            }
        }];
    } else {
        if ( [self.delegate respondsToSelector:@selector(pyGridView:didSelectItem:)] ) {
            [self.delegate pyGridView:self didSelectItem:_selectedItem];
        }
    }
    _selectedItem = nil;
}

- (void)_actionPanHandler:(id)sender event:(PYViewEvent *)event
{
    if ( _responderGesture.state == UIGestureRecognizerStateEnded ) {
        // Same as touch end
        [_selectedItem setState:_selectedItemState];
        if ( _selectedItem.collapseRate > 0 ) {
            [PYView animateWithDuration:ANIMATION_TIME animations:^{
                if ( _selectedItem.isCollapsed ) {
                    [_selectedItem uncollapse];
                } else {
                    [_selectedItem collapse];
                }
            }];
        } else {
            if ( [self.delegate respondsToSelector:@selector(pyGridView:didSelectItem:)] ) {
                [self.delegate pyGridView:self didSelectItem:_selectedItem];
            }
        }
        return;
    }
    UITouch *_touch = [event.touches anyObject];
    CGPoint _touchPoint = [_touch locationInView:_containerView];
    if ( _responderGesture.state == UIGestureRecognizerStateChanged ) {
        if ( _selectedItem != nil ) {
            // Still in selected item
            if ( CGRectContainsPoint(_selectedItem._innerFrame, _touchPoint) == YES ) return;
        }
        PYGridItem *_newMoving = nil;
        for ( PYGridItem *_item in self ) {
            if ( CGRectContainsPoint(_item._innerFrame, _touchPoint) == NO ) continue;
            _newMoving = _item;
        }
        // in padding gap.
        if ( _newMoving == nil ) return;
        
        if ( _newMoving.state == UIControlStateDisabled ) return;
        UIControlState _newState = _newMoving.state;
        [PYView animateWithDuration:ANIMATION_TIME animations:^{
            [_selectedItem setState:_selectedItemState];
            [_newMoving setState:UIControlStateHighlighted];
        } completion:^(BOOL finished) {
            _selectedItem = _newMoving;
            _selectedItemState = _newState;
        }];
    }
}

#pragma mark -
#pragma mark Messages

- (void)addHeadView:(UIView *)headView
{
    if ( headView == nil ) {
        NSArray *_subviews = [[_headContainer subviews] copy];
        for ( UIView *_s in _subviews ) {
            [_s removeFromSuperview];
        }
        [_headContainer setFrame:CGRectZero];
    } else {
        [_headContainer addSubview:headView];
        CGRect _headFrame = _headContainer.bounds;
        _headFrame.size.height = headView.bounds.size.height;
        _headFrame.size.width = self.bounds.size.width;
        CGRect _subFrame = _headFrame;
        _subFrame.size.width = headView.bounds.size.width;
        _subFrame.origin.x = (_headFrame.size.width - _subFrame.size.width) / 2;
        
        [_headContainer setFrame:_headFrame];
        [headView setFrame:_subFrame];
    }
    if ( self.superview != nil ) [self _reformCellsWithFixedOutbounds];
}
- (void)addFootView:(UIView *)footView
{
    if ( footView == nil ) {
        NSArray *_subviews = [[_footContainer subviews] copy];
        for ( UIView *_s in _subviews ) {
            [_s removeFromSuperview];
        }
        [_footContainer setFrame:CGRectZero];
    } else {
        [_footContainer addSubview:footView];
        CGRect _footFrame = _footContainer.bounds;
        _footFrame.size.height = footView.bounds.size.height;
        _footFrame.size.width = self.bounds.size.width;
        CGRect _subFrame = _footFrame;
        _subFrame.size.width = footView.bounds.size.width;
        _subFrame.origin.x = (_footFrame.size.width - _subFrame.size.width) / 2;
        
        [_footContainer setFrame:_footFrame];
        [footView setFrame:_subFrame];
    }
    
    if ( self.superview != nil ) [self _reformCellsWithFixedOutbounds];
}

- (void)initGridViewWithScale:(PYGridScale)scale
{
    if ( scale.row * scale.column == 0 ) return;
    [self _clearAllCache];
    _gridScale = scale;
    
    // Initialize the grid config
    _gridConfig = (_GridRow *)malloc(sizeof(_GridRow) * scale.row);
    for ( int32_t r = 0; r < scale.row; ++r ) {
        _gridConfig[r] = (_GridNode __unsafe_unretained*)malloc(sizeof(_GridNode) * scale.column);
        
        // Init the grid item.
        for ( int32_t c = 0; c < scale.column; ++c ) {
            PYGridItem *_new_node = [PYGridItem object];
            _gridConfig[r][c] = _new_node;
            [_new_node _setParentGridView:self];
            [_new_node _initNodeAtIndex:(PYGridCoordinate){r, c}];
            [_containerView addSubview:_new_node];
        }
    }
}
- (void)mergeGridItemFrom:(PYGridCoordinate)from to:(PYGridCoordinate)to
{
    int32_t _minX = MIN(from.x, to.x);
    int32_t _maxX = MAX(from.x, to.x) + 1;
    int32_t _minY = MIN(from.y, to.y);
    int32_t _maxY = MAX(from.y, to.y) + 1;
    
    PYGridItem *_reservered_node = _gridConfig[_minX][_minY];
    for ( int32_t x = _minX; x < _maxX; ++x ) {
        for ( int32_t y = _minY; y < _maxY; ++y ) {
            if ( _gridConfig[x][y] == nil ) continue;
            [_gridConfig[x][y] removeFromSuperview];
            _gridConfig[x][y] = nil;
        }
    }
    [_reservered_node _setScale:(PYGridScale){_maxX - _minX, _maxY - _minY}];
    _gridConfig[_minX][_minY] = _reservered_node;
    [_containerView addSubview:_reservered_node];
    
    if ( self.superview != nil ) [self _reformCellsWithFixedOutbounds];
}

- (PYGridItem *)itemAtCoordinate:(PYGridCoordinate)coordinate
{
    // Get the grid item.
    return _gridConfig[coordinate.x][coordinate.y];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if ( self.superview == nil ) return;
    //
    [_backgroundImageView setFrame:self.bounds];
    [self _reformCellsWithFixedOutbounds];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if ( newSuperview == nil ) return;
    //
    [_backgroundImageView setFrame:self.bounds];
    [self _reformCellsWithFixedOutbounds];
}

- (void)dealloc
{
    [self _clearAllCache];
}

#pragma mark --
#pragma mark NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id __unsafe_unretained [])buffer
                                    count:(NSUInteger)len
{
    if ( state->state == 0 ) {
        state->mutationsPtr = (unsigned long *)(void *)_gridConfig;
        state->extra[0] = 0;
        state->extra[1] = -1;
        
        state->state = 1;
    }
    
    state->itemsPtr = buffer;
    NSUInteger _objectCount = 0;
    
    do {
        if ( (int32_t)state->extra[0] >= _gridScale.row ) break;
        for (
             int32_t r = (int32_t)state->extra[0], c = (int32_t)state->extra[1] + 1;
             c < _gridScale.column && _objectCount < len;
             ++c) {
            PYGridItem __unsafe_unretained *_item = _gridConfig[r][c];
            state->extra[1] = c;
            
            if ( _item == nil ) continue;
            
            *buffer++ = _item;
            _objectCount += 1;
        }
        // Reach the end of row
        if ( (int32_t)state->extra[1] >= (_gridScale.column - 1) ) {
            state->extra[0] += 1;
            state->extra[1] = -1;
        }
    } while ( _objectCount < len );
    
    if ( _objectCount == 0 ) {
        state->itemsPtr = NULL;
    }
    return _objectCount;
}

#pragma mark --
#pragma mark Gesture

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark --
#pragma mark Common Setting

- (void)setItemBackgroundColor:(UIColor *)color forState:(UIControlState)state
{
    for ( PYGridItem *_item in self ) {
        [_item _setBackgroundColor:color forState:state];
    }
}
- (void)setItemBackgroundImage:(UIImage *)image forState:(UIControlState)state
{
    for ( PYGridItem *_item in self ) {
        [_item _setBackgroundImage:image forState:state];
    }
}
- (void)setItemBorderWidth:(CGFloat)width forState:(UIControlState)state
{
    for ( PYGridItem *_item in self ) {
        [_item _setBorderWidth:width forState:state];
    }
}
- (void)setItemBorderColor:(UIColor *)color forState:(UIControlState)state
{
    for ( PYGridItem *_item in self ) {
        [_item _setBorderColor:color forState:state];
    }
}
- (void)setItemShadowOffset:(CGSize)offset forState:(UIControlState)state
{
    for ( PYGridItem *_item in self ) {
        [_item _setShadowOffset:offset forState:state];
    }
}
- (void)setItemShadowColor:(UIColor *)color forState:(UIControlState)state
{
    for ( PYGridItem *_item in self ) {
        [_item _setShadowColor:color forState:state];
    }
}
- (void)setItemShadowOpacity:(CGFloat)opacity forState:(UIControlState)state
{
    for ( PYGridItem *_item in self ) {
        [_item _setShadowOpacity:opacity forState:state];
    }
}
- (void)setItemShadowRadius:(CGFloat)radius forState:(UIControlState)state
{
    for ( PYGridItem *_item in self ) {
        [_item _setShadowRadius:radius forState:state];
    }
}
- (void)setItemTitle:(NSString *)title forState:(UIControlState)state
{
    for ( PYGridItem *_item in self ) {
        [_item _setTitle:title forState:state];
    }
}
- (void)setItemTextColor:(UIColor *)color forState:(UIControlState)state
{
    for ( PYGridItem *_item in self ) {
        [_item _setTextColor:color forState:state];
    }
}
- (void)setItemTextFont:(UIFont *)font forState:(UIControlState)state
{
    for ( PYGridItem *_item in self ) {
        [_item _setTextFont:font forState:state];
    }
}
- (void)setItemTextShadowOffset:(CGSize)offset forState:(UIControlState)state
{
    for ( PYGridItem *_item in self ) {
        [_item _setTextShadowOffset:offset forState:state];
    }
}
- (void)setItemTextShadowRadius:(CGFloat)radius forState:(UIControlState)state
{
    for ( PYGridItem *_item in self ) {
        [_item _setTextShadowRadius:radius forState:state];
    }
}
- (void)setItemTextShadowColor:(UIColor *)color forState:(UIControlState)state
{
    for ( PYGridItem *_item in self ) {
        [_item _setTextShadowColor:color forState:state];
    }
}
- (void)setItemIconImage:(UIImage *)image forState:(UIControlState)state
{
    for ( PYGridItem *_item in self ) {
        [_item _setIconImage:image forState:state];
    }
}
- (void)setItemIndicateImage:(UIImage *)image forState:(UIControlState)state
{
    for ( PYGridItem *_item in self ) {
        [_item _setIndicateImage:image forState:state];
    }
}
- (void)setItemInnerShadowColor:(UIColor *)color forState:(UIControlState)state
{
    for ( PYGridItem *_item in self ) {
        [_item _setInnerShadowColor:color forState:state];
    }
}
- (void)setItemInnerShadowRect:(PYPadding)rect forState:(UIControlState)state
{
    for ( PYGridItem *_item in self ) {
        [_item _setInnerShadowRect:rect forState:state];
    }
}

- (void)setItemStyle:(PYGridItemStyle)style
{
    for ( PYGridItem *_item in self ) {
        [_item setGridItemStyle:style];
    }
}

- (void)setItemCornerRadius:(CGFloat)cornerRaidus
{
    for ( PYGridItem *_item in self ) {
        [_item setCornerRadius:cornerRaidus];
    }
}

- (void)drawRect:(CGRect)rect
{
    // Update the seperator
    // No seperator
    if ( _seperatorStyle == PYGridSeperatorStyleNone ) return;
    
    CGContextRef _ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(_ctx, .5f);
    CGContextSetStrokeColorWithColor(_ctx, [UIColor lightGrayColor].CGColor);
    
    for ( PYGridItem * _item in self ) {
        if ( (_seperatorStyle & 0x0100) && (_item.coordinate.x + _item.scale.row < _gridScale.row)) {
            // Need hor
            CGFloat _x = _item.frame.origin.x + _padding / 2;
            CGFloat _y = _item.frame.origin.y + _item.frame.size.height + _padding * 1.5;
            CGFloat _w = _item.frame.size.width + _padding;
            // For Lite
            if ( _seperatorStyle & 0x0002 ) {
                _x += (_w / 5);
                _w = (_w / 5 * 3);
            }
            
            CGContextMoveToPoint(_ctx, _x, _y);
            CGContextAddLineToPoint(_ctx, _x + _w, _y);
            CGContextStrokePath(_ctx);
        }
        if ( (_seperatorStyle & 0x200) && (_item.coordinate.y + _item.scale.column < _gridScale.column)) {
            // Need ver
            CGFloat _x = _item.frame.origin.x + _item.frame.size.width + _padding * 1.5;
            CGFloat _y = _item.frame.origin.y + _padding / 2;
            CGFloat _h = _item.frame.size.height + _padding;
            // For Lite
            if ( _seperatorStyle & 0x0002 ) {
                _y += (_h / 5);
                _h = (_h / 5 * 3);
            }
            
            CGContextMoveToPoint(_ctx, _x, _y);
            CGContextAddLineToPoint(_ctx, _x, _y + _h);
            CGContextStrokePath(_ctx);
        }
    }
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
