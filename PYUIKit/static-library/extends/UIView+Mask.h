//
//  UIView+Mask.h
//  FootPath
//
//  Created by Push Chen on 3/28/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

/* UIView Mask Statues Observer Names */
#define kUIViewMaskStatuesPopUp		@"kUIViewMaskStatuesPopUp"
#define kUIViewMaskStatuesDismiss	@"kUIViewMaskStatuesDismiss"

/* UIView as a pop up mask. */
@interface UIView(Mask)

/* set the transparency of the mask */
@property (nonatomic, assign) CGFloat transparency;

/* Set the mask color */
@property (nonatomic, assign) UIColor *maskColor;

/* Set if the mask will show */
-(void) setMaskVisible:(BOOL)aVisible;

/* 
	Set if the mask view handle the tap to dismiss event.
	Default is NO.
 */
-(void) setTapGestureDismiss:(BOOL)enabled;

/* Add Observer for mask statue changing. */
//-(void)addObserver:(id)observer action:(SEL)aSelector forStatuesChange:(NSString *)statuesChangeName;

/* remove the observer */
//-(void)removeObserver:(id)observer forStatuesChange:(NSString *)statuesChangeName;

@end
