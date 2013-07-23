//
//  PYHUDView+Singleton.h
//  PYUIKit
//
//  Created by Chen Push on 3/13/13.
//  Copyright (c) 2013 Markphone Culture Media Co.Ltd. All rights reserved.
//

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

