//
//  PYFileManager.h
//  PYCore
//
//  Created by littlepush on 9/5/12.
//  Copyright (c) 2012 PushLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <dirent.h>
#include <unistd.h>
#include <sys/stat.h>

typedef int			FHandle;
// File Stream Open Statue.
typedef enum {
	FS_READ 	= O_RDONLY,
	FS_WRITE	= O_WRONLY | O_CREAT | O_TRUNC,
	FS_APPEND	= O_APPEND | O_CREAT
} FOSTATUE;

@interface PYFileStream : NSObject
{
	enum { FS_MAX_BUFFER_SIZE = 0x4000 };
	NSMutableData			*__buffer;
	NSString				*__filePath;
	FHandle					__fhandle;
	FOSTATUE				__ostatue;
}

@property (nonatomic, readonly) NSString		*filepath;

/* Open For Reading Only */
-(BOOL) openForRead:(NSString *)path;
/* Open For Writing Only */
-(BOOL) openForWrite:(NSString *)path;
/* Open for reading and writing */
-(BOOL) openReadAndWrite:(NSString *)path;
/* Defailt Open: Read And Write */
-(BOOL) openFile:(NSString *)path;
/* Open for writing and seek to end of file */
-(BOOL) openForAppend:(NSString *)path;
/* Save file */
-(BOOL) saveFile;
/* Flush the data and close the file handle */
-(void) closeFile;

#pragma Operation Of File
/* Write data to file */
-(BOOL) writeData:(NSData *)data;
-(BOOL) writeString:(NSString *)string;
-(BOOL) writeLine:(NSString *)string;

/* Append data to file */
-(BOOL) appendData:(NSData *)data;
-(BOOL) appendString:(NSString *)string;
-(BOOL) appendLine:(NSString *)string;

/* Read data from file */
// Read a word
-(NSString *) readWord;
// Read line
-(NSString *) readLine;
// Read specified size
-(NSData *) readLength:(NSUInteger)length;
// Read all file
-(NSData *) readToEnd; 

@end

/*
	FileManager from PLib
	get basic information of a file
	do some basic operations.
 */
@interface PYFileManager : NSObject

// Check if a file is existed;
+(BOOL) isFileExisted:(NSString *)path;
// Create a new file at path. if the file is already existed, just return YES
+(BOOL) createFile:(NSString *)path;
// Delete a file at specified path.
+(BOOL) deleteFile:(NSString *)path;
// Move file A to B
+(BOOL) moveFile:(NSString *)originPath to:(NSString *)destPath;
// Copy file A to B
+(BOOL) copyFile:(NSString *)originPath to:(NSString *)destPath overwrite:(BOOL)overwrite;
// Append data to file
+(BOOL) appendData:(NSData *)data toFile:(NSString *)path;
// Clear a file's content
+(BOOL) clearFile:(NSString *)path;


// Get the create time of a file
+(NSDate *) createDateOfFile:(NSString *)path;
// Get the last modify time of a file
+(NSDate *) modifyDateOfFile:(NSString *)path;
// Get the last access time of a file
+(NSDate *) accessDateOfFile:(NSString *)path;
// Get the create time of a file
+(long) createTimeOfFile:(NSString *)path;
// Get the last modify time of a file
+(long) modifyTimeOfFile:(NSString *)path;
// Get the last access time of a file
+(long) accessTimeOfFile:(NSString *)path;
// Get the size of a file.
+(long) sizeOfFile:(NSString *)path;

@end
