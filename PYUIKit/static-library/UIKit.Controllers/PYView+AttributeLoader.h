//
//  PYView+AttributeLoader.h
//  PYUIKit
//
//  Created by Push Chen on 11/13/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import <PYUIKit/PYUIKit.h>
#import "PYView.h"
#import "PYScrollView.h"
#import "PYTableView.h"
#import "PYSlider.h"
#import "PYSwitcher.h"
#import "PYLabelLayer.h"
#import "PYLabel.h"
#import "PYImageLayer.h"
#import "PYImageView.h"

@interface PYView (AttributeLoader)

+ (void)rendView:(PYView *)view withOption:(NSDictionary *)option;

@end

@interface PYScrollView (AttributeLoader)

+ (void)rendView:(PYScrollView *)scrollView withOption:(NSDictionary *)option;

@end

@interface PYTableView (AttributeLoader)

+ (void)rendView:(PYTableView *)tableView withOption:(NSDictionary *)option;

@end

@interface PYSlider (AttributeLoader)

+ (void)rendView:(PYSlider *)slider withOption:(NSDictionary *)option;

@end

@interface PYSwitcher (AttributeLoader)

+ (void)rendView:(PYSwitcher *)switcher withOption:(NSDictionary *)option;

@end

@interface PYLabelLayer (AttributeLoader)

+ (void)rendLayer:(PYLabelLayer *)labelLayer withOption:(NSDictionary *)option;

@end

@interface PYLabel (AttributeLoader)

+ (void)rendView:(PYLabel *)label withOption:(NSDictionary *)option;

@end

@interface PYImageLayer (AttributeLoader)

+ (void)rendLayer:(PYImageLayer *)imageLayer withOption:(NSDictionary *)option;

@end

@interface PYImageView (AttributeLoader)

+ (void)rendView:(PYImageView *)imageView withOption:(NSDictionary *)option;

@end
