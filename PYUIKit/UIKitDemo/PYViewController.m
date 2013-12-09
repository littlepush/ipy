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

@interface PYViewController ()

@end

@implementation PYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *_testPath = [[[NSBundle mainBundle] bundlePath]
                           stringByAppendingPathComponent:@"testFile.txt"];
    NSURL *_testUrl = [NSURL fileURLWithPath:_testPath];
    NSData *_tempData = [PYResource loadDataWithContentsOfFile:[_testUrl absoluteString]];
    DUMPObj(_tempData);
    
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
    [_gridView initGridViewWithScale:(PYGridScale){5, 1}];
    [_gridView setFrame:CGRectMake((320.f - 200.f) / 2, 150.f, 200, 200)];
    [_gridView setPadding:10.f];
    [_gridView setBorderColor:[UIColor blackColor]];
    [_gridView setBorderWidth:1.f];
    
//    [_gridView
//     setItemBackgroundColor:[UIColor colorWithOptionString:@"v(48)$#3787B1:#61BCFF" reverseOnVerticalis:YES]
//     forState:UIControlStateNormal];
    [_gridView
     setItemBackgroundColor:[UIColor colorWithString:@"#FF0000"]
     forState:UIControlStateNormal];
//    [_gridView
//     setItemBackgroundColor:[UIColor colorWithOptionString:@"v(48)$#CCCCCC:#FFFFFF" reverseOnVerticalis:YES]
//     forState:UIControlStateHighlighted];
    [_gridView
     setItemBackgroundColor:[UIColor colorWithString:@"#000000"]
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
//    PYGridItem *_specifialItem = [_gridView itemAtCoordinate:(PYGridCoordinate){1, 0}];
//    if ( _specifialItem != nil ) {
//        [_specifialItem
//         setBackgroundColor:[UIColor colorWithOptionString:@"v(48)$#FFFFFF:#CCCCCC" reverseOnVerticalis:YES]
//         forState:UIControlStateNormal];
//        [_specifialItem setTextColor:[UIColor blackColor] forState:UIControlStateNormal];
//        _specifialItem.collapseRate = 3.f;
//        [_specifialItem setInnerShadowColor:[UIColor redColor] forState:UIControlStateHighlighted];
//        [_specifialItem setInnerShadowRect:PYPaddingMake(10, 10, 15, 0) forState:UIControlStateHighlighted];
//        [_specifialItem setInnerShadowRect:PYPaddingZero forState:UIControlStateNormal];
//    }
//    PYGridItem *_fixedItem = [_gridView itemAtCoordinate:(PYGridCoordinate){0, 0}];
//    _fixedItem.collapseRate = 3;
//    [_gridView mergeGridItemFrom:(PYGridCoordinate){1, 0} to:(PYGridCoordinate){1, 1}];
//    
    [_gridView setItemShadowColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_gridView setItemShadowOffset:CGSizeMake(1, 1) forState:UIControlStateNormal];
    [_gridView setItemShadowRadius:3.f forState:UIControlStateNormal];
    [_gridView setItemShadowOpacity:.7 forState:UIControlStateNormal];
    
    [_gridView setDelegate:self];
    
    UIViewController *_testCtrl = [UIViewController object];
    [_testCtrl.view addSubview:_gridView];

    [self presentPopViewController:_testCtrl];
    
    //[_gridView setSupportTouchMoving:YES];
    //[self.view addSubview:_gridView];
    
    [UIView rendView:self.view withOption:@{@"backgroundColor":@"v(568)$#000000:#CCDDEE"}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pyGridView:(PYGridView *)gridView didSelectItem:(PYGridItem *)item
{
    PYLog(@"Click");
}

@end
