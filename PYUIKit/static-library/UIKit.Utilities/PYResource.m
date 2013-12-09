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
        _localPath = @"";
    }
    return self;
}

+ (NSData *)__loadDataWithContentsOfFile:(NSString *)filepath scale:(CGFloat *)scale
{
    if ( scale != NULL ) *scale = 1.f;
    
    NSData *_contentData = [NSData dataWithContentsOfURL:[NSURL URLWithString:filepath]];
    if ( _contentData != nil ) return _contentData;
    
    // Failed.
    NSString *_rootDir = [filepath stringByDeletingLastPathComponent];
    NSArray *_pathComponents = [_rootDir pathComponents];
    NSString *_firstPart = [_pathComponents safeObjectAtIndex:0];
    if ( [_firstPart length] == 0 ) {
        // Not a falidate path
        return nil;
    }
    if ( [_firstPart rangeOfString:@":"].location != NSNotFound ) {
        // has protocol header
        // try to rebuild the path components
        NSMutableArray *_components = [NSMutableArray arrayWithArray:_pathComponents];
        [_components removeObjectAtIndex:0];
        //if ( [_firstPart rangeOfString:@"file:"].location == NSNotFound ) {
            // Do not need to add file path.
            NSArray *_protocolParts = [_firstPart componentsSeparatedByString:@":"];
            NSString *_protocolHeader = [_protocolParts safeObjectAtIndex:0];
            _protocolHeader = [_protocolHeader stringByAppendingString:@"://"];
            [_components insertObject:_protocolHeader atIndex:0];
        //} else {
        //    [_components insertObject:@"" atIndex:0];
        //}
        _rootDir = [_components componentsJoinedByString:@"/"];
        DUMPObj(_rootDir);
    }
    NSString *_fileExt = [filepath pathExtension];
    NSString *_nodeComponent = [filepath lastPathComponent];
    NSString *_filename = [_nodeComponent stringByDeletingPathExtension];
    
    // Try @2x
    if ( scale != NULL ) *scale = 2.f;
    NSString *_2xFilename = [[_filename stringByAppendingString:@"@2x"]
                             stringByAppendingPathExtension:_fileExt];
    NSString *_2xPath = [_rootDir stringByAppendingPathComponent:_2xFilename];
    _contentData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_2xPath]];
    if ( _contentData != nil ) return _contentData;
    
    // Try -568h@2x only
    if ( scale != NULL ) *scale = 2.f;
    if ( PYIsIphone && [UIScreen mainScreen].bounds.size.height >= 568.f ) {
        NSString *_568hFilename = [[_filename stringByAppendingString:@"-568h@2x"]
                                   stringByAppendingPathExtension:_fileExt];
        NSString *_568hPath = [_rootDir stringByAppendingPathComponent:_568hFilename];
        _contentData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_568hPath]];
        if ( _contentData != nil ) return _contentData;
    }
    
    // Try ~iphone/~ipad
    for ( int i = 0; i < 2; ++i ) {
        if ( PYIsIphone ) {
            if ( [UIScreen mainScreen].bounds.size.height >= 568.f && i == 0 ) {
                if ( scale != NULL ) *scale = 2.f;
                NSString *_iphone568Filename = [[_filename stringByAppendingString:@"-568h@2x~iphone"]
                                                stringByAppendingPathExtension:_fileExt];
                NSString *_iphone568Path = [_rootDir stringByAppendingPathComponent:_iphone568Filename];
                _contentData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_iphone568Path]];
                if ( _contentData != nil ) return _contentData;
            }
            if ( scale != NULL ) *scale = (i + 1.f);
            NSString *_iphoneFilename = [[_filename stringByAppendingString:@"~iphone"]
                                         stringByAppendingPathExtension:_fileExt];
            NSString *_iphonePath = [_rootDir stringByAppendingPathComponent:_iphoneFilename];
            _contentData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_iphonePath]];
            if ( _contentData != nil ) return _contentData;
        } else {
            if ( scale != NULL ) *scale = (i + 1.f);
            NSString *_ipadFilename = [[_filename stringByAppendingString:@"~ipad"]
                                       stringByAppendingPathExtension:_fileExt];
            NSString *_ipadPath = [_rootDir stringByAppendingPathComponent:_ipadFilename];
            _contentData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_ipadPath]];
            if ( _contentData != nil ) return _contentData;
        }
        // Loop to Try @2x~iphone/@2x~ipad
        _filename = [_filename stringByAppendingString:@"@2x"];
    }
    return _contentData;
}

// Global loading, ignore any setting of [PYResource]
+ (NSData *)loadDataWithContentsOfFile:(NSString *)filepath
{
    return [PYResource __loadDataWithContentsOfFile:filepath scale:NULL];
}

+ (UIImage *)imageNamed:(NSString *)imageName
{
    PYSingletonLock
    if ( _self->_resourceFromLocal ) {
        if ( _self->_resourceInBundle ) {
            return [UIImage imageNamed:imageName];
        } else {
            CGFloat _scale = 1.f;
            NSString *_localImagePath = [_self->_localPath
                                         stringByAppendingPathComponent:imageName];
            NSData *_data = [PYResource __loadDataWithContentsOfFile:_localImagePath
                                                               scale:&_scale];
            if ( _data == nil ) return nil;
            return [UIImage imageWithData:_data scale:_scale];
        }
    } else {
        if ( [_self->_remoteDomain length] == 0 ) return nil;
        NSString *_reqUrl = [_self->_remoteDomain stringByAppendingPathComponent:imageName];
        CGFloat _scale = 1.f;
        NSData *_data = [PYResource __loadDataWithContentsOfFile:_reqUrl scale:&_scale];
        if ( _data == nil ) return nil;
        return [UIImage imageWithData:_data scale:_scale];
    }
    PYSingletonUnLock
}

+ (NSData *)contentWithFile:(NSString *)filename ofType:(NSString *)type
{
    PYSingletonLock
    if ( _self->_resourceFromLocal ) {
        if ( _self->_resourceInBundle ) {
            return [NSData dataWithContentsOfFile:
                    [[NSBundle mainBundle]
                     pathForResource:filename
                     ofType:type]];
        } else {
            NSString *_filename = [filename stringByAppendingPathExtension:type];
            NSString *_localFilePath = [_self->_localPath
                                        stringByAppendingPathComponent:_filename];
            return [PYResource loadDataWithContentsOfFile:_localFilePath];
        }
    } else {
        NSString *_reqUrl = [_self->_remoteDomain
                             stringByAppendingPathComponent:
                             [filename stringByAppendingPathExtension:type]];
        return [PYResource loadDataWithContentsOfFile:_reqUrl];
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
            NSString *_localFilePath = [_self->_localPath
                                        stringByAppendingPathComponent:_dir_filename];
            return [PYResource loadDataWithContentsOfFile:_localFilePath];
        }
    } else {
        NSString *_reqUrl = [_self->_remoteDomain
                             stringByAppendingPathExtension:
                             [dir stringByAppendingPathComponent:
                              [filename stringByAppendingPathExtension:type]]];
        return [PYResource loadDataWithContentsOfFile:_reqUrl];
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

+ (void)changeToLoadLocalResourceInSpecifiedFolder:(NSString *)folder
{
    PYSingletonLock
    _self->_resourceFromLocal = YES;
    _self->_resourceInBundle = NO;
    _self->_localPath = [folder copy];
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

