//
//  PYNewHumanViewController.h
//  PYDataDemo
//
//  Created by Push Chen on 5/9/14.
//  Copyright (c) 2014 PushLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PYHumanInfo.h"

@interface PYNewHumanViewController : UIViewController
{
    PYHumanInfo                     *_newHumanInfo;
    
    IBOutlet UIScrollView           *_containerPanel;
    IBOutlet UITextField            *_nameField;
    IBOutlet UISegmentedControl     *_genderSegCtrl;
    IBOutlet UITextField            *_ageField;
    IBOutlet UITextField            *_phoneField;
    IBOutlet UITextField            *_emailField;
}

@end
