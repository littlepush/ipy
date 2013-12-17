//
//  UIViewController+PopUp.m
//  PYUIKit
//
//  Created by Push Chen on 8/26/13.
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

#import "UIViewController+PopUp.h"

#define UIVIEW_POP_MASK_VIEW_TAG            10240

@interface __PYMaskView : UIView
@property (nonatomic, assign)   UIViewController            *customController;
@property (nonatomic, assign)   PYPopUpAnimationType        animationType;
@end

@implementation __PYMaskView
@synthesize customController, animationType;
- (void)_actionMaskViewTapHandler:(id)sender
{
    @synchronized( self ) {
        if ( self.customController == nil ) return;
        if ( self.customController.parentViewController == nil ) return;
        if ( self.customController.parentViewController.popState != UIViewControllerPopStatePopedUp ) return;
        [self.customController dismissPopedViewControllerAnimation:self.animationType
                                                          complete:nil];
    }
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self ) {
        UITapGestureRecognizer *_tapGesture =
        [[UITapGestureRecognizer alloc]
         initWithTarget:self
         action:@selector(_actionMaskViewTapHandler:)];
        [self addGestureRecognizer:_tapGesture];
    }
    return self;
}
@end

@implementation UIViewController (PopUp)

@dynamic popState;
- (UIViewControllerPopState)popState
{
    @synchronized( self ) {
        NSNumber *_nsState = [self.view.layer valueForKey:@"VIEW_CONTROLLER_POP_STATE"];
        if ( _nsState == nil ) return UIViewControllerPopStateUnknow;
        return (UIViewControllerPopState)[_nsState integerValue];
    }
}
- (void)setPopState:(UIViewControllerPopState)state
{
    @synchronized( self ) {
        [self willChangeValueForKey:@"popState"];
        [self.view.layer setValue:PYIntToObject(state) forKey:@"VIEW_CONTROLLER_POP_STATE"];
        [self didChangeValueForKey:@"popState"];
    }
}

@dynamic isPopViewVisiable;
- (BOOL)isPopViewVisiable
{
    UIView *_maskView = [self.view viewWithTag:UIVIEW_POP_MASK_VIEW_TAG];
    return _maskView != nil;
}

// Message Callback
- (void)willPopViewController:(UIViewController *)controller
{
    
}
- (void)didPopedViewController:(UIViewController *)controller
{
    
}
- (void)willDismissPopViewController:(UIViewController *)controller
{
    
}
- (void)didDismissedPopViewController:(UIViewController *)controller
{
    
}

// Pop up the view controller with specified animation type.
// Default animation type is Jelly.
- (void)presentPopViewController:(UIViewController *)controller
{
    [self presentPopViewController:controller
                         animation:PYPopUpAnimationTypeJelly
                          complete:nil];
}
- (void)presentPopViewController:(UIViewController *)controller
                        complete:(PYActionDone)complete
{
    [self presentPopViewController:controller
                         animation:PYPopUpAnimationTypeJelly
                          complete:complete];
}

