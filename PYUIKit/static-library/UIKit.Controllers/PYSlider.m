//
//  PYSlider.m
//  PYUIKit
//
//  Created by Push Chen on 7/30/13.
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

#import "PYSlider.h"
#import "UIImage+UIKit.h"
#import "PYScrollView+SideAnimation.h"

CGRect _paddingRect(CGRect source, PYPadding padding) {
    source.origin.x += padding.left;
    source.origin.y += padding.top;
    source.size.width -= (padding.left + padding.right);
    source.size.height -= (padding.top + padding.bottom);
    if ( source.size.width <= 0.f ) source.size.width = 1.f;
    if ( source.size.height <= 0.f ) source.size.height = 1.f;
    return source;
}

@implementation PYSlider

// Properties
//delegate;
@synthesize delegate;
//*backgroundImage;
@dynamic backgroundImage;
- (UIImage *)backgroundImage
{
    return _backgroundLayer.image;
}
- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    [_backgroundLayer setImage:backgroundImage];
}
- (UIColor *)backgroundColor
{
    return [UIColor colorWithCGColor:_backgroundLayer.backgroundColor];
}
- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [_backgroundLayer setBackgroundColor:backgroundColor.CGColor];
}
//*slideButtonImage;
@dynamic slideButtonImage;
- (UIImage *)slideButtonImage
{
    return _slideButtonLayer.image;
}
- (void)setSlideButtonImage:(UIImage *)slideButtonImage
{
    [_slideButtonLayer setImage:slideButtonImage];
}
//*slideButtonColor;
@dynamic slideButtonColor;
- (UIColor *)slideButtonColor
{
    return [UIColor colorWithCGColor:_slideButtonLayer.backgroundColor];
}
- (void)setSlideButtonColor:(UIColor *)slideButtonColor
{
    [_slideButtonLayer setBackgroundColor:slideButtonColor.CGColor];
}
//*minTrackTintImage;
@dynamic minTrackTintImage;
- (UIImage *)minTrackTintImage
{
#ifdef _SLIDE_USE_IMAGE_VIEW_
    return _minTrackTintLayer.image;
#else
    return _minTrackImage;
#endif
}
- (void)setMinTrackTintImage:(UIImage *)minTrackTintImage
{
#ifdef _SLIDE_USE_IMAGE_VIEW_
    [_minTrackTintLayer setImage:minTrackTintImage];
#else
    _minTrackImage = minTrackTintImage;
    if ( self.superview == nil ) return;
    if ( CGRectIsEmpty(self.bounds) ) return;
    [_minTrackTintLayer setImage:
     [_minTrackImage cropInRect:_minTrackTintLayer.frame]];
#endif
}
//*minTrackTintColor;
@dynamic minTrackTintColor;
- (UIColor *)minTrackTintColor
{
#ifdef _SLIDE_USE_IMAGE_VIEW_
    return _minTrackTintLayer.backgroundColor;
#else
    return [UIColor colorWithCGColor:_minTrackTintLayer.backgroundColor];
#endif
}
- (void)setMinTrackTintColor:(UIColor *)minTrackTintColor
{
#ifdef _SLIDE_USE_IMAGE_VIEW_
    [_minTrackTintLayer setBackgroundColor:minTrackTintColor];
#else
    [_minTrackTintLayer setBackgroundColor:minTrackTintColor.CGColor];
#endif
}
//minimum;
@synthesize minimum = _minimumValue;
- (void)setMinimum:(CGFloat)minimum
{
    if ( isnan(minimum) ) return;
    _minimumValue = minimum;
    @synchronized( self ) {
        [self _recalculateSlideInfo];
    }
}
//maximum;
@synthesize maximum = _maximumValue;
- (void)setMaximum:(CGFloat)maximum
{
    if ( maximum == 0 || isnan(maximum) ) return;
    _maximumValue = maximum;
    @synchronized( self ) {
        [self _recalculateSlideInfo];
    }
}
//currentValue;
@synthesize currentValue;
- (CGFloat)currentValue
{
    return _internalProperties._slide_current_value;
}

