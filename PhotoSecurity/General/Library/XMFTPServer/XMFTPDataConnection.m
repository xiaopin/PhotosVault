//
//  XMFTPDataConnection.m
//  XMFtpServer
//
//  Created by chi on 16/3/28.
//  Copyright © 2016年 chi. All rights reserved.
//

#import "XMFTPDataConnection.h"

#import "XMFTPConnection.h"

@implementation XMFTPDataConnection


@synthesize receivedData;
@synthesize connectionState;

// ----------------------------------------------------------------------------------------------------------
-(id)initWithAsyncSocket:(AsyncSocket*)newSocket forConnection:(id)aConnection withQueuedData:(NSMutableArray*)queuedData
// ----------------------------------------------------------------------------------------------------------
{
    self = [super init ];
    if (self)
    {
        dataSocket = newSocket;						// Hang onto the socket that was generated - the FDC is retained by FC
        ftpConnection = aConnection;
        
        [ dataSocket setDelegate:self ];
        
        if ( [queuedData count ] )
        {
            if (g_XMFTP_LogEnabled) {
                XMFTPLog(@"FC:Write Queued Data");
            }
            [self writeQueuedData:queuedData ];
            [ queuedData removeAllObjects ];					// Clear out queue
        }
        // [ dataSocket readDataToData:[AsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:FTP_CLIENT_REQUEST ];
        [ dataSocket readDataWithTimeout:READ_TIMEOUT tag:FTP_CLIENT_REQUEST ];
        dataListeningSocket = nil;
        receivedData = nil; //	[[ NSMutableData alloc ] init ]   12/nov/08 - no need for this. rcd is just a pointer
        
        connectionState = clientQuiet;						// Nothing coming through
    }
    return self;
}

// ----------------------------------------------------------------------------------------------------------
-(void)writeString:(NSString*)dataString
// ----------------------------------------------------------------------------------------------------------
{
    if (g_XMFTP_LogEnabled) {
        XMFTPLog(@"FDC:writeStringData");
    }
    
    NSMutableData *data = [[ dataString dataUsingEncoding:NSUTF8StringEncoding ] mutableCopy];				// Autoreleased
    [ data appendData:[AsyncSocket CRLFData] ];
    
    [ dataSocket writeData:data withTimeout:READ_TIMEOUT tag:FTP_CLIENT_REQUEST ];
    [ dataSocket readDataWithTimeout:READ_TIMEOUT tag:FTP_CLIENT_REQUEST ];
}

// ----------------------------------------------------------------------------------------------------------
-(void)writeData:(NSMutableData*)data
// ----------------------------------------------------------------------------------------------------------
{
    if (g_XMFTP_LogEnabled) {
        XMFTPLog(@"FDC:writeData");
    }
    //	[ data appendData:[AsyncSocket CRLFData] ];												// Add on CRLF to end of data - as Windows Explorer needs it
    
    connectionState = clientReceiving;														// We hope
    
    [ dataSocket writeData:data withTimeout:READ_TIMEOUT tag:FTP_CLIENT_REQUEST ];
    
    [ dataSocket readDataWithTimeout:READ_TIMEOUT tag:FTP_CLIENT_REQUEST ];
}
// ----------------------------------------------------------------------------------------------------------
-(void)writeQueuedData:(NSMutableArray*)queuedData
// ----------------------------------------------------------------------------------------------------------
{
    for (NSMutableData* data in queuedData) {
        [self writeData:data ];
    }
}

// ----------------------------------------------------------------------------------------------------------
-(void)closeConnection
// ----------------------------------------------------------------------------------------------------------
{
    if (g_XMFTP_LogEnabled) {
        XMFTPLog(@"FDC:closeConnection");;
    }

    [ dataSocket disconnect  ];
    
}
#pragma mark ASYNCSOCKET DELEGATES
// ----------------------------------------------------------------------------------------------------------
-(BOOL)onSocketWillConnect:(AsyncSocket *)sock
// ----------------------------------------------------------------------------------------------------------
{
    if (g_XMFTP_LogEnabled) {
        XMFTPLog(@"FDC:onSocketWillConnect");
    }

    [ dataSocket readDataWithTimeout:READ_TIMEOUT tag:0 ];
    return YES;
}

// ----------------------------------------------------------------------------------------------------------
-(void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
// ----------------------------------------------------------------------------------------------------------
{
    // This shouldnt happen - we should be connected already - and havent set up a listening socket
    if (g_XMFTP_LogEnabled) {
        XMFTPLog(@"FDC:New Connection -- shouldn't be called");
    }
}



// ----------------------------------------------------------------------------------------------------------
-(void)onSocket:(AsyncSocket*)sock didReadData:(NSData*)data withTag:(long)tag
// ----------------------------------------------------------------------------------------------------------
{
    if (g_XMFTP_LogEnabled) {
        XMFTPLog(@"FDC:didReadData");;
    }
    //	[ dataSocket readDataToData:[AsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:FTP_CLIENT_REQUEST ];			// continue reading
    [ dataSocket readDataWithTimeout:READ_TIMEOUT tag:FTP_CLIENT_REQUEST ];
    
    
    receivedData = [data mutableCopy];								// make autoreleased copy of data
    
    // notify connection data came through,  ( will write data for us )
    [ftpConnection didReceiveDataRead ];						// notify, the connection, so it knows to write								// let go, not our business anymore
    connectionState = clientSent;
}


// ----------------------------------------------------------------------------------------------------------
-(void)onSocket:(AsyncSocket*)sock didWriteDataWithTag:(long)tag
// ----------------------------------------------------------------------------------------------------------
{
    if (g_XMFTP_LogEnabled) {
        XMFTPLog(@"FDC:didWriteData");
    }

    [ ftpConnection didReceiveDataWritten ];				// notify that we are finished writing
    
    //	[ dataSocket readDataToData:[AsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:FTP_CLIENT_REQUEST ];			// continue reading
    [ dataSocket readDataWithTimeout:READ_TIMEOUT tag:FTP_CLIENT_REQUEST ];
}


// ----------------------------------------------------------------------------------------------------------
-(void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
// ----------------------------------------------------------------------------------------------------------
{
    if (g_XMFTP_LogEnabled) {
        XMFTPLog(@"FDC:willDisconnect");
    }

    // if we were writing and there's no error,  then it must be the end of file
    
    if ( connectionState == clientSending )
    {
        if (g_XMFTP_LogEnabled) {
            XMFTPLog(@"FDC::did FinishReading");;
        }
        // hopefully this is the end of the connection. not sure how we can tell
    }
    else
    {
        if (g_XMFTP_LogEnabled) {
            XMFTPLog(@"FDC: we werent expecting this as we never set clientSending  prob late coming up");
        }
    }
    [ ftpConnection didFinishReading ];																				// its over, please send the message	
}

- (BOOL)onReadStreamEnded:(AsyncSocket*)sock
{
    if (g_XMFTP_LogEnabled) {
        XMFTPLog(@"FDC: onReadStreamEnded %d(clientSending is %d)", connectionState, clientSending);
    }
    if ( connectionState == clientSent ||
        connectionState == clientSending ) return YES;
    return NO;
}


@end
