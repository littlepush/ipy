//
//  PYExtend.m
//  PYUIKit
//
//  Created by Push Chen on 7/16/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "PYExtend.h"

UIViewController * _pyviewController_multiplatform( NSString *_name ) {
	NSString *_key = [NSString stringWithFormat:@"k.vc.%@", _name];
	UIViewController *_view = GlobalCacheGetObjectOfKey(_key);
	if ( _view == nil ) {
		NSString *_nibName = [NSString stringWithFormat:@"%@%s", _name, 
			PYIsIphone ? "_iPhone" : "_iPad"];
		_view = [[[NSClassFromString(_name) alloc] 
			initWithNibName:_nibName bundle:nil] autorelease];
		GlobalCacheSetObjectValueOfKey(_key, _view);
	}
	return _view;
}

UIViewController * _pyviewController( NSString *_name ) {
	NSString *_key = [NSString stringWithFormat:@"k.vc.%@", _name];
	UIViewController *_view = GlobalCacheGetObjectOfKey(_key);
	if ( _view == nil ) {
		_view = [[[NSClassFromString(_name) alloc] 
			initWithNibName:_name bundle:nil] autorelease];
		GlobalCacheSetObjectValueOfKey(_key, _view);
	}
	return _view;	
}

UIViewController *_pyviewController_multiplatform_nocache( NSString *_name ) {
	NSString *_nibName = [NSString stringWithFormat:@"%@%s", _name, 
		PYIsIphone ? "_iPhone" : "_iPad"];
	UIViewController *_view = [[[NSClassFromString(_name) alloc] 
		initWithNibName:_nibName bundle:nil] autorelease];
	return _view;
}

UIViewController *_pyviewController_nocache( NSString *_name ) {
	UIViewController *_view = [[[NSClassFromString(_name) alloc] 
		initWithNibName:_name bundle:nil] autorelease];
	return _view;	
}

UIView *_pyloadView( NSString *_name, Class _class ) {
	NSArray *_nibs = [[NSBundle mainBundle] 
		loadNibNamed:_name owner:nil options:nil];
	for ( id _object in _nibs ) {
		if ( [_object isKindOfClass:_class] ) {
			return (UIView *)_object;
		}
	}
	return nil;
}

UIView *_pyloadView_multiplatform( NSString *_name, Class _class ) {
	NSString *_nibName = [_name stringByAppendingString:(
		PYIsIphone ? @"_iPhone" : @"_iPad"
	)];
	NSArray *_nibs = [[NSBundle mainBundle]
		loadNibNamed:_nibName owner:nil options:nil];
	for ( id _object in _nibs ) {
		if ( [_object isKindOfClass:_class] ) {
			return (UIView *)_object;
		}
	}
	return nil;
}

