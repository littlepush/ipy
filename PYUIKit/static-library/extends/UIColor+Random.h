//
//  UIColor+Random.h
//  pyutility-uitest
//
//  Created by Push Chen on 6/5/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/* UIColor Random Extend. */
/* use [UIColor randomColor] to return a random color. */

@interface UIColor (Random)

+(UIColor*) randomColor;

+(UIColor*) colorWithString:(NSString *)clrString;

@end
