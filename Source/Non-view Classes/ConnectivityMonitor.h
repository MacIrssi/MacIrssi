//
//  ConnectivityMonitor.h
//  MacIrssi
//
//  Created by Matt Wright on 23/07/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SystemConfiguration/SCNetworkReachability.h>

#import "glib.h"
#import "common.h"
#import "irssi.h"
#import "signals.h"
#import "servers.h"
#import "servers-reconnect.h"

@interface ConnectivityMonitor : NSObject {
	BOOL isSleeping;
	GSList *sleepList;
}

+ (ConnectivityMonitor*)sharedMonitor;
- (id)init;

// Notifications from workspace on system state
- (void)workspaceWillSleep:(NSNotification*)notification;
- (void)workspaceDidWake:(NSNotification*)notification;

// SCNetworkReachability
- (void)networkReachabilityCallback:(SCNetworkReachabilityRef)target flags:(SCNetworkConnectionFlags)flags info:(void*)info;

@end
