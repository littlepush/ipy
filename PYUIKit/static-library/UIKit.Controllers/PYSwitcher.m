//
//  PYSwitcher.m
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

#import "PYSwitcher.h"

@implementation PYSwitcher

- (void)viewJustBeenCreated
{
    [super viewJustBeenCreated];
    
    _isEnabled = YES;
    
    // Backgrond
    _backgroundLayer = [PYLayer layer];
    [self.layer addSublayer:_backgroundLayer];
    [_backgroundLayer setBackgroundColor:[UIColor darkGrayColor].CGColor];
    
    // Left
    _leftLabel = [PYLabelLayer layer];
    [self.layer addSublayer:_leftLabel];
    [_leftLabel setText:@"L"];
    [_leftLabel setTextFont:[UIFont systemFontOfSize:8.f]];
    [_leftLabel setTextBorderWidth:.5f];
    [_leftLabel setTextBorderColor:[UIColor grayColor]];
    [_leftLabel setTextColor:[UIColor whiteColor]];
    [_leftLabel setTextAlignment:NSTextAlignmentCenter];
    
    // Right
    _rightLabel = [PYLabelLayer layer];
    [self.layer addSublayer:_rightLabel];
    [_rightLabel setText:@"R"];
    [_rightLabel setTextFont:[UIFont systemFontOfSize:8.f]];
    [_rightLabel setTextBorderWidth:.5f];
    [_rightLabel setTextBorderColor:[UIColor grayColor]];
    [_rightLabel setTextColor:[UIColor whiteColor]];
    [_rightLabel setTextAlignment:NSTextAlignmentCenter];
    
    // Button
    _buttonLayer = [PYLayer layer];
    [self.layer addSublayer:_buttonLayer];
    [_buttonLayer setBackgroundColor:[UIColor lightGrayColor].CGColor];
    _showSide = PYSwitcherShowSideRight;
    
    // Add Actions
    [self setEvent:PYResponderEventSwipe withRestraint:PYResponderRestraintSwipeHorizontal];
    [self setEvent:PYResponderEventTap withRestraint:PYResponderRestraintSingleTap];
    
    [self addTarget:self
             action:@selector(_actionSwipeForView:event:)
  forResponderEvent:PYResponderEventSwipe];
    [self addTarget:self
             action:@selector(_actionTapForView:event:)
  forResponderEvent:PYResponderEventTap];
}

- (void)_actionSwipeForView:(PYSwitcher *)switcher event:(PYViewEvent *)event
{
    if ( _isEnabled == NO ) return;
    if ( event.swipeSide == PYResponderRestraintSwipeLeft ) {
        if ( _showSide == PYSwitcherShowSideRight ) return;
        [self switchToSide:PYSwitcherShowSideRight];
    } else {
        if ( _showSide == PYSwitcherShowSideLeft ) return;
        [self switchToSide:PYSwitcherShowSideLeft];
    }
}

- (void)_actionTapForView:(PYSwitcher *)switcher event:(PYViewEvent *)event
{
    if ( _isEnabled == NO ) return;
    UITouch *_touch = [event.touches anyObject];
    CGPoint _point = [_touch locationInView:self];
    BOOL _isLeft = (_point.x < (self.bounds.size.width / 2));
    if ( _isLeft ) {
        if ( _showSide == PYSwitcherShowSideRight ) return;
        [self switchToSide:PYSwitcherShowSideRight];
    } else {
        if ( _showSide == PYSwitcherShowSideLeft ) return;
        [self switchToSide:PYSwitcherShowSideLeft];
    }
}

@synthesize delegate;

@synthesize backgroundImage = _backgroundImage;
- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    _backgroundLayer.contents = (id)backgroundImage.CGImage;
}

@synthesize buttonImage = _buttonImage;
- (void)setButtonImage:(UIImage *)buttonImage
{
    _buttonImage = buttonImage;
    _buttonLayer.contents = (id)buttonImage.CGImage;
}

@synthesize leftLabel = _leftLabel;
@synthesize rightLabel = _rightLabel;

@dynamic leftText;
- (NSString *)leftText
{
    return [_leftLabel.text copy];
}

@dynamic rightText;
- (NSString *)rightText
{
    return [_rightLabel.text copy];
}

@synthesize currentSide = _showSide;

@synthesize isEnabled = _isEnabled;

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_backgroundLayer setFrame:self.bounds];
    CGRect _b = self.bounds;
    CGRect _lb = _b;
    CGRect _rb = _b;
    _lb.size.width /= 2;
    _rb.size.width /= 2;
    _rb.origin.x = _rb.size.width;
    
    [_leftLabel setFrame:_lb];
    [_rightLabel setFrame:_rb];
    if ( _showSide == PYSwitcherShowSideLeft ) {
        [_buttonLayer setFrame:_rb];
    } else {
        [_buttonLayer setFrame:_lb];
    }
}

- (void)switchToSide:(PYSwitcherShowSide)side
{
    if ( side == _showSide ) return;
    CGRect _b = self.bounds;
    _b.size.width /= 2;
    if ( side == PYSwitcherShowSideLeft ) {
        _b.origin.x = _b.size.width;
    }
    [CATransaction begin];
    [CATransaction setAnimationDuration:.175];
    [_buttonLayer setFrame:_b];
    [CATransaction commit];
    
    _showSide = side;
    if ( [((NSObject *)self.delegate) respondsToSelector:@selector(switcher:didSwitchedToSide:)] ) {
        [self.delegate switcher:self didSwitchedToSide:_showSide];
    }
}

- (void)setEnable:(BOOL)enabled
{
    _isEnabled = enabled;
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
