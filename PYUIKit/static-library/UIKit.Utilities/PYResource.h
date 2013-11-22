//
//  PYResource.h
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

#import <Foundation/Foundation.h>

@interface PYResource : NSObject
{
    // Remote
    BOOL                    _resourceFromLocal;
    NSString                *_remoteDomain;
    // Local
    BOOL                    _resourceInBundle;
    NSString                *_localPath;
}

// Singleton instance.
+ (PYResource *)sharedResource;

// Load the resource, [sync].
+ (UIImage *)imageNamed:(NSString *)imageName;
+ (NSData *)contentWithFile:(NSString *)filename ofType:(NSString *)type;
+ (NSData *)contentWithFile:(NSString *)filename ofType:(NSString *)type inDir:(NSString *)dir;

// By default, the resources are all load from local files in bundle
+ (void)changeToLoadLocalBundleResource;

// Resources are all put in specified path and folder.
+ (void)changeToLoadLocalResourceInSpecifiedFolder:(NSString *)folder;

// Change to load remote resource under specified domain.
// We use HTTP to request the file.
+ (void)changeToLoadRemoteResourceWithDomain:(NSString *)domain;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
