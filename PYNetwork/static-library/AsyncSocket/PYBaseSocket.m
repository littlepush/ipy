//
//  PYBaseSocket.m
//  PYNetwork
//
//  Created by Push Chen on 7/11/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "PYBaseSocket.h"

@interface PYBaseSocket( Internal )

-(void) errorOccurred;
-(void) sockErrorOccurred:(int)errorCode;
-(void) errorWithCustomizedMessage:(NSString *)errorMsg;

-(int) socketSelect:(BOOL)beRead;

-(void) changeStatusTo:(PYSocketStatus)status;
-(void) gatherPeerInformation;

@end

@implementation PYBaseSocket

@synthesize isSocketBeBound = _beBound;
@synthesize remotePeerInfo = _remotePeerInfo;
@synthesize localPeerInfo = _localPeerInfo;

@dynamic socketWriteTimeout;
-(NSUInteger) socketWriteTimeout {
	if ( _socket == PYNINVALIDATE ) return PYNINVALIDATE;
	struct timeval _tv;
	socklen_t length;
	getsockopt(_socket, SOL_SOCKET, SO_SNDTIMEO, (void *)&_tv, &length);
	NSUInteger _timeout = _tv.tv_sec * 1000 + _tv.tv_usec / 1000;
	return _timeout;
}

-(void) setWriteTimeout:(NSUInteger)timeout {
	if ( _socket == PYNINVALIDATE ) return;
	struct timeval _tv = { timeout / 1000, (timeout % 1000) * 1000 };
	if (0 == setsockopt(_socket, SOL_SOCKET, SO_SNDTIMEO, 
		(const char *)&_tv, sizeof(struct timeval)))
	{
		[self errorOccurred];
	}
}

@synthesize isSocketReusable = _isSocketReusable;
-(void)setReusable:(BOOL)reusable {
	_isSocketReusable = reusable;
	setsockopt( _socket, SOL_SOCKET, SO_REUSEADDR,
		(const char *)&_isSocketReusable, sizeof(int));
}

@synthesize isSocketSendDelay = _isSocketSendDelay;
-(void) setSendDelay:(BOOL)delay {
	if ( _socket == PYNINVALIDATE ) return;
	_isSocketSendDelay = delay;
	int flag = delay ? 0 : 1;
	setsockopt( _socket, IPPROTO_TCP, 
		TCP_NODELAY, (const char *)&flag, sizeof(int) );
}

@dynamic socketWriteBufferSize;
-(NSUInteger) socketWriteBufferSize {
	if ( _socket == PYNINVALIDATE ) return PYNINVALIDATE;
	
	NSUInteger _size = PYNINVALIDATE, _length = 0;
	getsockopt(_socket, SOL_SOCKET, SO_SNDBUF, 
		(void *)&_size, &_length);
	return _size;
}
-(void) setWriteBufferSize:(NSUInteger)aSize {
	if ( _socket == PYNINVALIDATE ) return;
	
	setsockopt(_socket, SOL_SOCKET, SO_SNDBUF, 
		(const char *)&aSize, sizeof(unsigned int));
}

@dynamic socketReadBufferSize;
-(NSUInteger) socketReadBufferSize {
	if ( _socket == PYNINVALIDATE ) return PYNINVALIDATE;
	
	NSUInteger _size = PYNINVALIDATE, _length = 0;
	getsockopt(_socket, SOL_SOCKET, SO_RCVBUF, 
		(void *)&_size, &_length);
	return _size;
}
-(void) setReadBufferSize:(NSUInteger)aSize {
	if ( _socket == PYNINVALIDATE ) return;
	
	setsockopt(_socket, SOL_SOCKET, SO_RCVBUF, 
		(const char *)&aSize, sizeof(unsigned int));
}

@dynamic socketLingerTime;
-(NSUInteger)socketLingerTime {
	if ( _socket == PYNINVALIDATE ) return PYNINVALIDATE;
	struct linger _linger;
	NSUInteger _length;
	getsockopt(_socket, SOL_SOCKET, 
		SO_LINGER, (void *)&_linger, &_length);
	if ( _linger.l_onoff == 0 ) return PYNINVALIDATE;
	return _linger.l_linger;
}
-(void) setSocketIdleTime:(NSUInteger)lingerTime {
	if ( _socket == PYNINVALIDATE ) return;
	struct linger _linger = { (lingerTime > 0 ? 1 : 0), lingerTime };
	setsockopt(_socket, SOL_SOCKET, SO_LINGER, 
		(const void *)&_linger, sizeof(struct linger));
}

