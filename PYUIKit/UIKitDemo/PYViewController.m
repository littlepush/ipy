//
//  PYViewController.m
//  UIKitDemo
//
//  Created by Push Chen on 7/27/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import "PYViewController.h"
#import "PYPhotoListCell.h"
#import <objc/runtime.h>
#import "PYUIKit.h"

@interface PYViewController ()

@end

@implementation PYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _testList = [UITableView object];
    [_testList setFrame:self.view.bounds];
    
    [self.view addSubview:_testList];
    
    _manager = [UITableManager object];
    [_manager bindTableView:_testList];
    
    _manager.identify = @"TestManager";
    _manager.defaultTarget = self;
    [_manager reloadTableDataWithMultipleSectionDataSource:@[@[@"1", @"2", @"3"]]];
    //[_manager reloadTableDataWithDataSource:@[@"1", @"2", @"3"]];
}

- (void)PYEventHandler(TestManager, PYTableManagerEventCreateNewCell)
{
    UITableViewCell *_cell = (UITableViewCell *)sender;
    [_cell setBackgroundColor:[UIColor randomColor]];
}

- (void)PYEventHandler(TestManager, PYTableManagerEventSelectCell)
{
    //UITableViewCell *_cell = (UITableViewCell *)sender;
    NSIndexPath *_indexPath = (NSIndexPath *)exInfo;
    [_testList deselectRowAtIndexPath:_indexPath animated:YES];
    [PYHUDView displayMessage:PYIntToString(_indexPath.row) duration:1.5f];
}

- (NSNumber *)PYEventHandler(TestManager, UITableManagerEventCanDeleteCell)
{
    return @(YES);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
