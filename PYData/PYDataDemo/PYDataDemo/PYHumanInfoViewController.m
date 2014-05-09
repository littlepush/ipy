//
//  PYHumanInfoViewController.m
//  PYDataDemo
//
//  Created by Push Chen on 5/9/14.
//  Copyright (c) 2014 PushLab. All rights reserved.
//

#import "PYHumanInfoViewController.h"
#import "PYHumanInfo.h"

@interface PYHumanInfoViewController ()

@end

@implementation PYHumanInfoViewController

@synthesize humanIdentifier;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setEdgesForExtendedLayout:(UIRectEdgeAll|~UIRectEdgeTop)];
    
    PYGlobalDataCache *_gdc = [PYGlobalDataCache gdcWithIdentify:kHumanInfoCache];
    DUMPObj(_gdc);
    PYHumanInfo *_humanInfo = [_gdc objectForKey:self.humanIdentifier];
    
    _objectIdLabel.text = _humanInfo.objectId;
    _typeLabel.text = _humanInfo.type;
    _nameLabel.text = _humanInfo.name;
    _genderLabel.text = _humanInfo.gender;
    _ageLabel.text = PYIntToString(_humanInfo.age);
    _phoneLabel.text = _humanInfo.phoneNumber;
    _emailLabel.text = _humanInfo.email;
    
    self.title = _humanInfo.name;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
