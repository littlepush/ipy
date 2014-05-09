//
//  PYNewHumanViewController.m
//  PYDataDemo
//
//  Created by Push Chen on 5/9/14.
//  Copyright (c) 2014 PushLab. All rights reserved.
//

#import "PYNewHumanViewController.h"

@interface PYNewHumanViewController ()

@end

@implementation PYNewHumanViewController

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
    
    _newHumanInfo = [PYHumanInfo object];
    
    UIBarButtonItem *_doneItem = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                  target:self
                                  action:@selector(_doneActionHandler:)];
    [self.navigationItem setRightBarButtonItem:_doneItem];
}

- (void)_doneActionHandler:(id)sender
{
    //
    _newHumanInfo.name = _nameField.text;
    _newHumanInfo.age = [_ageField.text intValue];
    _newHumanInfo.gender = [_genderSegCtrl titleForSegmentAtIndex:
                            _genderSegCtrl.selectedSegmentIndex];
    _newHumanInfo.phoneNumber = _phoneField.text;
    _newHumanInfo.email = _emailField.text;
    
    // Update the object
    PYGlobalDataCache *_gdc = [PYGlobalDataCache gdcWithIdentify:kHumanInfoCache];
    [_gdc setObject:_newHumanInfo forKey:_newHumanInfo.objectIdentify];
    
    // Update the list
    NSMutableArray *_dataSource = (NSMutableArray *)[_gdc objectForKey:kHumanList];
    if ( _dataSource == nil ) {
        _dataSource = [NSMutableArray array];
    }
    [_dataSource addObject:_newHumanInfo.objectIdentify];
    [_gdc setObject:_dataSource forKey:kHumanList];
    
    // Tell all observer
    [NF_CENTER postNotificationName:kHumanListUpdateNotification object:nil];
    [self.navigationController popViewControllerAnimated:YES];
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
