//
//  PYKernel.m
//  PYCore
//
//  Created by Push Chen on 7/31/14.
//  Copyright (c) 2014 PushLab. All rights reserved.
//

#import "PYKernel.h"
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
//#import <CoreTelephony/CTCarrier.h>
//#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "PYCoreMacro.h"
#import <UIKit/UIKit.h>

static PYKernel *_gKernel = nil;
@implementation PYKernel

PYSingletonAllocWithZone(_gKernel);
PYSingletonDefaultImplementation
+ (instancetype)currentKernel
{
    PYSingletonLock
    if ( _gKernel == nil ) {
        _gKernel = [[PYKernel alloc] init];
    }
    return _gKernel;
    PYSingletonUnLock
}

@synthesize version = _version;
@synthesize lastVersion = _oldVersionInCache;
@synthesize deviceId = _deviceId;
//@synthesize carrier = _carrier;
@synthesize isJailBroken = _isJailBroken;
@dynamic phoneType;
- (NSString *)phoneType
{
    // The phone type of this app should be iphone.
    return PYDEVICEMODELNAME;
}
@synthesize deviceToken = _deviceToken;
@synthesize productName = _productName;
@synthesize isFirstTimeInstall = _isFirstTimeInstall;

@dynamic internalVersion;
- (NSString *)internalVersion
{
    static const char * _months[] = {
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    };
    char _date[] = __DATE__;
    int year = atoi(_date + 9);
    _date[6] = 0;
    int day = atoi(_date + 4);
    _date[3] = 0;
    int month = 0;
    for (int i = 0; i < 12; ++i)
    {
        if (!strcmp(_date, _months[i]))
        {
            month = i + 1;
            break;
        }
    }
    NSString *_innerVersion = [NSString stringWithFormat:@"%02d%02d%02d", year, month, day];
    int _h, _m, _s;
    sscanf(__TIME__, "%02d:%02d:%02d", &_h, &_m, &_s);
    NSString *_minVersion = [NSString stringWithFormat:@"%02d%02d%02d", _h, _m, _s];
    return [NSString stringWithFormat:@"%@.%@.%@", self.version, _innerVersion, _minVersion];
}

- (id)init
{
    self = [super init];
    if ( self ) {
        if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0") ) {
            NSUUID *_nsUUID = nil;
            while (YES) {
                _nsUUID = [[UIDevice currentDevice] identifierForVendor];
                if ( _nsUUID == nil ) {
                    sleep(1);
                } else {
                    break;
                }
            }
            _deviceId = [_nsUUID UUIDString];
        } else {
            _deviceId = [NSKeyedUnarchiver
                         unarchiveObjectWithFile:
                         [PYLIBRARYPATH stringByAppendingPathComponent:@"com.ipy.deviceid"]];
            if ( [_deviceId length] == 0 ) {
                // Generate the device id.
                _deviceId = PYGUID;
                [NSKeyedArchiver
                 archiveRootObject:_deviceId
                 toFile:[PYLIBRARYPATH stringByAppendingPathComponent:@"com.ipy.deviceid"]];
            }
        }
        _version = [NSString stringWithFormat:@"%@",
                    [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
        _oldVersionInCache = [NSKeyedUnarchiver
                              unarchiveObjectWithFile:
                              [PYLIBRARYPATH stringByAppendingString:@"com.ipy.lastversion"]];
        if ( [_oldVersionInCache length] == 0 ) {
            _isFirstTimeInstall = YES;
        } else {
            if ( [_version isEqualToString:_oldVersionInCache] ) {
                _isFirstTimeInstall = NO;
            } else {
                _isFirstTimeInstall = YES;
            }
        }
        // Update version info.
        [NSKeyedArchiver
         archiveRootObject:_oldVersionInCache
         toFile:[PYLIBRARYPATH stringByAppendingString:@"com.ipy.lastversion"]];
        
        _deviceToken = [NSKeyedUnarchiver
                       unarchiveObjectWithFile:
                       [PYLIBRARYPATH stringByAppendingString:@"com.ipy.devicetoken"]];

        if ( _deviceToken == nil || [_deviceToken length] == 0 ) {
            _deviceToken = [@"" copy];
        }
//        CTTelephonyNetworkInfo *_ctInfo = [[CTTelephonyNetworkInfo alloc] init];
//        CTCarrier *_carrierObj = _ctInfo.subscriberCellularProvider;
//        _carrier = _carrierObj.carrierName;
        
        _isJailBroken = NO;
        if ( [[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"] ) {
            _isJailBroken = YES;
        }
        if ( [[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/lib/apt"] ) {
            _isJailBroken = YES;
        }
        
        NSString *_bundleIdentify = [[[NSBundle mainBundle] infoDictionary]
                                     objectForKey:(NSString *)kCFBundleIdentifierKey];
        NSArray *_bundleIdItems = [_bundleIdentify componentsSeparatedByString:@"."];
        if ( [_bundleIdItems count] == 0 ) {
            _productName = @"Unknow";
        } else {
            _productName = [_bundleIdItems lastObject];
        }
    }
    return self;
}

// Update device token
- (void)updateDeviceToken:(NSString *)newToken
{
    _deviceToken = [newToken copy];
    [NSKeyedArchiver
     archiveRootObject:_deviceToken
     toFile:[PYLIBRARYPATH stringByAppendingString:@"com.ipy.devicetoken"]];
}

@end
