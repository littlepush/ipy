//
//  PYRectangleCalc.h
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

#ifndef PYUIKit_PYRectangleCalc_h
#define PYUIKit_PYRectangleCalc_h

#ifdef __cplusplus
extern "C" {
#endif
    // Inner Shadow Size Structure;
    // For the inner shadow of each side in the view.
    typedef struct {
        CGFloat                 left;
        CGFloat                 right;
        CGFloat                 top;
        CGFloat                 bottom;
    } PYPadding;
    
    // Create a padding object from string
    PYPadding PYPaddingFromString(NSString *string);
    
    // Format the padding object into string.
    NSString *NSStringFromPYPadding(PYPadding padding);
    
    // Create a shadow rect
    PYPadding PYPaddingMake(CGFloat l, CGFloat r, CGFloat t, CGFloat b);
    
    // Create a shadow rect with all same padding size
    PYPadding PYPaddingWithPadding(CGFloat p);

    // Create a shadow rect with only top
    PYPadding PYPaddingOnTop(CGFloat t);
    
    // Compare two shadow rect
    BOOL PYPaddingCompare(PYPadding p1, PYPadding p2);
    
    // Check if the shadow rect is zero
    BOOL PYPaddingIsZero(PYPadding padding);
    
    // The const zero padding
    extern const PYPadding PYPaddingZero;
    
    // Compare if two rect is excatelly same
    BOOL PYRectComp( CGRect r1, CGRect r2 );
    
    // if rect [in] is inside [out]
    BOOL PYIsRectInside( CGRect _in, CGRect _out );
    
    // Check if two rect is joined
    BOOL PYIsRectJoined( CGRect r1, CGRect r2 );
    
    // Get the joined rect
    void PYRectCrop( CGRect r1, CGRect r2, CGRect *_out );
    
    // Combine two rect
    CGRect PYRectCombine( CGRect r1, CGRect r2 );
    
#ifdef __cplusplus
}
#endif

#endif

// @littlepush
// littlepush@gmail.com
// PYLab