@dynamic isSocketHasDataToRead;
-(BOOL)isSocketHasDataToRead {
	int _result = [self socketSelect:YES];
	if ( _result == PYNINVALIDATE ) {
		// socket return error.
		[self closeConnection]; return NO;
	}
	if ( _result == 0 ) {
		// socket return timeout.
		return NO;
	}
	char c;
	if ( recv(_socket, &c, 1, MSG_PEEK ) <= 0 ) {
		// just receive EOF
		[self closeConnection]; return NO;
	}
	return YES;	
}

@dynamic isSocketHasDataToWrite;
-(BOOL)isSocketHasDataToWrite {
	int _result = [self socketSelect:NO];
	if ( _result == PYNINVALIDATE ) {
		[self closeConnection]; return NO;
	}
	return YES;
}

@dynamic isSocketConnected;
-(BOOL)isSocketConnected {
	return self.isSocketHasDataToRead || self.isSocketHasDataToWrite;
}

@dynamic socketIdleTime;
-(NSUInteger)socketIdleTime {
	if ( _socket == PYNINVALIDATE ) return PYNINVALIDATE;
	NSDate *_now = [NSDate date];
	NSTimeInterval _interval = [_now timeIntervalSinceDate:_idleTimer];
	return (NSUInteger)_interval;
}

@synthesize lastError = _lastError;
@synthesize delegate = _delegate;


// initialize
-(id) init {
	self = [super init];
	if ( self ) {
		_socket = PYNINVALIDATE;
		_beBound = NO;
		_beBoundCloseOnDone = NO;
		_remotePeerInfo = nil;
		_localPeerInfo = nil;
		// Status
		_lastSocketStatus = PYSocketStatusEmpyt;
		_currentSocketStatus = PYSocketStatusEmpyt;
		
		_idleTimer = nil;
		_lastError = nil;
	}
	return self;
}

-(void) dealloc {
	// release
	if ( !_beBound || _beBoundCloseOnDone ) {
		[self closeConnection];
	};
	
	[_remotePeerInfo release];
	_remotePeerInfo = nil;
	
	[_localPeerInfo release];
	_localPeerInfo = nil;
	
	[_idleTimer release];
	_idleTimer = nil;
	
	_lastError = nil;
	[super dealloc];	
}

-(PYSocketProcessStatus) connectToPeer:(PYSocketPeerInfo*)peerInfo 
	timedoutAfter:(NSUInteger)milliseconds
{
	if ( peerInfo == nil ) {
		[self errorWithCustomizedMessage:@"Invalide Peer Information"];
		return PYSocketProcessStatusError;
	}
	
	// Close Old Socket Object.
	if ( _socket != PYNINVALIDATE ) [self closeConnection];
	[self changeStatusTo:PYSocketStatusConnecting];
	
	unsigned int _inAddr = PYNDomainToInAddr(peerInfo.peerAddress);
	if ( _inAddr == PYNINVALIDATE ) {
		[self errorOccurred]; return PYSocketProcessStatusError;
	}

	// Create Socket Handle
	_socket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	if ( _socket == PYNINVALIDATE ) {
		[self errorOccurred]; return PYSocketProcessStatusError;
	}
				
	// Set With TCP_NODELAY
	int flag = 1;
	if( setsockopt( _socket, IPPROTO_TCP, 
		TCP_NODELAY, (const char *)&flag, sizeof(int) ) == -1 ) {
		[self errorOccurred]; return PYSocketProcessStatusError;
	}

	struct sockaddr_in _sockAddr;
	memset( &_sockAddr, 0, sizeof(_sockAddr) );

	_sockAddr.sin_addr.s_addr = _inAddr;
	_sockAddr.sin_family = AF_INET;
	_sockAddr.sin_port = htons(peerInfo.peerPort);

	if ( milliseconds > 0 ) {
		unsigned long _u = 1;
		PLIB_NETWORK_IOCTL_CALL(_socket, FIONBIO, &_u);
	}
	
	if ( connect( _socket, (struct sockaddr *)&_sockAddr, 
		sizeof(_sockAddr) ) == -1 )
	{
		if ( milliseconds == 0 ) {
			[self errorOccurred]; return PYSocketProcessStatusError;
		}
		struct timeval _tm = { milliseconds / 1000, (milliseconds % 1000) * 1000 };
		fd_set _fs;
		int _error = 0, len = sizeof(_error);
		FD_ZERO( &_fs );
		FD_SET( _socket, &_fs );
		BOOL rtn = NO;
		if ( select(_socket + 1, NULL, &_fs, NULL, &_tm) > 0 ) {
			getsockopt( _socket, SOL_SOCKET, SO_ERROR, 
				(char *)&_error, (socklen_t *)&len);
			if ( _error == 0 ) rtn = YES;
		}
		if ( !rtn ) {
			if ( _error == EINPROGRESS )
			{return PYSocketProcessStatusTimeOut;}
			else
			{[self sockErrorOccurred:_error]; return PYSocketProcessStatusError;}
		}
	}
	// Reset Socket Statue
	if ( milliseconds > 0 )
	{
		unsigned long _u = 0;
		PLIB_NETWORK_IOCTL_CALL(_socket, FIONBIO, &_u);
	}

	// Get Socket Remote Address and Local Port
	[self gatherPeerInformation];
	[self changeStatusTo:PYSocketStatusIdle];
	return PYSocketProcessStatusOK;
}
-(void) asyncConnectToPeer:(PYSocketPeerInfo *)peerInfo 
	timedoutAfter:(NSUInteger)milliseconds 
	completion:(PYSocketSuccess)cblock 
	timedout:(PYSocketTimeout)tblock 
	error:(PYSocketError)eblock
{
	BEGIN_ASYNC_INVOKE
		PYSocketProcessStatus _result = [self 
			connectToPeer:peerInfo timedoutAfter:milliseconds];
		if ( _result == PYSocketProcessStatusOK ) {
			if ( cblock ) { cblock(); } return;
		}
		if ( _result == PYSocketProcessStatusTimeOut ) {
			if ( tblock ) { tblock(); } return;
		}
		if ( _result == PYSocketProcessStatusError ) {
			if ( eblock ) { eblock( _lastError ); } return;
		}
	END_ASYNC_INVOKE;
}
-(void) closeConnection
{
	if ( _socket == PYNINVALIDATE ) return;
	if ( _beBound ) return;
	// Before Close;
	[self changeStatusTo:PYSocketStatusClosing];

	PLIB_NETWORK_CLOSESOCK( _socket );		
	_socket = PYNINVALIDATE;

	if ( [_delegate respondsToSelector:
		@selector(socket:didCloseConnectionToPeer:)] ) {
		[_delegate socket:self didCloseConnectionToPeer:_remotePeerInfo];
	}
	
	[self changeStatusTo:PYSocketStatusEmpyt];
}

