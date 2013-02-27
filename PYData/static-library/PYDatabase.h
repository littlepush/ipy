//
//  PYDatabase.h
//  PYData
//
//  Created by littlepush on 8/10/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PYDataPredefination.h"
#import "PYSqlStatement.h"

@protocol PYDatabase <NSObject>

@required

/* Init the data from a sql statement */
-(id) initWithDataRow:(PYSqlStatement *)sqlStmt;

-(void) bindDataWithSqlStatement:(PYSqlStatement *)sqlStmt withObject:(id)object;

@end

/* Database Execute Adaptor */
@protocol PYDBExecuteAdaptor <NSObject>

@required
-(void) formatSqlStatement:(PYSqlStatement *)sqlStmt;

@optional
/* unarchived row from sql statement. */
-(id) dataRowFromSqlStatement:(PYSqlStatement *)sqlStmt;

/* Did finish to execute the sql statement, result may be nsarray or nsnumber */
-(void) dbExecute:(PYSqlStatement *)sqlStmt didFinishedWithData:(id)result;
/* Error happened when execute the sql statement */
-(void) dbExecute:(PYSqlStatement *)sqlStmt didFailedWithError:(NSError *)error;

@end

#define PYDatabaseDefaultExtention		@"dat"

typedef void (*dbFunc)(sqlite3_context*,int,sqlite3_value**);
typedef void (*dbfFunc)(sqlite3_context*);

/* Database adaptor */
@interface PYDatabase : NSObject
{
	@private		/* the clild class cannot access this database var. */
	sqlite3			*database;
	NSString		*dbPath;
	NSArray			*tablesArray;
}

// the database file path
@property (nonatomic, readonly) NSString			*databaseFilePath;

/* get tables of current database */
@property (nonatomic, readonly) NSArray				*tables;

/* initialize */
// use default file extention
-(id) initDatabaseWithName:(NSString *)name;
// check the main bundle and expend the file to the document path
-(id) initDatabaseWithName:(NSString *)name type:(NSString *)type;
// load the database from specified file path
-(id) initDatabaseWithFile:(NSString *)filePath;
// global
+(id) databaseWithName:(NSString *)name;
+(id) databaseWithName:(NSString *)name type:(NSString *)type;
+(id) databaseWithFile:(NSString *)filePath;

/* load database data dynamicly */
-(NSError *) loadDatabaseFromNib:(NSBundle *)bundle 
	name:(NSString*)name type:(NSString *)type;
-(NSError *) loadDatabaseWithName:(NSString *)name type:(NSString *)type;
-(NSError *) loadDatabaseFromFile:(NSString *)path;

/* add extend functions */
-(void) bindFunction:(dbFunc)func name:(NSString *)funcName argc:(int)argc;
-(void) bindFunction:(dbFunc)func step:(dbFunc)sfunc 
	name:(NSString *)funcName argc:(int)argc;
-(void) bindFunction:(dbFunc)func step:(dbFunc)sfunc final:(dbfFunc)ffunc 
	name:(NSString *)funcName argc:(int)argc;

/* close database */
-(void) closeDatabase;

// add and execute the action, when finished, tell the owner
-(void) executeSql:(PYSqlStatement *)sqlStmt 
	withOwner:(id<PYDBExecuteAdaptor>)owner;

@end
