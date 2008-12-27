//
//  ConnectivityMonitor.m
//  MacIrssi
//
//  Created by Matt Wright on 23/07/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

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
		isSleeping = NO;
	}
	return self;
}

static void networkReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkConnectionFlags flags, void *info)
{
  	[[ConnectivityMonitor sharedMonitor] networkReachabilityCallback:target flags:flags info:info];
}

// Notifications from workspace on system state
- (void)workspaceWillSleep:(NSNotification*)notification
{
	NSLog(@"ConnectivityMonitor: workspaceWillSleep:");
	
	isSleeping = YES;
	sleepList = NULL;
	
	GSList *tmp, *next;
	SERVER_CONNECT_REC *conn;
	for (tmp = servers; tmp != NULL; tmp = next)
	{
		SERVER_REC *rec = (SERVER_REC*)tmp->data;
		
		conn = server_connect_copy_skeleton(rec->connrec, TRUE);
		if (rec->connected)
		{
			reconnect_save_status(conn, rec);
		}
		conn->reconnection = TRUE;
		
		NSLog(@"ConnectivityMonitor: found connection to %s:%d, rooms: %s, prepping for sleep.",
			  conn->address, conn->port, conn->channels);
		
		// Annoyingly, this has to be set before disconnect, or you'll lose the link to the next server
		next = tmp->next;
		
		signal_emit("command disconnect", 2, "* Computer has gone to sleep", rec);
		
		sleepList = g_slist_append(sleepList, conn);
	}
}

- (void)workspaceDidWake:(NSNotification*)notification
{
	NSLog(@"ConnectivityMonitor: workspaceDidSleep:");
	
	GSList *tmp, *next;
	
	isSleeping = NO;
	
	for (tmp = sleepList; tmp != NULL; tmp = next)
	{
		SERVER_CONNECT_REC *rec = (SERVER_CONNECT_REC*)tmp->data;
		
		NSLog(@"ConnectivityMonitor: Creating ReachabilityRef with address %s.", rec->address);
		
		SCNetworkReachabilityRef target = SCNetworkReachabilityCreateWithName(NULL, rec->address);
		SCNetworkReachabilityContext reachabilityContext = {
			.version = 0,
			.info = rec,
		};
		SCNetworkReachabilitySetCallback(target, networkReachabilityCallback, &reachabilityContext);
		SCNetworkReachabilityScheduleWithRunLoop(target, [[NSRunLoop currentRunLoop] getCFRunLoop], kCFRunLoopDefaultMode);

		next = tmp->next;
	}
}
															
- (void)networkReachabilityCallback:(SCNetworkReachabilityRef)target flags:(SCNetworkConnectionFlags)flags info:(void*)info
{
	NSLog(@"networkReachabilityCallback: got flags: %c%c%c%c%c%c%c",  
 	      (flags & kSCNetworkFlagsTransientConnection)  ? 't' : '-',  
 	      (flags & kSCNetworkFlagsReachable)            ? 'r' : '-',  
 	      (flags & kSCNetworkFlagsConnectionRequired)   ? 'c' : '-',  
 	      (flags & kSCNetworkFlagsConnectionAutomatic)  ? 'C' : '-',  
 	      (flags & kSCNetworkFlagsInterventionRequired) ? 'i' : '-',  
 	      (flags & kSCNetworkFlagsIsLocalAddress)       ? 'l' : '-',  
 	      (flags & kSCNetworkFlagsIsDirect)             ? 'd' : '-');
	
	if ((flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired))
	{
		// Remove from callback now that we're connected again
		SCNetworkReachabilityUnscheduleFromRunLoop(target, [[NSRunLoop currentRunLoop] getCFRunLoop], kCFRunLoopDefaultMode);
		
		SERVER_CONNECT_REC *conn = (SERVER_CONNECT_REC*)info;
		NSLog(@"ConnectivityMonitor: %s reachable, reconnecting.", conn->address);
		
		server_connect(conn);
		server_connect_unref(conn);
	}
	
}

@end
