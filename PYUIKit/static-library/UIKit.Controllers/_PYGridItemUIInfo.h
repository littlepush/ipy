//
//  _PYGridItemUIInfo.h
//  PYUIKit
//
//  Created by Push Chen on 11/19/13.
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

#import <Foundation/Foundation.h>

@interface _PYGridItemUIInfo : NSObject

@property (nonatomic, strong)   UIColor             *backgroundColor;
@property (nonatomic, strong)   UIImage             *backgroundImage;
@property (nonatomic, strong)   UIColor             *borderColor;
@property (nonatomic, assign)   CGFloat             borderWidth;

@property (nonatomic, strong)   UIImage             *iconImage;
@property (nonatomic, strong)   UIImage             *indicateImage;

// Cell Shadow
@property (nonatomic, assign)   CGSize              shadowOffset;
@property (nonatomic, assign)   CGFloat             shadowOpacity;
@property (nonatomic, assign)   CGFloat             shadowRadius;
@property (nonatomic, strong)   UIColor             *shadowColor;

// Title Info
@property (nonatomic, copy)     NSString            *titleText;
@property (nonatomic, strong)   UIColor             *textColor;
@property (nonatomic, strong)   UIFont              *textFont;

// Title Shadow
@property (nonatomic, assign)   CGSize              textShadowOffset;
@property (nonatomic, assign)   CGFloat             textShadowRadius;
@property (nonatomic, strong)   UIColor             *textShadowColor;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
