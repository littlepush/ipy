//
//  PYCoreMacro.h
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

#ifndef PYCore_PYCoreMacro_h
#define PYCore_PYCoreMacro_h

#include <time.h>
#include <sys/timeb.h>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/stat.h>

// Common Type definition
typedef signed char				Int8;
typedef signed short int		Int16;
typedef signed int				Int32;
typedef signed long long int	Int64;
typedef unsigned char			Uint8;
typedef unsigned short int		Uint16;
typedef unsigned int			Uint32;
typedef unsigned long long int	Uint64;

#define CLR_RED(x)				"\033[1;31m" #x "\033[0m"   //error
#define CLR_YELLOW(x)			"\033[1;33m" #x "\033[0m"	//warn
#define CLR_GREEN(x)			"\033[1;32m" #x "\033[0m"	//info

#ifdef __cplusplus
extern "C" {
#endif
    
    #define PYCORE_TIME_FORMAT_BASIC	@"%04d-%02d-%02d %02d:%02d:%02d,%03d"
    
    // Get current time in simple format
    NSString * __getCurrentFormatDate();
    
    // Log fucntions
    void __formatLogLine(const char * __file,
                         const char * __func, Uint32
                         __line, NSString *__log);
    BOOL __qt_print_logHead(const char * __func, Uint32 __line );
    BOOL __qt_print_bool( const char * _exp, BOOL _bexp );
    BOOL __qt_print_while( const char * _exp, BOOL _bexp );
    BOOL __qt_print_else_bool( const char * _exp, BOOL _bexp );
    
    // Basic Functions
    NSString *__qt_doucmentPath( );
    NSString *__qt_guid( );
    NSString *__qt_timestampId( );
    
#ifdef __cplusplus
}
#endif

#define PYDOCUMENTPATH      (__qt_doucmentPath())
#define PYGUID              (__qt_guid())
#define PYTIMESTAMP         (__qt_timestampId())

