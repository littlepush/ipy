//
//  PYLibImage.h
//  pyutility-uitest
//
//  Created by Push Chen on 5/15/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  PYLibImageIndexSwitchBkg = 0,
  PYLibImageIndexSwitchBtn = 1,
  PYLibImageIndexNavbarTBkg = 2,
  PYLibImageIndexSlideBkg = 3,
  PYLibImageIndexSlideBtn = 4,
  PYLibImageIndexSlideMin = 5,
  PYLibImageIndexSlideMax = 6,
  PYLibImageCalendarPrevMonth = 7,
  PYLibImageCalendarPrevYear = 8,
  PYLibImageCalendarNextMonth = 9,
  PYLibImageCalendarNextYear = 10,
  PYLibImageCalendarWeekEnd = 11,
  PYLibImageCalendarWeekDay = 12,
  PYLibImageFrameShadowLeft = 13,
  PYLibImageFrameShadowRight = 14
} PYLibImageIndex;

@interface PYLibImage : NSObject

+(UIImage *)imageForKey:(PYLibImageIndex)imgIndex;

@end
