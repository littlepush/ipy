//
//  PYHumanListViewController.h
//  PYDataDemo
//
//  Created by Push Chen on 5/9/14.
//  Copyright (c) 2014 PushLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PYHumanListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    UITableView                         *_humanList;
    
    // Data Source
    NSMutableArray                      *_dataSource;
}

@end
