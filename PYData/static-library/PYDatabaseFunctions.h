//
//  PYDatabaseFunctions.h
//  PYData
//
//  Created by littlepush on 8/11/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#ifndef PYData_PYDatabaseFunctions_h
#define PYData_PYDatabaseFunctions_h

#include <sqlite3.h>

/* 
	calculate the distance between two location,
	the function contains 4 args.
	Usage:
		SELECT * FROM table_name WHERE distance( lat, lon, toLat, toLon ) < D
 */
void PYDatabaseFunctionDistance( sqlite3_context *context, 
	int argc, sqlite3_value **argv );
#define PYBindDatabaseFunctionDistance( database )		\
	[(database) bindFunction:&PYDatabaseFunctionDistance	\
		name:@"distance" argc:4]

#endif
