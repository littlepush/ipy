//
//  PYBillBoard.m
//  PYUIKit
//
//  Created by Push Chen on 8/14/13.
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

#import "PYBillBoard.h"

@implementation PYBillBoard
@synthesize isAnimating = _isAnimated;

- (void)_animationForBillBoard:(id)sender
{
    @synchronized(self) {
        if ( _isAnimated == NO ) return;
        
        if ( PYABSF(self.paddingLeft) >= _textWidth ) {
            // First part is all out of screen.
            CGFloat _deltaPadding = PYABSF(self.paddingLeft) - _textWidth;
            self.paddingLeft = -_deltaPadding;
        }
        self.paddingLeft -= self.step;
        [self setNeedsDisplay];
    }
}

- (void)willMoveToSuperLayer:(CALayer *)layer
{
    if ( layer == nil ) {
        [self stopBillBoardAnimation];
    }
}
- (void)startBillBoardAnimation
{
    @synchronized(self) {
        // Copy data.
        _sourceText = [self.text copy];
        _oldPadding = self.paddingLeft;
        _oldLineBreakMode = self.lineBreakMode;
        
        // Multiple Line is not supported
        if ( self.multipleLine ) return;
        CGSize _textSize = [self.text sizeWithFont:self.textFont];
        // If the text is short and can not fit the label bounds,
        // do not start the animation.
        if ( _textSize.width <= self.bounds.size.width ) return;
        
        CGSize _spaceSize = [@"  " sizeWithFont:self.textFont];
        _textWidth = _textSize.width + _spaceSize.width;
        // Double cache.
        self.text = [NSString stringWithFormat:@"%@  %@",
                     _sourceText, _sourceText];
        self.lineBreakMode = NSLineBreakByClipping;
        
        if ( self.step == 0.f ) self.step = 1.f;
        if ( self.interval == 0.f ) self.interval = .1f;
        
        // Start the animation.
        _isAnimated = YES;
        
        // Start the animation.
        _billboardTimer = [NSTimer scheduledTimerWithTimeInterval:self.interval
                                                           target:self
                                                         selector:@selector(_animationForBillBoard:)
                                                         userInfo:nil
                                                          repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_billboardTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopBillBoardAnimation
{
    @synchronized(self) {
        _isAnimated = NO;
        if ( _billboardTimer != nil ) {
            [_billboardTimer invalidate];
            _billboardTimer = nil;
        }
        self.text = _sourceText;
        self.paddingLeft = _oldPadding;
        self.lineBreakMode = _oldLineBreakMode;
        [self setNeedsDisplay];
    }
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
