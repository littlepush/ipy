//
//  PYComponentView.h
//  pyutility-uitest
//
//  Created by Push Chen on 6/5/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PYComponentViewInitChecking		\
	if ( _initialed ) return;			\
	_initialed = YES;

/*
 Component Baisc View of PYUtility Framework
 */
@interface PYComponentView : UIView
{
	BOOL			_initialed;
}

/* the property to tell if the view has benn initialized by customized code. */
@property (nonatomic, readonly)	BOOL IsInitialed;

/* one should never invoke this message manually. */
-(void) internalInitial;

@end

/* A view responsed for the touch up inside event */
@interface PYTouchView : UIControl
{
	BOOL			_initialed;
}

/* the property to tell if the view has benn initialized by customized code. */
@property (nonatomic, readonly)	BOOL IsInitialed;

/* one should never invoke this message manually. */
-(void) internalInitial;

@end