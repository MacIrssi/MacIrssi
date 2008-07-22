//
//  EventController.m
//  MacIrssi
//
//  Created by Matt Wright on 04/07/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "EventController.h"
#import "GrowlApplicationBridge.h"

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
           [NSNumber numberWithBool:true], @"growlEvent", 
           [NSNumber numberWithBool:true], @"growlEventBackground", nil], @"IRSSI_QUERY_NEW",
          
          [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:true], @"bounceIcon", nil], @"IRSSI_QUERY_OLD",
          
          [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:true], @"playSound", @"Morse", @"playSoundSound", 
           [NSNumber numberWithBool:true], @"bounceIcon",
           [NSNumber numberWithBool:true], @"bounceIconUntilFront",
           [NSNumber numberWithBool:true], @"growlEvent", 
           [NSNumber numberWithBool:true], @"growlEventBackground", nil], @"IRSSI_ROOM_HIGHLIGHT",          
          nil];
}

-(id)init
{
  if (self = [super init])
  {
    notificationCenter = [NSNotificationCenter defaultCenter];
    
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
    
  }
  return self;
}
     
-(void)event:(NSNotification*)notification
{
  NSDictionary *eventSettings = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"eventDefaults"];
  if ([eventSettings valueForKey:[notification name]])
  {
    NSDictionary *event = [eventSettings valueForKey:[notification name]];
    if ([event valueForKey:@"playSound"] && [[event valueForKey:@"playSound"] intValue] == 1)
    {
      // do sound
      if (([event valueForKey:@"playSoundBackground"] && ([[event valueForKey:@"playSoundBackground"] intValue] == 1) && ![NSApp isActive]) ||
          ([event valueForKey:@"playSoundBackground"] && [[event valueForKey:@"playSoundBackground"] intValue] == 0) ||
          (![event valueForKey:@"playSoundBackground"]))
      {
        NSString *soundName = [event valueForKey:@"playSoundSound"];
        NSSound *sound = [NSSound soundNamed:soundName];
        if (!sound) 
        {
          NSString *soundPath = [[NSBundle mainBundle] resourcePath];
          soundPath = [soundPath stringByAppendingPathComponent:@"Sounds"];
          soundPath = [soundPath stringByAppendingPathComponent:soundName];
          soundPath = [soundPath stringByAppendingPathExtension:@"aiff"];
          sound = [[[NSSound alloc] initWithContentsOfFile:soundPath byReference:YES] autorelease];
        }
        [sound play];
      }
    }
    if ([event valueForKey:@"bounceIcon"] && [[event valueForKey:@"bounceIcon"] intValue] == 1)
    {
      // bounce icon
      NSRequestUserAttentionType type = NSInformationalRequest;
      if ([event valueForKey:@"bounceIconUntilFront"] && [[event valueForKey:@"bounceIconUntilFront"] intValue] == 1)
      {
        type = NSCriticalRequest;
      }
      [NSApp requestUserAttention:type];
    }
    if ([event valueForKey:@"growlEvent"] && [[event valueForKey:@"growlEvent"] intValue] == 1)
    {
      // growl event
      if (([event valueForKey:@"growlEventBackground"] && ([[event valueForKey:@"growlEventBackground"] intValue] == 1) && ![NSApp isActive]) ||
          ([event valueForKey:@"growlEventBackground"] && [[event valueForKey:@"growlEventBackground"] intValue] == 0) ||
          (![event valueForKey:@"growlEventBackground"]))
      {
        NSString *title = @"MacIrssi";
        NSString *description = [self eventNameForCode:[notification name]];
        BOOL stick = (([event valueForKey:@"growlEventUntilFront"] && [[event valueForKey:@"growlEventUntilFront"] intValue] == 1) ? YES : NO);
        
        if ([notification userInfo] && [[notification userInfo] valueForKey:@"Description"])
        {
          title = [self eventNameForCode:[notification name]];
          description = [[notification userInfo] valueForKey:@"Description"];
        }
        
        if ([notification userInfo] && [[notification userInfo] valueForKey:@"Title"])
        {
          title = [[notification userInfo] valueForKey:@"Title"];
        }
        
        NSData *icon = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"activityNewImportant" ofType:@"png"]];
        [GrowlApplicationBridge notifyWithTitle:title
                                    description:description
                               notificationName:[self eventNameForCode:[notification name]]
                                       iconData:icon
                                       priority:0
                                       isSticky:stick
                                   clickContext:nil];
      }
    }
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
 