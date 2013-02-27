//
//  PYDatabaseManager.m
//  PYData
//
//  Created by littlepush on 8/13/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "PYDatabaseManager.h"

/*  */

static PYDatabaseManager *gDatabaseManager;
@implementation PYDatabaseManager

@dynamic tables;
-(NSArray *)tables { 
	if ( internalDatabase == nil ) return nil;
	return internalDatabase.tables;
}

+(PYDatabaseManager *)sharedDatabaseManager
{
	PYSingletonLock
	if ( gDatabaseManager == nil ) {
		gDatabaseManager = [[PYDatabaseManager object] retain];
		return gDatabaseManager;
	}
	PYSingletonUnLock;
	return gDatabaseManager;
}

PYSingletonAllocWithZone(gDatabaseManager);
PYSingletonDefaultImplementation;

/* Manager Messages */
-(BOOL) openDatabaseWithName:(NSString *)dbname
{
	if ( internalDatabase != nil ) return YES;
	internalDatabase = [[PYDatabase databaseWithName:dbname] retain];
	return ( internalDatabase != nil );
}
-(BOOL) openDatabaseWithName:(NSString *)dbname type:(NSString *)type
{
	if ( internalDatabase != nil ) return YES;
	internalDatabase = [[PYDatabase databaseWithName:dbname type:type] retain];
	return ( internalDatabase != nil );
}
-(BOOL) openDatabaseWithBundle:(NSBundle *)bundle 
	name:(NSString *)dbname type:(NSString *)type
{
	if ( internalDatabase != nil ) return YES;
	internalDatabase = [[PYDatabase object] retain];
	NSError *err = [internalDatabase loadDatabaseFromNib:bundle name:dbname type:type];
	if ( err ) {
		PYLog(@"%@", [err localizedDescription]);
		internalDatabase = nil;
	}
	return ( err == nil );
}

-(id<PYDataAction>) _actionWithParam:(id)param owner:(
	id<PYDatabaseRequestOwner>)owner name:(NSString *)actionName
{
	NSString * _fullClassName = [actionName stringByAppendingString:@"DBAction"];
	id<PYDataAction> _action = [NSClassFromString(_fullClassName) object];
	_action.executeSource = param;
	_action.delegate = owner;
	_action.name = _fullClassName;
	return _action;	
}

/* add extend functions */
-(void) bindFunction:(dbFunc)func name:(NSString *)funcName argc:(int)argc
{
	if ( internalDatabase == nil ) return;
	[internalDatabase bindFunction:func name:funcName argc:argc];
}
-(void) bindFunction:(dbFunc)func step:(dbFunc)sfunc 
	name:(NSString *)funcName argc:(int)argc
{
	if ( internalDatabase == nil ) return;
	[internalDatabase bindFunction:func step:sfunc name:funcName argc:argc];
}
-(void) bindFunction:(dbFunc)func step:(dbFunc)sfunc final:(dbfFunc)ffunc 
	name:(NSString *)funcName argc:(int)argc
{
	if ( internalDatabase == nil ) return;
	[internalDatabase bindFunction:func step:sfunc final:ffunc name:funcName argc:argc];
}

-(void) startDBAction:(id<PYDataAction>)action
{
	if ( internalDatabase == nil ) return;
	PYSqlStatement *sqlStmt = [PYSqlStatement 
		sqlStatementWithSQL:[[action class] sqlStatementString]];
	// set the unique name
	if ( [action.name length] == 0 ) {
		sqlStmt.name = TIMESTAMP;
	} else {
		sqlStmt.name = [action.name stringByAppendingString:TIMESTAMP];
	}
	
	// init the queue
	PYSingletonLock
	if ( actionQueue == nil ) {
		actionQueue = [[NSMutableDictionary dictionary] retain];
	}
	PYSingletonUnLock
	
	// add the action
	[actionQueue setValue:action forKey:sqlStmt.name];
	BEGIN_ASYNC_INVOKE
	[internalDatabase executeSql:sqlStmt withOwner:self];
	END_ASYNC_INVOKE;
}

-(void) startDBAction:(id<PYDataAction>)action owner:(id<PYDatabaseRequestOwner>)owner
{
	action.delegate = owner;
	[self startDBAction:action];
}

-(void) removeAllDBAction
{
	if ( actionQueue == nil ) return;
	[actionQueue removeAllObjects];
}

/* Execute Adaptor Delegate */
-(void) formatSqlStatement:(PYSqlStatement *)sqlStmt
{
	if ( actionQueue == nil || [actionQueue count] == 0 ) return;
	
	// get the action
	id<PYDataAction> action = [actionQueue objectForKey:sqlStmt.name];
	if ( action == nil ) return;
	
	// call the action's format message
	[[action class] formatSqlStatement:sqlStmt object:action.executeSource];
}

/* unarchived row from sql statement. */
-(id) dataRowFromSqlStatement:(PYSqlStatement *)sqlStmt
{
	if ( actionQueue == nil || [actionQueue count] == 0 ) return nil;
	
	// get the action
	id<PYDataAction> action = [actionQueue objectForKey:sqlStmt.name];
	if ( action == nil ) return nil;
	
	if ( [action respondsToSelector:@selector(getRowDataFromSqlStatement:)] )
	{
		return [action getRowDataFromSqlStatement:sqlStmt];
	}
	return nil;
}

/* Did finish to execute the sql statement, result may be nsarray or nsnumber */
-(void) dbExecute:(PYSqlStatement *)sqlStmt didFinishedWithData:(id)result
{
	if ( actionQueue == nil || [actionQueue count] == 0 ) return;
	
	// get the action
	id<PYDataAction> action = [[[actionQueue objectForKey:sqlStmt.name] 
		retain] autorelease];
	if ( action == nil ) return;
	[actionQueue removeObjectForKey:sqlStmt.name];
	
	if ( [action respondsToSelector:@selector(tellDelegateWithResult:)] )
	{
		BEGIN_MAINTHREAD_INVOKE
		[action tellDelegateWithResult:result];
		END_MAINTHREAD_INVOKE
	} 
	else
	{
		if ( [action.delegate respondsToSelector:@selector(dbAction:didFinishWithResult:)] )
		{
			BEGIN_MAINTHREAD_INVOKE
			[action.delegate dbAction:action didFinishWithResult:result];
			END_MAINTHREAD_INVOKE
		}
	}
}

/* Error happened when execute the sql statement */
-(void) dbExecute:(PYSqlStatement *)sqlStmt didFailedWithError:(NSError *)error
{
	if ( actionQueue == nil || [actionQueue count] == 0 ) return;
	
	// get the action
	id<PYDataAction> action = [[[actionQueue objectForKey:sqlStmt.name] 
		retain] autorelease];
	if ( action == nil ) return;
	[actionQueue removeObjectForKey:sqlStmt.name];

	if ( [action.delegate respondsToSelector:@selector(dbAction:didFailedWithError:)] )
	{
		BEGIN_MAINTHREAD_INVOKE
		[action.delegate dbAction:action didFailedWithError:error];
		END_MAINTHREAD_INVOKE
	}
}

@end
