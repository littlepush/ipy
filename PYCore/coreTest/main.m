//
//  main.m
//  coreTest
//
//  Created by littlepush on 9/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PYCore.h"

int main(int argc, const char * argv[])
{

	@autoreleasepool {
	    
		NSString *_s = @"PCFET0NUWVBFIEhUTUwgUFVCTElDICItLy9JRVRGLy9EVEQgSFRNTCAyLjAvL0VOIj4NCjxodG1sPg0KPGhlYWQPHRpdGxlPjQwMyBGb3JiaWRkZW48L3RpdGxlPjwvaGVhZD4NCjxib2R5IGJnY29sb3I9IndoaXRlIj4NCjxoMT40MDMgRm9yYmlkZGVuPC9oMT4NCjxwPllvdSBkb24ndCBoYXZlIHBlcm1pc3Npb24gdG8gYWNjZXNzIHRoZSBVUkwgb24gdGhpcyBzZXJ2ZXIuIFNvcnJ5IGZvciB0aGUgaW5jb252ZW5pZW5jZS48YnIvPg0KUGxlYXNlIHJlcG9ydCB0aGlzIG1lc3NhZ2UgYW5kIGluY2x1ZGUgdGhlIGZvbGxvd2luZyBpbmZvcm1hdGlvbiB0byB1cy48YnIvPg0KVGhhbmsgeW91IHZlcnkgbXVjaCE8L3ADQo8dGFibGUDQo8dHIDQo8dGQVVJMOjwvdGQDQo8dGQaHR0cDovL3JlYWRlci50LmN0bnYuY24vbWFpbi9tZW51cy5qc29uPC90ZD4NCjwvdHIDQo8dHIDQo8dGQU2VydmVyOjwvdGQDQo8dGQbG9oZTA5PC90ZD4NCjwvdHIDQo8dHIDQo8dGQRGF0ZTo8L3RkPg0KPHRkPjIwMTMvMDIvMDQgMTc6MzE6MzM8L3RkPg0KPC90cj4NCjwvdGFibGUDQo8aHIvPlBvd2VyZWQgYnkgVGVuZ2luZS8xLjQuMg0KPC9ib2R5Pg0KPC9odG1sPg0K==";
		NSString *_i = @"ABCDEFG";
		NSString *_e = [_i base64EncodeString];
		NSLog(@"%@, %@", _e, [_e base64DecodeString]);
		NSLog(@"%@", [_s base64DecodeString]);
	}
    return 0;
}