//hideSlideButton;
@dynamic hideSlideButton;
- (BOOL)hideSlideButton
{
    return _slideButtonLayer.hidden;
}
- (void)setHideSlideButton:(BOOL)hide
{
    _slideButtonLayer.hidden = hide;
    @synchronized( self ) {
        [self _recalculateSlideInfo];
    }
}
//slideDirection;
@synthesize slideDirection = _slideDirection;
- (void)setSlideDirection:(PYSliderDirection)direction
{
    _slideDirection = direction;
    [self setEvent:PYResponderEventPan
     withRestraint:(PYResponderRestraint)_slideDirection];
    @synchronized( self ) {
        [self _recalculateSlideInfo];
    }
}
@synthesize backgroundPadding = _backgroundPadding;
- (void)setBackgroundPadding:(PYPadding)backgroundPadding
{
    _backgroundPadding = backgroundPadding;
    @synchronized( self ) {
        [self _recalculateSlideInfo];
    }
}
@synthesize slideButtonPadding = _slideButtonPadding;
- (void)setSlideButtonPadding:(PYPadding)slideButtonPadding
{
    _slideButtonPadding = slideButtonPadding;
    @synchronized( self ) {
        [self _recalculateSlideInfo];
    }
}
//isDragging;
@synthesize isDragging = _isUserDragging;
//buttonCenter;
@dynamic buttonPosition;
- (CGPoint)buttonPosition
{
    if ( _slideButtonLayer.isHidden ) return CGPointZero;
    return _slideButtonLayer.position;
}

#pragma mark -
#pragma mark Internal Messages

- (void)_recalculateSlideInfo
{
    _internalProperties._slide_real_range = (_maximumValue - _minimumValue);
    _internalProperties._background_frame = _paddingRect(self.bounds, _backgroundPadding);
    if ( _slideDirection == PYSliderDirectionHorizontal ) {
        _internalProperties._slide_real_length = _internalProperties._background_frame.size.width;
    } else {
        _internalProperties._slide_real_length = _internalProperties._background_frame.size.height;
    }
    if ( _slideButtonLayer.isHidden ) return;
    
    // _current_value = (_position/_real_length) * (real_range) + _min
    // _position = (_current_value - _min) / _real_range * _real_length
    _internalProperties._slide_position = ((_internalProperties._slide_current_value - _minimumValue)
                                           / _internalProperties._slide_real_range
                                           * _internalProperties._slide_real_length);
    // _position = _slide_frame.center - BP<L/T>
    // _slide_frame.center = _position + BP<L/T>
    // _slide_frame = paddingRect(_slide_side_size_frame, SP)
    // _slide_frame = ??
    CGFloat _hcenter = 0, _vcenter = 0, _sideSize = 0;
    if ( _slideDirection == PYSliderDirectionHorizontal ) {
        _hcenter = 0 + _backgroundPadding.left;
        _vcenter = _internalProperties._background_frame.size.height / 2 + _backgroundPadding.top;
        _sideSize = self.bounds.size.height;
    } else {
        _hcenter = _internalProperties._background_frame.size.width / 2 + _backgroundPadding.left;
        _vcenter = _internalProperties._background_frame.size.height + _backgroundPadding.top;
        _sideSize = self.bounds.size.width;
    }
    CGFloat _frame_width = _sideSize - _slideButtonPadding.left - _slideButtonPadding.right;
    CGFloat _frame_height = _sideSize - _slideButtonPadding.top - _slideButtonPadding.bottom;
    CGFloat _x = _hcenter - _frame_width / 2;
    CGFloat _y = _vcenter - _frame_height / 2;
    _internalProperties._slide_frame = CGRectMake(_x, _y, _frame_width, _frame_height);
}

- (void)_actionTouchBegin:(id)sender event:(PYViewEvent *)event
{
    @synchronized( self ) {
        _isUserDragging = YES;
    }
}

- (void)_actionTouchEnd:(id)sender event:(PYViewEvent *)event
{
    @synchronized( self ) {
        _isUserDragging = NO;
    }
}

- (void)_actionTouchCancel:(id)sender event:(PYViewEvent *)event
{
    @synchronized( self ) {
        _isUserDragging = NO;
    }
}

