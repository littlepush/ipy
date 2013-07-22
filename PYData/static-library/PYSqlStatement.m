//
//  PYSqlStatement.m
//  PYData
//
//  Created by littlepush on 8/10/12.
//  CoPYright (c) 2012 Push Lab. All rights reserved.
//

#import "PYSqlStatement.h"

@implementation PYSqlStatement

@synthesize statement = sqlstmt;
@synthesize sqlString = sqlString;
@synthesize name;

- (id)init 
{
	self = [super init];
	if ( self ) {
		bindCount = 1;
		//inited = NO;
	}
	return self;
}

- (id)initSqlStatementWithSQL:(NSString *)sql 
{
	self = [super init];
	if ( self ) {
		bindCount = 1;
        self.sqlString = sql;
	}
	return self;
}

+ (PYSqlStatement *)sqlStatementWithSQL:(NSString *)sql 
{
	PYSqlStatement *sqlStmt = [[PYSqlStatement alloc] initSqlStatementWithSQL:sql];
	return sqlStmt;
}

- (void)dealloc
{
	[self finalizeStatement];
}

- (void)finalizeStatement 
{
	SQLITE_ENDSTMT(sqlstmt);
	bindCount = 1;
	sqlstmt = NULL;
}

- (void)resetBinding
{
    bindCount = 1;
    sqlite3_reset(sqlstmt);
}
- (void)prepareForReading
{
	bindCount = 0;
}

/* Binding */
- (void)bindInOrderInt:(int)value
{
	sqlite3_bind_int( sqlstmt, bindCount++, value );
}
- (void)bindInOrderCString:(const char *)value
{
	if ( value == NULL ) [self bindInOrderNull];
	else 
		sqlite3_bind_text( sqlstmt, bindCount++, value, -1, NULL);
}
- (void)bindInOrderText:(NSString *)value
{
	if ( value == nil || [value isEqual:[NSNull null]] )
		[self bindInOrderNull];
	else 
		[self bindInOrderCString:[value cStringUsingEncoding:NSUTF8StringEncoding]];
}
- (void)bindInOrderDouble:(double)value
{
	sqlite3_bind_double( sqlstmt, bindCount++, value );
}
- (void)bindInOrderFloat:(float)value
{
	sqlite3_bind_double(sqlstmt, bindCount++, value);
}
- (void)bindInOrderDate:(NSDate *)value
{
	if ( value == nil || [value isEqual:[NSNull null]] )
		[self bindInOrderNull];
	else 
		[self bindInOrderDouble:[value timeIntervalSince1970]];
}
- (void)bindInOrderData:(NSData *)value
{
    if ( value == nil || [value isEqual:[NSNull null]] )
        [self bindInOrderNull];
    else
        sqlite3_bind_blob( sqlstmt, bindCount++, [value bytes], [value length], NULL);
}
- (void)bindInOrderNull
{
	sqlite3_bind_null(sqlstmt, bindCount++);
}

/* get value */
- (int)getInOrderInt
{
	return sqlite3_column_int( sqlstmt, bindCount++ );
}
- (char *)getInOrderCString
{
	return (char *)sqlite3_column_text(sqlstmt, bindCount++);
}
- (NSString *)getInOrderText
{
	char * _text = [self getInOrderCString];
	if ( _text == NULL ) return nil;
	return [NSString stringWithCString:_text 
		encoding:NSUTF8StringEncoding];
}
- (double)getInOrderDouble
{
	return sqlite3_column_double( sqlstmt, bindCount++ );
}
- (float)getInOrderFloat
{
	return [self getInOrderDouble];
}
- (NSDate *)getInOrderDate
{
	return [NSDate dateWithTimeIntervalSince1970:[self getInOrderDouble]];
}
- (NSData *)getInOrderData
{
    int _length = sqlite3_column_bytes(sqlstmt, bindCount);
    NSData *_data = [NSData dataWithBytes:sqlite3_column_blob(sqlstmt, bindCount++)
                                   length:_length];
    return _data;
}

/* Parameters */
- (NSString *)columnNameAtIndex:(NSUInteger)index
{
	return [NSString stringWithCString:sqlite3_column_name(sqlstmt, index)
		encoding:NSUTF8StringEncoding];
}

- (NSUInteger)bindParameterCount
{
	return sqlite3_bind_parameter_count(sqlstmt);
}

- (NSString *)bindParameterNameAtIndex:(NSUInteger)index
{
	return [NSString stringWithCString:sqlite3_bind_parameter_name(sqlstmt, index)
		encoding:NSUTF8StringEncoding];
}

@end
