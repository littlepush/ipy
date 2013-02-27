//
//  PYSharedManager.m
//  PYCore
//
//  Created by littlepush on 8/27/12.
//  Copyright (c) 2012 PushLab. All rights reserved.
//

#import "PYSharedManager.h"
#import "NSObject+Extended.h"

@implementation PYSharedManager

@dynamic pendingActionCount;
-(NSUInteger) pendingActionCount { return [_actionCallbackCache count]; }

/* Init and dealloc */
-(id) init
{
	self = [super init];
	if ( !self ) return self;
	// Init the cache
	_actionCallbackCache = [[NSMutableDictionary dictionary] retain];
	_delegate = [[NSMutableArray array] retain];
	return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if ( !self ) return self;
	// Init the cache
	_actionCallbackCache = [[NSMutableDictionary dictionary] retain];
	_delegate = [[NSMutableArray array] retain];	
	return self;
}

-(void) encodeWithCoder:(NSCoder *)aCoder
{
	// do nothing
}

-(void) dealloc
{
	[_actionCallbackCache removeAllObjects];
	_actionCallbackCache = nil;
	
	[_delegate removeAllObjects];
	_delegate = nil;
	
	[super dealloc];
}

#pragma Default Action
/* Basic Action Cache Message */
-(void) action:(NSString *)name done:(PYActionDone)done get:(PYActionGet)get 
	failed:(PYActionFailed)failed finished:(PYActionFinished)finished
{
	PYActionBlock *_actionBlock = [PYActionBlock object];
	_actionBlock.name = name;
	_actionBlock.done = done;
	_actionBlock.get = get;
	_actionBlock.failed = failed;
	_actionBlock.finished = finished;
	
	[_actionCallbackCache setValue:_actionBlock forKey:_actionBlock.name];
}

#pragma Extend Actions
/* Single call back block */
-(void) action:(NSString *)name done:(PYActionDone)done
{
	[self action:name done:done get:nil failed:nil finished:nil];
}
-(void) action:(NSString *)name get:(PYActionGet)get
{
	[self action:name done:nil get:get failed:nil finished:nil];
}
-(void) action:(NSString *)name failed:(PYActionFailed)failed
{
	[self action:name done:nil get:nil failed:failed finished:nil];
}
-(void) action:(NSString *)name finished:(PYActionFinished)finished
{
	[self action:name done:nil get:nil failed:nil finished:finished];
}

/* Two callback blocks */
-(void) action:(NSString *)name done:(PYActionDone)done get:(PYActionGet)get
{
	[self action:name done:done get:get failed:nil finished:nil];
}
-(void) action:(NSString *)name done:(PYActionDone)done failed:(PYActionFailed)failed
{
	[self action:name done:done get:nil failed:failed finished:nil];
}
-(void) action:(NSString *)name done:(PYActionDone)done finihsed:(PYActionFinished)finished
{
	[self action:name done:done get:nil failed:nil finished:finished];
}

-(void) action:(NSString *)name get:(PYActionGet)get failed:(PYActionFailed)failed
{
	[self action:name done:nil get:get failed:failed finished:nil];
}
-(void) action:(NSString *)name get:(PYActionGet)get finished:(PYActionFinished)finished
{
	[self action:name done:nil get:get failed:nil finished:finished];
}

-(void) action:(NSString *)name finished:(PYActionFinished)finished failed:(PYActionFailed)failed
{
	[self action:name done:nil get:nil failed:failed finished:finished];
}

/* Three callback blocks */
-(void) action:(NSString *)name done:(PYActionDone)done
	failed:(PYActionFailed)failed finished:(PYActionFinished)finished
{
	[self action:name done:done get:nil failed:failed finished:finished];
}
-(void) action:(NSString *)name done:(PYActionDone)done 
	get:(PYActionGet)get failed:(PYActionFailed)failed
{
	[self action:name done:done get:get failed:failed finished:nil];
}
-(void) action:(NSString *)name done:(PYActionDone)done 
	get:(PYActionGet)get finished:(PYActionFinished)finished
{
	[self action:name done:done get:get failed:nil finished:finished];
}
-(void) action:(NSString *)name get:(PYActionGet)get
	failed:(PYActionFailed)failed finished:(PYActionFinished)finished
{
	[self action:name done:nil get:get failed:failed finished:finished];
}

