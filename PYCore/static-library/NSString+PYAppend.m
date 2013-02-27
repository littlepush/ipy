//
//  NSString+PYAppend.m
//  PYCore
//
//  Created by Push Chen on 7/17/12.
//  Copyright (c) 2012 PushLab. All rights reserved.
//

#import "NSString+PYAppend.h"
#import "PYCoder.h"

@implementation NSString (PYAppend)

@dynamic isValidateEmailAddress;
-(BOOL) isValidateEmailAddress
{
	// Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
	BOOL stricterFilter = YES;
	NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
	NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
	NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
	NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
	return [emailTest evaluateWithObject:self];
}

- (BOOL)appendToFile:(NSString *)path usingEncoding:(NSStringEncoding)encoding
{
    NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:path]; 
    if (fh == nil)
        return [self writeToFile:path atomically:YES encoding:encoding error:nil];
    
    [fh truncateFileAtOffset:[fh seekToEndOfFile]];
    NSData *encoded = [self dataUsingEncoding:encoding];
    
    if (encoded == nil) return NO;
    
    [fh writeData:encoded];
    return YES;
}

- (BOOL)appendLineToFile:(NSString *)path usingEncoding:(NSStringEncoding)encoding
{
	NSString *_line = [self stringByAppendingFormat:@"\n"];
    NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:path]; 
    if (fh == nil) {
        return [_line writeToFile:path 
			atomically:YES encoding:encoding error:nil];
    }
    [fh truncateFileAtOffset:[fh seekToEndOfFile]];
    NSData *encoded = [_line dataUsingEncoding:encoding];
    
    if (encoded == nil) return NO;
    
    [fh writeData:encoded];
    return YES;	
}

- (NSString *) base64EncodeString
{
	return [PYCoder encodeBase64:self];
}

- (NSString *) base64DecodeString
{
	return [PYCoder decodeBase64:self];
}

- (NSString *) md5sum
{
	return [PYCoder md5sum:self];
}

-(NSString *) reformTelphone
{
	NSString *_newTel = [[self copy] autorelease];
	_newTel = [_newTel stringByReplacingOccurrencesOfString:@"-" withString:@""];
	_newTel = [_newTel stringByReplacingOccurrencesOfString:@" " withString:@""];
	_newTel = [_newTel stringByReplacingOccurrencesOfString:@"(" withString:@""];
	_newTel = [_newTel stringByReplacingOccurrencesOfString:@")" withString:@""];
	_newTel = [_newTel stringByReplacingOccurrencesOfString:@"+" withString:@""];

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

-(NSString *) urlEncodeString
{
    NSString *outputStr = (NSString *)   
		CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,  
                                            (CFStringRef)self,
                                            NULL,  
                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",  
                                            kCFStringEncodingUTF8);  
    return [outputStr autorelease];
}  

-(NSString *) urlDecodeString
{
    NSMutableString *outputStr = [NSMutableString stringWithString:self];
    [outputStr replaceOccurrencesOfString:@"+"  
                               withString:@" "  
                                  options:NSLiteralSearch  
                                    range:NSMakeRange(0, [outputStr length])];  
  
    return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];  
} 
@end
