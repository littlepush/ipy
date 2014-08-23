//
//  PYViewController.m
//  UIKitDemo
//
//  Created by Push Chen on 7/27/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import "PYViewController.h"
#import "PYPhotoListCell.h"
#import <objc/runtime.h>
#import "PYUIKit.h"
#import "PYCoverFlowViewController.h"

@interface PYTestCell : UITableViewCell< PYTableCell >

@end

@implementation PYTestCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self.textLabel setFont:[UIFont systemFontOfSize:18.f]];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

+ (NSNumber *)heightOfCellWithSpecifiedContentItem:(id)contentItem
{
    return @44;
}

- (void)rendCellWithSpecifiedContentItem:(id)contentItem
{
    [self.textLabel setText:contentItem];
}

@end

@interface PYViewController ()

@end

@implementation PYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _testList = [UITableView object];
    [_testList setFrame:self.view.bounds];
    
    //[self.view addSubview:_testList];
    
    _manager = [UITableManager object];
    [_manager bindTableView:_testList];
    
    _manager.identify = @"TestManager";
    [_manager bindTableView:_testList withDataSource:@[@"1", @"2", @"3"]];
    _manager.defaultTarget = self;
    [_manager setDefaultCellClass:[PYTestCell class]];
    
    //[_manager reloadTableDataWithMultipleSectionDataSource:@[@[@"1", @"2", @"3"]]];
    //[_manager reloadTableDataWithDataSource:@[@"1", @"2", @"3"]];
    
    _cycle = [PYCycleProgress layer];
    [_cycle setMaxValue:100];
    
    [_cycle setProgressBarWidth:10.f];
    [_cycle setProgressBarColor:[UIColor randomColor]];
    [_cycle setBorderWidth:1.f];
    [_cycle setBorderColor:[UIColor blackColor].CGColor];
    
    [_cycle setFrame:CGRectMake(100, 100, 100, 100)];
    //[self.view.layer addSublayer:_cycle];
    
    [self.view setBackgroundColor:[UIColor randomColor]];
    _sLayer = [CAShapeLayer layer];
    /*
    [_sLayer setFrame:CGRectMake(100, 100, 50, 50)];
    [_sLayer setFillColor:[UIColor clearColor].CGColor];
    [_sLayer setPath:[UIBezierPath
                      bezierPathWithArcCenter:CGPointMake(25.f, 25.f)
                      radius:25
                      startAngle:0
                      endAngle:2 * M_PI
                      clockwise:YES].CGPath];
    
    [_sLayer setStrokeColor:[UIColor randomColor].CGColor];
    [_sLayer setLineWidth:10.f];
    [_sLayer setBackgroundColor:[UIColor clearColor].CGColor];
    [self.view.layer addSublayer:_sLayer];
     */
    
    // Two layers is better
    [_sLayer setFrame:CGRectMake(0, 100, 320, 100)];
    [_sLayer setBorderWidth:1.f];
    [_sLayer setBorderColor:[UIColor blackColor].CGColor];
    [_sLayer setFillColor:[UIColor colorWithOptionString:@"v(100)$#FFFFFF^0.3:#FFFFFF^0.0" reverseOnVerticalis:YES].CGColor];
    [_sLayer setStrokeColor:[UIColor whiteColor].CGColor];
    UIBezierPath *_bp = [UIBezierPath bezierPath];
    [_bp moveToPoint:CGPointMake(0, 49.f)];
    [_bp addLineToPoint:CGPointMake(40, 55.f)];
    [_bp addLineToPoint:CGPointMake(80, 23.f)];
    [_bp addLineToPoint:CGPointMake(120, 76.5f)];
    [_bp addLineToPoint:CGPointMake(160, 66.f)];
    [_bp addLineToPoint:CGPointMake(200, 84.f)];
    [_bp addLineToPoint:CGPointMake(280, 33.f)];
    [_bp addLineToPoint:CGPointMake(320, 69.4f)];
    [_bp addLineToPoint:CGPointMake(320, 100)];
    [_bp addLineToPoint:CGPointMake(0, 100)];
    [_bp closePath];
    [_sLayer setPath:_bp.CGPath];
    [_sLayer setLineWidth:3.f];
    [_sLayer setBackgroundColor:[UIColor clearColor].CGColor];
    [self.view.layer addSublayer:_sLayer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CABasicAnimation *_valueAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    _valueAnimation.fromValue = @(0.f);
    _valueAnimation.toValue = @(1.f);
    _valueAnimation.duration = 3.f;
    [_sLayer addAnimation:_valueAnimation forKey:@"valueChangeAnimation"];
}

- (void)PYEventHandler(TestManager, PYTableManagerEventCreateNewCell)
{
    UITableViewCell *_cell = (UITableViewCell *)obj1;
    [_cell setBackgroundColor:[UIColor randomColor]];
}

- (void)PYEventHandler(TestManager, PYTableManagerEventSelectCell)
{
    //UITableViewCell *_cell = (UITableViewCell *)sender;
    NSIndexPath *_indexPath = (NSIndexPath *)obj2;
    [_testList deselectRowAtIndexPath:_indexPath animated:YES];
    [PYHUDView displayMessage:PYIntToString(_indexPath.row) duration:1.5f];
}

- (NSNumber *)PYEventHandler(TestManager, UITableManagerEventCanDeleteCell)
{
    return @(YES);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
