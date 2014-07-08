//
//  PYSlider.h
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

#import "PYScrollView.h"
#import "PYImageLayer.h"

#define _SLIDE_USE_IMAGE_VIEW_

#ifdef _SLIDE_USE_IMAGE_VIEW_
#import "PYImageView.h"
#endif

@protocol PYSliderDelegate;

typedef NS_ENUM(NSInteger, PYSliderDirection) {
    PYSliderDirectionHorizontal = PYResponderRestraintPanHorizontal,
    PYSliderDirectionVerticalis = PYResponderRestraintPanVerticalis
};

@interface PYSlider : PYResponderView
{
    PYImageLayer                *_backgroundLayer;
    PYImageLayer                *_slideButtonLayer;
#ifdef _SLIDE_USE_IMAGE_VIEW_
    PYImageView                 *_minTrackTintLayer;
#else
    PYImageLayer                *_minTrackTintLayer;
    UIImage                     *_minTrackImage;
#endif

    CGFloat                     _minimumValue;
    CGFloat                     _maximumValue;
    PYSliderDirection           _slideDirection;
    BOOL                        _isUserDragging;
    
    PYPadding                   _backgroundPadding;
    PYPadding                   _slideButtonPadding;
    
    // Internal properties
    struct {
        CGRect                      _background_frame;      // paddingRect(_backgroundLayer.frame)
        CGRect                      _slide_frame;           // paddingRect(_slideButtonLayer.frame)
        CGFloat                     _slide_position;        // _slide_frame.center - BP<L/T>
        CGFloat                     _slide_real_length;     // _background_frame.width
        CGFloat                     _slide_current_value;   // (_position/_real_length) * (real_range) + _min
        CGFloat                     _slide_real_range;      // _max - _min
        CGFloat                     _slide_offset __deprecated;
    }                           _internalProperties;
}

@property (nonatomic, assign)   IBOutlet    id<PYSliderDelegate>    delegate;

// Background image
@property (nonatomic, strong)   UIImage                             *backgroundImage;

// Slide button
@property (nonatomic, strong)   UIImage                             *slideButtonImage;
@property (nonatomic, strong)   UIColor                             *slideButtonColor;
@property (nonatomic, readonly) PYImageLayer                        *slideButtonLayer;

// Padding
@property (nonatomic, assign)   PYPadding                           backgroundPadding;
@property (nonatomic, assign)   PYPadding                           slideButtonPadding;

// Min
@property (nonatomic, strong)   UIImage                             *minTrackTintImage;
@property (nonatomic, strong)   UIColor                             *minTrackTintColor;

// Value
@property (nonatomic, assign)	CGFloat                             minimum;
@property (nonatomic, assign)	CGFloat                             maximum;
@property (nonatomic, readonly)	CGFloat                             currentValue;

// Option
@property (nonatomic, assign)   BOOL                                hideSlideButton;
@property (nonatomic, assign)   PYSliderDirection                   slideDirection;
@property (nonatomic, readonly) BOOL                                isDragging;

// The center of the button in side the slider.
@property (nonatomic, readonly) CGPoint                             buttonPosition;

/* Initial Slide View */
- (id)initWithMinimum:(CGFloat)min maximum:(CGFloat)max;

/* set current value with animation */
- (void)setCurrentValue:(CGFloat)aValue animated:(BOOL)animated;

@end

// Slider Delegate
@protocol PYSliderDelegate <NSObject>

@optional

// User Draging
- (void)pySliderBeginToDrag:(PYSlider *)slider;
- (void)pySliderEndOfDraging:(PYSlider *)slider;

// When user just tap on the slide button.
- (void)pySliderTapSlideButton:(PYSlider *)slider;

// Tell the delegate the current slider has changed the value to a new one.
- (void)pySlider:(PYSlider *)slider valueChangedTo:(CGFloat)value;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
