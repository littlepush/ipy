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
    
    [PYResource changeToLoadRemoteResourceWithDomain:@"http://home.pushchen.com:12580/ipy-dev/"];
	// Do any additional setup after loading the view, typically from a nib.
    _testSlider = [PYSlider object];
    UIColor *_bkgColor =
    [UIColor colorWithOptionString:
     @"v(24)$"
     @"#000000^0/0:"
     @"#000000^0/.333:"
     @"#000000/.333:"
     @"#000000/.666:"
     @"#000000^0/.666:"
     @"#000000^0/1"];
    [_testSlider setBackgroundColor:_bkgColor];
    UIColor *_minColor =
    [UIColor colorWithOptionString:
     @"v(24)$#"
     @"000000^0/0:"
     @"#000000^0/.375:"
     @"#B3FFFC/.375:"
     @"#B3FFFC/.625:"
     @"#000000^0/.625:"
     @"#000000^0/1"];
    [_testSlider setMinTrackTintColor:_minColor];
    [_testSlider setSlideButtonImage:[PYResource imageNamed:@"slide-button.png"]];
    [_testSlider setMaximum:100.f];
    [_testSlider setFrame:CGRectMake(10, 100, 300, 24.f)];
    [_testSlider setCurrentValue:99.f animated:NO];
    
    [self.view addSubview:_testSlider];
    
    // Test the grid view
    _gridView = [PYGridView object];
    [_gridView initGridViewWithScale:(PYGridScale){2, 2}];
    [_gridView setFrame:CGRectMake((320.f - 252.f) / 2, 150.f, 252.f, 108.f)];
    [_gridView setPadding:4.f];
    
    [_gridView
     setItemBackgroundColor:[UIColor colorWithOptionString:@"v(48)$#3787B1:#61BCFF" reverseOnVerticalis:YES]
     forState:UIControlStateNormal];
    [_gridView
     setItemBackgroundColor:[UIColor colorWithOptionString:@"v(48)$#CCCCCC:#FFFFFF" reverseOnVerticalis:YES]
     forState:UIControlStateHighlighted];
    [_gridView setItemCornerRadius:3.f];
    [_gridView setItemBorderColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_gridView setItemBorderColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [_gridView setItemBorderWidth:1.f forState:UIControlStateNormal];
    [_gridView setItemTextColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [_gridView setItemTextColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_gridView setItemTextFont:[UIFont boldSystemFontOfSize:12.f] forState:UIControlStateNormal];
    for ( PYGridItem *_item in _gridView ) {
        [_item setTitle:[NSString stringWithFormat:@"<%d,%d>",
                         _item.coordinate.x, _item.coordinate.y]
               forState:UIControlStateNormal];
    }
    PYGridItem *_specifialItem = [_gridView itemAtCoordinate:(PYGridCoordinate){1, 0}];
    if ( _specifialItem != nil ) {
        [_specifialItem
         setBackgroundColor:[UIColor colorWithOptionString:@"v(48)$#FFFFFF:#CCCCCC" reverseOnVerticalis:YES]
         forState:UIControlStateNormal];
        [_specifialItem setTextColor:[UIColor blackColor] forState:UIControlStateNormal];
        _specifialItem.collapseRate = 3.f;
    }
    PYGridItem *_fixedItem = [_gridView itemAtCoordinate:(PYGridCoordinate){0, 0}];
    _fixedItem.collapseRate = 3;
    [_gridView mergeGridItemFrom:(PYGridCoordinate){1, 0} to:(PYGridCoordinate){1, 1}];
    
    [_gridView setItemShadowColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_gridView setItemShadowOffset:CGSizeMake(1, 1) forState:UIControlStateNormal];
    [_gridView setItemShadowRadius:3.f forState:UIControlStateNormal];
    [_gridView setItemShadowOpacity:.7 forState:UIControlStateNormal];
    
    [_gridView setSupportTouchMoving:YES];
    [self.view addSubview:_gridView];
    
    [UIView rendView:self.view withOption:@{@"backgroundColor":@"v(568)$#000000:#CCDDEE"}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
