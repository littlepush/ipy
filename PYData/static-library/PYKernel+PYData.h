//
//  PYKernel+PYData.h
//  PYData
//
//  Created by Push Chen on 7/31/14.
//  Copyright (c) 2014 Push Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PYCore/PYCore.h>

@interface PYKernel (PYData)

// GDC Object Cache Operations
- (void)updateKernelObject:(NSObject<NSCoding> *)object forKey:(NSString *)key;
- (NSObject<NSCoding> *)kernelObjectForKey:(NSString *)key;

@end
