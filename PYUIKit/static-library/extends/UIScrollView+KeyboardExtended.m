//
//  UIScrollView+KeyboardExtended.m
//  PYUIKit
//
//  Created by Wang Pei(tsubasa) on 8/31/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "UIScrollView+KeyboardExtended.h"
#import "UIView+Responsder.h"

@interface UIScrollView (private)

- (void)moveResponsderToTopWithKeyboardHeight:(int)height;

@end

@implementation UIScrollView (KeyboardExtended)

- (void)resgisterScrollKeyboardEvent {
    [[NSNotificationCenter defaultCenter] addObserver:self 
                              selector:@selector(keyboardWillShow:) 
                              name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                              selector:@selector(keyboardWillHide:) 
                              name:UIKeyboardWillHideNotification object:nil];
	#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 50000
    [[NSNotificationCenter defaultCenter] addObserver:self 
                              selector:@selector(keyboardWillChange:) 
                              name:UIKeyboardWillChangeFrameNotification object:nil];
	#endif
}

- (void)unresgisterScrollKeyboardEvent {
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)aNotification {
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    [self moveResponsderToTopWithKeyboardHeight:keyboardRect.size.height];
}

- (void)keyboardWillHide:(NSNotification*)aNotification {
    [UIView animateWithDuration:0.3 animations:^
     {
         [self setContentInset:UIEdgeInsetsZero];
     } completion:^(BOOL finished){
         [self setContentOffset:CGPointZero animated:YES];
     }];
}

- (void)keyboardWillChange:(NSNotification*)aNotification {
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    [self moveResponsderToTopWithKeyboardHeight:keyboardRect.size.height];
}

- (void)moveResponsderToTopWithKeyboardHeight:(int)height {
    [self setContentInset:UIEdgeInsetsMake(0, 0, height ,0)];
    // find the responsder
    UIView *responsder = [self findFirstResponsder];
    if ( responsder == nil ) return;
    // reset the content
    int margin = 0;
	CGPoint origin = [responsder originInSuperview:self];
    margin = origin.y - ( self.frame.size.height - height)/2;
    if ( margin <= 0 ) return;
    [self setContentOffset:CGPointMake(0, margin) animated:YES];
}

@end
