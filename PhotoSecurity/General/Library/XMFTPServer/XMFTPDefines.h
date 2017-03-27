//
//  XMFTPDefines.h
//  XMFtpServer
//
//  Created by chi on 16/3/28.
//  Copyright © 2016年 chi. All rights reserved.
//

#ifndef XMFTPDefines_h
#define XMFTPDefines_h


enum {
    pasvftp=0,epsvftp,portftp,lprtftp, eprtftp
};

#define DATASTR(args) [ args dataUsingEncoding:NSUTF8StringEncoding ]

#define SERVER_PORT 20000
#define READ_TIMEOUT -1

#define FTP_CLIENT_REQUEST 0

enum {
    
    clientSending=0, clientReceiving=1, clientQuiet=2,clientSent=3
};


#ifdef DEBUG
#define XMFTPLog(...) NSLog(__VA_ARGS__)
#else
#define XMFTPLog(...)
#endif


extern BOOL g_XMFTP_LogEnabled;

#endif /* XMFTPDefines_h */
