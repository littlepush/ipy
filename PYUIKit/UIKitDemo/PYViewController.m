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

- (void)_actionRViewSwipeHandler:(PYResponderView *)rview event:(PYViewEvent *)event
{
    DUMPInt(event.swipeSide);
}

- (void)_actionRViewTouchEndHandler:(PYResponderView *)rview event:(PYViewEvent *)event
{
    [(PYImageView *)rview refreshContent];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    /*
    _tableView = [UITableView object];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    CGRect _tf = [UIScreen mainScreen].bounds;
    _tf.origin.x = 0.f;
    _tf.origin.y = 0.f;
    [_tableView setFrame:_tf];
    [self.view addSubview:_tableView];
    
    PYScrollView *_scrollView = [PYScrollView object];
    [_scrollView setFrame:CGRectMake(0, 0, 320.f, 480.f)];
    [_scrollView setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:_scrollView];
    
    for ( int i = 0; i < 5; ++i ) {
        PYView *_s = [PYView object];
        [_s setFrame:CGRectMake(0, 120 * i, 320, 120)];
        [_s setBackgroundColor:[UIColor randomColor]];
        [_scrollView addSubview:_s];
    }
    [_scrollView setScrollSide:PYScrollVerticalis];
    [_scrollView setContentSize:CGSizeMake(320.f, 120 * 5)];
    [_scrollView setAlwaysBounceVertical:YES];
    [_scrollView setPagable:YES];
    [_scrollView setPageSize:CGSizeMake(320.f, 120.f)];
     */
    
    _pyTableView = [PYTableView object];
    [_pyTableView setDataSource:self];
    CGRect _tf = [UIScreen mainScreen].bounds;
    [_pyTableView setFrame:_tf];
    [_pyTableView setLoopEnabled:YES];
    [_pyTableView setPageSize:CGSizeMake(320.f, 120.f)];
    [_pyTableView setPagable:YES];
    [self.view addSubview:_pyTableView];
    
    NSTimer *_timer = [NSTimer scheduledTimerWithTimeInterval:3.f
                                                       target:self
                                                     selector:@selector(_testTimerHandler:)
                                                     userInfo:nil
                                                      repeats:YES];
}

- (void)_testTimerHandler:(id)sender
{
    [_pyTableView scrollToNextPage:YES];
}

//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}
//
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

- (NSInteger)pytableViewNumberOfRows:(PYTableView *)tableView
{
    return 10;
}

- (CGFloat)pytableView:(PYTableView *)tableView heightForRowAtIndex:(NSInteger)index
{
    return 120.f;
}

- (PYTableViewCell *)pytableView:(PYTableView *)tableView cellForRowAtIndex:(NSInteger)index
{
    static NSString *const _identify = @"TestContentCell";
    PYTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:_identify];
    if ( _cell == nil ) {
        _cell = [[PYTableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault
                 reuseIdentifier:_identify];
        [_cell setBackgroundColor:[UIColor randomColor]];
    }
    return _cell;
}

@end
