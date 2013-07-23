//
//  PYUIKitMacro.h
//  PYUIKit
//
//  Created by Push Chen on 7/24/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#ifndef PYUIKit_PYUIKitMacro_h
#define PYUIKit_PYUIKitMacro_h

#define PYIsRetina                                                  \
    ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]	\
    && [[UIScreen mainScreen] scale] == 2.0)

// Float Equal
#ifndef PYFLOATEQUAL
#define PYFLOATEQUAL( f1, f2 )                  (ABS((f1) - (f2)) < 0.001)

#endif