#ifdef DEBUG
#    define PYLog(f, ...)	__formatLogLine(__FILE__, __FUNCTION__,                         \
                                __LINE__, [NSString stringWithFormat:(f), ##__VA_ARGS__])
#	 define IF(exp)         __qt_print_logHead(__FUNCTION__, __LINE__);                     \
                            if (__qt_print_bool( #exp, (exp) ))
#	 define ELSEIF(exp)     else if (__qt_print_logHead(__FUNCTION__, __LINE__) &&          \
                                __qt_print_else_bool( #exp, (exp)))
#	 define WHILE(exp)      __qt_print_logHead(__FUNCTION__, __LINE__);                     \
                            while (__qt_print_while( #exp, (exp) ))
#	 define DUMPInt(i)      __qt_print_logHead(__FUNCTION__, __LINE__);                     \
                            printf("{%s}:%d\n", #i, i)
#	 define DUMPFloat(f)	__qt_print_logHead(__FUNCTION__, __LINE__);                     \
                            printf("{%s}:%f\n", #f, f)
#	 define DUMPObj(o)      __qt_print_logHead(__FUNCTION__, __LINE__);                     \
                            printf("{%s}:%s\n", #o, [[o description] UTF8String])
#else
#    define PYLog(f, ...)   /* */
#	 define IF(exp)         if ( exp )
#	 define ELSEIF(exp)		else if ( exp )
#	 define WHILE(exp)      while ( exp )
#	 define DUMPInt(i)      /* */
#	 define DUMPFloat(f)	/* */
#	 define DUMPObj(o)      /* */
#endif

// Always Log
#define ALog(...)           NSLog(__VA_ARGS__)

#define PYLongToString(value)	[NSString stringWithFormat:@"%ld", value]
#define PYLongToObject(value)	[NSNumber numberWithLong:value]
#define PYIntToString(value)	[NSString stringWithFormat:@"%d", value]
#define PYIntToObject(value)	[NSNumber numberWithInt:value]
#define PYDoubleToObject(value)	[NSNumber numberWithDouble:value]
#define PYBoolToObject(value)	[NSNumber numberWithBool:value]

/* For async queue invoking. */
#define BEGIN_ASYNC_INVOKE									\
    dispatch_queue_t coQueue = dispatch_get_global_queue(	\
        DISPATCH_QUEUE_PRIORITY_LOW, 0);					\
    dispatch_async(coQueue, ^{
#define BEGIN_ASYNC_INVOKE_AFTER( sec )                     \
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,         \
        sec * NSEC_PER_SEC), dispatch_get_current_queue(),  \
^{
#define END_ASYNC_INVOKE									\
});
#define BEGIN_MAINTHREAD_INVOKE								\
dispatch_async( dispatch_get_main_queue(), ^{
#define END_MAINTHREAD_INVOKE								\
});
#define NOWDATE												\
[NSDate date]

#define PYValueInRange(v, min, max)							\
(((v) > (min)) && ((v) < (max)))
#define PYValueJustInrange(v, min, max)						\
(((v) >= (min)) && ((v) <= (max)))

#define CHAR_CONNECT_BASIC1( x, y )             x##y
#define CHAR_CONNECT( x, y )                    CHAR_CONNECT_BASIC1( x, y )


#define PYGETNIL( _obj, _getter )                           \
({ ((_obj) == nil) ? nil : [(_obj) _getter]; })
#define PYGETNIL2( _obj, _getter1, _getter2 )               \
PYGETNIL( PYGETNIL(_obj, _getter1), _getter2 )
#define PYGETDEFAULT( _obj, _getter, _default )             \
({ ((_obj) == nil) ? (_default) : [(_obj) _getter]; })

#define PYFLOATEQUAL( f1, f2 )                  (ABS((f1) - (f2)) < 0.001)

#define PYTHROW( f, ... )                                   \
    [self raiseExceptionWithMessage:[NSString               \
stringWithFormat:(f), ##__VA_ARGS__]];
#define PYASSERT( condition, f, ... )                       \
if ( !(condition) ) PYTHROW( f, ##__VA_ARGS__ )

#define PYIsIphone                                          \
([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define PYIsIpad                                            \
([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

#define SYSTEM_VERSION_EQUAL_TO(v)                          \
    ([[[UIDevice currentDevice] systemVersion]              \
        compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)                      \
    ([[[UIDevice currentDevice] systemVersion]              \
        compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)          \
    ([[[UIDevice currentDevice] systemVersion]              \
        compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                         \
    ([[[UIDevice currentDevice] systemVersion]              \
        compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)             \
    ([[[UIDevice currentDevice] systemVersion]              \
        compare:v options:NSNumericSearch] != NSOrderedDescending)


#define IS_WIDESCREEN (fabs((double)[[UIScreen mainScreen] bounds].size.height - \
                        (double)568) < DBL_EPSILON)
#define IS_IPHONE ([[[UIDevice currentDevice] model] isEqualToString:@"iPhone"])
#define IS_IPOD   (ß[[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"])

#define IS_IPHONE_5 (IS_IPHONE && IS_WIDESCREEN)


/* Coding Implementation */
/* The message has not been implementation yet, this macro is used as a mark */
#define __PY_NOT_IMPLEMENTATION__                           \
    [self raiseExceptionWithMessage:[NSString               \
        stringWithFormat:@"[%s] Not Implementation", __FUNCTION__]]
#define __PY_STATIC_NOT_IMPLEMENTATION__                    \
    [NSObject raiseExceptionWithMessage:@"Not Implementation"]

/* Singleton Imp */
#if !__has_feature(objc_arc)
#define PYSingletonDefaultImplementation					\
    -(id)copyWithZone:(NSZone *)zone { return self; }		\
    -(id)retain { return self; }							\
    -(NSUInteger)retainCount { return UINT_MAX; }			\
    -(oneway void)release { }								\
    -(id)autorelease { return self; }

#define PYSingletonAllocWithZone( gObj )					\
    +(id) allocWithZone:(NSZone *)zone {					\
        @synchronized(self) {								\
            if ( gObj == nil ) {							\
                gObj = [super allocWithZone:zone];			\
                return gObj;								\
        }                                                   \
        }													\
        return gObj;										\
    }
#else
#define PYSingletonDefaultImplementation					\
-(id)copyWithZone:(NSZone *)zone { return self; }
#define PYSingletonAllocWithZone( gObj )					\
    +(id) allocWithZone:(NSZone *)zone {					\
        @synchronized(self) {								\
            if ( gObj == nil ) {							\
                gObj = [super allocWithZone:zone];			\
                return gObj;								\
            }												\
        }													\
        return gObj;										\
    }
#endif

#define PYSingletonLock										\
@synchronized(self) {
#define PYSingletonUnLock									\
}

#define NF_CENTER	[NSNotificationCenter defaultCenter]

#define PYArchiveObject(property)                               \
[aCoder encodeObject:self.property forKey:@"kArc" #property]
#define PYArchiveInt(property)                                  \
[aCoder encodeInt:self.property forKey:@"kArc" #property]
#define PYArchiveInteger(property)                              \
[aCoder encodeInteger:self.property forKey:@"kArc" #property]
#define PYArchiveDouble(property)                               \
[aCoder encodeDouble:self.property forKey:@"kArc" #property]
#define PYArchiveBool(property)                                 \
[aCoder encodeBool:self.property forKey:@"kArc" #property]
#define PYArchiveValue(property)                                \
[aCoder encodeObject:[NSValue valueWithBytes:&(self->property)  \
    objCType:@encode(typeof(self->property))]					\
    forKey:@"kArc" #property]

#define PYUnArchiveObject(property)                             \
self.property = [aDecoder decodeObjectForKey:@"kArc" #property]
#define PYUnArchiveInt(property)                                \
self.property = [aDecoder decodeIntForKey:@"kArc" #property]
#define PYUnArchiveInteger(property)                            \
self.property = [aDecoder decodeIntegerForKey:@"kArc" #property]
#define PYUnArchiveDouble(property)                             \
self.property = [aDecoder decodeDoubleForKey:@"kArc" #property]
#define PYUnArchiveBool(property)                               \
self.property = [aDecoder decodeBoolForKey:@"kArc" #property]
#define PYUnArchiveValue(property)                              \
[(NSValue *)[aDecoder decodeObjectForKey:@"kArc" #property]     \
    getValue:&(self->property)]

// Block Definition
typedef void (^PYActionDone)(void);
typedef void (^PYActionGet)(id object);
typedef void (^PYActionFailed)(NSError *error);

#endif

// @littlepush
// littlepush@gmail.com
// PYLab
