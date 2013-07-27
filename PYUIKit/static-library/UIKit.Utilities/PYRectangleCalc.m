//
//  PYRectangleCalc.c
//  PYUIKit
//
//  Created by Push Chen on 7/24/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#include <stdio.h>
#include "PYUIKitMacro.h"
#include "PYRectangleCalc.h"

const PYPadding PYPaddingZero = (PYPadding){0, 0, 0, 0};

// Create a shadow rect
PYPadding PYPaddingMake(CGFloat l, CGFloat r, CGFloat t, CGFloat b)
{
    return (PYPadding){l, r, t, b};
}

// Create a shadow rect with all same padding size
PYPadding PYPaddingWithPadding(CGFloat p)
{
    return (PYPadding){p, p, p, p};
}

// Create a shadow rect with only top
PYPadding PYPaddingOnTop(CGFloat t)
{
    return (PYPadding){0, 0, t, 0};
}

// Compare two shadow rect
BOOL PYPaddingCompare(PYPadding p1, PYPadding p2)
{
    return (PYFLOATEQUAL(p1.left, p2.left) &&
            PYFLOATEQUAL(p1.right, p2.right) &&
            PYFLOATEQUAL(p1.top, p2.top) &&
            PYFLOATEQUAL(p1.bottom, p2.bottom));
}

// Check if the shadow rect is zero
BOOL PYPaddingIsZero(PYPadding padding)
{
    return PYPaddingCompare(padding, PYPaddingZero);
}

// Compare if two rect is excatelly same
BOOL PYRectComp( CGRect r1, CGRect r2 )
{
    return (r1.origin.x == r2.origin.x &&
            r1.origin.y == r2.origin.y &&
            r1.size.width == r2.size.width &&
            r1.size.height == r2.size.height);
}

// if rect [in] is inside [out]
BOOL PYIsRectInside( CGRect _in, CGRect _out )
{
    return (_in.origin.x >= _out.origin.x &&
            _in.origin.y >= _out.origin.y &&
            (_in.size.width + _in.origin.x) <= (_out.size.width + _out.origin.x) &&
            (_in.size.height + _in.origin.y) <= (_out.size.height + _out.origin.y));
}

// Check if two rect is joined
BOOL PYIsRectJoined( CGRect r1, CGRect r2 )
{
    CGPoint _c1 = (CGPoint){
        (r1.origin.x + r1.size.width / 2),
        (r1.origin.y + r1.size.height / 2)
    };
    CGPoint _c2 = (CGPoint){
        (r2.origin.x + r2.size.width / 2),
        (r2.origin.y + r2.size.height / 2)
    };
    
    BOOL _widthCheck = (ABS(_c2.x - _c1.x) <= ((r1.size.width + r2.size.width) / 2));
    BOOL _heightCheck = (ABS(_c2.y - _c1.y) <= ((r1.size.height + r2.size.height) / 2));
    return ( _widthCheck && _heightCheck );
}

// Get the joined rect
void PYRectCrop( CGRect r1, CGRect r2, CGRect *_out )
{
    if ( _out == NULL ) return;
    if ( !PYIsRectJoined(r1, r2) ) {
        return;
    }
    
    CGPoint _origin = CGPointMake(MAX(r1.origin.x, r2.origin.x),
                                  MAX(r1.origin.y, r2.origin.y));
    CGFloat _w2 = MIN(r1.origin.x + r1.size.width, r2.origin.x + r2.size.width) - _origin.x;
    CGFloat _h2 = MIN(r1.origin.y + r1.size.height, r2.origin.y + r2.size.height) - _origin.y;
    
    *_out = CGRectMake(_origin.x, _origin.y, _w2, _h2);
}

// Combine two rect
CGRect PYRectCombine( CGRect r1, CGRect r2 )
{
    CGFloat _x = MIN(r1.origin.x, r2.origin.x);
    CGFloat _y = MIN(r1.origin.y, r2.origin.y);
    
    CGFloat _w = MAX(r1.origin.x + r1.size.width, r2.origin.x + r2.size.width) - _x;
    CGFloat _h = MAX(r1.origin.y + r1.size.height, r2.origin.y + r2.size.height) - _y;
    return CGRectMake(_x, _y, _w, _h);
}
