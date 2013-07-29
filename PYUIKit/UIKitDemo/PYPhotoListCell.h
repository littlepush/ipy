//
//  PYPhotoListCell.h
//  PYUIKit
//
//  Created by Push Chen on 7/29/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PYPhotoListCell : UITableViewCell
{
    PYImageView                         *_contentImageView;
    PYImageLayer                        *_shadowLayer;
}

// Get the cell's height with specified content identify
+ (CGFloat)cellHeightForContentIdentify:(NSString *)contentIdentify;

// Rend the cell
- (void)rendCellContentWithIdentify:(NSString *)contentIdentify;

// Cell just been create, to initialize some actions or controllers
- (void)cellJustBeenCreated;

@end