- (void)_actionPanHandler:(id)sender event:(PYViewEvent *)event
{
    if ( _responderGesture.state == UIGestureRecognizerStateBegan ) {
        if ( [((NSObject *)self.delegate) respondsToSelector:@selector(pySliderBeginToDrag:)] ) {
            [self.delegate pySliderBeginToDrag:self];
        }
    } else if ( _responderGesture.state == UIGestureRecognizerStateEnded ) {
        if ( [((NSObject *)self.delegate) respondsToSelector:@selector(pySliderEndOfDraging:)] ) {
            [self.delegate pySliderEndOfDraging:self];
        }
    } else if ( _responderGesture.state == UIGestureRecognizerStateChanged ) {
        if ( _slideDirection == PYSliderDirectionHorizontal ) {
            CGFloat _deltaValue = ((event.preciseDistance.width /
                                    _internalProperties._slide_real_length) *
                                   _internalProperties._slide_real_range);
            [self _setCurrentValue:(_internalProperties._slide_current_value + _deltaValue)];
        } else {
            CGFloat _deltaValue = ((event.preciseDistance.height /
                                    _internalProperties._slide_real_length) *
                                   _internalProperties._slide_real_range);
            [self _setCurrentValue:(_internalProperties._slide_current_value + _deltaValue)];
        }
    }
}

- (void)_actionTapHandler:(id)sender event:(PYViewEvent *)event
{
    UITouch *_tapTouch = [event.touches anyObject];
    CGPoint _tapPoint = [_tapTouch locationInView:self];
    if ( _slideButtonLayer.hidden == NO ) {
        if ( CGRectContainsPoint(_slideButtonLayer.frame, _tapPoint) ) {
            // Slide button tap
            if ( [((NSObject *)self.delegate) respondsToSelector:@selector(pySliderTapSlideButton:)] ) {
                [self.delegate pySliderTapSlideButton:self];
            }
            return;
        }
    }
    // Set value
    if ( _slideDirection == PYSliderDirectionHorizontal ) {
        CGFloat _percentage = ((_tapPoint.x - _backgroundPadding.left) /
                               _internalProperties._slide_real_length);
        CGFloat _value = (_percentage * _internalProperties._slide_real_range + _minimumValue);
        [self _setCurrentValue:_value];
    } else {
        CGFloat _percentage = ((_tapPoint.y + _backgroundPadding.top) /
                               _internalProperties._slide_real_length);
        _percentage = 1 - _percentage;
        CGFloat _value = (_percentage * _internalProperties._slide_real_range + _minimumValue);
        [self _setCurrentValue:_value];
    }
}

- (void)viewJustBeenCreated
{
    [super viewJustBeenCreated];
    
    // Register Event.
    [self addTarget:self action:@selector(_actionTouchBegin:event:)
  forResponderEvent:PYResponderEventTouchBegin];
    [self addTarget:self action:@selector(_actionTouchEnd:event:)
  forResponderEvent:PYResponderEventTouchEnd];
    [self addTarget:self action:@selector(_actionTouchCancel:event:)
  forResponderEvent:PYResponderEventTouchCancel];
    [self addTarget:self action:@selector(_actionPanHandler:event:)
  forResponderEvent:PYResponderEventPan];
    [self setEvent:PYResponderEventPan
     withRestraint:PYResponderRestraintPanHorizontal];
    [self addTarget:self action:@selector(_actionTapHandler:event:)
  forResponderEvent:PYResponderEventTap];
    [self setEvent:PYResponderEventTap
     withRestraint:PYResponderRestraintSingleTap];
    
    // Object init
    _backgroundLayer = [PYImageLayer layer];
    [_backgroundLayer setBackgroundColor:[UIColor clearColor].CGColor];
    [self.layer addSublayer:_backgroundLayer];
    
    [super setBackgroundColor:[UIColor clearColor]];
    
#ifdef _SLIDE_USE_IMAGE_VIEW_
    _minTrackTintLayer = [PYImageView object];
    [_minTrackTintLayer setBackgroundColor:[UIColor clearColor]];
    [_minTrackTintLayer setContentMode:UIViewContentModeLeft];
    [_minTrackTintLayer setClipsToBounds:YES];
    [self addSubview:_minTrackTintLayer];
#else
    _minTrackTintLayer = [PYImageLayer layer];
    [_minTrackTintLayer setBackgroundColor:[UIColor clearColor].CGColor];
    [self.layer addSublayer:_minTrackTintLayer];
#endif
    
    _slideButtonLayer = [PYImageLayer layer];
    [_slideButtonLayer setBackgroundColor:[UIColor clearColor].CGColor];
    [self.layer addSublayer:_slideButtonLayer];
    NSMutableDictionary *_actionDict = [NSMutableDictionary dictionaryWithDictionary:_slideButtonLayer.actions];
    [_actionDict setObject:[NSNull null] forKey:@"transform"];
    _slideButtonLayer.actions = _actionDict;

    _minimumValue = 0.f;
    _maximumValue = 1.f;
    
    _slideDirection = PYSliderDirectionHorizontal;
    
    [self setClipsToBounds:NO];
}

