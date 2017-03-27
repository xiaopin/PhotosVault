//
//  XMFTPHelper.h
//  XMFtpServer
//
//  Created by chi on 16/3/28.
//  Copyright © 2016年 chi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMFTPHelper : NSObject

+ (NSString *)localIPAddress;

@end



#pragma mark LS replacement
NSString* createList(NSString* directoryPath);

#pragma mark Supporting Functions
int filesinDirectory(NSString* filePath );
NSMutableString* int2BinString(int x);
NSMutableString *byte2String(int x );
NSMutableString *bin2perms(NSString *binaryValue);
