//
//  UIViewController+PopUp.h
//  FootPath
//
//  Created by Push Chen on 3/29/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSlideMenuDirection			@"kSlideMenuDirection"
#define kSlideMenuLayer				@"kSlideMenuLayer"
#define kSlideMenuFollow			@"kSlideMenuFollow"
#define kSlideMenuInAnimation		@"kSlideMenuInAnimation"
#define kSlideMenuOutAnimation		@"kSlideMenuOutAnimation"

typedef enum {
	SlideMenuAnimationTypeScale,
	SlideMenuAnimationTypeFold
} SlideMenuAnimationType;

#define SMAnimationOpt(t, o)		\
	[UISlideMenuAnimationOpt animationType:t opt:o]

@interface UISlideMenuAnimationOpt : NSObject

@property (nonatomic, assign) SlideMenuAnimationType	type;
@property (nonatomic, assign) CGFloat					opt;

+(UISlideMenuAnimationOpt *)animationType:(SlideMenuAnimationType)t opt:(CGFloat)o;

@end


typedef void(^PopUpAnimation)(void);
typedef void(^SlideMenuAnimation)(void);

/*
	UIViewController PopUp Catalog
 */
@interface UIViewController(PopUp)

/* present the pop up view in front of current view with a scale animation. */
-(void) presentPopUpViewController:(UIViewController *)controller animated:(BOOL)animated;

/* present the pop up view in front of current view with a rotate animation. */
-(void) presentRotatePopUpViewController:(UIViewController *)controller 
	duration:(NSTimeInterval)duration;

/* present the pop up view from a specified point */
-(void) presentPopUpViewController:(UIViewController *)controller 
	fromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
	complention:(PopUpAnimation)code;

/* dismiss current popped up view with a scale animation. */
-(void) dismissPopUpViewControllerAnimated:(BOOL)animated;

/* dismiss current popped up view with a rotate animation. */
-(void) dismissRotatePopUpViewControllerDuration:(NSTimeInterval)duration;

/* slide the menu from one direction */
@property (nonatomic, readonly) UIViewController	*slideMenuBaseController;

-(void) presentSlideMenu:(UIViewController*)menuController 
	withOption:(NSDictionary *)option;
	
-(void) presentSlideMenu:(UIViewController*)menuController 
	withOption:(NSDictionary *)option 
	complention:(SlideMenuAnimation)code;

/* dismiss the slide menu */
-(void) dismissSlideMenuViewControllerAnimated:(BOOL)animated;

-(void) dismissSlideMenuViewControllerAnimated:(BOOL)animated 
	complention:(SlideMenuAnimation)code;
	
-(void) slideMenuDidDismissed:(UIViewController *)slideMenu;

@end
