//
//  NSObject+PYCore.h
//  PYCore
//
//  Created by Push Chen on 3/31/13.

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

#if __has_feature(objc_arc)
#define __AUTO_RELEASE(obj)                 obj
#define __RETAIN(obj)                       obj
#define __RELEASE(obj)                      // nothing
#else
#define __AUTO_RELEASE(obj)                 [obj autorelease]
#define __RETAIN(obj)                       [obj retain]
#define __RELEASE(obj)                      [obj release]
#endif

@interface NSObject (PYCore)

/* Raise an exception and throw the message specifed. */
- (void)raiseExceptionWithMessage:(NSString *)message;
+ (void)raiseExceptionWithMessage:(NSString *)message;

/* Create a NSError object with message */
- (NSError *)errorWithCode:(int)code message:(NSString *)message;
+ (NSError *)errorWithCode:(int)code message:(NSString *)message;

/* return an autorelease object */
+ (id)object;

/* Increase the reference count in Non-ARC mode, or do nothing */
- (id)increaseRC;

/* Decrease the reference count in Non-ARC mode, or do nothing */
- (void)decreaseRC;

// For Delegated object, try to perform selector
- (id)tryPerformSelector:(SEL)sel;
- (id)tryPerformSelector:(SEL)sel withObject:(id)object;
- (id)tryPerformSelector:(SEL)sel withObject:(id)obj1 withObject:(id)obj2;

// Perform Block In background thread.
- (void)performBlockInBackground:(void(^)())block;

// The object must be a certain type, or throw an exception.
- (void)mustBeTypeOrFailed:(Class)type;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
