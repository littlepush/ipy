//
//  PYNavViewController.m
//  PYUIKit
//
//  Created by Push Chen on 11/25/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

/*
 LISENCE FOR IPY
 COPYRIGHT (c) 2013, Push Chen.
 ALL RIGHTS RESERVED.
 
 REDISTRIBUTION AND USE IN SOURCE AND BINARY
 FORMS, WITH OR WITHOUT MODIFICATION, ARE
 PERMITTED PROVIDED THAT THE FOLLOWING CONDITIONS
 ARE MET:
 
 YOU USE IT, AND YOU JUST USE IT!.
 WHY NOT USE THIS LIBRARY IN YOUR CODE TO MAKE
 THE DEVELOPMENT HAPPIER!
 ENJOY YOUR LIFE AND BE FAR AWAY FROM BUGS.
 */

#import "PYNavViewController.h"

@interface PYNavViewController ()

@end

@implementation PYNavViewController

@dynamic navigationController;
- (PYNavigationController *)navigationController
{
    return (PYNavigationController *)[super navigationController];
}

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    if ( [PYLayer isDebugEnabled] ) {
        __formatLogLine(__FILE__, __FUNCTION__, __LINE__,
                        [NSString stringWithFormat:@"***[%@:%p] Dealloced***",
                         NSStringFromClass([self class]), self]);
    }
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
