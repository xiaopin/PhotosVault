//
//  XMFTPServer.m
//  XMFtpServer
//
//  Created by chi on 16/3/28.
//  Copyright © 2016年 chi. All rights reserved.
//

#import "XMFTPServer.h"

BOOL g_XMFTP_LogEnabled = NO;

@implementation XMFTPServer


@synthesize listenSocket, connectedSockets, server, notificationObject, portNumber, delegate, commands, baseDir, connections;

@synthesize clientEncoding;
@synthesize changeRoot;

// ----------------------------------------------------------------------------------------------------------
- (id)initWithPort:(unsigned)serverPort withDir:(NSString*)aDirectory notifyObject:(id)sender
// ----------------------------------------------------------------------------------------------------------
{
    if( self = [super init] ) {
        
        NSError *error = nil;
        
        self.notificationObject = sender;
        
        // Load up commands
        NSString *plistPath = [[ NSBundle mainBundle ] pathForResource:@"xmftp_commands" ofType:@"plist"];
        if ( ! [ [ NSFileManager defaultManager ] fileExistsAtPath:plistPath ] )
        {
            NSAssert(0, @"xmftp_commands.plist missing");
        }
        commands = [ [ NSDictionary alloc ] initWithContentsOfFile:plistPath];
        
        // Clear out connections list
        NSMutableArray *myConnections = [[NSMutableArray alloc] init];
        self.connections = myConnections;
        
        
        
        // Create a socket
        self.portNumber = serverPort;
        
        AsyncSocket *myListenSocket = [[AsyncSocket alloc] initWithDelegate:self];
        self.listenSocket = myListenSocket;
        
        if (g_XMFTP_LogEnabled) {
            XMFTPLog(@"Listening on %u", portNumber);
        }
        
        [listenSocket acceptOnPort:serverPort error:&error];					// start lisetning on this port.
        
        NSMutableArray *myConnectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
        self.connectedSockets = myConnectedSockets;
        
        // Set directory - have to do this because on iphone, some directories arent what they report back as, so need real path it resolves to, CHECKME - might be an easier way
        NSFileManager	*fileManager  = [ NSFileManager defaultManager ];
        NSString		*expandedPath = [ aDirectory stringByStandardizingPath ];
        
        // CHANGE TO NEW DIRECTORY & GET SYSTEM FILE PATH ( no .. etc )
        if ([ fileManager changeCurrentDirectoryPath:expandedPath ]) 	// try changing to directory
        {
            
            self.baseDir = [[ fileManager currentDirectoryPath ] copy] ;				// Gets the real path. CHECKME.
            //	self.baseDir = @"/Users";																			// REMOVEME - added for testing 7/6/10
        }
        else
        {
            self.baseDir =  aDirectory;													// shouldnt get to this line really
        }
        
        self.changeRoot = false;		// true if you want them to be sandboxed/chrooted into the basedir
        
        // the default client encoding is UTF8
        self.clientEncoding = NSUTF8StringEncoding;
    }
    return self;
}
// ----------------------------------------------------------------------------------------------------------
-(void)stopFtpServer
// ----------------------------------------------------------------------------------------------------------
{
    if(listenSocket)[listenSocket disconnect];
    
    [connectedSockets removeAllObjects];
    
    [connections removeAllObjects];
    
}
#pragma mark ASYNCSOCKET DELEGATES
// ----------------------------------------------------------------------------------------------------------
- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
// ----------------------------------------------------------------------------------------------------------
{
    
    XMFTPConnection *newConnection = [[XMFTPConnection alloc ] initWithAsyncSocket:newSocket forServer:self];
    
    
    
    
    [ connections addObject:newConnection ];			// Add this to our list of connections
    
    if (g_XMFTP_LogEnabled) {
        XMFTPLog(@"FS:didAcceptNewSocket  port:%i", [sock localPort]);
    }
    
    if ([sock localPort] == portNumber )
    {
        if (g_XMFTP_LogEnabled) {
            XMFTPLog(@"Connection on Server Port");
        }
    }
    else
    {
        // must be a data comms port
        // spawn a data comms port
        // look for the connection with the same port
        // and attach it
        if (g_XMFTP_LogEnabled) {
            XMFTPLog(@"--ERROR %i, %i", [sock localPort],portNumber);
        }
    }
}

// ----------------------------------------------------------------------------------------------------------
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
// ----------------------------------------------------------------------------------------------------------
{
    if (g_XMFTP_LogEnabled) {
        XMFTPLog(@"FtpServer:didConnectToHost  port:%i", [sock localPort]);
    }
    
}

#pragma mark NOTIFICATIONS
// ----------------------------------------------------------------------------------------------------------
-(void)didReceiveFileListChanged
// ----------------------------------------------------------------------------------------------------------
{
    if ([notificationObject respondsToSelector:@selector(didReceiveFileListChanged)])
        [notificationObject didReceiveFileListChanged ];
}
#pragma mark CONNECTIONS
// ----------------------------------------------------------------------------------------------------------
- (void)closeConnection:(id)theConnection
// ----------------------------------------------------------------------------------------------------------
{
    // Search through connections for this one - and delete
    // this should release it - and delloc
    
    [connections removeObject:theConnection ];
    
    
}

// ----------------------------------------------------------------------------------------------------------
-(NSString*)createList:(NSString*)directoryPath
// ----------------------------------------------------------------------------------------------------------
{ 
    return createList(directoryPath);
    
    
}

- (void)dealloc
{
    if(listenSocket)
    {
        [listenSocket disconnect];
    }
}

@end
