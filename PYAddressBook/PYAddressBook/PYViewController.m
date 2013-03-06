//
//  PYViewController.m
//  PYAddressBook
//
//  Created by littlepush on 9/19/12.
//  Copyright (c) 2012 PushLab. All rights reserved.
//

#import "PYViewController.h"
#import "PYMultipleAddressBookViewController.h"

@interface PYViewController ()

@end

@implementation PYViewController

@synthesize addressBook;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.addressBook = [[PYMultipleAddressBookViewController object] retain];
	[self.addressBook.view setFrame:self.view.frame];
	[self.view addSubview:self.addressBook.view];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
