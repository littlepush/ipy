//
//  PYDatabaseManager.h
//  PYData
//
//  Created by littlepush on 8/13/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PYDatabase.h"

@protocol PYDatabaseRequestOwner;

#define PYDECLARE_DATA_ACTION( action )						\
	extern NSString * const action;							\
	@interface action##DBAction : NSObject<PYDataAction>	\
	@end
	
#define PYIMPLEMENT_DATA_ACTION( action )					\
	NSString * const action = @#action;						\
	@implementation action##DBAction						\
	@synthesize name;										\
	@synthesize executeSource;								\
	@synthesize userInfo;									\
	@synthesize delegate;									\
	-(void) dealloc	{										\
		name = nil; executeSource = nil;					\
		userInfo = nil; delegate = nil;						\
		[super dealloc];									\
	}
	
#define PYENDIMPLEMENT_DATA_ACTION							\
	@end

/* Extend Action */
@protocol PYDataAction <NSObject>

@required
@property (nonatomic, copy)		NSString *name;

/* The data source object */
@required
@property (nonatomic, retain)	id executeSource;

/* User info */
@optional
@property (nonatomic, retain)	id userInfo;

/* Request delegate */
@required
@property (nonatomic, retain)	id delegate;

/* Sql String */
@required
+(NSString *) sqlStatementString;
+(void) formatSqlStatement:(PYSqlStatement *)sqlStmt object:(id)object;

@optional
-(id) getRowDataFromSqlStatement:(PYSqlStatement *)sqlStmt;
-(void) tellDelegateWithResult:(id)result;

@end

/* The owner's delegate protocol */
// user should write an extend catalog to get more detail call back
@protocol PYDatabaseRequestOwner <NSObject>

@optional
-(void) dbAction:(id<PYDataAction>)action didFinishWithResult:(id)result;
-(void) dbAction:(id<PYDataAction>)action didFailedWithError:(NSError *)error;

@end

#define SHARED_DBMGR		[PYDatabaseManager sharedDatabaseManager]

/* Database manager */
@interface PYDatabaseManager : NSObject< PYDBExecuteAdaptor >
{
	PYDatabase				*internalDatabase;
	NSMutableDictionary		*actionQueue;
}

+(PYDatabaseManager *)sharedDatabaseManager;

@property (nonatomic, readonly) NSArray		*tables;

-(BOOL) openDatabaseWithName:(NSString *)dbname;
-(BOOL) openDatabaseWithName:(NSString *)dbname type:(NSString *)type;
-(BOOL) openDatabaseWithBundle:(NSBundle *)bundle 
	name:(NSString *)dbname type:(NSString *)type;

-(id<PYDataAction>) _actionWithParam:(id)param owner:(
	id<PYDatabaseRequestOwner>)owner name:(NSString *)actionName;

/* add extend functions */
-(void) bindFunction:(dbFunc)func name:(NSString *)funcName argc:(int)argc;
-(void) bindFunction:(dbFunc)func step:(dbFunc)sfunc 
	name:(NSString *)funcName argc:(int)argc;
-(void) bindFunction:(dbFunc)func step:(dbFunc)sfunc final:(dbfFunc)ffunc 
	name:(NSString *)funcName argc:(int)argc;

/* Start the async database action */
-(void) startDBAction:(id<PYDataAction>)action;
-(void) startDBAction:(id<PYDataAction>)action owner:(id<PYDatabaseRequestOwner>)owner;
-(void) removeAllDBAction;

@end


