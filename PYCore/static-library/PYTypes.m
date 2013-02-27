//
//  PYTypes.m
//  PYCore
//
//  Created by Push Chen on 12/1/11.
//  Copyright (c) 2011 Push Lab. All rights reserved.
//

#import "PYTypes.h"

#ifndef PY_CONSOLE_DEBUG
@implementation PYPoint

#define kEncodingPYPointX	@"kEncodingPYPointX"
#define kEncodingPYPointY	@"kEncodingPYPointY"

@synthesize x, y;

+(PYPoint *)pointX:(PYFloat)x Y:(PYFloat)y
{
	PYPoint *point = [[[PYPoint alloc] init] autorelease];
	point.x = x;
	point.y = y;
	return point;
}

+(PYPoint *)initWithCGPoint:(CGPoint)point
{
	return [PYPoint pointX:point.x Y:point.y];
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if ( self ) {
		self.x = [aDecoder decodeFloatForKey:kEncodingPYPointX];
		self.y = [aDecoder decodeFloatForKey:kEncodingPYPointY];
	}
	return self;
}

-(void) encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeFloat:x forKey:kEncodingPYPointX];
	[aCoder encodeFloat:y forKey:kEncodingPYPointY];
}

-(CGPoint)convertToCGPoint
{
	CGPoint point = { self.x, self.y };
	return point;
}

@end

@implementation PYSize

#define kEncodingPYSizeWidth	@"kEncodingPYSizeWidth"
#define kEncodingPYSizeHeight	@"kEncodingPYSizeHeight"

@synthesize width, height;

+(PYSize *)sizeWidth:(PYFloat)w Height:(PYFloat)h
{
	PYSize *size = [[[PYSize alloc] init] autorelease];
	size.width = w;
	size.height = h;
	return size;
}

+(PYSize *)initWithCGSize:(CGSize)size
{
	return [PYSize sizeWidth:size.width Height:size.height];
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if ( self ) {
		self.width = [aDecoder decodeFloatForKey:kEncodingPYSizeWidth];
		self.height = [aDecoder decodeFloatForKey:kEncodingPYSizeHeight];
	}
	return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeFloat:width forKey:kEncodingPYSizeWidth];
	[aCoder encodeFloat:height forKey:kEncodingPYSizeHeight];
}

-(CGSize)convertToCGSize
{
	CGSize size = { self.width, self.height };
	return size;
}

@end

@implementation PYRect

#define kEncodingPYRectOrigin	@"kEncodingPYRectOrigin"
#define kEncodingPYRectSize		@"kEncodingPYRectSize"

@synthesize origin, size;

+(PYRect *)rectWithx:(PYFloat)x y:(PYFloat)y width:(PYFloat)width height:(PYFloat)height
{
	PYRect *rect = [[[PYRect alloc] init] autorelease];
	rect.origin = [PYPoint pointX:x Y:y];
	rect.size = [PYSize sizeWidth:width Height:height];
	return rect;
}

+(PYRect *)initWithCGRect:(CGRect)rect
{
	PYRect *newRect = [PYRect rectWithx:rect.origin.x y:rect.origin.y width:rect.size.width height:rect.size.height];
	return newRect;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if ( self ) {
		self.origin = [aDecoder decodeObjectForKey:kEncodingPYRectOrigin];
		self.size = [aDecoder decodeObjectForKey:kEncodingPYRectSize];
	}
	return self;
}

-(void) encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:self.origin forKey:kEncodingPYRectOrigin];
	[aCoder encodeObject:self.size forKey:kEncodingPYRectSize];
}

-(CGRect)convertToCGRect
{
	CGRect rect = CGRectMake(origin.x, origin.y, size.width, size.height);
	return rect;
}

@end
#endif

/* Inner Class Implementation */
@implementation PYObserver
@synthesize selector, target;

+(PYObserver *)observerWithTarget:(id)tar selector:(SEL)sel
{
	PYObserver *observer = [[[PYObserver alloc] init] autorelease];
	observer.target = tar;
	observer.selector = sel;
	return observer;
}

@end

@implementation PYKeyValuePair

#define kEncodingPYKVKey	@"kEncodingPYKVKey"
#define kEncodingPYKVValue	@"kEncodingPYKVValue"

@synthesize key, value;

+(PYKeyValuePair *)pairWithKey:(NSString *)k Value:(id<NSObject>)v
{
	PYKeyValuePair *_pair = [[[PYKeyValuePair alloc] init] autorelease];
	_pair.key = k;
	_pair.value = v;
	return _pair;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if ( self ) {
		self.key = [aDecoder decodeObjectForKey:kEncodingPYKVKey];
		self.value = [aDecoder decodeObjectForKey:kEncodingPYKVValue];
	}
	return self;
}

-(void) encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:key forKey:kEncodingPYKVKey];
	[aCoder encodeObject:value forKey:kEncodingPYKVValue];
}


@end

@implementation PYObjectPair

#define kEncodingPYObjFirst		@"kEncodingPYObjFirst"
#define kEncodingPYObjSecond	@"kEncodingPYObjSecond"

@synthesize first, second;

+(PYObjectPair *)pairWithFirst:(id)_1st Second:(id)_2nd
{
	PYObjectPair *pair = [[[PYObjectPair alloc] init] autorelease];
	pair.first = _1st;
	pair.second = _2nd;
	return pair;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if ( self ) {
		self.first = [aDecoder decodeObjectForKey:kEncodingPYObjFirst];
		self.second = [aDecoder decodeObjectForKey:kEncodingPYObjSecond];
	}
	return self;
}

-(void) encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:first forKey:kEncodingPYObjFirst];
	[aCoder encodeObject:second forKey:kEncodingPYObjSecond];
}

@end

@implementation PYActionBlock

@synthesize name;
@synthesize done;
@synthesize get;
@synthesize failed;
@synthesize finished;

-(void) dealloc
{
	self.name = nil;
	self.done = nil;
	self.get = nil;
	self.failed = nil;
	self.finished = nil;
	[super dealloc];
}

////#if !__has_feature(objc_arc)
//+(PYActionBlock *)actionBlockWithStruct:(PYActionBlockStruct)actionStruct
//{
//	PYActionBlock *actionBlock = [[[PYActionBlock alloc] init] autorelease];
//	actionBlock.name = actionStruct.name;
//	actionBlock.done = actionStruct.done;
//	actionBlock.get = actionStruct.get;
//	actionBlock.failed = actionStruct.failed;
//	actionBlock.finished = actionStruct.finished;
//	return actionBlock;
//}
////#endif

@end



