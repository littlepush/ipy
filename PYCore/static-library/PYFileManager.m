//
//  PYFileManager.m
//  PYCore
//
//  Created by littlepush on 9/5/12.
//  Copyright (c) 2012 PushLab. All rights reserved.
//

#import "PYFileManager.h"
#import "NSObject+Extended.h"
#import "PYMainMacro.h"

#define __OPEN__			open
#define __CLOSE__			close
#define __READ__			read
#define __WRITE__			write
#define __SEEK__			lseek
#define __EOF__				eof
#define __PERMISSION__		0644
#define __DIR__				getcwd

@interface PYFileStream (Internal)

-(BOOL) __flushData:(NSData *)data;
-(BOOL) __flushString:(NSString *)string;
-(NSUInteger) __fileSize;

@end

@implementation PYFileStream

@synthesize filepath = __filePath;

#pragma Init
-(id) init
{
	self = [super init];
	if ( !self ) return self;
	
	__fhandle = -1;
		
	return self;
}
-(void) dealloc
{
	[self closeFile];
	[__buffer release];
	[__filePath release];
	
	[super dealloc];
}
#pragma Internal
-(BOOL) __flushData:(NSData *)data
{
	if ( __fhandle == -1 || __ostatue == FS_READ ) return NO;
	if ( data == nil || [data length] == 0 ) return YES;
	if ( -1 == __WRITE__( __fhandle, data.bytes, data.length ) )
	{
		[self closeFile];
		return NO;
	}
	return YES;
}

-(BOOL) __flushString:(NSString *)string
{
	if ( __fhandle == -1 || __ostatue == FS_READ ) return NO;
	if ( string == nil || [string length] == 0 ) return YES;
	if ( -1 == __WRITE__( __fhandle, string.UTF8String, string.length ) )
	{
		[self closeFile];
		return NO;
	}
	return YES;
}

-(NSUInteger) __fileSize
{
	struct stat st;
	if ( 0 != stat(__filePath.UTF8String, &st) ) 
		return -1;
	return st.st_size;				
}

#pragma Operations
/* Open For Reading Only */
-(BOOL) openForRead:(NSString *)path {
	if ( __fhandle != -1 ) return __ostatue == FS_READ;
	if ( -1 == (__fhandle = __OPEN__(path.UTF8String, FS_READ)) )
		return NO;
	__ostatue = FS_READ;
	__filePath = [path retain];
	return YES;
}
/* Open For Writing Only */
-(BOOL) openForWrite:(NSString *)path {
	if ( __fhandle != -1 ) return __ostatue == FS_WRITE;
	if ( -1 == (__fhandle = __OPEN__(path.UTF8String, FS_WRITE, __PERMISSION__)) )
		return NO;
	__ostatue = FS_WRITE;
	__filePath = [path retain];
	return YES;
}
/* Open for reading and writing */
-(BOOL) openReadAndWrite:(NSString *)path {
	if ( __fhandle != -1 ) return __ostatue == (FS_READ | FS_WRITE);
	if ( -1 == (__fhandle = __OPEN__(path.UTF8String, (FS_READ | FS_WRITE), __PERMISSION__)) )
		return NO;
	__ostatue = (FS_READ | FS_WRITE);
	__filePath = [path retain];
	return YES;	
}
/* Defailt Open: Read And Write */
-(BOOL) openFile:(NSString *)path {
	return [self openReadAndWrite:path];
}
/* Open for writing and seek to end of file */
-(BOOL) openForAppend:(NSString *)path {
	if ( __fhandle != -1 ) return __ostatue == FS_APPEND;
	if ( -1 == (__fhandle = __OPEN__(path.UTF8String, FS_APPEND, __PERMISSION__)) )
		return NO;
	__ostatue = FS_APPEND;
	__filePath = [path retain];
	return YES;
}
/* Save file, atom */
-(BOOL) saveFile {
	if ( ![self __flushData:__buffer] ) return NO;
	// Reset buffer
	[__buffer setLength:0];
	return YES;
}
/* Flush the data and close the file handle */
-(void) closeFile {
	if ( __fhandle == -1 ) return;
	if ( ![self saveFile] ) return;
	__CLOSE__(__fhandle);
	__fhandle = -1;
}

