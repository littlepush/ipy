//
//  PYResource.m
//  PYUIKit
//
//  Created by Push Chen on 11/13/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
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

#import "PYResource.h"

static PYResource *_gResource = nil;
#define _self           [PYResource sharedResource]

@implementation PYResource

+ (PYResource *)sharedResource
{
    PYSingletonLock
    if ( _gResource == nil ) {
        _gResource = [PYResource object];
    }
    return _gResource;
    PYSingletonUnLock
}

PYSingletonAllocWithZone(_gResource);
PYSingletonDefaultImplementation

- (id)init
{
    self = [super init];
    if ( self ) {
        _resourceFromLocal = YES;
        _remoteDomain = @"";
        _resourceInBundle = YES;
        _localResourceFolder = @"";
    }
    return self;
}


+ (UIImage *)imageNamed:(NSString *)imageName
{
    PYSingletonLock
    if ( _self->_resourceFromLocal ) {
        if ( _self->_resourceInBundle ) {
            return [UIImage imageNamed:imageName];
        } else {
            NSString *_localImagePath = [_self->_localResourceFolder
                                         stringByAppendingPathComponent:imageName];
            return [UIImage imageWithContentsOfFile:_localImagePath];
        }
    } else {
        if ( [_self->_remoteDomain length] == 0 ) return nil;
        NSString *_reqUrl = [_self->_remoteDomain stringByAppendingPathComponent:imageName];
        NSURL *_url = [NSURL URLWithString:_reqUrl];
        NSData *_data = [NSData dataWithContentsOfURL:_url];
        if ( _data == nil ) return nil;
        return [UIImage imageWithData:_data];
    }
    PYSingletonUnLock
}

+ (NSData *)contentWithFile:(NSString *)filename ofType:(NSString *)type
{
    PYSingletonLock
    if ( _self->_resourceFromLocal ) {
        if ( _self->_resourceInBundle ) {
            return [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:type]];
        } else {
            NSString *_filename = [filename stringByAppendingPathExtension:type];
            NSString *_localFilePath = [_self->_localResourceFolder
                                            stringByAppendingPathComponent:_filename];
            return [NSData dataWithContentsOfFile:_localFilePath];
        }
    } else {
        NSString *_reqUrl = [_self->_remoteDomain
                             stringByAppendingPathComponent:
                             [filename stringByAppendingPathExtension:type]];
        NSURL *_url = [NSURL URLWithString:_reqUrl];
        return [NSData dataWithContentsOfURL:_url];
    }
    PYSingletonUnLock
}

+ (NSData *)contentWithFile:(NSString *)filename ofType:(NSString *)type inDir:(NSString *)dir
{
    PYSingletonLock
    if ( _self->_resourceFromLocal ) {
        if ( _self->_resourceInBundle ) {
            return [NSData dataWithContentsOfFile:
                    [[NSBundle mainBundle] pathForResource:filename
                                                    ofType:type
                                               inDirectory:dir]];
        } else {
            NSString *_filename = [filename stringByAppendingPathExtension:type];
            NSString *_dir_filename = [dir stringByAppendingPathComponent:_filename];
            NSString *_localFilePath = [_self->_localResourceFolder
                                        stringByAppendingPathComponent:_dir_filename];
            return [NSData dataWithContentsOfFile:_localFilePath];
        }
    } else {
        NSString *_reqUrl = [_self->_remoteDomain
                             stringByAppendingPathExtension:
                             [dir stringByAppendingPathComponent:
                              [filename stringByAppendingPathExtension:type]]];
        NSURL *_url = [NSURL URLWithString:_reqUrl];
        return [NSData dataWithContentsOfURL:_url];
    }
    PYSingletonUnLock
}

+ (void)changeToLoadLocalBundleResource
{
    PYSingletonLock
    _self->_resourceFromLocal = YES;
    _self->_resourceInBundle = YES;
    PYSingletonUnLock
}

+ (void)changeToLoadLocalResourceInFolder:(NSString *)folder
{
    PYSingletonLock
    _self->_resourceFromLocal = YES;
    _self->_resourceInBundle = NO;
    _self->_localResourceFolder = [folder copy];
    PYSingletonUnLock
}

+ (void)changeToLoadRemoteResourceWithDomain:(NSString *)domain
{
    PYSingletonLock
    _self->_remoteDomain = [domain copy];
    _self->_resourceFromLocal = NO;
    PYSingletonUnLock
}


@end

// @littlepush
// littlepush@gmail.com
// PYLab

