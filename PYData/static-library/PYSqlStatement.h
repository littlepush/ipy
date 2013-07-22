//
//  PYSqlStatement.h
//  PYData
//
//  Created by Push Chen on 8/10/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
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