#pragma Operation Of File
/* Write data to file */
-(BOOL) writeData:(NSData *)data {
	if ( data == nil || [data length] == 0 ) return YES;
	if ( __fhandle == -1 || __ostatue == FS_APPEND || 
		(__ostatue & FS_WRITE) == 0 ) return NO;
	// Check buffer size
	if ( data.length >= FS_MAX_BUFFER_SIZE ) {
		if ( ![self saveFile] ) return NO;
		// Flush current data.
		return [self __flushData:data];
	}
	// if data is not bigger enough, but the final data is too big
	if ( (data.length + __buffer.length) >= FS_MAX_BUFFER_SIZE )
	{
		if ( ![self saveFile] ) return NO;
	}
	[__buffer appendData:data];
	return YES;
}
-(BOOL) writeString:(NSString *)string {
	if ( [string length] == 0 ) return YES;
	if ( __fhandle == -1 || __ostatue == FS_APPEND ||
		(__ostatue & FS_WRITE) == 0 ) return NO;
	// Check buffer size
	if ( string.length >= FS_MAX_BUFFER_SIZE ) {
		if ( ![self saveFile] ) return NO;
		// Flush current data.
		return [self __flushString:string];
	}
	// if data is not bigger enough, but the final data is too big
	if ( (string.length + __buffer.length) >= FS_MAX_BUFFER_SIZE )
	{
		if ( ![self saveFile] ) return NO;
	}
	[__buffer appendBytes:string.UTF8String length:string.length];
	return YES;	
}
-(BOOL) writeLine:(NSString *)string {
	if ( string == nil || [string length] == 0 )
		return [self writeString:@"\n"];
	NSString *_line = [string stringByAppendingFormat:@"\n"];
	return [self writeString:_line];
}

/* Append data to file */
-(BOOL) appendData:(NSData *)data {
	if ( data == nil || [data length] == 0 ) return YES;
	if ( __fhandle == -1 || __ostatue != FS_APPEND ) return NO;
	// Check buffer size
	if ( data.length >= FS_MAX_BUFFER_SIZE ) {
		if ( ![self saveFile] ) return NO;
		// Flush current data.
		return [self __flushData:data];
	}
	// if data is not bigger enough, but the final data is too big
	if ( (data.length + __buffer.length) >= FS_MAX_BUFFER_SIZE )
	{
		if ( ![self saveFile] ) return NO;
	}
	[__buffer appendData:data];
	return YES;
}
-(BOOL) appendString:(NSString *)string {
	if ( [string length] == 0 ) return YES;
	if ( __fhandle == -1 || __ostatue != FS_APPEND ) return NO;
	// Check buffer size
	if ( string.length >= FS_MAX_BUFFER_SIZE ) {
		if ( ![self saveFile] ) return NO;
		// Flush current data.
		return [self __flushString:string];
	}
	// if data is not bigger enough, but the final data is too big
	if ( (string.length + __buffer.length) >= FS_MAX_BUFFER_SIZE )
	{
		if ( ![self saveFile] ) return NO;
	}
	[__buffer appendBytes:string.UTF8String length:string.length];
	return YES;	
}
-(BOOL) appendLine:(NSString *)string {
	if ( string == nil || [string length] == 0 )
		return [self writeString:@"\n"];
	NSString *_line = [string stringByAppendingFormat:@"\n"];
	return [self writeString:_line];
}

