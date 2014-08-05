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

@interface PYTestCell : UITableViewCell< PYTableCell >

@end

@implementation PYTestCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self.textLabel setFont:[UIFont systemFontOfSize:18.f]];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

+ (NSNumber *)heightOfCellWithSpecifiedContentItem:(id)contentItem
{
    return @44;
}

- (void)rendCellWithSpecifiedContentItem:(id)contentItem
{
    [self.textLabel setText:contentItem];
}

@end

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
    [_manager bindTableView:_testList withDataSource:@[@"1", @"2", @"3"]];
    _manager.defaultTarget = self;
    [_manager setDefaultCellClass:[PYTestCell class]];
    
    //[_manager reloadTableDataWithMultipleSectionDataSource:@[@[@"1", @"2", @"3"]]];
    //[_manager reloadTableDataWithDataSource:@[@"1", @"2", @"3"]];
}

- (void)PYEventHandler(TestManager, PYTableManagerEventCreateNewCell)
{
    UITableViewCell *_cell = (UITableViewCell *)obj1;
    [_cell setBackgroundColor:[UIColor randomColor]];
}

- (void)PYEventHandler(TestManager, PYTableManagerEventSelectCell)
{
    //UITableViewCell *_cell = (UITableViewCell *)sender;
    NSIndexPath *_indexPath = (NSIndexPath *)obj2;
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
