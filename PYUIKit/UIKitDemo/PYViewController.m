//
//  PYViewController.m
//  UIKitDemo
//
//  Created by Push Chen on 7/27/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import "PYViewController.h"
#import "PYPhotoListCell.h"

@interface PYViewController ()

@end

@implementation PYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    PYResponderView *_rView = [[PYResponderView alloc]
//                               initWithFrame:CGRectMake(100, 100, 100, 100)];
//    [_rView setBackgroundColor:[UIColor randomColor]];
//    [self.view addSubview:_rView];
    _tableView = [UITableView object];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    CGRect _tf = [UIScreen mainScreen].applicationFrame;
    _tf.origin.x = 0.f;
    _tf.origin.y = 0.f;
    [_tableView setFrame:_tf];
    [self.view addSubview:_tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [PYPhotoListCell cellHeightForContentIdentify:@"Test"];
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const _identify = @"RTPhotoListCellIdentify";
    UITableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:_identify];
    if ( _cell == nil ) {
        _cell = [[PYPhotoListCell alloc]
                 initWithStyle:UITableViewCellStyleDefault
                 reuseIdentifier:_identify];
        [_cell tryPerformSelector:@selector(cellJustBeenCreated)];
        [_cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return _cell;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PYPhotoListCell *_cell = (PYPhotoListCell *)cell;
    [_cell rendCellContentWithIdentify:PYIntToString(indexPath.row)];
}

@end