#pragma Other Actions
// Get an action block and remain it in the cache
-(PYActionBlock *) actionWithName:(NSString *)name
{
	return [_actionCallbackCache valueForKey:name];
}
// Remove an action block from the cache
-(void) removeActionNamed:(NSString *)name
{
	[_actionCallbackCache removeObjectForKey:name];
}
// Get an action block and remove it from the cache
-(PYActionBlock *) fetchActionWithName:(NSString *)name
{
	PYActionBlock *_actionBlock = [[[_actionCallbackCache 
		valueForKey:name] retain] autorelease];
	if ( name == nil || [name length] == 0 ) return _actionBlock;
	[_actionCallbackCache removeObjectForKey:name];
	return _actionBlock;
}

#pragma Globa
-(void) removeAllActions
{
	[_actionCallbackCache removeAllObjects];
}

#pragma Services
+(id) sharedManager { return nil; }
-(void) startServices { }
-(void) stopServices { [self archiveData]; }
-(void) archiveData {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(
		NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [paths objectAtIndex:0];
	NSString *_path = [documentDirectory stringByAppendingPathComponent:
		NSStringFromClass([self class])];
	_path = [_path stringByAppendingPathExtension:@"dat"];
	NSData *_gData = [NSKeyedArchiver archivedDataWithRootObject:self];
	[_gData writeToFile:_path atomically:YES];
}

#pragma Delegates
-(void) addDelegate:(id<PYSharedManagerDelegate>)delegate
{
	if ( [_delegate containsObject:delegate] ) return;
	[_delegate addObject:delegate];
}
-(void) removeDelegate:(id<PYSharedManagerDelegate>)delegate
{
	if ( ![_delegate containsObject:delegate] ) return;
	[_delegate removeObject:delegate];
}
-(void) delegatesPerform:(SEL)selector
{
	[_delegate objectsTryToPerformSelector:selector];
}
-(void) delegatesPerform:(SEL)selector withObject:(id)object
{
	[_delegate objectsTryToPerformSelector:selector withObject:object];
}
-(void) delegatesPerform:(SEL)selector withObject:(id)obj1 withObject:(id)obj2
{
	[_delegate objectsTryToPerformSelector:selector withObject:obj1 withObject:obj2];
}

+(void) insertArray:(NSArray *)array toListHead:(NSMutableArray *)list compare:(PYActionCompare)comp
{
	if ( [array count] == 0 ) return;
	if ( list == nil ) return;
	if ( comp == nil ) {
		int c = [array count];
		for ( int i = c - 1; i >= 0; --i ) {
			[list insertObject:[array objectAtIndex:i] atIndex:0];
		}
		return;
	}
	
	int c = [array count];
	id _rightObj = [list count] == 0 ? nil : [list objectAtIndex:0];
	for ( int i = c - 1; i >= 0; --i ) {
		id _leftObj = [array objectAtIndex:i];
		if ( _rightObj == nil ) {
			[list insertObject:_leftObj atIndex:0];
		} else {
			int r = comp( _leftObj, _rightObj );
			if ( r != PYCompareLess ) continue;
			[list insertObject:_leftObj atIndex:0];
		}
		_rightObj = _leftObj;
	}
}
+(void) insertArray:(NSArray *)array toListTail:(NSMutableArray *)list compare:(PYActionCompare)comp
{
	if ( [array count] == 0 ) return;
	if ( list == nil ) return;
	if ( comp == nil ) {
		int c = [array count];
		for ( int i = 0; i < c; ++i ) {
			[list addObject:[array objectAtIndex:i]];
		}
		return;
	}
	
	int c = [array count];
	id _rightObj = [list lastObject];
	for ( int i = 0; i < c; ++i ) {
		id _leftObj = [array objectAtIndex:i];
		if ( _rightObj == nil ) {
			[list addObject:_leftObj];
		} else {
			int r = comp( _leftObj, _rightObj );
			if ( r != PYCompareGreat ) continue;
			[list addObject:_leftObj];
		}
		_rightObj = _leftObj;
	}
}


@end
