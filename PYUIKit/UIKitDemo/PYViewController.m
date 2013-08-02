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

- (void)_actionRViewTapHandler:(id)sender
{
    PYLog(@"Tap event handler");
}

- (void)_actionRViewPressHandler:(id)sender
{
    PYLog(@"Press event handler");
}

- (void)_actionRViewRotateHandler:(PYResponderView *)rview event:(PYViewEvent *)event
{
    //PYLog(@"Receive rotate event.");
    //DUMPFloat(event.rotateDeltaArc);
    rview.transform = CGAffineTransformRotate(rview.transform, event.rotateDeltaArc);
}

- (void)_actionRViewPinchHandler:(PYResponderView *)rview event:(PYViewEvent *)event
{
    //DUMPFloat(event.pinchRate);
    CGRect _pinchFrame = rview.frame;
    CGSize _originSize = _pinchFrame.size;
    _pinchFrame.size.width *= event.pinchRate;
    _pinchFrame.size.height *= event.pinchRate;
    _pinchFrame.origin.x -= (_pinchFrame.size.width - _originSize.width) / 2;
    _pinchFrame.origin.y -= (_pinchFrame.size.height - _originSize.height) / 2;
    [rview setFrame:_pinchFrame];
    rview.transform = CGAffineTransformScale(rview.transform, event.pinchRate, event.pinchRate);
    _pinchFrame.origin.y += 280;
    [_imageView setFrame:_pinchFrame];
}

- (void)_actionRViewTouchEndHandler:(PYResponderView *)rview event:(PYViewEvent *)event
{
    [(PYImageView *)rview refreshContent];
}

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
    
    PYImageView *_rView = [[PYImageView alloc]
                           initWithFrame:CGRectMake(50, 100, 240, 180)];
    [_rView setContentMode:UIViewContentModeScaleAspectFit];
    [_rView setImageUrl:@"http://www.wallsfeed.com/wp-content/uploads/2012/10/Sexy-Alina-Vacariu-Romania.jpg"];
    [_rView setEvent:PYResponderEventTap withRestraint:PYResponderRestraintDoubleTap];
    [_rView setEvent:PYResponderEventPress withRestraint:PYResponderRestraintOneFingerPress];
    [_rView setEvent:PYResponderEventRotate withRestraint:PYResponderRestraintRotateDefault];
    //[_rView setEvent:PYResponderEventPinch withRestraint:PYResponderRestraintPinchDefault];
    
    [_rView addTarget:self
               action:@selector(_actionRViewTapHandler:)
    forResponderEvent:PYResponderEventTap];
    [_rView addTarget:self
               action:@selector(_actionRViewPressHandler:)
    forResponderEvent:PYResponderEventPress];
    [_rView addTarget:self
               action:@selector(_actionRViewRotateHandler:event:)
    forResponderEvent:PYResponderEventRotate];
    [_rView addTarget:self
               action:@selector(_actionRViewPinchHandler:event:)
    forResponderEvent:PYResponderEventPinch];
    [_rView addTarget:self
               action:@selector(_actionRViewTouchEndHandler:event:)
    forResponderEvent:PYResponderEventTouchEnd];
    [self.view addSubview:_rView];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 380, 240, 180)];
    [_imageView setImage:_rView.image];
    [_imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:_imageView];
    
    PYLog(@"Image View Layer: %@", NSStringFromClass([_imageView.layer class]));
    PYLog(@"Image View sublayers: %@", [_imageView.layer sublayers]);
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
    return 100;
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
