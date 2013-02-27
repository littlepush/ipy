//
//  PYMainMacro.h
//  PYCore
//
//  Created by littlepush on 9/5/12.
//  Copyright (c) 2012 PushLab. All rights reserved.
//

#ifndef PYCore_PYMainMacro_h
#define PYCore_PYMainMacro_h

#include <time.h>
#include <sys/timeb.h>
#include <sys/types.h>

// Common Type definition
typedef signed char				Int8;
typedef signed short int		Int16;
typedef signed int				Int32;
typedef signed long long int	Int64;
typedef unsigned char			Uint8;
typedef unsigned short int		Uint16;
typedef unsigned int			Uint32;
typedef unsigned long long int	Uint64;

#define _PY_CLR_RED_			"\033[0;32;31m"
#define _PY_CLR_LRED_			"\033[1;31m"
#define _PY_CLR_YELLOW_			"\033[1;33m"
#define _PY_CLR_GREEN_			"\033[1;32m"
#define _PY_CLR_BLUE_			"\033[1;34m"
#define _PY_CLR_PURPLE			"\033[1;35m"

#define CLR_RED(x)				"\033[1;31m" #x "\033[0m"  //error
#define CLR_YELLOW(x)			"\033[1;33m" #x "\033[0m"	//warn
#define CLR_GREEN(x)			"\033[1;32m" #x "\033[0m"	//info

#ifdef __cplusplus
extern "C" {
#endif

#define PLIB_TIME_FORMAT_BASIC	@"%04d-%02d-%02d %02d:%02d:%02d,%03d"

static inline
NSString * __getCurrentFormatDate() {
	struct timeb _timeBasic;
	struct tm *  _timeStruct;
	ftime( &_timeBasic );
	_timeStruct = localtime( &_timeBasic.time );
	return [NSString stringWithFormat:PLIB_TIME_FORMAT_BASIC,
		(Uint16)(_timeStruct->tm_year + 1900), (Uint8)(_timeStruct->tm_mon + 1), 
		(Uint8)(_timeStruct->tm_mday), (Uint8)(_timeStruct->tm_hour), 
		(Uint8)(_timeStruct->tm_min), (Uint32)(_timeStruct->tm_sec), 
		(Uint16)(_timeBasic.millitm)];
}

static inline
void __formatLogLine(
	const char * __file, 
	const char * __func,
	Uint32 __line,
	NSString *__log)
{
	printf("[%s]<%s:%u> %s\n", [__getCurrentFormatDate() UTF8String],
		__func, __line, [__log UTF8String]);
}

static inline
void __py_print_logHead(const char * __func, Uint32 __line ) {
	printf("[%s]<%s:%u>", [__getCurrentFormatDate() UTF8String], __func, __line);
}
static inline
BOOL __py_print_bool( const char * _exp, BOOL _bexp ) {
	printf("{%s}: %s\n", _exp, (_bexp ? "YES" : "NO"));
	return _bexp;
}
static inline
BOOL __py_print_while( const char * _exp, BOOL _bexp ) {
	printf("{WHILE:%s}: %s\n", _exp, (_bexp ? "YES" : "NO"));
	return _bexp;
}
static inline
BOOL __py_print_else_bool( const char * _exp, BOOL _bexp ) {
	printf("{else: %s}: %s\n", _exp, (_bexp ? "YES" : "NO"));
	return _bexp;
}

#ifdef __cplusplus
}
#endif