-(void) bindWithSocket:(SOCKET_T)sock closeOnDone:(BOOL)close
{
	if ( sock > 65535 ) return;
	if ( sock == PYNINVALIDATE ) return;
	
	if ( _socket != PYNINVALIDATE ) {
		[self closeConnection];
	}
	_socket = sock;
	_beBoundCloseOnDone = close;
	_beBound = YES;

	[self gatherPeerInformation];
	[self changeStatusTo:PYSocketStatusBinding];
	[self changeStatusTo:PYSocketStatusIdle];
}

-(int) writeData:(NSData *)data
{
	const char *_d = data.bytes;
	int _l = data.length;
	unsigned int _a = 0;
	int _r = 0;
	
	while ( _a < _l )
	{
		_r = send(_socket, _d + _a, ( _l - _a ), 0 | PLIB_NETWORK_NOSIGNAL);
		if ( _r < 0 ) return _r;
		_a += _r;
	}
	return _a;
}

-(void) asyncWriteData:(NSData *)data completion:(PYSocketWriteBlock)wblock error:(PYSocketError)eblock
{
	BEGIN_ASYNC_INVOKE
		int _ret = [self writeData:data];
		if ( _ret < 0 ) {
			if ( eblock ) { eblock( _lastError ); }
			return;
		}
		if ( wblock ) {
			wblock( _ret );
		}
	END_ASYNC_INVOKE;
}

-(NSData *) readDataWithTimeOut:(NSUInteger)timeout
{
	struct timeval _tv;
	fd_set recvFs;
	FD_ZERO( &recvFs );
	FD_SET( _socket, &recvFs );
	NSMutableData *_data = [NSMutableData dataWithCapacity:512];

	NSTimeInterval _startTime = [[NSDate date] timeIntervalSince1970];
	NSUInteger _leftTime = timeout;
	do {
		_tv.tv_sec = (long)_leftTime / 1000;
		_tv.tv_usec = ((long)_leftTime % 1000) * 1000;
		
		if ( _socket == PYNINVALIDATE ) return nil;
		FD_ZERO( &recvFs );
		FD_SET( _socket, &recvFs );
		
		int _retCode = select( _socket + 1, &recvFs, NULL, NULL, &_tv );
		if ( _retCode < 0 )		// Error
		{
			[self errorOccurred];
			return nil;
		}
		if ( _retCode == 0 ) 	// TimeOut
			break;

		_retCode = [_data appendDataFromSocket:_socket];
		if ( _retCode < 0 ) {
			[self errorOccurred];
			return nil;
		}
		NSTimeInterval _currentTime = [[NSDate date] timeIntervalSince1970];
		if ( (NSUInteger)(_currentTime - _startTime) >= timeout )
			return _data;
	} while ( true );
	
	return _data;
}

