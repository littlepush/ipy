//
//  UIViewController+PopUp.m
//  FootPath
//
//  Created by Push Chen on 3/29/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "UIViewController+PopUp.h"
#import "UIView+Mask.h"
#import <QuartzCore/QuartzCore.h>
#import "PYLibImage.h"

@implementation UISlideMenuAnimationOpt

@synthesize type, opt;

+(UISlideMenuAnimationOpt *)animationType:(SlideMenuAnimationType)t opt:(CGFloat)o
{
	UISlideMenuAnimationOpt *smopt = [UISlideMenuAnimationOpt object];
	smopt.type = t;
	smopt.opt = o;
	return smopt;
}

@end

#define kPopUpViewControllerMaskView	@"kPopUpViewControllerMaskView"
#define kPopUpViewSuperViewController	@"kPopUpViewSuperViewController"
#define kPopedUpView					@"kPopedUpView"
#define kSlideMenuViewBindView			@"kSlideMenuViewBindView"
#define kSlideMenuShadowView			@"kSlideMenuShadowView"

#define SMOPT		UISlideMenuAnimationOpt

@implementation UIViewController(PopUp)

-(void) presentPopUpViewController:(UIViewController *)controller animated:(BOOL)animated
{
	UIView *maskView = [self.view.layer valueForKey:kPopUpViewControllerMaskView];
	if ( maskView == nil ) {
		maskView = [[[UIView alloc] initWithFrame:self.view.bounds] autorelease];
		[self.view.layer setValue:maskView forKey:kPopUpViewControllerMaskView];
		//[maskView setTapGestureDismiss:YES];
		[self.view addSubview:maskView];
	}
	[maskView setMaskVisible:YES];
	
	[controller.view.layer setValue:self forKey:kPopUpViewSuperViewController];
	[self.view.layer setValue:controller forKey:kPopedUpView];
	
	[controller.view setCenter:CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2)];
	
	[self.view addSubview:controller.view];
	if ( animated ) {
		controller.view.transform = CGAffineTransformMakeScale(.01, .01);
		[UIView animateWithDuration:.3 / 1.5 animations:^(void){
			controller.view.transform = CGAffineTransformMakeScale(1.1, 1.1);
		} completion:^(BOOL finished) {
			[UIView animateWithDuration:.3 / 2 animations:^{
				controller.view.transform = CGAffineTransformMakeScale(0.9, 0.9);
			} completion:^(BOOL finished) {
				[UIView animateWithDuration:.3 / 2 animations:^{
					controller.view.transform = CGAffineTransformIdentity;
				}];
			}];
		}];
	} 
}

-(void) presentRotatePopUpViewController:(UIViewController *)controller
	duration:(NSTimeInterval)duration
{
	[controller.view setCenter:CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2)];
	[self.view addSubview:controller.view];
	//[self.view.layer addSublayer:controller.view.layer];
	//[self.view bringSubviewToFront:controller.view];
	
	//controller.view.transform = CGAffineTransformMakeScale(.01, .01);
	[controller.view.layer setZPosition:INT_MAX];
	CATransform3D trans = CATransform3DIdentity;
	trans.m34 = -0.002;
	CATransform3D rotateTrans = CATransform3DRotate(trans, M_PI, 0, 1, 0);
	CATransform3D transform = CATransform3DScale(rotateTrans, 0.01, 0.01, 1);
	[controller.view.layer setTransform:transform];
	
	[controller.view.layer setValue:self forKey:kPopUpViewSuperViewController];
	[self.view.layer setValue:controller forKey:kPopedUpView];	
	
	[UIView animateWithDuration:duration animations:^{
		[controller.view.layer setTransform:CATransform3DIdentity];
	}];
}

-(void) presentPopUpViewController:(UIViewController *)controller 
	fromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
	complention:(PopUpAnimation)code
{
	UIView *maskView = [self.view.layer valueForKey:kPopUpViewControllerMaskView];
	if ( maskView == nil ) {
		maskView = [[[UIView alloc] initWithFrame:self.view.bounds] autorelease];
		[self.view.layer setValue:maskView forKey:kPopUpViewControllerMaskView];
		//[maskView setTapGestureDismiss:YES];
		[self.view addSubview:maskView];
	}
	[maskView setMaskVisible:YES];
	
	[controller.view.layer setValue:self forKey:kPopUpViewSuperViewController];
	[self.view.layer setValue:controller forKey:kPopedUpView];
	
	[controller.view setCenter:endPoint];
	[self.view addSubview:controller.view];
	
	CGPoint _tp = CGPointMake(startPoint.x - endPoint.x, 
		startPoint.y - endPoint.y);
	CGAffineTransform _trans = CGAffineTransformMakeTranslation(_tp.x, _tp.y);
	_trans = CGAffineTransformScale(_trans, .01, .01);
	controller.view.transform = _trans;
	[UIView animateWithDuration:.3 / 1.5 animations:^(void){
		CGAffineTransform _t = CGAffineTransformMakeTranslation(0, 0);
		controller.view.transform = CGAffineTransformScale(_t, 1.05, 1.05);
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:.3 / 2 animations:^{
			controller.view.transform = CGAffineTransformMakeScale(0.95, 0.95);
		} completion:^(BOOL finished) {
			[UIView animateWithDuration:.3 / 2 animations:^{
				controller.view.transform = CGAffineTransformIdentity;
			} completion:^(BOOL finished) {
				if ( code ) code();
			}];
		}];
	}];
}

