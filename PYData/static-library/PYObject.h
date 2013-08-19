//
//  PYObject.h
//  PYData
//
//  Created by Push Chen on 8/19/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@protocol PYObject <NSObject>

@required
// Generate the content identify for GDC of a specified id.
// When we do not know the object but only get the item id, we
// use this method to generate the content identify and then fetch
// the item from GDC.
+ (NSString *)identifyOfId:(NSString *)objectId;

// Convert the JSON dictionary to our base bean object.
- (void)objectFromJsonDict:(NSDictionary *)jsonDict;

@optional
// Convert the bean object to a dictionary.
- (NSDictionary *)objectToJsonDict;

@end

@interface PYObject : NSObject <PYObject>

@property (nonatomic, copy)     NSString                *objectId;
@property (nonatomic, strong)   PYDate                  *updateTime;
@property (nonatomic, copy)     NSString                *type;
@property (nonatomic, copy)     NSString                *name;

// Properties for Global Data Cache Usage.
@property (nonatomic, readonly) NSString                *objectIdentify;
@property (nonatomic, readonly) Class                   objectClass;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