-(void) asyncReceiveWithTimeout:(NSUInteger)timeout 
	data:(PYSocketRecvBlock)dblock 
	timedout:(PYSocketTimeout)tblock 
	error:(PYSocketError)eblock
{
	if ( _socket == PYNINVALIDATE ) return;
	if ( !dblock ) return;
	
	BEGIN_ASYNC_INVOKE
		struct timeval _tv;
		fd_set recvFs;
		FD_ZERO( &recvFs );
		FD_SET( _socket, &recvFs );
	
		NSTimeInterval _startTime = [[NSDate date] timeIntervalSince1970];
		NSUInteger _leftTime = timeout;
		char _buffer[1024] = { 0 };
		do {
			_tv.tv_sec = (long)_leftTime / 1000;
			_tv.tv_usec = ((long)_leftTime % 1000) * 1000;
			
			if ( _socket == PYNINVALIDATE ) return;
			FD_ZERO( &recvFs );
			FD_SET( _socket, &recvFs );
			
			int _retCode = select( _socket + 1, &recvFs, NULL, NULL, &_tv );
			if ( _retCode < 0 )		// Error
			{
				[self errorOccurred];
				if ( eblock ) {
					eblock( _lastError );
				}
				return;
			}
			if ( _retCode == 0 ) 	// TimeOut
			{
				if ( tblock ) {
					tblock();
				}
				return;
			}
			
			_retCode = recv( _socket, _buffer, 1024, 0 );
			if ( _retCode < 0 ) {
				[self errorOccurred];
				if ( eblock ) {
					eblock( _lastError );
				}
				return;
			}
			NSData *_data = [NSData dataWithBytesNoCopy:_buffer 
				length:_retCode freeWhenDone:NO];
			PYSocketReceiveStatus _continue = dblock( _data );
			if ( _continue == PYSocketReceiveStatusIlleage ) {
				// occurred
				[self errorWithCustomizedMessage:@"Receive data with illeage package"];
				if ( eblock ) { eblock(_lastError); }
				return;
			}
			if ( _continue == PYSocketReceiveStatusDone ) break;
			
			// else is unfinished
			
			NSTimeInterval _currentTime = [[NSDate date] timeIntervalSince1970];
			if ( (NSUInteger)(_currentTime - _startTime) >= timeout ) {
				if ( tblock ) {
					tblock();
				}
				return;
			}
		} while ( true );
	END_ASYNC_INVOKE;
}

-(void) errorOccurred
{
	[self changeStatusTo:PYSocketStatusError];
	
	int _errCode = errno;
	NSString *_errorMsg = [NSString stringWithFormat:@"%s", strerror(_errCode)];
	NSMutableDictionary *_errorDictionary = [NSMutableDictionary dictionary];
	[_errorDictionary setValue:_errorMsg forKey:NSLocalizedDescriptionKey];
	_lastError = nil;
	_lastError = [[NSError 
		errorWithDomain:@"PYBaseSocket" 
		code: _errCode
		userInfo:_errorDictionary] retain];	
	
	if ( [_delegate respondsToSelector:@selector(socket:occurredError:)] ) {
		[_delegate socket:self occurredError:_lastError];
	}
	
	[self closeConnection];
}
-(void) errorWithCustomizedMessage:(NSString *)errorMsg
{
	[self changeStatusTo:PYSocketStatusError];
	
	NSMutableDictionary *_errorDictionary = [NSMutableDictionary dictionary];
	[_errorDictionary setValue:errorMsg forKey:NSLocalizedDescriptionKey];
	_lastError = nil;
	_lastError = [[NSError 
		errorWithDomain:@"PYBaseSocket" 
		code: -1
		userInfo:_errorDictionary] retain];		
	if ( [_delegate respondsToSelector:@selector(socket:occurredError:)] ) {
		[_delegate socket:self occurredError:_lastError];
	}
	
	[self closeConnection];
}
-(void) sockErrorOccurred:(int)errorCode
{
	[self changeStatusTo:PYSocketStatusError];
	
	NSString *_errorMsg = [NSString stringWithFormat:@"%s", strerror(errorCode)];
	NSMutableDictionary *_errorDictionary = [NSMutableDictionary dictionary];
	[_errorDictionary setValue:_errorMsg forKey:NSLocalizedDescriptionKey];
	_lastError = nil;
	_lastError = [[NSError 
		errorWithDomain:@"PYBaseSocket" 
		code: errorCode
		userInfo:_errorDictionary] retain];		
	
	if ( [_delegate respondsToSelector:@selector(socket:occurredError:)] ) {
		[_delegate socket:self occurredError:_lastError];
	}
	
	[self closeConnection];
}

