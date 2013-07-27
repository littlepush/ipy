//
//  PYViewController.m
//  UIKitDemo
//
//  Created by Push Chen on 7/27/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import "PYViewController.h"

@interface PYViewController ()

@end

@implementation PYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    PYResponderView *_rView = [[PYResponderView alloc]
                               initWithFrame:CGRectMake(100, 100, 100, 100)];
    [_rView setBackgroundColor:[UIColor randomColor]];
    [self.view addSubview:_rView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
