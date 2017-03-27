//
//  XMFTPHelper.m
//  XMFtpServer
//
//  Created by chi on 16/3/28.
//  Copyright © 2016年 chi. All rights reserved.
//

#import "XMFTPHelper.h"

#import <SystemConfiguration/SystemConfiguration.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <unistd.h>
#include <ifaddrs.h>

@implementation XMFTPHelper

// Get IP Address
+ (NSString *)localIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}

@end


// ----------------------------------------------------------------------------------------------------------
NSString* createList(NSString* directoryPath)
// ----------------------------------------------------------------------------------------------------------
{
    NSFileManager *fileManager = [ NSFileManager defaultManager ];
    NSDictionary *fileAttributes;
    NSError *error;
    
    NSString*			fileType;
    NSNumber*			filePermissions;
    long				fileSubdirCount;
    NSString*			fileOwner;
    NSString*			fileGroup;
    NSNumber*			fileSize;
    NSDate*				fileModified;
    NSString*			fileDateFormatted;
    NSDateFormatter*    dateFormatter = [[ NSDateFormatter alloc ] init];
    
    BOOL				fileIsDirectory;
    
    
    NSMutableString*	returnString= [ NSMutableString new ];
    NSString*			formattedString;
    
    NSString*			binaryString;
    
    [returnString appendString:@"\r\n"];
    
    NSDirectoryEnumerator *dirEnum =    [fileManager  enumeratorAtPath:directoryPath];
    NSString *filePath;
    
    NSString* firstChar;
    NSString* fullFilePath;
    
    [dateFormatter setDateFormat:@"MMM dd HH:mm"];
    NSLocale *englishLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en"];
    [dateFormatter setLocale:englishLocale];
    
    
    NSLog(@"Get LS for %@", directoryPath );
    int numberOfFiles = 0;
    while (filePath = [dirEnum nextObject]) {
        
        firstChar = [ filePath substringToIndex:1 ];
        
        [dirEnum skipDescendents ];			// don't go down that recursive road
        
        if ( ![ firstChar isEqualToString:@"."] )			// dont show hidden files
        {
            fullFilePath = [directoryPath stringByAppendingPathComponent:filePath];
            
            fileAttributes = [ fileManager attributesOfItemAtPath:fullFilePath error:&error ];
            
            fileType =		  [ fileAttributes valueForKey:NSFileType ];
            
            filePermissions		= [ fileAttributes valueForKey:NSFilePosixPermissions ];
            fileSubdirCount		= filesinDirectory(fullFilePath);
            fileOwner			= [ fileAttributes valueForKey:NSFileOwnerAccountName ];
            fileGroup			= [ fileAttributes valueForKey:NSFileGroupOwnerAccountName ];
            fileSize			= [ fileAttributes valueForKey:NSFileSize ];
            fileModified		= [ fileAttributes valueForKey:NSFileModificationDate ];
            fileDateFormatted	= [ dateFormatter stringFromDate:fileModified ];
            
            fileIsDirectory     = (fileType == NSFileTypeDirectory );
            
            
            fileSubdirCount = fileSubdirCount <1 ? 1 : fileSubdirCount;
            
            binaryString =  int2BinString([filePermissions intValue]) ;
            binaryString = [ binaryString substringFromIndex:7 ];// snip off the front
            formattedString = [ NSString stringWithFormat:@"%@%@ %5li %12@ %12@ %10qu %@ %@", fileIsDirectory ? @"d" : @"-" ,bin2perms(binaryString),fileSubdirCount, fileOwner, fileGroup, [fileSize unsignedLongLongValue], fileDateFormatted , filePath ];
            
            [ returnString appendString:formattedString ];
            [ returnString appendString:@"\n" ];
            numberOfFiles++;
        }
    }
    [returnString insertString: [NSString stringWithFormat:@"total %d", numberOfFiles] atIndex:0];
    //	NSLog(returnString );
    return returnString;																				// FIXME - release count
    
}
// ----------------------------------------------------------------------------------------------------------
int filesinDirectory(NSString* filePath )
// ----------------------------------------------------------------------------------------------------------
{
    int no_files =0;
    NSFileManager *fileManager = [ NSFileManager defaultManager ];
    NSDirectoryEnumerator *dirEnum =    [fileManager  enumeratorAtPath:filePath];
    
    while (filePath = [dirEnum nextObject]) {
        [dirEnum skipDescendents ];										// don't want children
        no_files++;
    }
    
    return no_files;
}
// ----------------------------------------------------------------------------------------------------------
NSMutableString* int2BinString(int x)
// ----------------------------------------------------------------------------------------------------------
{
    NSMutableString *returnString = [[ NSMutableString alloc ] init];
    int hi, lo;
    hi=(x>>8) & 0xff;
    lo=x&0xff;
    
    [ returnString appendString:byte2String(hi) ];
    [ returnString appendString:byte2String(lo) ];
    return returnString;
}



// ----------------------------------------------------------------------------------------------------------
NSMutableString *byte2String(int x )
// ----------------------------------------------------------------------------------------------------------
{
    NSMutableString *returnString  = [[ NSMutableString alloc ]init];
    
    int n;
    
    for(n=0; n<8; n++)
    {
        if((x & 0x80) !=0)
        {
            
            [ returnString appendString:@"1"];
            
            
        }
        else
        {
            [ returnString appendString:@"0"];
        }
        x = x<<1;
    }
    
    return returnString;
}

// ----------------------------------------------------------------------------------------------------------
NSMutableString *bin2perms(NSString *binaryValue)
// ----------------------------------------------------------------------------------------------------------
{
    NSMutableString *returnString = [[ NSMutableString alloc ] init];
    NSRange subStringRange;
    subStringRange.length = 1;
    NSString *replaceWithChar = nil;
    
    for (int n=0; n < [binaryValue length]; n++) 
    {
        subStringRange.location = n;
        // take the char
        // if pos = 0, 3,6
        if ( n == 0 || n == 3 || n ==6)
        {
            replaceWithChar = @"r";
        }
        if ( n == 1 || n == 4 || n ==7)
        {
            replaceWithChar = @"w";			
        }
        if ( n == 2 || n == 5 || n ==7)
        {
            replaceWithChar = @"x";
        }
        
        if ( [[binaryValue substringWithRange:subStringRange ] isEqualToString:@"1" ] )
        {
            [ returnString appendString:replaceWithChar ];
        }
        else
        {
            [ returnString appendString:@"-" ];
        }
        
    }
    
    return returnString;
}