- (void)presentPopViewController:(UIViewController *)controller
                       animation:(PYPopUpAnimationType)type
                        complete:(PYActionDone)complete
{
    [self presentPopViewController:controller
                         animation:type
                            center:CGPointMake(self.view.bounds.size.width / 2,
                                               self.view.bounds.size.height / 2)
                          complete:complete];
}
- (void)presentPopViewController:(UIViewController *)controller
                       animation:(PYPopUpAnimationType)type
                          center:(CGPoint)center
                        complete:(PYActionDone)complete
{
    if ( controller == nil ) return;
    if ( self.popState != UIViewControllerPopStateUnknow &&
        self.popState != UIViewControllerPopStateDismissed ) return;
    @synchronized( self ) {
        self.popState = UIViewControllerPopStateWillPop;
        [self willPopViewController:controller];
        [self addChildViewController:controller];
        CGRect _frame = controller.view.bounds;
        if ( _frame.size.width > self.view.frame.size.width ) {
            _frame.size.width = self.view.frame.size.width;
        }
        if ( _frame.size.height > self.view.frame.size.height ) {
            _frame.size.height = self.view.frame.size.height;
        }
        [controller.view setFrame:_frame];
        [controller.view setCenter:center];
        [self displayMaskViewWithAlpha:.3 animation:type
                   customizeController:controller];
        [self.view addSubview:controller.view];
        
        // No animation effective
        if ( PYPopUpAnimationTypeNone == type ) {
            self.popState = UIViewControllerPopStatePopedUp;
            [self didPopedViewController:controller];
            
            if ( complete ) complete( );
            return;
        }
        
        if ( PYPopUpAnimationTypeFade == type ) {
            controller.view.alpha = 0.f;
            [UIView animateWithDuration:.3 / 2 animations:^{
                controller.view.alpha = 1.f;
            } completion:^(BOOL finished) {
                self.popState = UIViewControllerPopStatePopedUp;
                [self didPopedViewController:controller];
                if ( complete ) complete();
            }];
            return;
        }
        
        if ( PYPopUpAnimationTypeSlideFromLeft == type ) {
            controller.view.transform = CGAffineTransformMakeTranslation(-self.view.bounds.size.width, 0);
            [UIView animateWithDuration:.3 / 2 animations:^{
                controller.view.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                self.popState = UIViewControllerPopStatePopedUp;
                [self didPopedViewController:controller];
                if ( complete ) complete();
            }];
            return;
        }
        
        if ( PYPopUpAnimationTypeSlideFromRight == type ) {
            controller.view.transform = CGAffineTransformMakeTranslation(self.view.bounds.size.width, 0);
            [UIView animateWithDuration:.3 / 2 animations:^{
                controller.view.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                self.popState = UIViewControllerPopStatePopedUp;
                [self didPopedViewController:controller];
                if ( complete ) complete();
            }];
            return;
        }
        
        if ( PYPopUpAnimationTypeSlideFromBottom == type ) {
            controller.view.transform = CGAffineTransformMakeTranslation(0, self.view.bounds.size.height);
            [UIView animateWithDuration:.3 / 2 animations:^{
                controller.view.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                self.popState = UIViewControllerPopStatePopedUp;
                [self didPopedViewController:controller];
                if ( complete ) complete();
            }];
            return;
        }
        
        if ( PYPopUpAnimationTypeSlideFromTop == type ) {
            controller.view.transform = CGAffineTransformMakeTranslation(0, -self.view.bounds.size.height);
            [UIView animateWithDuration:.3 / 2 animations:^{
                controller.view.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                self.popState = UIViewControllerPopStatePopedUp;
                [self didPopedViewController:controller];
                if ( complete ) complete();
            }];
            return;
        }
        // Scale to a point first.
        controller.view.transform = CGAffineTransformMakeScale(.01, .01);
        if ( PYPopUpAnimationTypeSmooth == type ) {
            [UIView animateWithDuration:.3 / 2 animations:^{
                controller.view.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                self.popState = UIViewControllerPopStatePopedUp;
                [self didPopedViewController:controller];
                if ( complete ) complete( );
            }];
            return;
        }
        if ( PYPopUpAnimationTypeJelly == type ) {
            [UIView animateWithDuration:.3 / 1.5 animations:^{
                controller.view.transform = CGAffineTransformMakeScale(1.1, 1.1);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:.3 / 2 animations:^{
                    controller.view.transform = CGAffineTransformMakeScale(.9, .9);
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:.3 / 2 animations:^{
                        controller.view.transform = CGAffineTransformIdentity;
                    } completion:^(BOOL finished) {
                        self.popState = UIViewControllerPopStatePopedUp;
                        [self didPopedViewController:controller];
                        if ( complete ) complete( );
                    }];
                }];
            }];
            return;
        }
    }
}