#ifdef DEBUG
#    define PYLog(f, ...)	__formatLogLine(__FILE__, __FUNCTION__,	\
		__LINE__, [NSString stringWithFormat:(f), ##__VA_ARGS__])
#	 define PYIF(exp)		__py_print_logHead(__FUNCTION__, __LINE__); if (__py_print_bool( #exp, (exp) ))
#	 define PYELIF(exp)		__py_print_logHead(__FUNCTION__, __LINE__); else if (__py_print_else_bool( #exp, (exp)))
#	 define PYWHILE(exp)	__py_print_logHead(__FUNCTION__, __LINE__); while (__py_print_while( #exp, (exp) ))
#	 define PYDUMPInt(i)	__py_print_logHead(__FUNCTION__, __LINE__); printf("{%s}:%d\n", #i, i)
#	 define PYDUMPFloat(f)	__py_print_logHead(__FUNCTION__, __LINE__); printf("{%s}:%f\n", #f, f)
#	 define PYDUMPObj(o)	__py_print_logHead(__FUNCTION__, __LINE__); printf("{%s}:%s\n", #o, [[o description] UTF8String])
#else
#    define PYLog(f, ...)	/* */
#	 define PYIF(exp)		if ( exp )
#	 define PYELIF(exp)		else if ( exp )
#	 define PYWHILE(exp)	while ( exp )
#	 define PYDUMPInt(i)	/* */
#	 define PYDUMPFloat(f)	/* */
#	 define PYDUMPObj(o)	/* */
#endif
#define ALog(...) NSLog(__VA_ARGS__)

/* For async queue invoking. */
#define BEGIN_ASYNC_INVOKE									\
	dispatch_queue_t coQueue = dispatch_get_global_queue(	\
		DISPATCH_QUEUE_PRIORITY_LOW, 0);					\
	dispatch_async(coQueue, ^{
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
#define CHAR_CONNECT1( x, y )                   CHAR_CONNECT_BASIC1( x, y )


// PYCHECKGET( PYCHECKGET(_object, level1getter), level2getter );	
#define PYGETNIL( _obj, _getter )					\
	({ ((_obj) == nil) ? nil : [(_obj) _getter]; })
#define PYGETNIL2( _obj, _getter1, _getter2 )		\
	PYGETNIL( PYGETNIL(_obj, _getter1), _getter2 )
#define PYGETDEFAULT( _obj, _getter, _default )		\
	({ ((_obj) == nil) ? (_default) : [(_obj) _getter]; })
	
#define PYFLOATEQUAL( f1, f2 )					(ABS((f1) - (f2)) < 0.001)

#define PYTHROW( message )							\
	[self raiseExceptionWithMessage:(message)]
#define PYASSERT( condition, message )				\
	if ( !(condition) ) PYTHROW( (message) )
	
#define PYLastErrorCode				errno
#define PYLastErrorMessage			[NSString stringWithFormat:@"%s", strerror(errno)]

#define PYIsIphone									\
	([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define PYIsIpad									\
	([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
	
#define PYIsRetina									\
	([[UIScreen mainScreen] respondsToSelector:@selector(scale)]	\
		&& [[UIScreen mainScreen] scale] == 2.0)
		
#define SYSTEM_VERSION_EQUAL_TO(v)                  \
	([[[UIDevice currentDevice] systemVersion]		\
		compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              \
	([[[UIDevice currentDevice] systemVersion]		\
		compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  \
	([[[UIDevice currentDevice] systemVersion]		\
		compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 \
	([[[UIDevice currentDevice] systemVersion]		\
		compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     \
	([[[UIDevice currentDevice] systemVersion]		\
		compare:v options:NSNumericSearch] != NSOrderedDescending)


#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define IS_IPHONE ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPhone" ] )
#define IS_IPOD   ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPod touch" ] )

#define IS_IPHONE_5 ( IS_IPHONE && IS_WIDESCREEN )


/* Coding Implementation */		
/* The message has not been implementation yet, this macro is used as a mark */
#define __PY_NOT_IMPLEMENTATION__					\
	[self raiseExceptionWithMessage:@"Not Implementation"]
#define __PY_STATIC_NOT_IMPLEMENTATION__			\
	[[NSObject object] raiseExceptionWithMessage:@"Not Implementation"]

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
			}												\
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

#if !__has_feature(objc_arc)
#define PYSingleton(interface, message, gobj)				\
+(interface *) message {									\
	PYSingletonLock											\
	if ( gobj == nil ) {									\
		NSArray *paths = NSSearchPathForDirectoriesInDomains(					\
		NSDocumentDirectory, NSUserDomainMask, YES);							\
		NSString *documentDirectory = [paths objectAtIndex:0];					\
		NSString *_path = [documentDirectory stringByAppendingPathComponent:	\
                           NSStringFromClass([self class])];					\
		_path = [_path stringByAppendingPathExtension:@"dat"];					\
		gobj = [NSKeyedUnarchiver unarchiveObjectWithFile:_path];				\
		if ( gobj == nil ) gobj = [[self class] object];	\
		[gobj retain];										\
	}														\
	PYSingletonUnLock										\
	return gobj;											\
}															\
PYSingletonDefaultImplementation							\
PYSingletonAllocWithZone( gobj )
#else
#define PYSingleton(interface, message, gobj)				\
+(interface *) message {									\
	PYSingletonLock											\
	if ( gobj == nil ) {									\
		NSArray *paths = NSSearchPathForDirectoriesInDomains(					\
		NSDocumentDirectory, NSUserDomainMask, YES);							\
		NSString *documentDirectory = [paths objectAtIndex:0];					\
		NSString *_path = [documentDirectory stringByAppendingPathComponent:	\
                           NSStringFromClass([self class])];					\
		_path = [_path stringByAppendingPathExtension:@"dat"];					\
		gobj = [NSKeyedUnarchiver unarchiveObjectWithFile:_path];				\
		if ( gobj == nil ) gobj = [[self class] object];	\
	}														\
	PYSingletonUnLock										\
	return gobj;											\
}															\
PYSingletonDefaultImplementation							\
PYSingletonAllocWithZone( gobj )
#endif

#define NF_CENTER	[NSNotificationCenter defaultCenter]


#define PYArchiveObject(property)		\
	[aCoder encodeObject:self.property forKey:@"kArc" #property]
#define PYArchiveInt(property)			\
	[aCoder encodeInt:self.property forKey:@"kArc" #property]
#define PYArchiveInteger(property)		\
	[aCoder encodeInteger:self.property forKey:@"kArc" #property]
#define PYArchiveDouble(property)		\
	[aCoder encodeDouble:self.property forKey:@"kArc" #property]
#define PYArchiveBool(property)			\
	[aCoder encodeBool:self.property forKey:@"kArc" #property]
#define PYArchiveValue(property)		\
	[aCoder encodeObject:[NSValue valueWithBytes:&(self->property)	\
		objCType:@encode(typeof(self->property))]					\
	forKey:@"kArc" #property]

#define PYUnArchiveObject(property)		\
	self.property = [aDecoder decodeObjectForKey:@"kArc" #property]
#define PYUnArchiveInt(property)			\
	self.property = [aDecoder decodeIntForKey:@"kArc" #property]
#define PYUnArchiveInteger(property)		\
	self.property = [aDecoder decodeIntegerForKey:@"kArc" #property]
#define PYUnArchiveDouble(property)		\
	self.property = [aDecoder decodeDoubleForKey:@"kArc" #property]
#define PYUnArchiveBool(property)			\
	self.property = [aDecoder decodeBoolForKey:@"kArc" #property]
#define PYUnArchiveValue(property)						\
	[(NSValue *)[aDecoder decodeObjectForKey:@"kArc" #property]	\
		getValue:&(self->property)]

#endif
