//
//  PYKernel.h
//  PYCore
//
//  Created by Push Chen on 7/31/14.
//  Copyright (c) 2014 PushLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PYKernel : NSObject
{
    NSString                                *_deviceId;
    NSString                                *_version;
    NSString                                *_deviceToken;
    NSString                                *_carrier;
    NSString                                *_productName;
    NSString                                *_oldVersionInCache;
    BOOL                                    _isJailBroken;

    BOOL                                    _isFirstTimeInstall;
}

// Phone Type: iphone
@property (nonatomic, readonly) NSString                *phoneType;
// Device: MD5 of first MAC Address
@property (nonatomic, readonly) NSString                *deviceId;
// Version in Bundle.
@property (nonatomic, readonly) NSString                *version;
// Version in Bundle.
@property (nonatomic, readonly) NSString                *lastVersion;
// Device Token
@property (nonatomic, readonly) NSString                *deviceToken;
// Carrier
@property (nonatomic, readonly) NSString                *carrier;
// Product name
@property (nonatomic, readonly) NSString                *productName;

// Internal Version of this application.
@property (nonatomic, readonly) NSString                *internalVersion;
// Is jail broken
@property (nonatomic, readonly) BOOL                    isJailBroken;

// If current time is first time to install current version.
@property (nonatomic, readonly) BOOL                    isFirstTimeInstall;

// Get shared kernel object.
+ (instancetype)currentKernel;

// Update device token
- (void)updateDeviceToken:(NSString *)newToken;


@end
