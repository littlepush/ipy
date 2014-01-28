//
//  PYViewController.m
//  CoreDemo
//
//  Created by Push Chen on 7/26/13.
//  Copyright (c) 2013 PushLab. All rights reserved.
//

#import "PYViewController.h"
#import "PYCore.h"

@interface PYViewController ()

@end

@implementation PYViewController

- (void)_noArgument
{
    PYLog(@"No argument");
}

- (void)_oneArgument:(id)arg
{
    PYLog(@"One Argument");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self tryPerformSelector:@selector(_noArgument) withObject:self];
    NSLog(@"%@", [[@"DC4833E2-7E21-46EF-B929-FA2CE293BCB5" md5sum] uppercaseString]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
