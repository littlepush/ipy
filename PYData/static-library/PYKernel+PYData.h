//
//  PYKernel+PYData.h
//  PYData
//
//  Created by Push Chen on 7/31/14.
//  Copyright (c) 2014 Push Lab. All rights reserved.
//

/*
 LGPL V3 Lisence
 This file is part of cleandns.
 
 PYData is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 PYData is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with cleandns.  If not, see <http://www.gnu.org/licenses/>.
 */

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
#import <PYCore/PYCore.h>

@interface PYKernel (PYData)

// GDC Object Cache Operations

/*!
 @brief update the value in kernel data cache.
 @discussion the kernel data cache uses the identifier "gdc.ipy.kernel"
 @param object
    An NSCoding object which the GlobalDataCache needs as value.
 @param key
    The identifier of the value.
 */
- (void)updateKernelObject:(NSObject<NSCoding> *)object forKey:(NSString *)key;

/*!
 @brief get data from kernel cache.
 @param key
    the identifier of the wanted value.
 */
- (NSObject<NSCoding> *)kernelObjectForKey:(NSString *)key;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
