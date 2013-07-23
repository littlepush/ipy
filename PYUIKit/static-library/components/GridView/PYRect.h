//
//  PYRect.h
//  PYUIKit
//
//  Created by Push Chen on 5/19/13.
//  Copyright (c) 2013 Markphone Culture Media Co.Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifndef PYUIKit_PYRect_h
#define PYUIKit_PYRect_h

#ifdef __cplusplus
extern "C" {
#endif

    // Compare if two rect is excatelly same
    BOOL CGRectComp( CGRect r1, CGRect r2 );
    
    // if rect [in] is inside [out]
    BOOL CGRectInside( CGRect _in, CGRect _out );
    
    // Check if two rect is joined
    BOOL CGRectJoined( CGRect r1, CGRect r2 );
    
    // Get the joined rect
    CGRect CGRectCrop( CGRect r1, CGRect r2, BOOL _upSide );
    
    // Combine two rect
    CGRect CGRectCombine( CGRect r1, CGRect r2 );
        
#ifdef __cplusplus
}
#endif
        
#endif
