//
//  PYObject.h
//  PYData
//
//  Created by Push Chen on 8/19/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

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

#import "PYGlobalDataCache.h"

@protocol PYObject <NSObject>

@required
/*!
 @brief  Generate the content identify for GDC of a specified id.
 @discussion When we do not know the object but only get the item id, we
 use this method to generate the content identify and then fetch
 the item from GDC.
 @param objectId
    The object id must be the string type.
 @return Return the string identifier.
 */
+ (NSString *)identifyOfId:(NSString *)objectId;

/*!
 @brief Convert the JSON dictionary to our base bean object.
 @discussion The basic PYObject will contains 4 parameters, 
 
    objectId => id
 
    updateTime => updatetime
 
    type => type
 
    name => name
 @param jsonDict
    The JSON dictionary object.
 */
- (void)objectFromJsonDict:(NSDictionary *)jsonDict;

/*!
 @brief Convert the bean object to a dictionary.
 @return Return the JSON dictionary object, contains all usable info.
 */
- (NSDictionary *)objectToJsonDict;

@end

@interface PYObject : NSObject <PYObject>

/*! @brief object id(id in JSON dictionary), unique with the same type. */
@property (nonatomic, copy)     NSString                *objectId;
/*! @brief update time of the object(updatetime in JSON dictionary) */
@property (nonatomic, strong)   PYDate                  *updateTime;
/*! @brief a string refers to current object's interface name(NSStringFromClass) */
@property (nonatomic, copy)     NSString                *type;
/*! @brief name of the object(name in JSON Dictionary) */
@property (nonatomic, copy)     NSString                *name;

/*! @brief unique identifier in any scope, usually is in the format of "type+objectId" */
@property (nonatomic, readonly) NSString                *objectIdentify;
/*! @brief get the class structure of current interface. */
@property (nonatomic, readonly) Class                   objectClass;

@end

@interface PYGlobalDataCache (PYObject)

/*!
 @brief Set a PYObject to the GDC directly.
 @discussion This method will invoke the PYObject's [objectToJsonDict] method
    and store the NSDictionary.
 @param value
    the PYObject object, be the value part.
 @param key
    the key to identify the value.
 */
- (void)setPYObject:(PYObject *)value forKey:(NSString *)key;
/*!
 @brief Set a PYObject to the GDC directly.
 @discussion This method will invoke the PYObject's [objectToJsonDict] method
    and store the NSDictionary.
 @param value
    the PYObject object, be the value part.
 @param key
    the key to identify the value.
 @param expire
    the expire date for the value
 */
- (void)setPYObject:(PYObject *)value forKey:(NSString *)key expire:(id<PYDate>)expire;
/*!
 @brief get the value in a type of PYObject for specified key.
 @discussion if the value is not a PYObject, will return nil.
 @param key
    key identifier of the value.
 */
- (PYObject *)PYObjectForKey:(NSString *)key;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