-(int) socketSelect:(BOOL)beRead
{
	if ( _socket == PYNINVALIDATE ) return -1;
	fd_set _fs;
	FD_ZERO(&_fs);
	FD_SET( _socket, &_fs );

	int _retCode = 0;
	struct timeval _tv = {0, 0};
	do {
		_retCode = select( _socket + 1, (beRead ? &_fs : NULL),
										(beRead ? NULL : &_fs),
										NULL, &_tv );
		if ( _retCode == -1 ) {
			// Check the error number
			int _err = errno;
			if ( _err != EINTR ) return -1;
			continue;
		}
		if ( _retCode == 0 ) {
			return 0;
		}
		return 1;
	} while ( 1 );

	return -1;
}

-(void) changeStatusTo:(PYSocketStatus)status
{
	// Cannot change the statue from empty to empty or idle.
	if ( _currentSocketStatus == PYSocketStatusEmpyt && 
		(status == PYSocketStatusIdle || status == PYSocketStatusEmpyt ) )
		return;
	_lastSocketStatus = _currentSocketStatus;
	_currentSocketStatus = status;
	
	if ( [_delegate respondsToSelector:@selector(socket:statusChangedTo:from:)] ) {
		[_delegate socket:self 
			statusChangedTo:_currentSocketStatus 
			from:_lastSocketStatus];
	}
	
	if ( _currentSocketStatus == PYSocketStatusIdle )
		_idleTimer = [[NSDate date] retain];
}

-(void) gatherPeerInformation
{
	if ( _socket == PYNINVALIDATE ) return;

	struct sockaddr_in _addr;
	socklen_t _addrLen = sizeof(_addr);
	memset( &_addr, 0, sizeof(_addr) );
	
	if ( 0 == getsockname(_socket, (struct sockaddr *)&_addr, &_addrLen) )
	{
		if ( _localPeerInfo != nil ) {
			[_localPeerInfo release];
			_localPeerInfo = nil;
		}
		NSUInteger _port = ntohs(_addr.sin_port);
		NSString *_address = [NSString stringWithFormat:@"%u.%u.%u.%u", 
			(unsigned int)(_addr.sin_addr.s_addr >> (0 * 8)) & 0x00FF,
			(unsigned int)(_addr.sin_addr.s_addr >> (1 * 8)) & 0x00FF,
			(unsigned int)(_addr.sin_addr.s_addr >> (2 * 8)) & 0x00FF,
			(unsigned int)(_addr.sin_addr.s_addr >> (3 * 8)) & 0x00FF];
		_localPeerInfo = [[PYSocketPeerInfo 
			peerInfoWithAddress:_address port:_port] retain];
	}
	memset( &_addr, 0, sizeof(_addr) );
	if ( 0 == getpeername( _socket, (struct sockaddr *)&_addr, &_addrLen ) )
	{
		if ( _remotePeerInfo != nil ) {
			[_remotePeerInfo release];
			_remotePeerInfo = nil;
		}
		
		NSUInteger _port = ntohs(_addr.sin_port);
		NSString *_address = [NSString stringWithFormat:@"%u.%u.%u.%u", 
			(unsigned int)(_addr.sin_addr.s_addr >> (0 * 8)) & 0x00FF,
			(unsigned int)(_addr.sin_addr.s_addr >> (1 * 8)) & 0x00FF,
			(unsigned int)(_addr.sin_addr.s_addr >> (2 * 8)) & 0x00FF,
			(unsigned int)(_addr.sin_addr.s_addr >> (3 * 8)) & 0x00FF];
		_remotePeerInfo = [[PYSocketPeerInfo
			peerInfoWithAddress:_address port:_port] retain];
	}
}

-(NSString *)description
{
	NSString *_socketDesc = [NSString 
		stringWithFormat:@"#SO:%d,Status:%@,Idle:%@,Peer:%@#",
		_socket, 
		PYSocketStatusDescription(_currentSocketStatus),
		(_idleTimer == nil ? nil : 
			[NSString stringWithFormat:@"%ds", 
				[[NSDate date] timeIntervalSinceDate:_idleTimer]]),
		_remotePeerInfo];
	return _socketDesc;
}

@end
