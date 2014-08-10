//
//  PYSqlStatement.h
//  PYData
//
//  Created by Push Chen on 8/10/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
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

@interface PYSqlStatement : NSObject
{
	@public
	sqlite3_stmt			*sqlstmt;
	@private
	int						bindCount;
	NSString				*sqlString;
	//BOOL					inited;
}

/* get the internal statement object, readonly */
@property (nonatomic, readonly) sqlite3_stmt		*statement;
@property (nonatomic, copy)		NSString			*sqlString;
@property (nonatomic, copy)		NSString			*name;

/* Init */
- (id)initSqlStatementWithSQL:(NSString *)sql;
+ (PYSqlStatement *)sqlStatementWithSQL:(NSString *)sql;

/* Finalized the statement */
- (void)finalizeStatement;

/* reset the bind statue */
- (void)resetBinding;
/* prepare for reading */
- (void)prepareForReading;

/* Bind the data in the statement */
- (void)bindInOrderInt:(int)value;
- (void)bindInOrderCString:(const char *)value;
- (void)bindInOrderText:(NSString *)value;
- (void)bindInOrderDouble:(double)value;
- (void)bindInOrderFloat:(float)value;
- (void)bindInOrderDate:(NSDate *)value;
- (void)bindInOrderData:(NSData *)value;
- (void)bindInOrderNull;

/* get the value from the statement */
- (int)getInOrderInt;
- (char *)getInOrderCString;
- (NSString *)getInOrderText;
- (double)getInOrderDouble;
- (float)getInOrderFloat;
- (NSDate *)getInOrderDate;
- (NSData *)getInOrderData;

/* parameters of sql statement */
- (NSString *)columnNameAtIndex:(NSUInteger)index;
- (NSUInteger)bindParameterCount;
- (NSString *)bindParameterNameAtIndex:(NSUInteger)index;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
