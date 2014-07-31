//
//  PYKernel+PYData.m
//  PYData
//
//  Created by Push Chen on 7/31/14.
//  Copyright (c) 2014 Push Lab. All rights reserved.
//

#import "PYKernel+PYData.h"
#import "PYGlobalDataCache.h"

@implementation PYKernel (PYData)

// GDC Object Cache Operations
- (void)updateKernelObject:(NSObject<NSCoding> *)object forKey:(NSString *)key
{
    static PYGlobalDataCache *_kernelCache = nil;
    if ( _kernelCache == nil ) {
        _kernelCache = [PYGlobalDataCache gdcWithIdentify:@"gdc.ipy.kernel"];
    }
    [_kernelCache setObject:object forKey:key];
}
- (NSObject<NSCoding> *)kernelObjectForKey:(NSString *)key
{
    static PYGlobalDataCache *_kernelCache = nil;
    if ( _kernelCache == nil ) {
        _kernelCache = [PYGlobalDataCache gdcWithIdentify:@"gdc.ipy.kernel"];
    }
    return [_kernelCache objectForKey:key];
}

@end
