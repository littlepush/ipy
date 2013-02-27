//
//  PYDatabaseFunctions.c
//  PYData
//
//  Created by littlepush on 8/11/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#include <stdio.h>
#include <assert.h>
#include <math.h>
#include "PYDatabaseFunctions.h"
#include <CoreLocation/CoreLocation.h>

#define DEG2RAD(degrees) (degrees * 0.01745327) // degrees * pi over 180

void PYDatabaseFunctionDistance( sqlite3_context *context, 
	int argc, sqlite3_value **argv )
{
	// check that we have four arguments (lat1, lon1, lat2, lon2)
	assert(argc == 4);
	// check that all four arguments are non-null
	for ( int i = 0; i < 4; ++i ) {
		if ( sqlite3_value_type(argv[i]) == SQLITE_NULL ) {
			sqlite3_result_null(context);
			return;
		}
	}
	// get the four argument values
	double lat1 = sqlite3_value_double(argv[0]);
	double lon1 = sqlite3_value_double(argv[1]);
	double lat2 = sqlite3_value_double(argv[2]);
	double lon2 = sqlite3_value_double(argv[3]);
	
	CLLocation *_location1 = LOCATION(lat1, lon1);
	CLLocation *_location2 = LOCATION(lat2, lon2);
	double _distance = [_location1 distanceFromLocation:_location2];
	PYLog(@"distance between [%f, %f] and [%f, %f] is %f", lat1, lon1, lat2, lon2, _distance);
	sqlite3_result_double(context, _distance);
	/*
	// convert lat1 and lat2 into radians now, to avoid doing it twice below
	double lat1rad = DEG2RAD(lat1);
	double lat2rad = DEG2RAD(lat2);
	
	// apply the spherical law of cosines to our latitudes and longitudes, 
	// and set the result appropriately
	// 6378.1 is the approximate radius of the earth in kilometres
	sqlite3_result_double(context, acos(sin(lat1rad) * sin(lat2rad) + 
		cos(lat1rad) * cos(lat2rad) * 
		cos(DEG2RAD(lon2) - DEG2RAD(lon1))) * 6378.1);
	*/
}

