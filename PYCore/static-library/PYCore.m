//
//  PYCore.m
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

// @littlepush
// littlepush@gmail.com
// PYLab

#import "PYCore.h"
#import "PYCoreMacro.h"
    
#define PYCORE_TIME_FORMAT_BASIC	@"%04d-%02d-%02d %02d:%02d:%02d,%03d"

// Get current time in simple format
NSString * __getCurrentFormatDate()
{
    struct timeb _timeBasic;
    struct tm *  _timeStruct;
    ftime( &_timeBasic );
    _timeStruct = localtime( &_timeBasic.time );
    return [NSString stringWithFormat:PYCORE_TIME_FORMAT_BASIC,
            (Uint16)(_timeStruct->tm_year + 1900), (Uint8)(_timeStruct->tm_mon + 1),
            (Uint8)(_timeStruct->tm_mday), (Uint8)(_timeStruct->tm_hour),
            (Uint8)(_timeStruct->tm_min), (Uint32)(_timeStruct->tm_sec),
            (Uint16)(_timeBasic.millitm)];
}

void __formatLogLine(const char * __file,
                     const char * __func, Uint32
                     __line, NSString *__log)
{
    printf("[%s]<%s:%u> %s\n", [__getCurrentFormatDate() UTF8String],
           __func, __line, [__log UTF8String]);
}

BOOL __qt_print_logHead(const char * __func, Uint32 __line )
{
    printf("[%s]<%s:%u>", [__getCurrentFormatDate() UTF8String],
           __func, __line);
    return YES;
}
BOOL __qt_print_bool( const char * _exp, BOOL _bexp )
{
    printf("{%s}: %s\n", _exp, (_bexp ? "YES" : "NO"));
    return _bexp;
}
BOOL __qt_print_while( const char * _exp, BOOL _bexp )
{
    printf("{WHILE:%s}: %s\n", _exp, (_bexp ? "YES" : "NO"));
    return _bexp;
}
BOOL __qt_print_else_bool( const char * _exp, BOOL _bexp )
{
    printf("{else: %s}: %s\n", _exp, (_bexp ? "YES" : "NO"));
    return _bexp;
}

NSString *__qt_doucmentPath( ) {
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    return documentDirectory;
}

NSString *__qt_guid( ) {
    // create a new UUID which you own
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    
    // create a new CFStringRef (toll-free bridged to NSString)
    // that you own
    NSString *uuidString = (NSString *)CFBridgingRelease
    (CFUUIDCreateString(kCFAllocatorDefault, uuid));
    uuidString = [uuidString
                  stringByReplacingOccurrencesOfString:@"-"
                  withString:@""];
    // transfer ownership of the string
    // to the autorelease pool
    
    // release the UUID
    CFRelease(uuid);
    
    return uuidString;
}

NSString *__qt_timestampId( ) {
    struct timeval _timenow;
    gettimeofday( &_timenow, NULL );
    int64_t _milesecond = _timenow.tv_sec;
    _milesecond *= 1000;
    _milesecond += (_timenow.tv_usec / 1000);
    NSString *_timestamp = [NSString stringWithFormat:@"%lld", _milesecond];
    return _timestamp;
}

