//
//  PYKeyedDb.h
//  PYData
//
//  Created by Push Chen on 1/19/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
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
#import "PYDataPredefination.h"
#import "PYSqlStatement.h"
#import <PYCore/PYDate.h>

#define		kKeyedDBTableName		@"_PYkeyedCache"

// DB Row
@interface PYKeyedDbRow : NSObject

@property (nonatomic, strong)   NSData          *value;
@property (nonatomic, strong)   id<PYDate>      expire;

@end

@interface PYKeyedDb : NSObject
{
	sqlite3				*_innerDb;
    NSString            *_dbPath;
    
    PYSqlStatement      *_insertStat;
    PYSqlStatement      *_updateStat;
    PYSqlStatement      *_deleteStat;
    PYSqlStatement      *_countStat;
    PYSqlStatement      *_selectStat;
    PYSqlStatement      *_checkStat;
    
    PYSqlStatement      *_selectKeys;
    
    NSString            *_cacheTbName;
}

// Set the keyed db default date object class.
// Default is PYDate.
+ (void)setKeyedDbDateClass:(Class)dateClass;

+ (PYKeyedDb *)keyedDbWithPath:(NSString *)dbPath cacheTableName:(NSString *)cacheTbname;
+ (PYKeyedDb *)keyedDbWithPath:(NSString *)dbPath;

- (BOOL)beginBatchOperation;
- (BOOL)endBatchOperation;
- (BOOL)addValue:(NSData *)formatedValue forKey:(NSString *)key expireOn:(id<PYDate>)expire;
- (BOOL)updateValue:(NSData *)formatedValue forKey:(NSString *)key expireOn:(id<PYDate>)expire;
- (void)deleteValueForKey:(NSString *)key;

- (BOOL)containsKey:(NSString *)key;

- (void)clearDBData;

// Get the value
- (PYKeyedDbRow *)valueForKey:(NSString *)key;

@property (nonatomic, readonly) NSArray     *allKeys;

// data all count
- (int)count;

@end

@interface PYKeyedDb (Private)

// Other interface or message cannot create the
// db by alloc/init.
- (id)init;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