- (id)initWithMinimum:(CGFloat)min maximum:(CGFloat)max
{
    self = [super init];
    if ( self ) {
        _minimumValue = min;
        _maximumValue = max;
    }
    return self;
}

- (void)setCurrentValue:(CGFloat)value animated:(BOOL)animated
{
    if ( _maximumValue <= _minimumValue ) return;
    if ( isnan(_maximumValue) || isnan(_minimumValue) ) return;
    @synchronized ( self ) {
        if ( animated ) {
            [UIView beginAnimations:@"" context:NULL];
            [UIView setAnimationDuration:.35];
        }
        [self _setCurrentValue:value];
        if ( animated ) {
            [UIView commitAnimations];
        }
    }
}

// Internal Set Value function.
- (void)_setCurrentValue:(CGFloat)value
{
    if ( isnan(value) || value < _minimumValue ) {
        _internalProperties._slide_current_value = _minimumValue;
    } else if ( value > _maximumValue ) {
        _internalProperties._slide_current_value = _maximumValue;
    } else {
        _internalProperties._slide_current_value = value;
    }
    
    CGFloat _percentage = ((_internalProperties._slide_current_value - _minimumValue) /
                           _internalProperties._slide_real_range);
    CGFloat _transformPos = _percentage * _internalProperties._slide_real_length;
    
    // Set slide button position.
    if ( _slideButtonLayer.hidden == NO ) {
        CATransform3D _btnTransform;
        if ( _slideDirection == PYSliderDirectionHorizontal ) {
            _btnTransform = CATransform3DMakeTranslation(_transformPos, 0, 0);
        } else {
            _btnTransform = CATransform3DMakeTranslation(0, _transformPos, 0);
        }
        _slideButtonLayer.transform = _btnTransform;
    }
    
    // Set min tint layer
    CGRect _minTintFrame = _internalProperties._background_frame;
    if ( _slideDirection == PYSliderDirectionHorizontal ) {
        _minTintFrame.size.width = _transformPos;
    } else {
        _minTintFrame.origin.y = (_minTintFrame.size.height - _transformPos);
        _minTintFrame.size.height = _transformPos;
    }
    [_minTrackTintLayer setFrame:_minTintFrame];
#ifndef _SLIDE_USE_IMAGE_VIEW_
    if ( _minTrackImage != nil && (_minTintFrame.size.width * _minTintFrame.size.height != 0.f) ) {
        [_minTrackTintLayer setImage:
         [_minTrackImage cropInRect:_minTintFrame]];
    }
#endif
    
    if ( [(NSObject *)self.delegate respondsToSelector:@selector(pySlider:valueChangedTo:)] ) {
        [self.delegate pySlider:self valueChangedTo:_internalProperties._slide_current_value];
    }
}

- (void)_updateItemFrame
{
    [self _recalculateSlideInfo];
    [_backgroundLayer setFrame:_internalProperties._background_frame];
    [_slideButtonLayer setFrame:_internalProperties._slide_frame];
    [self setCurrentValue:_internalProperties._slide_current_value animated:NO];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if ( self.superview == nil ) return;
    [self _updateItemFrame];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if ( newSuperview == nil ) return;
    [self _updateItemFrame];
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