-(void) dismissPopUpViewControllerAnimated:(BOOL)animated
{
	if ( animated ) {
		[UIView animateWithDuration:.3 / 1.5 animations:^{
			self.view.transform = CGAffineTransformMakeScale(.01, .01);
		} completion:^(BOOL finished) {
			[self.view removeFromSuperview];
		}];
	} else {
		[self.view removeFromSuperview];
	}
	
	UIViewController *superViewController = [self.view.layer valueForKey:kPopUpViewSuperViewController];
	if ( superViewController == nil ) return;
	UIView *maskView = [superViewController.view.layer valueForKey:kPopUpViewControllerMaskView];
	[self.view.layer setValue:nil forKey:kPopUpViewSuperViewController];
	[superViewController.view.layer setValue:nil forKey:kPopedUpView];
	if ( maskView == nil ) {
		return;
	}
	[maskView setMaskVisible:NO];
}

-(void) dismissRotatePopUpViewControllerDuration:(NSTimeInterval)duration
{
	[self.view.layer setZPosition:INT_MAX];
	CATransform3D trans = CATransform3DIdentity;
	trans.m34 = -0.002;
	CATransform3D rotateTrans = CATransform3DRotate(trans, M_PI, 0, 1, 0);
	CATransform3D transform = CATransform3DScale(rotateTrans, 0.01, 0.01, 1);
	
	[UIView animateWithDuration:duration animations:^{
		[self.view.layer setTransform:transform];
	} completion:^(BOOL finished) {
		[self.view removeFromSuperview];
	}];
	
	UIViewController *superViewController = [self.view.layer valueForKey:kPopUpViewSuperViewController];
	if ( superViewController == nil ) return;
	UIView *maskView = [superViewController.view.layer valueForKey:kPopUpViewControllerMaskView];
	[self.view.layer setValue:nil forKey:kPopUpViewSuperViewController];
	[superViewController.view.layer setValue:nil forKey:kPopedUpView];
	if ( maskView == nil ) {
		return;
	}
	[maskView setMaskVisible:NO];
}

/* slide the menu from one direction */
@dynamic slideMenuBaseController;
-(UIViewController *)slideMenuBaseController {
	return [self.view.layer valueForKey:kSlideMenuViewBindView];
}

-(void) presentSlideMenu:(UIViewController*)menuController 
	withOption:(NSDictionary *)option
{
	[self presentSlideMenu:menuController withOption:option complention:nil];
}
	
