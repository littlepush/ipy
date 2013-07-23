//
//  CGRect.c
//  PYUIKit
//
//  Created by Push Chen on 5/19/13.
//  Copyright (c) 2013 Markphone Culture Media Co.Ltd. All rights reserved.
//

#include <stdio.h>
#include "PYRect.h"

// Compare if two rect is excatelly same
BOOL CGRectComp( CGRect r1, CGRect r2 )
{
    return (r1.origin.x == r2.origin.x &&
            r1.origin.y == r2.origin.y &&
            r1.size.width == r2.size.width &&
            r1.size.height == r2.size.height);
}

// if rect [in] is inside [out]
BOOL CGRectInside( CGRect _in, CGRect _out )
{
    return (_in.origin.x >= _out.origin.x &&
            _in.origin.y >= _out.origin.y &&
            (_in.size.width + _in.origin.x) <= (_out.size.width + _out.origin.x) &&
            (_in.size.height + _in.origin.y) <= (_out.size.height + _out.origin.y));
}

// Check if two rect is joined
BOOL CGRectJoined( CGRect r1, CGRect r2 )
{
    CGPoint _c1 = CGPointMake(r1.origin.x + r1.size.width / 2,
                              r1.origin.y + r1.size.height / 2);
    CGPoint _c2 = CGPointMake(r2.origin.x + r2.size.width / 2,
                              r2.origin.y + r2.size.height / 2);
    
    BOOL _widthCheck = (ABS(_c2.x - _c1.x) <= ((r1.size.width + r2.size.width) / 2));
    BOOL _heightCheck = (ABS(_c2.y - _c1.y) <= ((r1.size.height + r2.size.height) / 2));
    return ( _widthCheck && _heightCheck );
}

// Get the joined rect
CGRect CGRectCrop( CGRect r1, CGRect r2, BOOL upSide )
{
    CGPoint _origin = CGPointMake(MAX(r1.origin.x, r2.origin.x),
                                  MAX(r1.origin.y, r2.origin.y));
    if ( CGRectJoined(r1, r2) ) {
        CGFloat _w2 = MIN(r1.origin.x + r1.size.width, r2.origin.x + r2.size.width) - _origin.x;
        CGFloat _h2 = MIN(r1.origin.y + r1.size.height, r2.origin.y + r2.size.height) - _origin.y;
        
        return CGRectMake(_origin.x, _origin.y, _w2, _h2);
    } else {
        if ( upSide == YES ) {
            CGPoint _origin2 = CGPointMake(MIN(r1.origin.x + r1.size.width, r2.origin.x + r2.size.width),
                                           MIN(r1.origin.y + r1.size.height, r2.origin.y + r2.size.height));
            return CGRectMake(_origin2.x, _origin2.y, 0, 0);
        } else {
            return CGRectMake(_origin.x, _origin.y, 0, 0);
        }
    }
}

// Combine two rect
CGRect CGRectCombine( CGRect r1, CGRect r2 )
{
    CGFloat _x = MIN(r1.origin.x, r2.origin.x);
    CGFloat _y = MIN(r1.origin.y, r2.origin.y);
    
    CGFloat _w = MAX(r1.origin.x + r1.size.width, r2.origin.x + r2.size.width) - _x;
    CGFloat _h = MAX(r1.origin.y + r1.size.height, r2.origin.y + r2.size.height) - _y;
    return CGRectMake(_x, _y, _w, _h);
}
