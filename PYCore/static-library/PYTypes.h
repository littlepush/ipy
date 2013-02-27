//
//  PYTypes.h
//  PYCore
//
//  Created by Push Chen on 12/1/11.
//  Copyright (c) 2011 Push Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#ifndef PY_CONSOLE_DEBUG
#import <UIKit/UIKit.h>

/* 
 Tuita Library Common Data Structure.
 Convert the CGTypes to NSTypes, so that we can use
 PYCache or other container to store the point information.
 */

/* We make all point as Float. */
typedef double PYFloat;

/* Replace for the CGPoint */
@interface PYPoint : NSObject<NSCoding>

@property (nonatomic, assign) PYFloat x;
@property (nonatomic, assign) PYFloat y;

+(PYPoint *)pointX:(PYFloat)x Y:(PYFloat)y;
+(PYPoint *)initWithCGPoint:(CGPoint)point;

-(CGPoint)convertToCGPoint;

@end

/* Replace for the CGSize */
@interface PYSize : NSObject<NSCoding> 

@property (nonatomic, assign) PYFloat width;
@property (nonatomic, assign) PYFloat height;

+(PYSize *)initWithCGSize:(CGSize)size;
+(PYSize *)sizeWidth:(PYFloat)w Height:(PYFloat)h;

-(CGSize)convertToCGSize;

@end

/* Replace for the CGRect */
@interface PYRect : NSObject<NSCoding> 

@property (nonatomic, retain) PYPoint	*origin;
@property (nonatomic, retain) PYSize	*size;

+(PYRect *)rectWithx:(PYFloat)x y:(PYFloat)y 
			   width:(PYFloat)width height:(PYFloat)height;
+(PYRect *)initWithCGRect:(CGRect)rect;
-(CGRect)convertToCGRect;

@end
#endif

/*
 Cache Observer Class, Inner usage.
 */
@interface PYObserver : NSObject

/* Properties for cache observer. */
@property (nonatomic, retain)	id<NSObject>	target;
@property (nonatomic, assign)	SEL				selector;

+(PYObserver *)observerWithTarget:(id)tar selector:(SEL)sel;

@end

/*
 Key-Value Pair object.
 */
@interface PYKeyValuePair : NSObject<NSCoding> 

@property (nonatomic, copy)		NSString		*key;
@property (nonatomic, retain)	id<NSObject>	value;

+(PYKeyValuePair *)pairWithKey:(NSString *)k Value:(id<NSObject>)v;

@end

/*
 Object Pair
 */
@interface PYObjectPair : NSObject<NSCoding> 

@property (nonatomic, retain)	id<NSObject>	first;
@property (nonatomic, retain)	id<NSObject>	second;

+(PYObjectPair *)pairWithFirst:(id<NSObject>)_1st Second:(id<NSObject>)_2nd;

@end

/*
	Action Block, none nscoding
 */
// objective-c block
typedef enum {
	PYCompareLess	= -1,
	PYCompareEqual	= 0,
	PYCompareGreat	= 1
} PYCompare;
typedef void (^PYActionDone)(void);
typedef void (^PYActionGet)(id result);
typedef void (^PYActionFailed)(NSError *error);
typedef void (^PYActionFinished)(BOOL success);
typedef PYCompare (^PYActionCompare)(id left, id right);

//#if !__has_feature(objc_arc)
//typedef struct {
//	PYActionDone		done;
//	PYActionGet			get;
//	PYActionFailed		failed;
//	PYActionFinished	finished;
//} PYActionBlockStruct;
//#endif

@interface PYActionBlock : NSObject

@property (nonatomic, copy)		NSString			*name;
@property (nonatomic, copy)		PYActionDone		done;
@property (nonatomic, copy)		PYActionGet			get;
@property (nonatomic, copy)		PYActionFailed		failed;
@property (nonatomic, copy)		PYActionFinished	finished;

//#if !__has_feature(objc_arc)
//+(PYActionBlock *) actionBlockWithStruct:(PYActionBlockStruct)actionStruct;
//#endif
//
@end

