/*
 ConnectivityMonitor.m
 Copyright (c) 2008, 2009 Matt Wright.
 
 MacIrssi is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 2 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "ConnectivityMonitor.h"
#import "net-sendbuffer.h"
#import <Glib/glib.h>

//#define CONNECTITIVTY_DEBUG 1

@implementation ConnectivityMonitor

+ (ConnectivityMonitor*)sharedMonitor
{
	static ConnectivityMonitor *sharedMonitor;
	if (!sharedMonitor)
	{
		sharedMonitor = [[ConnectivityMonitor alloc] init];
	}
	return sharedMonitor;
}

- (id)init
{
	if (self = [super init])
	{
    serverMap = [[NSMapTable mapTableWithStrongToStrongObjects] retain];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(serverDidConnect:) 
                                                 name:kMIServerConnectedEvent
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(serverDidDisconnect:)
                                                 name:kMIServerDisconnectedEvent
                                               object:nil];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self 
                                                           selector:@selector(workspaceWillSleep:) 
                                                               name:NSWorkspaceWillSleepNotification 
                                                             object:[NSWorkspace sharedWorkspace]];
	}
	return self;
}

static void networkReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkConnectionFlags flags, void *info)
{
#ifdef CONNECTITIVTY_DEBUG
	NSLog(@"networkReachabilityCallback: got flags: %c%c%c%c%c%c%c",  
 	      (flags & kSCNetworkFlagsTransientConnection)  ? 't' : '-',  
 	      (flags & kSCNetworkFlagsReachable)            ? 'r' : '-',  
 	      (flags & kSCNetworkFlagsConnectionRequired)   ? 'c' : '-',  
 	      (flags & kSCNetworkFlagsConnectionAutomatic)  ? 'C' : '-',  
 	      (flags & kSCNetworkFlagsInterventionRequired) ? 'i' : '-',  
 	      (flags & kSCNetworkFlagsIsLocalAddress)       ? 'l' : '-',  
 	      (flags & kSCNetworkFlagsIsDirect)             ? 'd' : '-');  
#endif
  [[ConnectivityMonitor sharedMonitor] networkReachabilityCallback:target flags:flags info:info];
}

- (void)serverDidConnect:(NSNotification*)notification
{
  NSValue *pointerToServerRec = [notification object];
  SERVER_REC *server_rec = [pointerToServerRec pointerValue];
  
  GIOChannel *channel = (server_rec->handle && server_rec->handle->handle) ? server_rec->handle->handle : NULL;
  
  SCNetworkReachabilityRef reachabilityRef = nil;
  if (channel == NULL) {
    /* No channel, not sure why but we can create a generic version from the rec address */
    reachabilityRef = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, server_rec->connrec->address);
  } else {
    struct sockaddr_storage local_address, remote_address;
    socklen_t local_address_size, remote_address_size;
    
    int server_rec_fd = g_io_channel_unix_get_fd(channel);
    local_address_size = remote_address_size = sizeof(local_address);
    
    if (getsockname(server_rec_fd, (struct sockaddr*)&local_address, &local_address_size) == -1) {
      NSLog(@"-[%@ %@] unable to getsockname for remote connection to %s.", [self className], NSStringFromSelector(_cmd), server_rec->connrec->address);
      return;
    }
    
    if (getpeername(server_rec_fd, (struct sockaddr*)&remote_address, &remote_address_size) == -1) {
      NSLog(@"-[%@ %@] unable to getpeername for remote connection to %s.", [self className], NSStringFromSelector(_cmd), server_rec->connrec->address);
      return;
    }
    
    reachabilityRef = SCNetworkReachabilityCreateWithAddressPair(kCFAllocatorDefault, (struct sockaddr*)&local_address, (struct sockaddr*)&remote_address);
  }
  
  if (reachabilityRef != nil) {
    SCNetworkReachabilityContext context = {
      .version = 0,
      .info = pointerToServerRec,
      .retain = CFRetain,
      .release = CFRelease,
    };
    
    [serverMap setObject:(id)reachabilityRef forKey:pointerToServerRec];

    SCNetworkReachabilitySetCallback(reachabilityRef, networkReachabilityCallback, &context);
    SCNetworkReachabilityScheduleWithRunLoop(reachabilityRef, [[NSRunLoop mainRunLoop] getCFRunLoop], kCFRunLoopCommonModes);
  }
}

- (void)serverDidDisconnect:(NSNotification*)notification
{
  NSValue *pointerToServerRec = [notification object];
  /* unused */ // SERVER_REC *server_rec = [pointerToServerRec pointerValue];
  
  SCNetworkReachabilityRef reachabilityRef = (SCNetworkReachabilityRef)[serverMap objectForKey:pointerToServerRec];

  if (reachabilityRef) {
    [serverMap removeObjectForKey:pointerToServerRec];
    SCNetworkReachabilityUnscheduleFromRunLoop(reachabilityRef, [[NSRunLoop mainRunLoop] getCFRunLoop], kCFRunLoopCommonModes);
    CFRelease(reachabilityRef);
  }
}

