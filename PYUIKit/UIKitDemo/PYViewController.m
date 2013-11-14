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
    [PYResource changeToLoadRemoteResourceWithDomain:@"http://home.pushchen.com:12580/ipy-dev/"];
    _testSlider = [PYSlider object];
    [_testSlider setBackgroundImage:[PYResource imageNamed:@"pb-bkg.png"]];
    [_testSlider setSlideButtonImage:[PYResource imageNamed:@"pb-sbtn.png"]];
    [_testSlider setMinTrackTintImage:[PYResource imageNamed:@"pb-min.png"]];
    [_testSlider setMaximum:100.f];
    [_testSlider setFrame:CGRectMake(10, 40, 300, 31.f)];
    [_testSlider setCurrentValue:99.f animated:NO];
    
    [self.view addSubview:_testSlider];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