/* Read data from file */
// Read a word
-(NSString *) readWord {
	if ( __fhandle == -1 || (__ostatue & FS_READ) == 0 ) return @"";
	char _c;
	NSMutableData *__word = [[[NSMutableData alloc] init] autorelease];
	int _ret = __READ__(__fhandle, &_c, sizeof(char));
	while ( _ret > 0 ) {
		// Meet a space character
		if ( isspace(_c) > 0 ) {
			if ( [__word length] != 0 ) break;
		} else {
			[__word appendBytes:&_c length:1];
		}
		_ret = __READ__(__fhandle, &_c, sizeof(char));
	}
	if ( _ret < 0 ) return @"";
	return [[[NSString alloc] initWithData:__word 
		encoding:NSUTF8StringEncoding] autorelease];
}
// Read line
-(NSString *) readLine {
	if ( __fhandle == -1 || (__ostatue & FS_READ) == 0 ) return @"";
	char _c;
	NSMutableData *__line = [[[NSMutableData alloc] init] autorelease];
	int _ret;
	for ( ;; ) {
		_ret = __READ__(__fhandle, &_c, sizeof(char));
		if ( _ret <= 0 ) break;
		if ( _c == '\n' ) break;
		[__line appendBytes:&_c length:1];
	}
	if (_ret <= 0) return @"";
	return [[[NSString alloc] initWithData:__line 
		encoding:NSUTF8StringEncoding] autorelease];
}
// Read specified size
-(NSData *) readLength:(NSUInteger)length {
	if ( __fhandle == -1 || (__ostatue & FS_READ) == 0 ) return nil;
	NSMutableData *__data = [NSMutableData dataWithLength:length];
	int _ret = __READ__(__fhandle, [__data mutableBytes], sizeof(char) * length);
	if ( _ret < 0 ) return nil;
	return __data;	
}
// Read all file
-(NSData *) readToEnd {
	if ( __fhandle == -1 || (__ostatue & FS_READ) == 0 ) return nil;
	NSUInteger __fsize = [self __fileSize];
	NSMutableData *__data = [NSMutableData dataWithLength:__fsize];
	int _ret = __READ__(__fhandle, [__data mutableBytes], sizeof(char) * __fsize);
	if ( _ret < 0 ) return nil;
	return __data;	
}

@end

@implementation PYFileManager

// Check if a file is existed;
+(BOOL) isFileExisted:(NSString *)path {
	PYASSERT([path length] > 0, @"File path is empty");
	return access(path.UTF8String, 0) == 0;
}
// Create a new file at path. if the file is already existed, just return YES
+(BOOL) createFile:(NSString *)path {
	if ( [PYFileManager isFileExisted:path] ) return YES;
	FHandle __fhandle = __OPEN__(path.UTF8String, FS_WRITE, __PERMISSION__ );
	if ( __fhandle < 0 ) return NO;
	__CLOSE__(__fhandle);
	return YES;
}
// Delete a file at specified path.
+(BOOL) deleteFile:(NSString *)path {
	PYASSERT([path length] > 0, @"File path is empty");
	return remove( path.UTF8String ) == 0;
}
// Move file A to B
+(BOOL) moveFile:(NSString *)originPath to:(NSString *)destPath {
	PYASSERT([originPath length] > 0, @"Origin file path is empty");
	PYASSERT([destPath length] > 0, @"Dest file path is empty");
	return rename( originPath.UTF8String, destPath.UTF8String ) == 0;
}
// Copy file A to B
+(BOOL) copyFile:(NSString *)originPath to:(NSString *)destPath overwrite:(BOOL)overwrite {
	PYASSERT([originPath length] > 0, @"Origin file path is empty");
	PYASSERT([destPath length] > 0, @"Dest file path is empty");
	if ( ![PYFileManager isFileExisted:originPath] ) return NO;
	if ( [PYFileManager isFileExisted:destPath] && !overwrite ) return NO;
	// rb, wb, two file
	FILE * pRead = fopen( originPath.UTF8String, "r" );
	if ( pRead == NULL ) return NO;
				
	FILE * pWrite = fopen( destPath.UTF8String, "w" );
	if ( pWrite == NULL ) { fclose( pRead ); return NO; }
				
	// Write data
	BOOL _allright = YES;
	char _c = fgetc(pRead);
	while ( _c != EOF ) {
		if ( EOF == fputc( _c, pWrite ) ) {
			_allright = NO;
			break;
		}
		_c = fgetc( pRead );
	}
	fclose( pRead );
	fflush( pWrite );
	fclose( pWrite );
	
	return _allright;
}
// Append data to file
+(BOOL) appendData:(NSData *)data toFile:(NSString *)path {
	PYASSERT([path length] > 0, @"File path is empty");
	PYFileStream *_appendStream = [PYFileStream object];
	if ( ![_appendStream openForAppend:path] ) return NO;
	return [_appendStream appendData:data];
}
// Clear a file's content
+(BOOL) clearFile:(NSString *)path {
	PYASSERT([path length] > 0, @"File path is empty");
	if ( ![PYFileManager isFileExisted:path] ) return NO;
	FILE *pFile = fopen(path.UTF8String, "w");
	if ( pFile == NULL ) return NO;
	fclose(pFile);
	return YES;
}

