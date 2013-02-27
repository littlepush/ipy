//
//  PYDatabase.m
//  PYData
//
//  Created by littlepush on 8/10/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "PYDatabase.h"

@interface PYDatabase (Private)

-(NSError *)prepare:(NSString *)sql statement:(sqlite3_stmt **)pstmt;
-(NSError *)execute:(sqlite3_stmt *)pstmt;
-(NSError *)query:(sqlite3_stmt *)pstmt;

-(NSError *)executeSql:(sqlite3_stmt *)pstmt code:(int *)pcode;

@end

@implementation PYDatabase

/* Proteries */
@synthesize databaseFilePath = dbPath;
// the tables need to read from the database
@dynamic tables;
-(NSArray *)tables
{
	static NSString *tableSelect = @"SELECT name FROM sqlite_master WHERE type = \"table\"";
	if ( database == NULL ) return nil;
	if ( tablesArray != nil ) return tablesArray;
	
	// query the database
	PYSqlStatement *sqlStmt = [PYSqlStatement sqlStatementWithSQL:tableSelect];
	NSError *_error = [self prepare:sqlStmt.sqlString statement:&(sqlStmt->sqlstmt)];
	if ( _error != nil ) {
		PYLog(@"%@", [_error localizedDescription]);
		return nil;
	}
	
	NSMutableArray *_tables = [NSMutableArray array];
	while ( nil == [self query:sqlStmt.statement] ) {
		[sqlStmt prepareForReading];
		[_tables addObject:[sqlStmt getInOrderText]];
	}
	
	tablesArray = [[NSArray arrayWithArray:_tables] retain];
	return tablesArray;
}

/* initialize */
// use default file extention
-(id) initDatabaseWithName:(NSString *)name
{
	self = [super init];
	if ( self ) {
		NSError *error = [self loadDatabaseWithName:name 
			type:PYDatabaseDefaultExtention];
		if ( error != nil ) {
			PYLog(@"%@", [error localizedDescription]);
			[self release];
			return nil;
		}
	}
	return self;
}
// check the main bundle and expend the file to the document path
-(id) initDatabaseWithName:(NSString *)name type:(NSString *)type
{
	self = [super init];
	if ( self ) {
		NSError *error = [self loadDatabaseWithName:name type:type];
		if ( error != nil ) {
			PYLog(@"%@", [error localizedDescription]);
			[self release];
			return nil;
		}
	}
	return self;
}
// load the database from specified file path
-(id) initDatabaseWithFile:(NSString *)filePath
{
	self = [super init];
	if ( self ) {
		NSError *error = [self loadDatabaseFromFile:filePath];
		if ( error != nil ) {
			PYLog(@"%@", [error localizedDescription]);
			[self release];
			return nil;
		}
	}
	return self;
}
// global
+(id) databaseWithName:(NSString *)name
{
	PYDatabase *db = [[[PYDatabase alloc] initDatabaseWithName:name] autorelease];
	return db;
}
+(id) databaseWithName:(NSString *)name type:(NSString *)type
{
	PYDatabase *db = [[[PYDatabase alloc] 
		initDatabaseWithName:name type:type] autorelease];
	return db;
}
+(id) databaseWithFile:(NSString *)filePath
{
	PYDatabase *db = [[[PYDatabase alloc]
		initDatabaseWithFile:filePath] autorelease];
	return db;
}

/* load database data dynamicly */
-(NSError *) loadDatabaseFromNib:(NSBundle *)bundle 
	name:(NSString*)name type:(NSString *)type
{
	NSString *_bundlePath = [bundle pathForResource:name ofType:type];
	return [self loadDatabaseFromFile:_bundlePath];
}
-(NSError *) loadDatabaseWithName:(NSString *)name type:(NSString *)type
{
	NSFileManager *fm = [NSFileManager defaultManager];
	
	// get document path
	NSArray *paths = NSSearchPathForDirectoriesInDomains(
		NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [paths objectAtIndex:0];
	
	// get the database file path
	NSString *dbFileName = [NSString stringWithFormat:@"%@.%@", name, type];
	NSString *dbFilePath = [documentDirectory stringByAppendingPathComponent:dbFileName];
	
	if ( ![fm fileExistsAtPath:dbFilePath] ) {
		NSError *error = nil;
		NSString *bundleDbPath = [[NSBundle mainBundle]
			pathForResource:name ofType:type];
		if ( [bundleDbPath length] == 0 ) {
			return [self errorWithCode:1 message:@"No Database file in bundle."];
		}
		// check if the main bundle contains the database file
		[fm copyItemAtPath:bundleDbPath toPath:dbFilePath error:&error];
		if ( error != nil ) {
			return error;
		}
	}
		
	return [self loadDatabaseFromFile:dbFilePath];
}
-(NSError *) loadDatabaseFromFile:(NSString *)path
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error = nil;
	if (![fm fileExistsAtPath:path] ) {
		error = [NSError errorWithDomain:@"PYDatabase-Load" 
			code:-1 
			userInfo:[NSDictionary 
				dictionaryWithObject:[NSString 
					stringWithFormat:@"database file does not existed at path: %@", 
					path] 
				forKey:NSLocalizedDescriptionKey]
			];
		return error;
	}
	
	// close previous database
	if ( database != NULL ) {
		sqlite3_close(database);
		database = NULL;
	}
	
	if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
		dbPath = [path retain];
		
		return nil;
	}
	return [NSError 
			errorWithDomain:@"FPDatabase" 
			code:-2 
			userInfo:[NSDictionary 
					  dictionaryWithObject:[NSString 
						stringWithFormat:@"Failed to open database at path:%@", path]
					  forKey:NSLocalizedDescriptionKey]];	
}

