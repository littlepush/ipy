//
//  PYBillBoard.h
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

#import "PYLabelLayer.h"

@interface PYBillBoard : PYLabelLayer
{
    NSString                    *_sourceText;
    CGFloat                     _textWidth;
    CGFloat                     _oldPadding;
    NSLineBreakMode             _oldLineBreakMode;
    
    BOOL                        _isAnimated;
    
    // The timer
    NSTimer                     *_billboardTimer;
}

@property (nonatomic, readonly) BOOL        isAnimating;

// The pixel each time stamp to move.
@property (nonatomic, assign)   CGFloat     step;
// The time window.
@property (nonatomic, assign)   CGFloat     interval;

// Bill Board Animation Switch.
- (void)startBillBoardAnimation;
- (void)stopBillBoardAnimation;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
