//
//  PYViewController.m
//  PYDataDemo
//
//  Created by Push Chen on 5/9/14.
//  Copyright (c) 2014 PushLab. All rights reserved.
//

#import "PYViewController.h"
#import "PYHumanListViewController.h"

@interface PYViewController ()

@end

@implementation PYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    PYHumanListViewController *_humanListVC = [PYHumanListViewController object];
    _rootNav = [[UINavigationController alloc] initWithRootViewController:_humanListVC];
    [self.view addSubview:_rootNav.view];
    [self addChildViewController:_rootNav];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
