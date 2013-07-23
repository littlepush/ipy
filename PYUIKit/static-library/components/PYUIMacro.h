//
//  PYUIMacro.h
//  PYUIKit
//
//  Created by Chen Push on 3/11/13.
//  Copyright (c) 2013 Markphone Culture Media Co.Ltd. All rights reserved.
//

#ifndef PYUIKit_PYUIMacro_h
#define PYUIKit_PYUIMacro_h

#define PYIsRetina                                                  \
    ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]	\
    && [[UIScreen mainScreen] scale] == 2.0)

#endif
