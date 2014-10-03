/*
 EventController.m
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

#import "EventController.h"
#import "ChannelController.h"
#import "Defaults.h"
#import "Util.h"

#import <Growl/GrowlApplicationBridge.h>

@interface EventController ()

- (void)_resetDockNotificationCount;

@end


@implementation EventController

+(NSDictionary*)defaults
{
  return [NSDictionary dictionaryWithObjectsAndKeys:
          [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:true], @"playSound", @"Pop", @"playSoundSound", nil], @"IRSSI_ROOM_JOIN",
          [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:true], @"playSound", @"Whip", @"playSoundSound", nil], @"IRSSI_ROOM_PART",
          [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:true], @"playSound", @"Explosion", @"playSoundSound", nil], @"IRSSI_ROOM_KICK",
          
          [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:true], @"playSound", @"DJ Scratch", @"playSoundSound", nil], @"IRSSI_ROOM_OP",
          [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:true], @"playSound", @"Switch", @"playSoundSound", nil], @"IRSSI_ROOM_VOICE",
          [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:true], @"playSound", @"Rattle", @"playSoundSound", nil], @"IRSSI_ROOM_DEVOICE",
          
          [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:true], @"playSound", @"Stoof", @"playSoundSound", 
           [NSNumber numberWithBool:true], @"bounceIcon",
           [NSNumber numberWithBool:true], @"bounceShowCountOnDock",
           [NSNumber numberWithBool:true], @"growlEvent", 
           [NSNumber numberWithBool:true], @"growlEventBackground", nil], @"IRSSI_QUERY_NEW",
          
          [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:true], @"bounceIcon", nil], @"IRSSI_QUERY_OLD",
          
          [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"growlEvent",
           [NSNumber numberWithBool:YES], @"growlEventBackground", nil], @"IRSSI_ROOM_ACTIVITY",
          
          [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:true], @"playSound", @"Morse", @"playSoundSound", 
           [NSNumber numberWithBool:true], @"bounceIcon",
           [NSNumber numberWithBool:true], @"bounceIconUntilFront",
           [NSNumber numberWithBool:true], @"bounceShowCountOnDock",
           [NSNumber numberWithBool:true], @"growlEvent", 
           [NSNumber numberWithBool:true], @"growlEventBackground", nil], @"IRSSI_ROOM_HIGHLIGHT",          
          nil];
}

-(id)init
{
  if (self = [super init])
  {
    notificationCenter = [NSNotificationCenter defaultCenter];
    eventControllerLock = [[NSLock alloc] init];
    
    availableEvents = [[NSArray arrayWithObjects:
                        @"IRSSI_SERVER_CONNECTED", 
                        @"IRSSI_SERVER_DISCONNECTED", 
                        @"IRSSI_SEPARATOR", 
                        @"IRSSI_ROOM_JOIN", 
                        @"IRSSI_ROOM_PART",
                        @"IRSSI_ROOM_KICK",
                        @"IRSSI_SEPARATOR",
                        @"IRSSI_ROOM_OP",
                        @"IRSSI_ROOM_DEOP",
                        @"IRSSI_ROOM_HALFOP",
                        @"IRSSI_ROOM_DEHALFOP",
                        @"IRSSI_ROOM_VOICE",
                        @"IRSSI_ROOM_DEVOICE",
                        @"IRSSI_SEPARATOR",
                        @"IRSSI_QUERY_NEW",
                        @"IRSSI_QUERY_OLD",
                        @"IRSSI_NOTICE",
                        @"IRSSI_ROOM_ACTIVITY",
                        @"IRSSI_ROOM_HIGHLIGHT",
                        nil] retain];
    availableEventNames = [[NSDictionary dictionaryWithObjectsAndKeys:
                            @"", @"IRSSI_SEPARATOR",
                            @"Server Connected", @"IRSSI_SERVER_CONNECTED",
                            @"Server Disconnected", @"IRSSI_SERVER_DISCONNECTED",
                            @"Member Joined Chat Room", @"IRSSI_ROOM_JOIN",
                            @"Member Left Chat Room", @"IRSSI_ROOM_PART",
                            @"Member Kicked From Chat Room", @"IRSSI_ROOM_KICK",
                            @"Member Promoted to Operator", @"IRSSI_ROOM_OP",
                            @"Member Demoted from Operator", @"IRSSI_ROOM_DEOP",
                            @"Member Promoted to Half-Operator", @"IRSSI_ROOM_HALFOP",
                            @"Member Demoted from Half-Operator", @"IRSSI_ROOM_DEHALFOP",
                            @"Member given Voice", @"IRSSI_ROOM_VOICE",
                            @"Member de-Voiced", @"IRSSI_ROOM_DEVOICE",
                            @"New Private Message", @"IRSSI_QUERY_NEW",
                            @"Additional Private Message", @"IRSSI_QUERY_OLD",
                            @"Notice Message", @"IRSSI_NOTICE",
                            @"Activity in Room", @"IRSSI_ROOM_ACTIVITY",
                            @"Highlighted in Room", @"IRSSI_ROOM_HIGHLIGHT",
                            nil] retain];
    
    NSEnumerator *eventEnumerator = [availableEvents objectEnumerator];
    NSString *event;
    while (event = [eventEnumerator nextObject])
    {
      if ([event isEqualToString:@"IRSSI_SEPARATOR"]) continue;
      [notificationCenter addObserver:self selector:@selector(event:) name:event object:nil];
    }
    
    // Copy defaults, remove keys that exist in user defaults, merge in new defaults and save
    NSMutableDictionary *defaults = [NSMutableDictionary dictionaryWithDictionary:[EventController defaults]];
    NSMutableDictionary *eventDefaults = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"eventDefaults"]];
    [defaults removeObjectsForKeys:[eventDefaults allKeys]];
    [eventDefaults addEntriesFromDictionary:defaults];
    [[NSUserDefaults standardUserDefaults] setObject:eventDefaults forKey:@"eventDefaults"];
    
    // Set the notifications count to zero and register for the app active notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_resetDockNotificationCount) name:NSApplicationDidBecomeActiveNotification object:NSApp];
    unreadNotificationsCount = 0;
  }
  return self;
}

- (void)_resetDockNotificationCount
{
  unreadNotificationsCount = 0;
  [[NSApp dockTile] setBadgeLabel:@""];
}
     
-(void)event:(NSNotification*)notification
{
  NSDictionary *eventSettings = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"eventDefaults"];
  if ([eventSettings valueForKey:[notification name]])
  {
    NSDictionary *event = [eventSettings valueForKey:[notification name]];
    
    // Here we should lock, I think I've had event based crashes because of multi-threadedness
    [eventControllerLock lock];
    
    // If we've been asked to play a sound...start working out what to do
    if ([event valueForKey:@"playSound"] && [[event valueForKey:@"playSound"] intValue] == 1)
    {
      // Sound is only played if:
      //   a) only in background is set AND NSApp isn't active
      //   b) if only in background is not set
      if (([event valueForKey:@"playSoundBackground"] && ([[event valueForKey:@"playSoundBackground"] intValue] == 1) && ![NSApp isActive]) ||
          ([event valueForKey:@"playSoundBackground"] && [[event valueForKey:@"playSoundBackground"] intValue] == 0) ||
          (![event valueForKey:@"playSoundBackground"]))
      {
        NSString *soundName = [event valueForKey:@"playSoundSound"];
        // pew pew
        playSoundNamed(soundName);
      }
    }
    
    // Similarly, we work out if we're meant to bounce the dock
    if ([event valueForKey:@"bounceIcon"] && [[event valueForKey:@"bounceIcon"] intValue] == 1)
    {
      // We bounce the dock if
      //   a) background AND ![NSApp isActive]
      //   b) !background
      // However, if bounce until front is set. We need to make it a critical request. Informational
      // only bounces the icon once.
      NSRequestUserAttentionType type = NSInformationalRequest;
      if ([event valueForKey:@"bounceIconUntilFront"] && [[event valueForKey:@"bounceIconUntilFront"] intValue] == 1)
      {
        type = NSCriticalRequest;
      }
      if ([event valueForKey:@"bounceShowCountOnDock"] && [[event valueForKey:@"bounceShowCountOnDock"] intValue] == 1 && ![NSApp isActive])
      {
        NSDockTile *tile = [NSApp dockTile];
        [tile setBadgeLabel:[NSString stringWithFormat:@"%d", ++unreadNotificationsCount]];
      }
      [NSApp requestUserAttention:type];
    }
    
    // Growling is a little more interesting though :)
    if ([event valueForKey:@"growlEvent"] && [[event valueForKey:@"growlEvent"] intValue] == 1)
    {
      // Work out if we're gonna growl at all, like the other events we only growl if:
      //   a) background is set AND ![NSApp isActive]
      //   b) !background
      if (([event valueForKey:@"growlEventBackground"] && ([[event valueForKey:@"growlEventBackground"] intValue] == 1) && ![NSApp isActive]) ||
          ([event valueForKey:@"growlEventBackground"] && [[event valueForKey:@"growlEventBackground"] intValue] == 0) ||
          (![event valueForKey:@"growlEventBackground"]))
      {
        // By default, the growl contains MacIrssi as the title and the event long name as the description.
        NSString *title = @"MacIrssi";
        NSString *description = [self eventNameForCode:[notification name]];
        
        // Set stick if we've been asked to stick until front.
        BOOL stick = (([event valueForKey:@"growlEventUntilFront"] && [[event valueForKey:@"growlEventUntilFront"] intValue] == 1) ? YES : NO);
        
        // clickContext's allow growl to callback to us if the growl box is clicked. Contexts have to be provided in propertyList types
        // So we can do one of a couple of things here:
        //   a) We're given a ChannelController, extract the refnum (window number, basically) and set context to be an NSNumber
        //   b) No ChannelController object but Server and Channel keys exist in the userinfo. So supply them in an NSDictionary.
        // The callback handler will cope with these later.
        NSNumber *context = nil;
        if ([notification object] && [[notification object] isKindOfClass:[ChannelController class]])
        {
          ChannelController *controller = [notification object];
          context = [NSNumber numberWithInt:[controller windowRec]->refnum];
        }
        else if ([notification userInfo] &&
                 [[notification userInfo] valueForKey:@"Server"] &&
                 [[notification userInfo] valueForKey:@"Channel"])
        {
          context = [NSDictionary dictionaryWithObjectsAndKeys:[[notification userInfo] valueForKey:@"Server"], @"Server",
                     [[notification userInfo] valueForKey:@"Channel"], @"Channel", nil];
        }
        
        // If there is a Description key in the dictionary, move the event name into the title and use the description
        if ([notification userInfo] && [[notification userInfo] valueForKey:@"Description"])
        {
          title = [self eventNameForCode:[notification name]];
          description = [[notification userInfo] valueForKey:@"Description"];
        }
        
        // We let you override the title too, isn't that nice. Its all supposed to be done so that you can supply as little or as much
        // cutsomisation per event tha you need.
        if ([notification userInfo] && [[notification userInfo] valueForKey:@"Title"])
        {
          title = [[notification userInfo] valueForKey:@"Title"];
        }

        // I haven't implemented icon overrides. Wouldn't be hard to do though.
				NSData *icon = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"activityNewImportant" ofType:@"png"]];
				
        // This is a bit messy though, if you want an event to "coalesce" (that is, only even display one growl event, updating the first if dupliates are raised)
        // then you need to add an identifier argument to the end of the notify call. Used in room activity.
				if (![notification userInfo] ||
					([notification userInfo] && [[notification userInfo] valueForKey:@"Coalesce"] && ![[[notification userInfo] valueForKey:@"Coalesce"] boolValue]) ||
					([notification userInfo] && ![[notification userInfo] valueForKey:@"Coalesce"]))
				{
					[GrowlApplicationBridge notifyWithTitle:title
																			description:description
																 notificationName:[self eventNameForCode:[notification name]]
																				 iconData:icon
																				 priority:0
																				 isSticky:stick
																		 clickContext:context];
				}
				else
				{
					[GrowlApplicationBridge notifyWithTitle:title
																			description:description
																 notificationName:[self eventNameForCode:[notification name]]
																				 iconData:icon
																				 priority:0
																				 isSticky:stick
																		 clickContext:context
																			 identifier:[notification name]];
				}
				
			}
		}
    
    // Time to unlock
    [eventControllerLock unlock];
  }
}

-(NSArray*)availableEvents
{
  return [NSArray arrayWithArray:availableEvents];
}

- (NSArray*)availableEventNames
{
  NSMutableArray *array = [NSMutableArray array];
  NSEnumerator *eventEnumerator = [availableEvents objectEnumerator];
  NSString *event;
  
  while (event = [eventEnumerator nextObject])
  {
    if ([event isEqualToString:@"IRSSI_SEPARATOR"]) continue;
    [array addObject:[self eventNameForCode:event]];
  }
  return array;
}

-(NSString*)eventNameForCode:(NSString*)code
{
  return [availableEventNames valueForKey:code];
}

- (NSString*)eventCodeForName:(NSString*)name
{
  NSArray *codes = [availableEventNames allKeysForObject:name];
  if ([codes count] == 0)
  {
    return nil;
  }
  return [codes objectAtIndex:0];
}

-(BOOL)boolForEvent:(NSString*)event alert:(NSString*)alert
{
  if (changedEventSettings && [changedEventSettings valueForKey:event] && [[changedEventSettings valueForKey:event] valueForKey:alert])
  {
    return [[[changedEventSettings valueForKey:event] valueForKey:alert] boolValue];
  }
  
  NSDictionary *eventSettings = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"eventDefaults"];
  if ([eventSettings valueForKey:event] && [[eventSettings valueForKey:event] valueForKey:alert])
  {
    return [[[eventSettings valueForKey:event] valueForKey:alert] boolValue];
  }
  return FALSE;
}

-(NSString*)stringForEvent:(NSString*)event alert:(NSString*)alert
{
  if (changedEventSettings && [changedEventSettings valueForKey:event] && [[changedEventSettings valueForKey:event] valueForKey:alert])
  {
    return [[changedEventSettings valueForKey:event] valueForKey:alert];
  }
  
  NSDictionary *eventSettings = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"eventDefaults"];
  if ([eventSettings valueForKey:event] && [[eventSettings valueForKey:event] valueForKey:alert])
  {
    return [[eventSettings valueForKey:event] valueForKey:alert];
  }
  return nil;  
}

- (void)setBoolForEvent:(NSString*)event alert:(NSString*)alert value:(BOOL)value
{
  if (!changedEventSettings)
  {
    changedEventSettings = [[NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"eventDefaults"]] retain];
  }
  if (![changedEventSettings valueForKey:event])
  {
    [changedEventSettings setValue:[NSMutableDictionary dictionary] forKey:event];
  }
  else if ([[changedEventSettings valueForKey:event] class] != [NSMutableDictionary class])
  {
    [changedEventSettings setValue:[NSMutableDictionary dictionaryWithDictionary:[changedEventSettings valueForKey:event]] forKey:event];
  }
  
  [[changedEventSettings valueForKey:event] setValue:[NSNumber numberWithBool:value] forKey:alert];
}

- (void)setStringForEvent:(NSString*)event alert:(NSString*)alert value:(NSString*)value
{
  if (!changedEventSettings)
  {
    changedEventSettings = [[NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"eventDefaults"]] retain];
  }
  if (![changedEventSettings valueForKey:event])
  {
    [changedEventSettings setValue:[NSMutableDictionary dictionary] forKey:event];
  }
  else if ([[changedEventSettings valueForKey:event] class] != [NSMutableDictionary class])
  {
    [changedEventSettings setValue:[NSMutableDictionary dictionaryWithDictionary:[changedEventSettings valueForKey:event]] forKey:event];
  }
  
  [[changedEventSettings valueForKey:event] setValue:value forKey:alert];
}

- (void)commitChanges
{
  if (changedEventSettings)
  {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:changedEventSettings forKey:@"eventDefaults"];
    [defaults synchronize];
    [changedEventSettings release];
    changedEventSettings = nil;
  }
}

- (void)cancelChanges
{
  [changedEventSettings release];
  changedEventSettings = nil;
}


@end
 