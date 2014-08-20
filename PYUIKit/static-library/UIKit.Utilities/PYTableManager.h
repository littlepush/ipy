//
//  PYTableManager.h
//  PYUIKit
//
//  Created by Push Chen on 8/20/14.
//  Copyright (c) 2014 Push Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PYTableManagerProtocol.h"
#import "PYTableView.h"

@interface PYTableManager : PYActionDispatcher
    <PYTableManagerProtocol, PYTableViewDelegate, PYTableViewDatasource>
{
    
}


@end
