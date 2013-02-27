//
//  PYKeyedDb.h
//  PYData
//
//  Created by Push Chen on 1/19/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PYDataPredefination.h"

@interface PYKeyedDb : NSObject
{
	sqlite3				*_innerDb;
}

+ (PYKeyedDb *) keyedDbWithPath:(NSString *)dbPath;

- (BOOL) addValue:(NSString *)formatedValue forKey:(NSString *)key;
- (BOOL) updateValue:(NSString *)formatedValue forKey:(NSString *)key;
- (void) deleteValueForKey:(NSString *)key;

- (BOOL) containsKey:(NSString *)key;

// Get the value
- (NSString *) valueForKey:(NSString *)key;

// data all count
- (int) count;

@end

@interface PYKeyedDb (Private)

// Other interface or message cannot create the
// db by alloc/init.
- (id) init;

@end