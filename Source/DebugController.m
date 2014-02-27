/*
 DebugController.m
 Copyright (c) 2010 Matt Wright.
 
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

#import "DebugController.h"
#import "AppController.h"
#import "ChannelController.h"
#import "AIMenuAdditions.h"
#import "IrssiBridge.h"
#import "ConnectivityMonitor.h"
#import "IrssiRunloop.h"

#import "module-formats.h"

#ifdef MACIRSSI_DEBUG
static DebugController *debugController = nil;
extern AppController *appController;

static char* loremIpsum[] = {
  "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
  "Nulla vitae justo tristique est sagittis volutpat id et turpis.",
  "Curabitur at erat neque, ut lobortis nunc.",
  "Pellentesque dignissim hendrerit quam, ut dapibus risus pulvinar nec.",
  "Phasellus a arcu ac mi varius pretium ut a tortor.",
  "Curabitur et lorem dui, non iaculis justo.",
  "Fusce fermentum est non ante adipiscing nec accumsan urna lacinia.",
  "Suspendisse adipiscing neque non neque congue eleifend."
};

static char *urlTestLines[] = {
  "http://foo.com/blah_blah",
  "http://foo.com/blah_blah/ ",
  "(Something like http://foo.com/blah_blah)",
  "http://foo.com/blah_blah_(wikipedia)",
  "http://foo.com/more_(than)_one_(parens)",
  "(Something like http://foo.com/blah_blah_(wikipedia))",
  "http://foo.com/blah_(wikipedia)#cite-1",
  "http://foo.com/blah_(wikipedia)_blah#cite-1",
  "http://foo.com/unicode_(✪)_in_parens",
  "http://foo.com/(something)?after=parens",
  "http://foo.com/blah_blah.",
  "http://foo.com/blah_blah/.",
  "<http://foo.com/blah_blah>",
  "<http://foo.com/blah_blah/>",
  "http://foo.com/blah_blah,",
  "http://www.extinguishedscholar.com/wpglob/?p=364.",
  "http://✪df.ws/1234",
  "rdar://1234",
  "rdar:/1234",
  "x-yojimbo-item://6303E4C1-6A6E-45A6-AB9D-3A908F59AE0E",
  "message://%3c330e7f840905021726r6a4ba78dkf1fd71420c1bf6ff@mail.gmail.com%3e",
  "http://➡.ws/䨹",
  "www.c.ws/䨹",
  "<tag>http://example.com</tag>",
  "Just a www.example.com link.",
  "http://example.com/something?with,commas,in,url, but not at end",
  "What about <mailto:gruber@daringfireball.net?subject=TEST> (including brokets).",
  "mailto:name@example.com",
  "bit.ly/foo",
  "“is.gd/foo/”",
  "WWW.EXAMPLE.COM",
  "http://www.asianewsphoto.com/(S(neugxif4twuizg551ywh3f55))/Web_ENG/View_DetailPhoto.aspx?PicId=752",
  "http://www.asianewsphoto.com/(S(neugxif4twuizg551ywh3f55))",
  "http://lcweb2.loc.gov/cgi-bin/query/h?pp/horyd:@field(NUMBER+@band(thc+5a46634))",
  "http://68.168.137.146:16504/listen.pls",
  "http://www.mmo-champion.com/news-2/earth-wind-and-fire-(10-player)-by-vanquish/",
  "http://developer.apple.com/mac/library/documentation/General/Conceptual/ConcurrencyProgrammingGuide/OperationQueues/OperationQueues.html#//apple_ref/doc/uid/TP40008091-CH102-SW1"
};

static int loremIpsumCount = 8;

#endif

@implementation DebugController

+ (void)initialiseDebugController
{
#ifdef MACIRSSI_DEBUG
  if (!debugController) {
    debugController = [[DebugController alloc] init];
  }
#endif
}

#ifdef MACIRSSI_DEBUG

- (id)init
{
  if (self = [super init])
  {
    debugMenu = [[NSMenu alloc] initWithTitle:@"Debug"];
    
    NSMenu *channelTestMenu = [[[NSMenu alloc] initWithTitle:@"Text"] autorelease];
    [channelTestMenu setDelegate:self];
    
    NSMenuItem *channelTextTestItem = [[NSMenuItem alloc] initWithTitle:@"Channel Text Test" action:nil keyEquivalent:@""];
    [channelTextTestItem setSubmenu:channelTestMenu];
    [channelTextTestItem setTag:0];
    [debugMenu addItem:channelTextTestItem];
    
    NSMenu *urlTestMenu = [[[NSMenu alloc] initWithTitle:@"URL"] autorelease];
    [urlTestMenu setDelegate:self];
    
    NSMenuItem *urlTestItem = [[NSMenuItem alloc] initWithTitle:@"URL Test" action:nil keyEquivalent:@""];
    [urlTestItem setSubmenu:urlTestMenu];
    [urlTestItem setTag:1];
    [debugMenu addItem:urlTestItem];
    
    NSMenu *sleepMenu = [[[NSMenu alloc] initWithTitle:@"Sleep"] autorelease];
    [sleepMenu setDelegate:self];
    
    NSMenuItem *sleepMenuItem = [[NSMenuItem alloc] initWithTitle:@"Sleep Events" action:nil keyEquivalent:@""];
    [sleepMenuItem setSubmenu:sleepMenu];
    [debugMenu addItem:sleepMenuItem];
    
    NSMenuItem *simulateSleepEvent = [[NSMenuItem alloc] initWithTitle:@"Simulate Sleep Event" target:self action:@selector(simulateSleepEvent:) keyEquivalent:@""];
    [sleepMenu addItem:simulateSleepEvent];
    
    NSMenuItem *simulateWakeEvent = [[NSMenuItem alloc] initWithTitle:@"Simulate Wake Event" target:self action:@selector(simulateWakeEvent:) keyEquivalent:@""];
    [sleepMenu addItem:simulateWakeEvent];
    
    NSMenu *disconnectionMenu = [[[NSMenu alloc] initWithTitle:@"Disconnection"] autorelease];
    
    NSMenuItem *disconnectionMenuItem = [[[NSMenuItem alloc] initWithTitle:@"Network Events" action:nil keyEquivalent:@""] autorelease];
    [disconnectionMenuItem setSubmenu:disconnectionMenu];
    [debugMenu addItem:disconnectionMenuItem];
    
    NSMenuItem *simulateConnection = [[[NSMenuItem alloc] initWithTitle:@"Simulate Connection" target:self action:@selector(simiulateConnection:) keyEquivalent:@""] autorelease];
    [disconnectionMenu addItem:simulateConnection];
    
    NSMenuItem *simulateDisconnection = [[[NSMenuItem alloc] initWithTitle:@"Simulate Disconnection" target:self action:@selector(simiulateDisconnection:) keyEquivalent:@""] autorelease];
    [disconnectionMenu addItem:simulateDisconnection];    

    NSMenuItem *activityNotificationItem = [[[NSMenuItem alloc] initWithTitle:@"Activity Notification Icon" action:nil keyEquivalent:@""] autorelease];
    [debugMenu addItem:activityNotificationItem];
    NSMenu *activityNotificationMenu = [[[NSMenu alloc] init] autorelease];
    NSMenuItem *activityNotificationTriggerItem = [[[NSMenuItem alloc] initWithTitle:@"Set Notification Icon" target:appController action:@selector(setNotificationIcon) keyEquivalent:@""] autorelease];
    NSMenuItem *activityNotificationClearItem = [[[NSMenuItem alloc] initWithTitle:@"Set Default Icon" target:appController action:@selector(setDefaultIcon) keyEquivalent:@""] autorelease];
    [activityNotificationMenu addItem:activityNotificationTriggerItem];
    [activityNotificationMenu addItem:activityNotificationClearItem];
    [activityNotificationItem setSubmenu:activityNotificationMenu];

    NSMenuItem *forceScrollToBottom = [[NSMenuItem alloc] initWithTitle:@"Force Scroll to Bottom" target:self action:@selector(forceScrollToBottom:) keyEquivalent:@""];
    [debugMenu addItem:forceScrollToBottom];
    
    NSMenuItem *changeOrientation = [[NSMenuItem alloc] initWithTitle:@"Toggle Orientation" target:self action:@selector(toggleOrientation:) keyEquivalent:@"O"];
    [debugMenu addItem:changeOrientation];
    
    NSMenuItem *deallocateIrssiRunloop = [[NSMenuItem alloc] initWithTitle:@"Deallocate Irssi Runloop" target:self action:@selector(deallocateIrssiRunloop:) keyEquivalent:@""];
    [debugMenu addItem:deallocateIrssiRunloop];

    // Put this thing in the menu now.
    NSMenuItem *mainMenuItem = [[NSMenuItem alloc] initWithTitle:@"Debug" action:nil keyEquivalent:@""];
    [mainMenuItem setSubmenu:debugMenu];
    
    [[NSApp mainMenu] insertItem:mainMenuItem atIndex:[[NSApp mainMenu] indexOfItemWithTitle:@"Window"]];
  }
  return self;
}

- (void)menuNeedsUpdate:(NSMenu *)menu
{
  if ([[menu title] isEqual:@"URL"] || [[menu title] isEqual:@"Text"])
  {
    [menu removeAllItems];
    
    NSArray *channels = [IrssiBridge channels];
    for (ChannelController *cc in channels)
    {
      NSString *title = [cc name];
      NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title target:self action:@selector(channelTextTest:) keyEquivalent:@"" representedObject:cc];
      
      if ([[menu title] isEqual:@"URL"])
      {
        [item setAction:@selector(urlTextTest:)];
      }
      
      [menu addItem:item];
    }  
  }
}

- (void)channelTextTest:(id)sender
{
  // Run a channel text test on the current channel controller.
  ChannelController *cc = [sender representedObject];
  
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                               cc, @"ChannelController",
                               [NSNumber numberWithInt:100], @"Count",
                               nil];
  
  // Lets set up a timer to run the chat spew.
  [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(channelTextTestTimer:) userInfo:dict repeats:YES];
  
  // Print to console so we can see when it starts/stops.
  NSLog(@"Started channel text test on window \"%@\"", [cc name]);
}

- (void)urlTextTest:(id)sender
{
  ChannelController *cc = [sender representedObject];
  int i, length;

  length = sizeof(urlTestLines) / sizeof(urlTestLines[0]);
  for (i=0; i < length; i++)
  {
    printformat_module_window("fe-common/core", [cc windowRec], 1, TXT_PUBMSG, "MacIrssi", urlTestLines[i], " ");
  }
}

- (void)channelTextTestTimer:(NSTimer*)timer
{
  NSDictionary *userInfo = [timer userInfo];
  
  ChannelController *controller = [userInfo objectForKey:@"ChannelController"];
  int remaining = [[userInfo objectForKey:@"Count"] intValue];
  
  printformat_module_window("fe-common/core", [controller windowRec], 1, TXT_PUBMSG, "MacIrssi", loremIpsum[remaining % loremIpsumCount], " ");

  remaining--;
  if (remaining == 0) {
    [timer invalidate];
    NSLog(@"Finished channel text test on window \"%@\"", [controller name]);
  } else {
    [userInfo setValue:[NSNumber numberWithInt:remaining] forKey:@"Count"];
  }
}

- (void)forceScrollToBottom:(id)sender
{
  ChannelController *cc = [appController currentChannelController];
  
  NSLog(@"Forcing %@ to scroll to bottom.", [cc name]);
  [cc forceScrollToBottom];
}

- (void)toggleOrientation:(id)sender
{
  int orientation = [[NSUserDefaults standardUserDefaults] integerForKey:@"channelBarOrientation"];
  orientation = (orientation == MIChannelBarHorizontalOrientation ? MIChannelBarVerticalOrientation : MIChannelBarHorizontalOrientation);

  [[NSUserDefaults standardUserDefaults] setInteger:orientation forKey:@"channelBarOrientation"];
  [appController channelBarOrientationDidChange:nil];  
}

- (void)simulateSleepEvent:(id)sender
{
  [[ConnectivityMonitor sharedMonitor] workspaceWillSleep:nil];
}

- (void)simulateWakeEvent:(id)sender
{
  [[ConnectivityMonitor sharedMonitor] refresh];
}

- (void)simiulateConnection:(id)sender
{
  [[ConnectivityMonitor sharedMonitor] _simulateAllReachable];
}

- (void)simiulateDisconnection:(id)sender
{
  [[ConnectivityMonitor sharedMonitor] _simulateAllUnreachable];
}

- (void)deallocateIrssiRunloop:(id)sender
{
  [[IrssiRunloop mainRunloop] stop];
  [[IrssiRunloop mainRunloop] release];
}

//- (void)dealloc
//{
//  
//}

#endif

@end