// Notifications from workspace on system state
- (void)workspaceWillSleep:(NSNotification*)notification
{
  for (NSValue *pointerToServerRec in [[serverMap copy] autorelease])
  {
    SERVER_REC *server_rec = [pointerToServerRec pointerValue];
    SCNetworkReachabilityRef reachabilityRef = (SCNetworkReachabilityRef)[serverMap objectForKey:pointerToServerRec];
    
    SERVER_CONNECT_REC *server_connection_rec = server_connect_copy_skeleton(server_rec->connrec, TRUE);
    if (server_rec->connected) {
      reconnect_save_status(server_connection_rec, server_rec);
    }
    server_connection_rec->reconnection = TRUE;
    
    /* swizzle our connection rec to the reconnection map */
    NSValue *newConnectionValue = [NSValue valueWithPointer:server_connection_rec];
    [serverMap removeObjectForKey:pointerToServerRec];
    [serverMap setObject:(id)reachabilityRef forKey:newConnectionValue];
    
    SCNetworkReachabilityContext context = {
      .version = 0,
      .info = newConnectionValue,
      .retain = CFRetain,
      .release = CFRelease,
    };
    SCNetworkReachabilitySetCallback(reachabilityRef, networkReachabilityCallback, &context);
    
    /* signal emit a disconnection so we tell people we're going away */
    signal_emit("command disconnect", 2, "* Computer has gone to sleep", server_rec);
  }
}

- (void)refresh
{
  for (id x in [[serverMap copy] autorelease])
  {
    void *context = (void*)x;
    SCNetworkReachabilityRef ref = (SCNetworkReachabilityRef)[serverMap objectForKey:x];
    
    /* we cheat, iterate over all refs and get the flags */
    SCNetworkConnectionFlags flags;
    BOOL valid = SCNetworkReachabilityGetFlags(ref, &flags);
    
    if (valid)
    {
      [self networkReachabilityCallback:ref flags:flags info:context];
    }
  }
}
															
- (void)networkReachabilityCallback:(SCNetworkReachabilityRef)target flags:(SCNetworkConnectionFlags)flags info:(void*)info
{
  /* Grab the target ref and rec from the info */
  NSValue *pointerToServerRec = (id)info;
  SERVER_REC *server_rec = (SERVER_REC*)[pointerToServerRec pointerValue];
  SCNetworkReachabilityRef reachabilityRef = (SCNetworkReachabilityRef)[serverMap objectForKey:pointerToServerRec];
  
  /* Now deal with either connection or disconnection */
  if ((flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired))
  {
    if (server_rec->type == module_get_uniq_id("SERVER CONNECT", 0))
    {
      SERVER_CONNECT_REC *reconnect_rec = (SERVER_CONNECT_REC*)server_rec;
      
      /* right, reconnect this bugger */
      server_rec = server_connect(reconnect_rec);
      server_connect_unref(reconnect_rec);
      
      NSValue *newPointerToRec = [NSValue valueWithPointer:server_rec];
      
      /* replace the servermap pointer */
      [serverMap removeObjectForKey:pointerToServerRec];
      [serverMap setObject:(id)reachabilityRef forKey:newPointerToRec];
      
      /* replace the reachability context with the server */
      SCNetworkReachabilityContext c = {
        .version = 0,
        .info = newPointerToRec,
        .retain = CFRetain,
        .release = CFRelease,
      };
      SCNetworkReachabilitySetCallback(target, networkReachabilityCallback, &c);
    }
  }
  else
  {
    if (server_rec->connected && !server_rec->disconnected && (server_rec->type != module_get_uniq_id("SERVER CONNECT", 0)))
    {
      /* copy the current state of connection */
      SERVER_CONNECT_REC *reconnect_rec = server_connect_copy_skeleton(server_rec->connrec, TRUE);
      reconnect_save_status(reconnect_rec, server_rec);
      reconnect_rec->reconnection = TRUE;
      
      NSValue *newPointer = [NSValue valueWithPointer:reconnect_rec];
      
      /* replace the servermap pointer */
      [serverMap removeObjectForKey:(id)pointerToServerRec];
      [serverMap setObject:(id)reachabilityRef forKey:newPointer];
      
      /* replace the reachability context with the reconnection record */
      SCNetworkReachabilityContext c = {
        .version = 0,
        .info = newPointer,
        .retain = CFRetain,
        .release = CFRelease,
      };
      SCNetworkReachabilitySetCallback(reachabilityRef, networkReachabilityCallback, &c);
      
      server_rec->connection_lost = TRUE;
      server_rec->no_reconnect = TRUE;
      server_disconnect(server_rec);
    }
  }
}

- (void)_simulateAllUnreachable
{
  for (NSValue *pointer in [[serverMap copy] autorelease]) {
    SCNetworkReachabilityRef ref = (SCNetworkReachabilityRef)[serverMap objectForKey:pointer];
    [self networkReachabilityCallback:ref flags:(kSCNetworkFlagsTransientConnection|kSCNetworkFlagsReachable|kSCNetworkFlagsConnectionRequired) info:pointer];
  }
}

- (void)_simulateAllReachable
{
  for (NSValue *pointer in [[serverMap copy] autorelease]) {
    SCNetworkReachabilityRef ref = (SCNetworkReachabilityRef)[serverMap objectForKey:pointer];
    [self networkReachabilityCallback:ref flags:(kSCNetworkFlagsReachable) info:pointer];
  }
}

@end
