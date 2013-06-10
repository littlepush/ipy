//
//  NSString+Validation.m
//  PYCore
//
//  Created by Push Chen on 6/10/13.
//  Copyright (c) 2013 PushLab. All rights reserved.
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

#import "NSString+Validation.h"
#import "NSObject+PYCore.h"

@implementation NSString (Validation)
- (BOOL)isIntager
{
    NSPredicate *numberPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES '^[0-9]+$'"];
    return [numberPredicate evaluateWithObject:self];
}

- (BOOL)isValidateEmailAddress
{
    // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
	BOOL stricterFilter = YES;
	NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
	NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
	NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
	NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
	return [emailTest evaluateWithObject:self];
}

- (BOOL)isValidateIp
{
    NSString *_regString = @"^(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])$";
    NSPredicate *ipTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", _regString];
    return [ipTest evaluateWithObject:self];
}

- (NSString *)reformTelphone
{
    NSString *_newTel0 = __AUTO_RELEASE(([self copy]));
	NSString *_newTel1 = [_newTel0 stringByReplacingOccurrencesOfString:@"-" withString:@""];
	NSString *_newTel2 = [_newTel1 stringByReplacingOccurrencesOfString:@" " withString:@""];
	NSString *_newTel3 = [_newTel2 stringByReplacingOccurrencesOfString:@"(" withString:@""];
	NSString *_newTel4 = [_newTel3 stringByReplacingOccurrencesOfString:@")" withString:@""];
	NSString *_newTel = [_newTel4 stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
	if ( [_newTel length] < 2 ) return _newTel;
	// For Chinese Only
	NSRange _86 = {0, 2};
	if ([[_newTel substringWithRange:_86] isEqualToString:@"86"])
	{
		NSRange _range = {2, [_newTel length] - 2};
		_newTel = [_newTel substringWithRange:_range];
	}
    return _newTel;
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
