//
//  XMFTPServer.h
//  XMFtpServer
//
//  Created by chi on 16/3/28.
//  Copyright © 2016年 chi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AsyncSocket.h"
#import "XMFTPDefines.h"
#import "XMFTPConnection.h"
#import "XMFTPHelper.h"


@interface XMFTPServer : NSObject{
    
    AsyncSocket		*listenSocket;
    NSMutableArray	*connectedSockets;
    id				server;
    id				notificationObject;
    
    int				portNumber;
    id				delegate;
    
    NSMutableArray *connections;
    
    NSDictionary	*commands;
    NSString		*baseDir;
    Boolean			changeRoot;							// Change root to virtual root ( basedir )
    int				clientEncoding;						// FTP client encoding type
}
- (id)initWithPort:(unsigned)serverPort withDir:(NSString *)aDirectory notifyObject:(id)sender;
- (void)stopFtpServer;

#pragma mark ASYNCSOCKET DELEGATES
- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket;
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port;

#pragma mark NOTIFICATIONS
- (void)didReceiveFileListChanged;

#pragma mark CONNECTIONS
- (void)closeConnection:(id)theConnection;
- (NSString *)createList:(NSString *)directoryPath;

@property (readwrite, strong) AsyncSocket *listenSocket;
@property (readwrite, strong) NSMutableArray *connectedSockets;
@property (readwrite, strong) id server;
@property (readwrite, strong) id notificationObject;
@property (readwrite) int portNumber;
@property (readwrite, strong) id delegate;
@property (readwrite, strong) NSMutableArray *connections;
@property (readwrite, strong) NSDictionary *commands;
@property (readwrite, strong) NSString *baseDir;
@property (readwrite) Boolean changeRoot;
@property (readwrite) int clientEncoding;

@end
