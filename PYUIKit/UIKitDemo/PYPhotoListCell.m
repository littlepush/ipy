//
//  PYPhotoListCell.m
//  PYUIKit
//
//  Created by Push Chen on 7/29/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import "PYPhotoListCell.h"

static NSString *_networkImages[10];

@implementation PYPhotoListCell

+ (void)initialize
{
    _networkImages[0] = @"http://images4.fanpop.com/image/photos/23800000/adriana-lima-sexy-victorias-secret-angels-23864997-931-647.jpg";
    _networkImages[1] = @"http://www.freephoto.in/photo/var/albums/Sexy_Girl9005.jpg?m=1365945495";
    _networkImages[2] = @"http://www.wallsfeed.com/wp-content/uploads/2012/10/Sexy-Alina-Vacariu-Romania.jpg";
    _networkImages[3] = @"http://hookupp.weebly.com/uploads/1/9/8/2/19828033/9919501_orig.jpeg";
    _networkImages[4] = @"http://4.bp.blogspot.com/-R0tOzx4jjhE/UbbBfjmqkeI/AAAAAAAABFs/wMjiOmoW1WM/s400/girls-920-26.jpg";
    _networkImages[5] = @"http://www.wallsave.com/wallpapers/1920x1200/most-beautiful-girls/1254563/most-beautiful-girls-1254563.jpg";
    _networkImages[6] = @"http://cdn.hitfix.com/photos/2892790/Selena-Gomez-and-the-bad-girls-of-Spring-Breakers.jpg";
    _networkImages[7] = @"http://static.hothdwallpaper.net/51baa511ad24454887.jpg";
    _networkImages[8] = @"http://wallpaper.piicss.com/wp-content/uploads/2013/01/wallpaper-HD-Girls-612.jpg";
    _networkImages[9] = @"http://hdwallpaper9.com/wp-content/uploads/2012/12/beautiful_girls_17-wallpaper-1920x1080.jpg";
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if ( newSuperview != nil ) return;
    [_contentImageView setImage:nil];
}

// Get the cell's height with specified content identify
+ (CGFloat)cellHeightForContentIdentify:(NSString *)contentIdentify
{
    return 330.f;
}

// Rend the cell
- (void)rendCellContentWithIdentify:(NSString *)contentIdentify
{
    [_contentImageView setAlpha:0.f];
    
    [UIView animateWithDuration:.3 animations:^{
        [_contentImageView setImageUrl:_networkImages[[contentIdentify intValue]]];
        [_contentImageView setAlpha:1.f];
    }];
}

// Cell just been create, to initialize some actions or controllers
- (void)cellJustBeenCreated
{
    _contentImageView = [PYImageView object];
    [_contentImageView setFrame:CGRectMake(10.f, 10.f, 300.f, 300.f)];
    [_contentImageView setBackgroundColor:[UIColor colorWithWhite:.75 alpha:.5]];
    [_contentImageView setDropShadowColor:[UIColor darkGrayColor]];
    [_contentImageView setDropShadowOffset:CGSizeMake(0, 7.f)];
    [_contentImageView setDropShadowOpacity:.7f];
    [_contentImageView setDropShadowRadius:7.f];
    [_contentImageView setDropShadowPath:[UIBezierPath bezierPathWithRect:_contentImageView.bounds]];
    [self addSubview:_contentImageView];
    
    //    _shadowLayer = [PYImageLayer layerWithPlaceholdImage:[UIImage imageNamed:@"photo.shadow.png"]];
    //    [_shadowLayer setFrame:CGRectMake(10, 310, 300, 20)];
    //    [self.layer addSublayer:_shadowLayer];
}

@end