// Dismiss the view controller, and set if need animation.
- (void)dismissPopedViewController:(BOOL)animated
{
    [self dismissPopedViewController:animated complete:nil];
}
- (void)dismissPopedViewController:(BOOL)animated
                          complete:(PYActionDone)complete
{
    if ( animated ) {
        [self dismissPopedViewControllerAnimation:PYPopUpAnimationTypeSmooth
                                         complete:complete];
    } else {
        [self dismissPopedViewControllerAnimation:PYPopUpAnimationTypeNone
                                         complete:complete];
    }
}
- (void)dismissPopedViewControllerAnimation:(PYPopUpAnimationType)type
                                   complete:(PYActionDone)complete
{
    @synchronized( self ) {
        if ( self.parentViewController == nil ) return;
        // If the previous state is not popedup, donot dismiss current view.
        if ( self.parentViewController.popState != UIViewControllerPopStatePopedUp ) return;
        __weak UIViewController *_parent = self.parentViewController;

        self.parentViewController.popState = UIViewControllerPopStateWillDismiss;
        [self.parentViewController willDismissPopViewController:self];
        if ( type == PYPopUpAnimationTypeNone ) {
            [self.view removeFromSuperview];
            [self.parentViewController hideMaskView:NO];
            [self removeFromParentViewController];
            _parent.popState = UIViewControllerPopStateDismissed;
            [_parent didDismissedPopViewController:self];
            if ( complete ) complete( );
            return;
        }
        
        [self.parentViewController hideMaskView:type];
        
        if ( type == PYPopUpAnimationTypeSlideFromLeft ) {
            [UIView animateWithDuration:.3 / 2 animations:^{
                self.view.transform =
                CGAffineTransformMakeTranslation(self.parentViewController.view.bounds.size.width, 0);;
            } completion:^(BOOL finished) {
                [self.view removeFromSuperview];
                [self removeFromParentViewController];
                self.view.transform = CGAffineTransformIdentity;
                _parent.popState = UIViewControllerPopStateDismissed;
                [_parent didDismissedPopViewController:self];
                if ( complete ) complete();
            }];
            return;
        }
        
        if ( type == PYPopUpAnimationTypeSlideFromRight ) {
            [UIView animateWithDuration:.3 / 2 animations:^{
                self.view.transform =
                CGAffineTransformMakeTranslation(-self.parentViewController.view.bounds.size.width, 0);;
            } completion:^(BOOL finished) {
                [self.view removeFromSuperview];
                [self removeFromParentViewController];
                self.view.transform = CGAffineTransformIdentity;
                _parent.popState = UIViewControllerPopStateDismissed;
                [_parent didDismissedPopViewController:self];
                if ( complete ) complete();
            }];
            return;
        }

        if ( type == PYPopUpAnimationTypeSlideFromBottom ) {
            [UIView animateWithDuration:.3 / 2 animations:^{
                self.view.transform =
                CGAffineTransformMakeTranslation(0, self.parentViewController.view.bounds.size.height);;
            } completion:^(BOOL finished) {
                [self.view removeFromSuperview];
                [self removeFromParentViewController];
                self.view.transform = CGAffineTransformIdentity;
                _parent.popState = UIViewControllerPopStateDismissed;
                [_parent didDismissedPopViewController:self];
                if ( complete ) complete();
            }];
            return;
        }

        if ( type == PYPopUpAnimationTypeSlideFromTop ) {
            [UIView animateWithDuration:.3 / 2 animations:^{
                self.view.transform =
                CGAffineTransformMakeTranslation(0, -self.parentViewController.view.bounds.size.height);;
            } completion:^(BOOL finished) {
                [self.view removeFromSuperview];
                [self removeFromParentViewController];
                self.view.transform = CGAffineTransformIdentity;
                _parent.popState = UIViewControllerPopStateDismissed;
                [_parent didDismissedPopViewController:self];
                if ( complete ) complete();
            }];
            return;
        }

        if ( type == PYPopUpAnimationTypeSmooth || type == PYPopUpAnimationTypeJelly ) {
            [UIView animateWithDuration:.3 / 1.5 animations:^{
                self.view.transform = CGAffineTransformMakeScale(.01, .01);
            } completion:^(BOOL finished) {
                [self.view removeFromSuperview];
                [self removeFromParentViewController];
                self.view.transform = CGAffineTransformIdentity;
                _parent.popState = UIViewControllerPopStateDismissed;
                [_parent didDismissedPopViewController:self];
                if ( complete ) complete( );
            }];
            return;
        }
        
        if ( type == PYPopUpAnimationTypeFade ) {
            [UIView animateWithDuration:.3 / 2 animations:^{
                self.view.alpha = 0.f;
            } completion:^(BOOL finished) {
                [self.view removeFromSuperview];
                [self removeFromParentViewController];
                self.view.transform = CGAffineTransformIdentity;
                _parent.popState = UIViewControllerPopStateDismissed;
                [_parent didDismissedPopViewController:self];
                if ( complete ) complete();
            }];
            return;
        }
    }
}

- (void)displayMaskViewWithAlpha:(CGFloat)alpha
                       animation:(PYPopUpAnimationType)type
             customizeController:(UIViewController *)controller
{
    __PYMaskView *_maskView = [[__PYMaskView alloc] initWithFrame:self.view.bounds];
    [_maskView setBackgroundColor:[UIColor blackColor]];
    _maskView.customController = controller;
    _maskView.animationType = type;
    [_maskView setTag:UIVIEW_POP_MASK_VIEW_TAG];
    [self.view addSubview:_maskView];
    if ( type == PYPopUpAnimationTypeNone ) {
        [_maskView setAlpha:alpha];
        return;
    }
    [_maskView setAlpha:0.f];
    
    CGFloat _animationTime = .3 / 2;
    if ( type == PYPopUpAnimationTypeJelly ) {
        _animationTime = .3 / 1.5 + .3 / 2 + .3 / 2;
    }
    [UIView animateWithDuration:_animationTime animations:^{
        [_maskView setAlpha:alpha];
    }];
}

- (void)hideMaskView:(PYPopUpAnimationType)type
{
    UIView *_maskView = [self.view viewWithTag:UIVIEW_POP_MASK_VIEW_TAG];
    if ( _maskView == nil ) return;
    if ( type == PYPopUpAnimationTypeNone ) {
        [_maskView removeFromSuperview];
        return;
    }
    
    CGFloat _animationTime = .3 / 2;
    if ( type == PYPopUpAnimationTypeJelly || type == PYPopUpAnimationTypeSmooth ) {
        _animationTime = .3 / 1.5;
    }
    [UIView animateWithDuration:_animationTime animations:^{
        [_maskView setAlpha:0.f];
    } completion:^(BOOL finished) {
        [_maskView removeFromSuperview];
    }];
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
