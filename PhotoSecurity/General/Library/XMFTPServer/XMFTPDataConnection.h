//
//  XMFTPDataConnection.h
//  XMFtpServer
//
//  Created by chi on 16/3/28.
//  Copyright © 2016年 chi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AsyncSocket.h"
#import "XMFTPDefines.h"

@class XMFTPConnection;

@interface XMFTPDataConnection : NSObject{
    AsyncSocket			*dataSocket;
    XMFTPConnection		*ftpConnection;						// connection which generated data socket we are tied to
    
    AsyncSocket			*dataListeningSocket;
    id					dataConnection;
    NSMutableData		*receivedData;
    int					connectionState;
    
}
-(id)initWithAsyncSocket:(AsyncSocket*)newSocket forConnection:(id)aConnection withQueuedData:(NSMutableArray*)queuedData;
-(void)writeString:(NSString*)dataString;
-(void)writeData:(NSMutableData*)data;
-(void)writeQueuedData:(NSMutableArray*)queuedData;
-(void)closeConnection;

#pragma mark ASYNCSOCKET DELEGATES
-(BOOL)onSocketWillConnect:(AsyncSocket *)sock;
-(void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket;
-(void)onSocket:(AsyncSocket*)sock didReadData:(NSData*)data withTag:(long)tag;
-(void)onSocket:(AsyncSocket*)sock didWriteDataWithTag:(long)tag;

-(void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err;

@property (readonly) NSMutableData *receivedData;
@property (readwrite) int connectionState;

@end
