//
//  PYViewController.h
//  UIKitDemo
//
//  Created by Push Chen on 7/27/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PYViewController : UIViewController <PYGridViewDelegate, PYSliderDelegate>
{
    PYSlider                *_testSlider;
    
    PYGridView              *_gridView;
    
    PYImageView             *_testImageView;
}

@end
