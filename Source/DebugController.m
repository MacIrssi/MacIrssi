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
    
    NSMenu *channelTestMenu = [[[NSMenu alloc] initWithTitle:@""] autorelease];
    [channelTestMenu setDelegate:self];
    
    NSMenuItem *channelTextTestItem = [[NSMenuItem alloc] initWithTitle:@"Channel Text Test" action:nil keyEquivalent:@""];
    [channelTextTestItem setSubmenu:channelTestMenu];
    [debugMenu addItem:channelTextTestItem];
    
    // Put this thing in the menu now.
    NSMenuItem *mainMenuItem = [[NSMenuItem alloc] initWithTitle:@"Debug" action:nil keyEquivalent:@""];
    [mainMenuItem setSubmenu:debugMenu];
    
    [[NSApp mainMenu] insertItem:mainMenuItem atIndex:[[NSApp mainMenu] indexOfItemWithTitle:@"Window"]];
  }
  return self;
}

- (void)menuNeedsUpdate:(NSMenu *)menu
{
  [menu removeAllItems];
  
  NSArray *channels = [IrssiBridge channels];
  for (ChannelController *cc in channels)
  {
    NSString *title = [cc name];
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title target:self action:@selector(channelTextTest:) keyEquivalent:@"" representedObject:cc];
    
    [menu addItem:item];
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

//- (void)dealloc
//{
//  
//}

#endif

@end
