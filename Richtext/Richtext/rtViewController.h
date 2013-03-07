//
//  rtViewController.h
//  Richtext
//
//  Created by Push Chen on 1/31/13.
//  Copyright (c) 2013 Push Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RichLabel.h"

@interface rtViewController : UIViewController

@property (nonatomic, retain)	IBOutlet		UITextField		*inputSource;
@property (nonatomic, retain)	IBOutlet		RichLabel		*richLabel;

- (IBAction)inputChanged:(id)sender;

@end
