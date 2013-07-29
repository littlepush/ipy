//
//  PYLabel.h
//  PYUIKit
//
//  Created by Push Chen on 7/30/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import "PYView.h"
#import "PYLabelLayer.h"

@interface PYLabel : PYView

@property (nonatomic, readonly) PYLabelLayer        *layer;

// Export the properties from label layer
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