-(void) presentSlideMenu:(UIViewController*)menuController 
	withOption:(NSDictionary *)option 
	complention:(SlideMenuAnimation)code
{
	if ( !CGAffineTransformIsIdentity(menuController.view.transform) ||
		!CGAffineTransformIsIdentity(self.view.transform) )
		return;
	
	// check the position of the menu
	CGRect _menuFrame = menuController.view.frame;
	CGRect _selfFrame = self.view.frame;
	
	_menuFrame.origin.y = _selfFrame.origin.y;
	_menuFrame.size.height = _selfFrame.size.height;
	
	CGPoint _trans = CGPointZero;
	
	int _leftOrRight = PYGETDEFAULT(PYGETNIL(option, 
		objectForKey:kSlideMenuDirection), intValue, 0);
		
	int _followOrStay = PYGETDEFAULT(PYGETNIL(option, 
		objectForKey:kSlideMenuFollow), intValue, 1);
	
	if ( _leftOrRight == 0 )	// left
	{
		_menuFrame.origin.x = (_followOrStay == 0) ? 0 : -(_menuFrame.size.width);
		_trans.x = _menuFrame.size.width;
	}
	else
	{
		_menuFrame.origin.x = (_followOrStay == 0) ? 
			(_selfFrame.size.width - _menuFrame.size.width) : _selfFrame.size.width;
		_trans.x = -(_menuFrame.size.width);
	}
	
	[menuController.view setFrame:_menuFrame];
	
	// add menu to superview
	int _topOrBottom = PYGETDEFAULT(PYGETNIL(option, 
		objectForKey:kSlideMenuLayer), intValue, 0);
		
	if ( _topOrBottom == 0 )	// top
	{
		// add menu view
		[self.view.superview addSubview:menuController.view];
		
		// add shadow view
		PYLibImageIndex _imgKey = (_leftOrRight == 0) ? 
			PYLibImageFrameShadowLeft : PYLibImageFrameShadowRight;
		CGFloat _x = (_leftOrRight == 0) ? _menuFrame.size.width : -13.f;
		UIImageView *_shadowView = [[[UIImageView alloc] 
			initWithImage:[PYLibImage imageForKey:_imgKey]] autorelease];
			
		[_shadowView setFrame:(CGRect){
			_x, 0, 13.f, _menuFrame.size.height}];
	
		[menuController.view insertSubview:_shadowView atIndex:0];
		[menuController.view.layer setValue:_shadowView forKey:kSlideMenuShadowView];
	}
	else
	{
		// add menu view
		[self.view.superview insertSubview:menuController.view atIndex:0];
		
		// add shadow view
		PYLibImageIndex _imgKey = (_leftOrRight == 0) ? 
			PYLibImageFrameShadowRight : PYLibImageFrameShadowLeft;
		CGFloat _x = (_leftOrRight == 0) ? -13.f : _selfFrame.size.width;
		UIImageView *_shadowView = [[[UIImageView alloc] 
			initWithImage:[PYLibImage imageForKey:_imgKey]] autorelease];
			
		[_shadowView setFrame:(CGRect){
			_x, 0, 13.f, _selfFrame.size.height}];
	
		[self.view insertSubview:_shadowView atIndex:0];
		[self.view.layer setValue:_shadowView forKey:kSlideMenuShadowView];
	}
	
	// do animation
	CGAffineTransform _menuTransform = CGAffineTransformMakeTranslation(_trans.x, 0);
	CGAffineTransform _selfTransform = _menuTransform;
	
	// Get other animation info.
	SMOPT *menuOpt = PYGETNIL(option, objectForKey:kSlideMenuInAnimation);
	if ( menuOpt != nil ) {
		
	}
	
	SMOPT *selfOpt = PYGETNIL(option, objectForKey:kSlideMenuOutAnimation);
	if ( selfOpt != nil ) {
		if ( selfOpt.type == SlideMenuAnimationTypeScale ) {
			CGFloat _selfShowSize = _selfFrame.size.width - _menuFrame.size.width;
			CGFloat _scaleLeftSize = _selfFrame.size.width * selfOpt.opt;
			CGFloat _transX = _trans.x;
			if ( _scaleLeftSize < _selfShowSize ) selfOpt.opt = 1;
			else {
				//_leftOrRight
				CGFloat d = (_selfShowSize - _selfFrame.size.width * (1 - selfOpt.opt));
				_transX += (_leftOrRight ? d : -d);
			}
		
			_selfTransform = CGAffineTransformMakeScale(selfOpt.opt, 1);
			_selfTransform = CGAffineTransformTranslate(
				_selfTransform, _transX, 0);
		} else if ( selfOpt.type == SlideMenuAnimationTypeFold ) {
		
		}
	}
	
	[UIView animateWithDuration:0.35 animations:^{
		if ( _followOrStay == 0 ) menuController.view.transform = CGAffineTransformIdentity;
		else menuController.view.transform = _menuTransform;
		self.view.transform = _selfTransform;
	} completion:^(BOOL finished) {
		[menuController.view.layer setValue:self forKey:kSlideMenuViewBindView];
		if ( code ) code();
	}];
}

/* dismiss the slide menu */
-(void) dismissSlideMenuViewControllerAnimated:(BOOL)animated
{
	[self dismissSlideMenuViewControllerAnimated:animated complention:nil];
}

-(void) dismissSlideMenuViewControllerAnimated:(BOOL)animated 
	complention:(SlideMenuAnimation)code
{
	UIViewController *_bindView = [self.view.layer valueForKey:kSlideMenuViewBindView];
	if ( animated ) {
		[UIView animateWithDuration:0.35 animations:^{
			self.view.transform = CGAffineTransformIdentity;
			//self.view.superview 
			if ( _bindView != nil ) {
				_bindView.view.transform = CGAffineTransformIdentity;
			}
		} completion:^(BOOL finished) {
			if ( code ) code();
			
			UIImageView *_shadowView = [self.view.layer valueForKey:kSlideMenuShadowView];
			if ( _shadowView != nil ) {
				[_shadowView removeFromSuperview];
			}
			
			if ( _bindView != nil )
				_shadowView = [_bindView.view.layer valueForKey:kSlideMenuShadowView];
			else _shadowView = nil;
			
			if ( _shadowView != nil ) [_shadowView removeFromSuperview];
			[self.view removeFromSuperview];
			
			if ( _bindView != nil ) {
				[_bindView slideMenuDidDismissed:self];
			}
			
		}];
	} else {
		self.view.transform = CGAffineTransformIdentity;
		//self.view.superview 
		if ( _bindView != nil ) {
			_bindView.view.transform = CGAffineTransformIdentity;
		}
		if ( code ) code();

		UIImageView *_shadowView = [self.view.layer valueForKey:kSlideMenuShadowView];
		if ( _shadowView != nil ) {
			[_shadowView removeFromSuperview];
		}
		
		if ( _bindView != nil )
			_shadowView = [_bindView.view.layer valueForKey:kSlideMenuShadowView];
		else _shadowView = nil;
		
		if ( _shadowView != nil ) [_shadowView removeFromSuperview];
		[self.view removeFromSuperview];
		
		if ( _bindView != nil ) {
			[_bindView slideMenuDidDismissed:self];
		}
	}
}

-(void) slideMenuDidDismissed:(UIViewController *)slideMenu { }

@end
