//
//  PYHUDView+Singleton.h
//  PYUIKit
//
//  Created by Push Chen on 3/13/13.
//  Copyright (c) 2013 PushLab. All rights reserved.
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

#import "PYHUDView.h"

@interface PYHUDView (Singleton)

// Singleton Instance
+ (PYHUDView *)sharedHUDView;

// Reset the auto hiding timer statue
- (void)_cleanAutoHidingTimer;

// Start the auto hiding timer.
- (void)_startAutoHidingTimer:(CGFloat)duration;

// Auto Hiding Timer Handler
- (void)_autoHidingTimerHandler:(NSTimer *)timer;

// Clear all shown data of hud view.
- (void)_clearAllData;

// Show the view
- (void)_showHUDView;

- (CGRect)_calculateHUDFrame:(CGSize)contentSize;

@end

// @littlepush
// littlepush@gmail.com
// PYLab

