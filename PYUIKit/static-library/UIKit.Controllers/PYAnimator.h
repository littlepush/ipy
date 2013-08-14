//
//  PYAnimator.h
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

#import "PYImageLayer.h"

@interface PYAnimator : PYImageLayer
{
    BOOL                    _animationStatue;
    NSMutableArray          *_piecesOfFrame;
    int                     _currentFrame;
    
    NSTimer                 *_animatorTimer;
}

@property (nonatomic, readonly) BOOL        isAnimating;
// Key property, the interval to change between two frames
@property (nonatomic, assign)   CGFloat     interval;

// Set the animation group image.
- (void)setAnimationImage:(UIImage *)animationImage
                  ofPiece:(int)piece
                frameSize:(CGSize)size;

// Start to play the animation.
- (void)startAnimation;
// Stop the animation.
- (void)stopAnimation;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
