//
//  PYHumanListViewController.m
//  PYDataDemo
//
//  Created by Push Chen on 5/9/14.
//  Copyright (c) 2014 PushLab. All rights reserved.
//

#import "PYHumanListViewController.h"
#import "PYNewHumanViewController.h"
#import "PYHumanInfoViewController.h"
#import "PYHumanInfo.h"

@interface PYHumanListViewController ()

@end

@implementation PYHumanListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)_loadDataSource
{
    PYGlobalDataCache *_gdc = [PYGlobalDataCache gdcWithIdentify:kHumanInfoCache];
    NSAssert(_gdc != nil, @"failed to get %@", kHumanInfoCache);
    _dataSource = (NSMutableArray *)[_gdc objectForKey:kHumanList];
    if ( _dataSource == nil ) _dataSource = [NSMutableArray array];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Human List";
    
    // Load data source
    [self _loadDataSource];
    
    // Initialize the table view.
    _humanList = [UITableView object];
    [_humanList setFrame:self.view.bounds];
    [self.view addSubview:_humanList];
    
    _humanList.delegate = self;
    _humanList.dataSource = self;
    
    // Initialize the add button
    UIBarButtonItem *_addItem = [[UIBarButtonItem alloc]
                                 initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                 target:self
                                 action:@selector(_addButtonAction:)];
    [self.navigationItem setRightBarButtonItem:_addItem];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_addButtonAction:(id)sender
{
    PYNewHumanViewController *_newHumanVC = [PYNewHumanViewController object];
    [self.navigationController pushViewController:_newHumanVC animated:YES];
}

- (void)_dataSourceUpdateNotificationHandler:(id)notify
{
    [self _loadDataSource];
    [_humanList reloadData];
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if ( parent == nil ) {
        [NF_CENTER removeObserver:self name:kHumanListUpdateNotification object:nil];
    } else {
        [NF_CENTER addObserver:self
                      selector:@selector(_dataSourceUpdateNotificationHandler:)
                          name:kHumanListUpdateNotification
                        object:nil];
    }
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const _cellIdentify = @"com.humanlist.cell";
    UITableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentify];
    if ( _cell == nil ) {
        _cell = [[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault
                 reuseIdentifier:_cellIdentify];
        [_cell.textLabel setFont:[UIFont systemFontOfSize:14]];
    }
    return _cell;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *_humanId = [_dataSource safeObjectAtIndex:indexPath.row];
    if ( [_humanId length] == 0 ) {
        [cell.textLabel setText:@"Error"];
    } else {
        PYGlobalDataCache *_gdc = [PYGlobalDataCache gdcWithIdentify:kHumanInfoCache];
        PYHumanInfo *_human = (PYHumanInfo *)[_gdc objectForKey:_humanId];
        [cell.textLabel setText:[NSString stringWithFormat:@"%@ - %@",
                                 _human.name, _human.objectIdentify]];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *_humanId = [_dataSource safeObjectAtIndex:indexPath.row];
    PYHumanInfoViewController *_infoVC = [PYHumanInfoViewController object];
    _infoVC.humanIdentifier = _humanId;
    [self.navigationController pushViewController:_infoVC animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( editingStyle != UITableViewCellEditingStyleDelete ) return;
    NSString *_humanId = [_dataSource safeObjectAtIndex:indexPath.row];
    [_dataSource removeObjectAtIndex:indexPath.row];
    PYGlobalDataCache *_gdc = [PYGlobalDataCache gdcWithIdentify:kHumanInfoCache];
    
    // Update the list
    [_gdc setObject:_dataSource forKey:kHumanList];
    
    // Delete the specified data.
    [_gdc setObject:nil forKey:_humanId];
    
    [tableView deleteRowsAtIndexPaths:@[indexPath]
                     withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
