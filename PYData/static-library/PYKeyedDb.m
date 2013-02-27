//
//  PYKeyedDb.m
//  PYData
//
//  Created by Push Chen on 1/19/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

#import "PYKeyedDb.h"
#import "PYSqlStatement.h"

static NSMutableDictionary			*keyedDBCache;
#define		kKeyedDBTableName		@"_pykeyedCache"

@interface PYKeyedDb ()

- (BOOL) initializeDbWithPath:(NSString *)dbPath;

// Create the db at specified path if the database is not existed.
- (BOOL) createDbWithPath:(NSString *)dbPath;

@end

@implementation PYKeyedDb

+(void) initialize
{
	// Initialize the global cache
	keyedDBCache = [[NSMutableDictionary dictionary] retain];
}

+ (PYKeyedDb *) keyedDbWithPath:(NSString *)dbPath
{
	PYLog(@"dbPath: %@", dbPath);
	NSString *_dbKey = [dbPath md5sum];
	PYIF ( [keyedDBCache objectForKey:_dbKey] != nil ) {
		return [keyedDBCache objectForKey:_dbKey];
	}
	
	PYKeyedDb *_newDb = [[[PYKeyedDb alloc] init] autorelease];
	PYIF ( [_newDb initializeDbWithPath:dbPath] == NO ) {
		PYIF ( [_newDb createDbWithPath:dbPath] == NO ) return nil;
	}
	[keyedDBCache setObject:_newDb forKey:_dbKey];
	return _newDb;
}

// 
- (id) init
{
	self = [super init];
	if ( self ) {
		// Do something if needed.
	}
	return self;
}

- (void) dealloc
{
	if ( _innerDb != NULL ) sqlite3_close(_innerDb);
	[super dealloc];
}

- (BOOL) initializeDbWithPath:(NSString *)dbPath
{
	NSFileManager *fm = [NSFileManager defaultManager];
	PYIF (![fm fileExistsAtPath:dbPath] ) {
		return NO;
	}
	
	PYIF (sqlite3_open([dbPath UTF8String], &_innerDb) == SQLITE_OK) {
		return YES;
	}
	return NO;
}

// Create the db at specified path if the database is not existed.
- (BOOL) createDbWithPath:(NSString *)dbPath
{
	NSFileManager *fm = [NSFileManager defaultManager];
	PYIF ( [fm fileExistsAtPath:dbPath] ) return NO;
	// Create the empty file
	[fm createFileAtPath:dbPath contents:nil attributes:nil];
	PYIF ( sqlite3_open([dbPath UTF8String], &_innerDb) != SQLITE_OK )
		return NO;
		
	// Create the table
	static const char * _createTableSql =
		"CREATE TABLE _pykeyedCache("	\
		"dbKey TEXT PRIMARY KEY,"		\
		"dbValue TEXT);";
	char *_error;
	PYIF( sqlite3_exec(_innerDb, _createTableSql, nil, nil, &_error) != SQLITE_OK ) {
		PYLog(@"%s", _error);
		sqlite3_close(_innerDb);
		_innerDb = NULL;
		[fm removeItemAtPath:dbPath error:nil];
		return NO;
	}
	
	sqlite3_close(_innerDb);
	return [self initializeDbWithPath:dbPath];
}

- (BOOL) addValue:(NSString *)formatedValue forKey:(NSString *)key
{
	static NSString *_insertSql = @"INSERT INTO " kKeyedDBTableName @" VALUES(?, ?);";
	PYLog(@"add key<%@>, value<%@>", key, formatedValue);
	PYSqlStatement *_st = [PYSqlStatement sqlStatementWithSQL:_insertSql];
	BOOL _statue = NO;
	PYIF (sqlite3_prepare_v2(_innerDb, _insertSql.UTF8String, -1, &_st->sqlstmt, NULL) == SQLITE_OK)
	{
		[_st bindInOrderText:key];
		[_st bindInOrderText:formatedValue];
		PYIF (sqlite3_step(_st.statement) == SQLITE_DONE )
		{
			_statue = YES;
		}
	}
	return _statue;
}

