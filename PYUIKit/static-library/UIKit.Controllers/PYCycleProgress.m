//
//  PYCycleProgress.m
//  PYUIKit
//
//  Created by Push Chen on 7/14/14.
//  Copyright (c) 2014 Push Lab. All rights reserved.
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

#import "PYCycleProgress.h"

@implementation PYCycleProgress
@synthesize progressBarColor = _progressBarColor;
- (void)setProgressBarColor:(UIColor *)progressBarColor
{
    _progressBarColor = progressBarColor;
    [self setNeedsDisplay];
}

@synthesize progressBarWidth = _progressBarWidth;
- (void)setProgressBarWidth:(CGFloat)progressBarWidth
{
    _progressBarWidth = progressBarWidth;
    [self setNeedsDisplay];
}

@synthesize maxValue = _maxValue;
- (void)setMaxValue:(CGFloat)maxValue
{
    _maxValue = maxValue;
    [self setNeedsDisplay];
}

@synthesize currentValue = _currentValue;
- (void)setCurrentValue:(CGFloat)currentValue
{
    _currentValue = currentValue;
    [self setNeedsDisplay];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void)drawInContext:(CGContextRef)ctx
{
    if ( _progressBarWidth == 0.f ) return;
    if ( _progressBarColor == nil ) return;
    if ( _maxValue == 0.f ) return;
    if ( _currentValue > _maxValue ) return;
    
    self.contentsScale = [UIScreen mainScreen].scale;
    
    CGPoint _center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    CGFloat _angle = (_currentValue / _maxValue) * M_PI * 2 - M_PI_2;
    UIBezierPath *_path = [UIBezierPath bezierPath];
    UIBezierPath *_tempPath = [UIBezierPath bezierPath];
    
    [_tempPath moveToPoint:CGPointMake(_center.x, _progressBarWidth)];
    [_tempPath addArcWithCenter:_center radius:(_center.x - _progressBarWidth * 2)
                     startAngle:-M_PI_2 endAngle:_angle clockwise:YES];
    CGPoint _tempPoint = _tempPath.currentPoint;
    
    [_path moveToPoint:CGPointMake(_center.x, 0)];
    [_path addArcWithCenter:_center radius:_center.x startAngle:-M_PI_2 endAngle:_angle clockwise:YES];
    [_path addLineToPoint:_tempPoint];
    [_path addLineToPoint:CGPointMake(_center.x, _progressBarWidth)];
    [_path addArcWithCenter:_center radius:(_center.x - _progressBarWidth * 2)
                 startAngle:_angle endAngle:-M_PI_2 clockwise:NO];
    
    CGContextSetLineWidth(ctx, 0.5);
    UIGraphicsPushContext(ctx);
    [_progressBarColor setFill];
    [_path fill];
    UIGraphicsPopContext();
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
