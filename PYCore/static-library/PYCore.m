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

#import "PYCore.h"
#import "PYCoreMacro.h"
#import <mach/mach.h>
#import <sys/utsname.h>

#define PYCORE_TIME_FORMAT_BASIC	@"%04d-%02d-%02d %02d:%02d:%02d,%03d"

/*
 Get current device's model.
 */
PYDeviceModel __getDeviceModel();

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

NSUInteger __getMemoryInUse()
{
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        return info.resident_size;
    } else {
        PYLog(@"Error with task_info(): %s", mach_error_string(kerr));
        return -1;
    }
}

PYDeviceModel __currentDeviceModel()
{
    static PYDeviceModel _deviceModel = PYiDeviceUnknow;
    if ( _deviceModel == PYiDeviceUnknow ) {
        _deviceModel = __getDeviceModel();
    }
    return _deviceModel;
}

PYDeviceModel __getDeviceModel()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *modelName = [NSString stringWithCString:systemInfo.machine
                                             encoding:NSUTF8StringEncoding];
    PYDeviceModel _model = PYiDeviceUnknow;
    
    if([modelName isEqualToString:@"i386"]) {
        _model = PYiPhoneSimulator;
    }
    else if([modelName isEqualToString:@"iPhone1,1"]) {
        _model = PYiPhone;
    }
    else if([modelName isEqualToString:@"iPhone1,2"]) {
        //modelName = @"iPhone 3G";
        _model = PYiPhone3G;
    }
    else if([modelName isEqualToString:@"iPhone2,1"]) {
        //modelName = @"iPhone 3GS";
        _model = PYiPhone3GS;
    }
    else if([modelName isEqualToString:@"iPhone3,1"]) {
        //modelName = @"iPhone 4";
        _model = PYiPhone4;
    }
    else if([modelName rangeOfString:@"iPhone4,"].location != NSNotFound ) {
        //modelName = @"iPhone 4S";
        _model = PYiPhone4S;
    }
    else if([modelName rangeOfString:@"iPhone5,"].location != NSNotFound ) {
        //modelName = @"iPhone 5";
        _model = PYiPhone5;
    }
    else if([modelName rangeOfString:@"iPod1,"].location != NSNotFound ) {
        //modelName = @"iPod 1st Gen";
        _model = PYiPod1;
    }
    else if([modelName rangeOfString:@"iPod2,"].location != NSNotFound ) {
        //modelName = @"iPod 2nd Gen";
        _model = PYiPod2;
    }
    else if([modelName rangeOfString:@"iPod3,"].location != NSNotFound ) {
        //modelName = @"iPod 3rd Gen";
        _model = PYiPod3;
    }
    else if([modelName rangeOfString:@"iPod4,"].location != NSNotFound ) {
        _model = PYiPod4;
    }
    else if([modelName rangeOfString:@"iPod5,"].location != NSNotFound ) {
        _model = PYiPod5;
    }
    else if([modelName isEqualToString:@"iPad1,1"]) {
        //modelName = @"iPad";
        _model = PYiPad1Gen;
    }
    else if([modelName isEqualToString:@"iPad2,1"]) {
        //modelName = @"iPad 2(WiFi)";
        _model = PYiPad2Wifi;
    }
    else if([modelName isEqualToString:@"iPad2,2"]) {
        //modelName = @"iPad 2(GSM)";
        _model = PYiPad2GSM;
    }
    else if([modelName isEqualToString:@"iPad2,3"]) {
        //modelName = @"iPad 2(CDMA)";
        _model = PYiPad2CDMA;
    }
    else if([modelName isEqualToString:@"iPad2,5"]) {
        _model = PYiPadMini1Wifi;
    }
    else if([modelName isEqualToString:@"iPad2,6"]) {
        _model = PYiPadMini1GSM;
    }
    else if([modelName isEqualToString:@"iPad3,1"]) {
        //modelName = @"iPad 3(WiFi)";
        _model = PYiPad3Wifi;
    }
    else if([modelName isEqualToString:@"iPad3,2"]) {
        //modelName = @"iPad 3(GSM)";
        _model = PYiPad3GSM;
    }
    else if([modelName isEqualToString:@"iPad3,3"]) {
        //modelName = @"iPad 3(CDMA)";
        _model = PYiPad3CDMA;
    }
    else if([modelName isEqualToString:@"iPad4,1"]) {
        //modelName = @"iPad 4(WiFi)";
        _model = PYiPad4Wifi;
    }
    else if([modelName isEqualToString:@"iPad4,2"]) {
        //modelName = @"iPad 4(GSM)";
        _model = PYiPad4GSM;
    }
    else if([modelName isEqualToString:@"iPad4,3"]) {
        //modelName = @"iPad 4(CDMA)";
        _model = PYiPad4CDMA;
    }
    
    return _model;
}

unsigned long long __getFreeSpace()
{
    NSFileManager *_fm = [NSFileManager defaultManager];
    NSError *_error = nil;
    NSDictionary *_fsAttr = [_fm attributesOfFileSystemForPath:NSHomeDirectory()
                                                         error:&_error];
    if ( _error != nil ) {
        PYLog(@"Get Free Space Error: %@", _error.localizedDescription);
        return 0;
    }
    unsigned long long _freeSpace = [[_fsAttr objectForKey:NSFileSystemFreeSize]
                                     unsignedLongLongValue];
    return _freeSpace;
}

NSString *__bytesToHumanReadableString(unsigned long long bytes)
{
    if ( bytes < PYKiloByte ) return [NSString stringWithFormat:@"%lluB", bytes];
    if ( bytes < PYMegaByte ) return [NSString stringWithFormat:@"%.2fKB", bytes / (float)PYKiloByte];
    if ( bytes < PYGigaByte ) return [NSString stringWithFormat:@"%.2fMB", bytes / (float)PYMegaByte];
    return [NSString stringWithFormat:@"%.2fGB", bytes / (float)PYGigaByte];
}

// @littlepush
// littlepush@gmail.com
// PYLab
