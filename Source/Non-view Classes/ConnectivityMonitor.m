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
    serverMap = [[NSMapTable alloc] initWithKeyPointerFunctions:[NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsOpaqueMemory|NSPointerFunctionsOpaquePersonality]
                                          valuePointerFunctions:[NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPersonality]
                                                       capacity:0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serverChangedNotification:) name:@"irssiServerChangedNotification" object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(workspaceWillSleep:) name:NSWorkspaceWillSleepNotification object:[NSWorkspace sharedWorkspace]];
	}
	return self;
}

static void networkReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkConnectionFlags flags, void *info)
{
  [[ConnectivityMonitor sharedMonitor] networkReachabilityCallback:target flags:flags info:info];
}

- (void)serverChangedNotification:(NSNotification*)notification
{
  NSValue *v = [notification object];
  SERVER_REC *rec = [v pointerValue];
  
  if (!rec->disconnected)
  {
    SCNetworkReachabilityRef ref = (SCNetworkReachabilityRef)[serverMap objectForKey:(id)rec];
    if (!ref)
    {
      SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, rec->connrec->address);
      SCNetworkReachabilityContext context = {
        .version = 0,
        .info = rec
      };
      SCNetworkReachabilitySetCallback(ref, networkReachabilityCallback, &context);
      SCNetworkReachabilityScheduleWithRunLoop(ref, [[NSRunLoop mainRunLoop] getCFRunLoop], kCFRunLoopCommonModes);
      
      [serverMap setObject:(id)ref forKey:(id)rec];
    }
  }
  else
  {
    SCNetworkReachabilityRef ref = (SCNetworkReachabilityRef)[serverMap objectForKey:(id)rec];
    if (ref != nil)
    {
      /* we still have a reachability ref, so we didn't disconnet unnaturally */
      [serverMap removeObjectForKey:(id)rec];
      CFRelease(ref);
    }
  }
}

// Notifications from workspace on system state
- (void)workspaceWillSleep:(NSNotification*)notification
{
	GSList *tmp, *next;
	SERVER_CONNECT_REC *conn;
	for (tmp = servers; tmp != NULL; tmp = next)
	{
		SERVER_REC *rec = (SERVER_REC*)tmp->data;
    SCNetworkReachabilityRef ref = (SCNetworkReachabilityRef)[serverMap objectForKey:(id)rec];
    if (!ref)
    {
      /* something is wrong, but we'll just bail instead of crashing */
      return;
    }
		
    /* copy the server connect rec */
		conn = server_connect_copy_skeleton(rec->connrec, TRUE);
		if (rec->connected)
		{
			reconnect_save_status(conn, rec);
		}
		conn->reconnection = TRUE;
    
    /* set up the server map properly */
    [serverMap removeObjectForKey:(id)rec];
    [serverMap setObject:(id)ref forKey:(id)conn];
    
    /* update the availability context */
    SCNetworkReachabilityContext c = {
      .version = 0,
      .info = conn,
    };
    SCNetworkReachabilitySetCallback(ref, networkReachabilityCallback, &c);
		
		next = tmp->next;
		signal_emit("command disconnect", 2, "* Computer has gone to sleep", rec);
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
  SERVER_REC *rec = (SERVER_REC*)info;
  SCNetworkReachabilityRef ref = (SCNetworkReachabilityRef)[serverMap objectForKey:(id)rec];
  
  /* Now deal with either connection or disconnection */
  if ((flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired))
  {
    if (rec->type == module_get_uniq_id("SERVER CONNECT", 0))
    {
      SERVER_CONNECT_REC *reconnect_rec = (SERVER_CONNECT_REC*)rec;
      
      /* right, reconnect this bugger */
      rec = server_connect(reconnect_rec);
      server_connect_unref(reconnect_rec);
      
      /* replace the servermap pointer */
      [serverMap removeObjectForKey:(id)reconnect_rec];
      [serverMap setObject:(id)ref forKey:(id)rec];
      
      /* replace the reachability context with the server */
      SCNetworkReachabilityContext c = {
        .version = 0,
        .info = rec,
      };
      SCNetworkReachabilitySetCallback(target, networkReachabilityCallback, &c);
    }    
  }
  else
  {
    if (rec->connected && !rec->disconnected && (rec->type != module_get_uniq_id("SERVER CONNECT", 0)))
    {
      /* copy the current state of connection */
      SERVER_CONNECT_REC *reconnect_rec = server_connect_copy_skeleton(rec->connrec, TRUE);
      reconnect_save_status(reconnect_rec, rec);
      reconnect_rec->reconnection = TRUE;
      
      /* replace the servermap pointer */
      [serverMap removeObjectForKey:(id)rec];
      [serverMap setObject:(id)ref forKey:(id)reconnect_rec];
      
      /* replace the reachability context with the reconnection record */
      SCNetworkReachabilityContext c = {
        .version = 0,
        .info = reconnect_rec,
      };
      SCNetworkReachabilitySetCallback(ref, networkReachabilityCallback, &c);
      
      rec->connection_lost = TRUE;
      server_disconnect(rec);
    }
  }
}

@end