-(void) bindFunction:(dbFunc)func name:(NSString *)funcName argc:(int)argc
{
	[self bindFunction:func step:NULL final:NULL name:funcName argc:argc];
}

-(void) bindFunction:(dbFunc)func step:(dbFunc)sfunc 
	name:(NSString *)funcName argc:(int)argc
{
	[self bindFunction:func step:sfunc final:NULL name:funcName argc:argc];
}

-(void) bindFunction:(dbFunc)func step:(dbFunc)sfunc final:(dbfFunc)ffunc 
	name:(NSString *)funcName argc:(int)argc
{
	if (database == NULL) return;
	sqlite3_create_function(database, [funcName UTF8String], argc,
		SQLITE_UTF8, NULL, func, sfunc, ffunc);
}

-(void) closeDatabase
{
	sqlite3_close(database);
	database = NULL;
}

-(void) dealloc
{
	sqlite3_close(database);
	database = NULL;
	tablesArray = nil;
	dbPath = nil;
	
	[super dealloc];
}

-(void) executeSql:(PYSqlStatement *)sqlStmt withOwner:(id<PYDBExecuteAdaptor>)owner
{
	if ( sqlStmt == nil ) return;
	NSError *_error = [self prepare:sqlStmt.sqlString statement:&(sqlStmt->sqlstmt)];
	if ( _error ) {
		if ( [owner respondsToSelector:@selector(dbExecute:didFailedWithError:)] ) {
			[owner dbExecute:sqlStmt didFailedWithError:_error];
		}
		return;
	}
	
	if ( [owner respondsToSelector:@selector(formatSqlStatement:)] ) {
		[owner formatSqlStatement:sqlStmt];
	}
	
	int _exeRet = 0;
	_error = [self executeSql:sqlStmt.statement code:&_exeRet];
	
	if ( _exeRet == SQLITE_ROW && _error != nil )	// empty resultset
	{
		if ( [owner respondsToSelector:@selector(dbExecute:didFinishedWithData:)] ) {
			[owner dbExecute:sqlStmt didFinishedWithData:[NSArray array]];
		}
		return;
	}
	
	if ( _exeRet == SQLITE_DONE )	// execute sql done
	{
		if ( [owner respondsToSelector:@selector(dbExecute:didFinishedWithData:)] ) {
			[owner dbExecute:sqlStmt didFinishedWithData:
				[NSNumber numberWithInt:sqlite3_changes(database)]];
		}
		return;
	}
	
	if ( _exeRet == SQLITE_ROW && _error == nil )
	{
		if ( ![owner respondsToSelector:@selector(dataRowFromSqlStatement:)] )
			return;
		NSMutableArray	*resultSet = [NSMutableArray array];
		do {
			[sqlStmt prepareForReading];
			id rowData = [owner dataRowFromSqlStatement:sqlStmt];
			[resultSet addObject:rowData];
		} while ( nil == [self executeSql:sqlStmt.statement code:&_exeRet] );
		
		if ( [owner respondsToSelector:@selector(dbExecute:didFinishedWithData:)] ) {
			[owner dbExecute:sqlStmt didFinishedWithData:resultSet];
		}
		return;
	}

	PYLog(@"db execute return other code: %d", _exeRet);
	if ( _error != nil ) {
		if ( [owner respondsToSelector:@selector(dbExecute:didFailedWithError:)] ) {
			[owner dbExecute:sqlStmt didFailedWithError:_error];
		}		
	}
	return;
}

/* 
	Private
*/
-(NSError *)prepare:(NSString *)sql statement:(sqlite3_stmt **)pstmt
{
	if ( sqlite3_prepare_v2(database, [sql UTF8String], -1, pstmt, NULL) != SQLITE_OK )
	{
		return [NSError 
				errorWithDomain:@"FPDatabase" 
				code:sqlite3_errcode(database)
				userInfo:[NSDictionary 
						  dictionaryWithObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] 
						  forKey:NSLocalizedDescriptionKey]];		
	}
	return nil;
}

-(NSError *)execute:(sqlite3_stmt *)pstmt;
{
	if ( sqlite3_step(pstmt) != SQLITE_DONE )
	{
		return [NSError
				errorWithDomain:@"FPDatabase" 
				code:sqlite3_errcode(database)
				userInfo:[NSDictionary
						  dictionaryWithObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] 
						  forKey:NSLocalizedDescriptionKey]];
	}
	return nil;
}

-(NSError *)query:(sqlite3_stmt *)pstmt
{
	if ( sqlite3_step(pstmt) != SQLITE_ROW )
	{
		return [NSError
				errorWithDomain:@"FPDatabase" 
				code:sqlite3_errcode(database)
				userInfo:[NSDictionary
						  dictionaryWithObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)]
						  forKey:NSLocalizedDescriptionKey]];		
	}
	return nil;
}

-(NSError *)executeSql:(sqlite3_stmt *)pstmt code:(int *)pcode
{
	int t = 0;
	int *ret = pcode == NULL ? &t : pcode;
	(*ret) = sqlite3_step(pstmt);
	if ( (*ret) != SQLITE_DONE && (*ret) != SQLITE_ROW )
	{
		return [NSError
				errorWithDomain:@"PYDatabase" 
				code:sqlite3_errcode(database)
				userInfo:[NSDictionary
						  dictionaryWithObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)]
						  forKey:NSLocalizedDescriptionKey]];		
	}
	return nil;
}

@end
