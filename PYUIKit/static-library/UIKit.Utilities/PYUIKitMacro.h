//
//  PYUIKitMacro.h
//  PYUIKit
//
//  Created by Push Chen on 7/24/13.
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

#ifndef PYUIKit_PYUIKitMacro_h
#define PYUIKit_PYUIKitMacro_h

#define PYIsRetina                                                  \
    ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]	\
    && [[UIScreen mainScreen] scale] == 2.0)

// Float Equal
#ifndef PYFLOATEQUAL
#define PYFLOATEQUAL( f1, f2 )                  (PYABSF((f1) - (f2)) < 0.001)
#endif

#endif

// @littlepush
// littlepush@gmail.com
// PYLab
