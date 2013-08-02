//
//  PYLabel.h
//  PYUIKit
//
//  Created by Push Chen on 7/30/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

/*
 LISENCE FOR IPY
 COPYRIGHT (c) 2013, Push Chen.
 ALL RIGHTS RESERVED.
 
 REDISTRIBUTION AND USE IN SOURCE AND BINARY
 FORMS, WITH OR WITHOUT MODIFICATION, ARE
 PERMITTED PROVIDED THAT THE FOLLOWING CONDITIONS
 ARE MET:
 
 YOU USE IT, AND YOU JUST USE IT!.
 WHY NOT USE THIS LIBRARY IN YOUR CODE TO MAKE
 THE DEVELOPMENT HAPPIER!
 ENJOY YOUR LIFE AND BE FAR AWAY FROM BUGS.
 */

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
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
@property (nonatomic, assign)   NSLineBreakMode     lineBreakMode;
#else
@property (nonatomic, assign)   UILineBreakMode     lineBreakMode;
#endif

// Padding the left side.
@property (nonatomic, assign)   CGFloat             paddingLeft;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
