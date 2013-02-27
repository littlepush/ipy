//
//  UIBarButtonItem+CustomizedImage.h
//  TuitaAnimation
//
//  Created by Push Chen on 1/30/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define __BBI_CONN_BASIC( x, y )				x##y
#define __BBI_CONN(x, y)						__BBI_CONN_BASIC(x, y)
#define BBIConn									__BBI_CONN

#define BBIDirectionLeft						Left
#define BBIDirectionRight						Right
#define BBISetNavImagedButton( nav, image, rate, selector, lr )					\
	UIBarButtonItem *BBIConn( _bbitem, __LINE__ ) = [[[UIBarButtonItem alloc]	\
													 initWithImage:image		\
													 scaleRate: rate			\
													 target:self				\
													 action:selector]			\
													autorelease];				\
	[nav.topItem BBIConn( BBIConn( set, lr ), BarButtonItem ):					\
		BBIConn( _bbitem, __LINE__ )]

#define BBISetHalfImagedButton( nav, image, selector, lr )	\
	BBISetNavImagedButton( nav, image, 0.5, selector, lr )
#define BBISetHalfLeftImagedButton( nav, image, selector )	\
	BBISetHalfImagedButton( nav, image, selector, BBIDirectionLeft )
#define BBISetHalfRightImagedButton( nav, image, selector )	\
	BBISetHalfImagedButton( nav, image, selector, BBIDirectionRight )
#define BBISetHalfImagedButtonByName( nav, imageName, selector, lr )	\
	BBISetHalfImagedButton( nav, ([UIImage imageNamed:imageName]), selector, lr )
#define BBISetHalfLeftImagedButtonByName( nav, imageName, selector )	\
	BBISetHalfImagedButtonByName( nav, imageName, selector, BBIDirectionLeft )
#define BBISetHalfRightImagedButtonByName( nav, imageName, selector )	\
	BBISetHalfImagedButtonByName( nav, imageName, selector, BBIDirectionRight )

@interface UIBarButtonItem(CustomizedImage)

// Init the UIBarButtonItem with an image.
-(UIBarButtonItem *)initWithImage:(UIImage *)image 
						   target:(id)target 
						   action:(SEL)selector;

-(UIBarButtonItem *)initWithImage:(UIImage *)image 
						scaleRate:(CGFloat)rate
						   target:(id)target 
						   action:(SEL)selector;

-(UIBarButtonItem *)initWithImage:(UIImage *)image
						scaleRate:(CGFloat)rate 
						title:(NSString*)title
						target:(id)target 
						action:(SEL)selector;
@end
