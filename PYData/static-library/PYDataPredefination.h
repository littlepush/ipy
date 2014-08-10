//
//  PYDataPredefination.h
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

// @littlepush
// littlepush@gmail.com
// PYLab
