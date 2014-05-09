//
//  PYHumanInfoViewController.h
//  PYDataDemo
//
//  Created by Push Chen on 5/9/14.
//  Copyright (c) 2014 PushLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PYHumanInfoViewController : UIViewController
{
    IBOutlet UILabel                    *_objectIdLabel;
    IBOutlet UILabel                    *_typeLabel;
    IBOutlet UILabel                    *_nameLabel;
    IBOutlet UILabel                    *_genderLabel;
    IBOutlet UILabel                    *_ageLabel;
    IBOutlet UILabel                    *_phoneLabel;
    IBOutlet UILabel                    *_emailLabel;
}

// The displayed human identifier
@property (nonatomic, copy)     NSString            *humanIdentifier;

@end