// Get the create time of a file
+(long) createTimeOfFile:(NSString *)path {
	PYASSERT([path length] > 0, @"File path is empty");
	struct stat st;
	if ( 0 != stat(path.UTF8String, &st) ) 
	{ return -1; }
	return st.st_ctimespec.tv_sec;
}
// Get the last modify time of a file
+(long) modifyTimeOfFile:(NSString *)path {
	PYASSERT([path length] > 0, @"File path is empty");
	struct stat st;
	if ( 0 != stat(path.UTF8String, &st) ) 
	{ return -1; }
	return st.st_mtimespec.tv_sec;
}
// Get the last access time of a file
+(long) accessTimeOfFile:(NSString *)path {
	PYASSERT([path length] > 0, @"File path is empty");
	struct stat st;
	if ( 0 != stat(path.UTF8String, &st) ) 
	{ return -1; }
	return st.st_atimespec.tv_sec;
}

// Get the create time of a file
+(NSDate *) createDateOfFile:(NSString *)path {
	PYASSERT([path length] > 0, @"File path is empty");
	struct stat st;
	if ( 0 != stat(path.UTF8String, &st) ) 
	{ return nil; }
	double interval = (double)st.st_ctimespec.tv_sec + 
		((double)st.st_ctimespec.tv_nsec / 1000000000.f);
	return [NSDate dateWithTimeIntervalSince1970:interval];
}
// Get the last modify time of a file
+(NSDate *) modifyDateOfFile:(NSString *)path {
	PYASSERT([path length] > 0, @"File path is empty");
	struct stat st;
	if ( 0 != stat(path.UTF8String, &st) ) 
	{ return nil; }
	double interval = (double)st.st_mtimespec.tv_sec + 
		((double)st.st_mtimespec.tv_nsec / 1000000000.f);
	return [NSDate dateWithTimeIntervalSince1970:interval];
}
// Get the last access time of a file
+(NSDate *) accessDateOfFile:(NSString *)path {
	PYASSERT([path length] > 0, @"File path is empty");
	struct stat st;
	if ( 0 != stat(path.UTF8String, &st) ) 
	{ return nil; }
	double interval = (double)st.st_atimespec.tv_sec + 
		((double)st.st_atimespec.tv_nsec / 1000000000.f);
	return [NSDate dateWithTimeIntervalSince1970:interval];
}
// Get the size of a file.
+(long) sizeOfFile:(NSString *)path {
	PYASSERT([path length] > 0, @"File path is empty");
	struct stat st;
	if ( 0 != stat(path.UTF8String, &st) ) 
		return -1;
	return st.st_size;				
}

@end
