//
//  PYCycleProgress.h
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

#import "PYLayer.h"

// A Cycle Progress Bar.
@interface PYCycleProgress : PYLayer
{
    CGFloat                 _progressBarWidth;
    UIColor                 *_progressBarColor;
    CGFloat                 _maxValue;
    CGFloat                 _currentValue;
}

// The thickness of the cycle border
@property (nonatomic, assign)   CGFloat         progressBarWidth;
// The cycle progress's color
@property (nonatomic, strong)   UIColor         *progressBarColor;
// Max value for a progress
@property (nonatomic, assign)   CGFloat         maxValue;
// Current value of this progress bar.
@property (nonatomic, assign)   CGFloat         currentValue;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
