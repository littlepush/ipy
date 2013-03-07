//
//  rtViewController.m
//  Richtext
//
//  Created by Push Chen on 1/31/13.
//  Copyright (c) 2013 Push Chen. All rights reserved.
//

#import "rtViewController.h"

@interface rtViewController ()

@end

@implementation rtViewController

@synthesize inputSource, richLabel;

- (void)dealloc
{
	self.inputSource = nil;
	self.richLabel = nil;
	
	[super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.richLabel.linkClickBlock = ^(NSString *link, NSString *address){
		NSLog(@"click %@", address);
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:address]];
	};
	
	RichText *_text = [RichText textWithString:@"蜻蜓.fm "];
	_text.address = @"http://www.qingting.fm";
	[self.richLabel appendRichText:_text];
	
	RichText *_imageText = [RichText textWithString:@"[4_org]"];
	_imageText.image = [UIImage imageNamed:@"4_org.png"];
	[self.richLabel appendRichText:_imageText];
	
	RichText *_normal = [RichText textWithString:@" normal statement here"];
	_normal.textColor = [UIColor darkGrayColor];
	[self.richLabel appendRichText:_normal];
	
	NSLog(@"rich text: %@", self.richLabel.text);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
	[self.inputSource becomeFirstResponder];
}

- (void)inputChanged:(id)sender
{
	[self.richLabel setText:inputSource.text];
}

@end
