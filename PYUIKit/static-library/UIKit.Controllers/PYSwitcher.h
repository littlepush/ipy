//
//  PYSwitcher.h
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

#import "PYResponderView.h"
#import "PYImageLayer.h"
#import "PYLabelLayer.h"

typedef enum {
    PYSwitcherShowSideLeft          = 0,
    PYSwitcherShowSideRight         = 1
} PYSwitcherShowSide;

@protocol PYSwitcherDelegate;

@interface PYSwitcher : PYResponderView
{
    PYSwitcherShowSide                  _showSide;
    PYLayer                             *_backgroundLayer;
    PYLayer                             *_buttonLayer;
    PYLabelLayer                        *_leftLabel;
    PYLabelLayer                        *_rightLabel;
    
    UIImage                             *_backgroundImage;
    UIImage                             *_buttonImage;
    
    BOOL                                _isEnabled;
}

@property (nonatomic, assign)   id<PYSwitcherDelegate>  delegate;

// Properties
@property (nonatomic, strong)   UIImage                 *backgroundImage;
@property (nonatomic, strong)   UIImage                 *buttonImage;
@property (nonatomic, strong)   PYLabelLayer            *leftLabel;
@property (nonatomic, strong)   PYLabelLayer            *rightLabel;
@property (nonatomic, readonly) NSString                *leftText;
@property (nonatomic, readonly) NSString                *rightText;
@property (nonatomic, readonly) PYSwitcherShowSide      currentSide;
@property (nonatomic, readonly) BOOL                    isEnabled;

// Manually switch to specified side
- (void)switchToSide:(PYSwitcherShowSide)side;

// Enable or disenable the controller
- (void)setEnable:(BOOL)enabled;

@end


@protocol PYSwitcherDelegate <NSObject>

@optional
// Did do
- (void)switcher:(PYSwitcher *)switcher didSwitchedToSide:(PYSwitcherShowSide)side;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
