/*
 ConnectivityMonitor.h
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