- (BOOL) updateValue:(NSString *)formatedValue forKey:(NSString *)key
{
	// Update
	static NSString *_updateSql = @"UPDATE " kKeyedDBTableName @" set dbValue=? WHERE dbKey=?";
	PYLog(@"update key<%@>, value<%@>", key, formatedValue);
	PYSqlStatement *_st = [PYSqlStatement sqlStatementWithSQL:_updateSql];
	BOOL _statue = NO;
	PYIF (sqlite3_prepare_v2(_innerDb, _updateSql.UTF8String, -1, &_st->sqlstmt, NULL) == SQLITE_OK)
	{
		[_st bindInOrderText:formatedValue];
		[_st bindInOrderText:key];
		PYIF (sqlite3_step(_st.statement) == SQLITE_DONE )
		{
			_statue = YES;
		}
	}
	return _statue;
}

- (void) deleteValueForKey:(NSString *)key
{
	// Delete
	static NSString *_deleteSql = @"DELETE " kKeyedDBTableName @" WHERE dbKey=?";
	PYLog(@"delete key<%@>", key);
	PYSqlStatement *_st = [PYSqlStatement sqlStatementWithSQL:_deleteSql];
	BOOL _statue = NO;
	PYIF (sqlite3_prepare_v2(_innerDb, _deleteSql.UTF8String, -1, &_st->sqlstmt, NULL) == SQLITE_OK)
	{
		[_st bindInOrderText:key];
		PYIF (sqlite3_step(_st.statement) == SQLITE_DONE )
		{
			_statue = YES;
		}
	}
	PYLog(@"delete key:%@<%@>", key, (_statue ? @"YES" : @"NO"));
}

- (BOOL) containsKey:(NSString *)key
{
	// Select
	static NSString *_selectSql = @"SELECT dbKey FROM " kKeyedDBTableName @" WHERE dbKey=?";
	PYLog(@"check key<%@>", key);
	PYSqlStatement *_st = [PYSqlStatement sqlStatementWithSQL:_selectSql];
	BOOL _statue = NO;
	PYIF (sqlite3_prepare_v2(_innerDb, _selectSql.UTF8String, -1, &_st->sqlstmt, NULL) == SQLITE_OK)
	{
		[_st bindInOrderText:key];
		PYIF (sqlite3_step(_st.statement) == SQLITE_ROW )
		{
			_statue = YES;
		}
	}
	return _statue;
}

- (NSString *) valueForKey:(NSString *)key
{
	static NSString *_selectSql = @"SELECT dbValue FROM " kKeyedDBTableName @" WHERE dbKey=?";
	PYLog(@"get key<%@>", key);
	PYSqlStatement *_st = [PYSqlStatement sqlStatementWithSQL:_selectSql];
	PYIF (sqlite3_prepare_v2(_innerDb, _selectSql.UTF8String, -1, &_st->sqlstmt, NULL) == SQLITE_OK)
	{
		[_st bindInOrderText:key];
		PYIF (sqlite3_step(_st.statement) == SQLITE_ROW )
		{
			[_st prepareForReading];
			return [_st getInOrderText];
		}
	}
	PYLog(@"No value for key<%@>", key);
	return @"";
}

- (int)count
{
	static NSString *_countSql = @"SELECT COUNT(dbKey) FROM " kKeyedDBTableName;
	PYSqlStatement *_st = [PYSqlStatement sqlStatementWithSQL:_countSql];
	PYIF (sqlite3_prepare_v2(_innerDb, _countSql.UTF8String, -1, &_st->sqlstmt, NULL) == SQLITE_OK)
	{
		PYIF (sqlite3_step(_st.statement) == SQLITE_ROW )
		{
			[_st prepareForReading];
			return [_st getInOrderInt];
		}
	}
	return -1;
}

@end
