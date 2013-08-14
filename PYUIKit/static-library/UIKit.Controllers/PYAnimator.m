//
//  PYAnimator.m
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

#import "PYAnimator.h"

@implementation PYAnimator
@synthesize isAnimating = _animationStatue;
@synthesize interval;

- (void)layerJustBeenCreated
{
    [super layerJustBeenCreated];
    _animationStatue = NO;
    _currentFrame = 0;
    self.interval = 1.f / 7.f;
    _piecesOfFrame = [NSMutableArray array];
}

- (void)layerJustBeenCopyed
{
    [super layerJustBeenCopyed];
    _animationStatue = NO;
    _currentFrame = 0;
    self.interval = 1.f / 7.f;
    _piecesOfFrame = [NSMutableArray array];
}

#pragma mark Methods

- (void)setAnimationImage:(UIImage *)animationImage
                  ofPiece:(int)piece
                frameSize:(CGSize)size
{
    [_piecesOfFrame removeAllObjects];
    _currentFrame = 0;
    
    CGFloat _width = animationImage.size.width;
    CGFloat _height = animationImage.size.height;
    int _maxCol = _width / size.width;
    int _maxRow = _height / size.height;
    CGFloat _s = animationImage.scale;
    
    for ( int i = 0; i < piece; ++i ) {
        CGFloat _row = i / _maxCol;
        CGFloat _col = (i % _maxCol);
        if ( _row >= _maxRow ) return;
        
        CGRect _pieceRect = CGRectMake(_col * size.width * _s, _row * size.height * _s,
                                       size.width * _s, size.height * _s);
        CGImageRef _pieceImgRef = CGImageCreateWithImageInRect(animationImage.CGImage, _pieceRect);
        UIImage *_ = [UIImage imageWithCGImage:_pieceImgRef];
        CFRelease(_pieceImgRef);
        
        [_piecesOfFrame addObject:_];
        
    }
}

- (void)_playingAnimation:(id)dummy
{
    //NSLog(@"%@", [UIApplication sharedApplication].keyWindow);
    if ( self.isAnimating == NO || self.hidden == YES ) return;
    if ( _currentFrame < [_piecesOfFrame count] ) {
        self.contents = (id)((UIImage *)[_piecesOfFrame objectAtIndex:_currentFrame]).CGImage;
    }
    _currentFrame += 1;
    if ( _currentFrame == [_piecesOfFrame count] )
        _currentFrame = 0;
}

- (void)startAnimation
{
    if ( _animationStatue == YES ) return;
    _animationStatue = YES;
    
    //
    _animatorTimer = [NSTimer scheduledTimerWithTimeInterval:self.interval
                                                      target:self
                                                    selector:@selector(_playingAnimation:)
                                                    userInfo:nil
                                                     repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_animatorTimer forMode:NSRunLoopCommonModes];
}

- (void)stopAnimation
{
    _animationStatue = NO;
    if ( _animatorTimer != nil ) {
        [_animatorTimer invalidate];
        _animatorTimer = nil;
    }
}

- (void)dealloc
{
    [self stopAnimation];
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
