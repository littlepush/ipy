//
//  PYLabelLayer.h
//  PYRadio
//
//  Created by Push Chen on 3/19/13.
//  Copyright (c) 2013 Markphone Culture Media Co.Ltd. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface PYLabelLayer : CALayer

// Properties like UILabel.
// But all this things will be used to draw text directly in layer.
@property (nonatomic, copy)     NSString            *text;
@property (nonatomic, strong)   UIColor             *textColor;
@property (nonatomic, strong)   UIFont              *textFont;
@property (nonatomic, assign)   CGSize              textShadowOffset;
@property (nonatomic, strong)   UIColor             *textShadowColor;
@property (nonatomic, assign)   CGFloat             textShadowRadius;
@property (nonatomic, assign)   CGFloat             textBorderWidth;
@property (nonatomic, strong)   UIColor             *textBorderColor;

@property (nonatomic, assign)   BOOL                multipleLine;
@property (nonatomic, assign)   NSTextAlignment     textAlignment;
@property (nonatomic, assign)   UILineBreakMode     lineBreakMode;

// Padding the left side.
@property (nonatomic, assign)   CGFloat             paddingLeft;

@end
