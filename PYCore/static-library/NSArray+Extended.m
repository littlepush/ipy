//
//  NSArray+Extended.m
//  PYCore
//
//  Created by littlepush on 8/6/12.
//  Copyright (c) 2012 PushLab. All rights reserved.
//

#import "NSArray+Extended.h"

@implementation NSArray (Extended)

-(void) objectsTryToPerformSelector:(SEL)selector
{
	NSEnumerator *enumerator = self.objectEnumerator;
	for ( id object in enumerator ) {
		if ( [object respondsToSelector:selector] ) {
			[object performSelector:selector];
		}
	}
}

-(void) objectsTryToPerformSelector:(SEL)selector withObject:(id)obj
{
	NSEnumerator *enumerator = self.objectEnumerator;
	for ( id object in enumerator ) {
		if ( [object respondsToSelector:selector] ) {
			[object performSelector:selector withObject:obj];
		}
	}
}

-(void) objectsTryToPerformSelector:(SEL)selector withObject:(id)obj1 withObject:(id)obj2
{
	NSEnumerator *enumerator = self.objectEnumerator;
	for ( id object in enumerator ) {
		if ( [object respondsToSelector:selector] ) {
			[object performSelector:selector withObject:obj1 withObject:obj2];			
		}
	}
}

@end
