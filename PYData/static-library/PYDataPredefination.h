//
//  PYDataPredefination.h
//  PYData
//
//  Created by littlepush on 8/10/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#ifndef PYData_PYDataPredefination_h
#define PYData_PYDataPredefination_h

#include <sqlite3.h>


#define SQLITE_STMT(st)				sqlite3_stmt *st;
#define SQLITE_STMT_FORBIND(st)		sqlite3_stmt *st; int _i##st = 1;
#define SQLITE_ENDSTMT(st)			sqlite3_finalize(st)
#define SQL_BIND_INT(st,v)			sqlite3_bind_int(st, _i##st++, v)
#define SQL_BIND_CSTRING(st,v)		sqlite3_bind_text(st, _i##st++, v, -1, NULL)
#define SQL_BIND_TEXT(st,v)			sqlite3_bind_text(st, _i##st++, [v UTF8String], -1, NULL)
#define SQL_BIND_DOUBLE(st,v)		sqlite3_bind_double(st, _i##st++, v)
#define SQL_BIND_DATE(st,v)			sqlite3_bind_double(st, _i##st++, [v timeIntervalSince1970])
#define SQL_BIND_LATITUDE(st,v)		sqlite3_bind_double(st, _i##st++, v.coordinate.latitude)
#define SQL_BIND_LONGITUDE(st,v)	sqlite3_bind_double(st, _i##st++, v.coordinate.longitude)

#define SQL_LASTROWID		@"SELECT last_insert_rowid()"

#define BEGIN_VASTRING( format )	\
	[NSString stringWithFormat:format
#define FORMAT_INT( value )			\
	,value
#define FORMAT_DOUBLE( value )		\
	,value
#define FORMAT_STRING( value )		\
	,value
#define FORMAT_DATE( value )		\
	,[value timeIntervalSince1970]
#define END_VASTRING				\
	]


#define PREPARE_SQLITE_STMT(stmt)	\
	int __i##stmt = 0
#define GET_SQLITE_INT(stmt)		\
	sqlite3_column_int( stmt, __i##stmt++ )
#define GET_SQLITE_TEXT(stmt)		\
	[[[NSString alloc] initWithCString:(char *)sqlite3_column_text( \
	stmt, __i##stmt++ ) encoding:NSUTF8StringEncoding] autorelease]
#define GET_SQLITE_CSTRING(stmt)	\
	(char *)sqlite3_column_text(stmt, __i##stmt++)
#define GET_SQLITE_DOUBLE(stmt)		\
	sqlite3_column_double( stmt, __i##stmt++ )
#define GET_SQLITE_DATE(stmt)		\
	[NSDate dateWithTimeIntervalSince1970:GET_SQLITE_DOUBLE(stmt)]


#endif
