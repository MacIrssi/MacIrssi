//
//  PreferenceObjectController.m
//  MacIrssi
//
//  Created by Matt Wright on 10/10/2008.
//  Copyright 2008 Matt Wright Consulting. All rights reserved.
//

#import "PreferenceObjectController.h"
#import "IrcnetBridgeController.h"
#import "ServerBridgeController.h"
#import "IrssiBridge.h"

// Irssi Imports
#import "common.h"
#import "settings.h"
#import "chatnets.h"
#import "irc.h"

@implementation PreferenceObjectController

- (id)init
{
  if (self = [super init])
  {
    chatnetArray = [[NSMutableArray alloc] init];
    serverArray = [[NSMutableArray alloc] init];
    
    // Load in the chatnets into IrcnetBridgeControllers and add them to the array
    GSList *tmp, *next;
    for (tmp = chatnets; tmp != NULL; tmp = next)
    {
      IRC_CHATNET_REC *chatnet = (IRC_CHATNET_REC*)tmp->data;
      
      IrcnetBridgeController *controller = [[[IrcnetBridgeController alloc] initWithChatnetRec:chatnet] autorelease];
      [chatnetArray addObject:controller];
      next = tmp->next;
    }
    
    for (tmp = setupservers; tmp != NULL; tmp = next)
    {
      SERVER_SETUP_REC *rec = (SERVER_SETUP_REC*)tmp->data;
      
      ServerBridgeController *controller = [[[ServerBridgeController alloc] initWithServerSetupRec:rec] autorelease];
      [serverArray addObject:controller];
      next = tmp->next;
    }
  }
  return self;
}

- (NSMutableArray*)chatnetArray
{
  return chatnetArray;
}

- (NSMutableArray*)serverArray
{
  return serverArray;
}

- (void)addChatnetWithName:(NSString*)string
{
  IRC_CHATNET_REC *rec = g_new0(IRC_CHATNET_REC, 1);
  rec->name = g_strdup([IrssiBridge irssiCStringWithString:string]);
  ircnet_create(rec);
  
  IrcnetBridgeController *controller = [[[IrcnetBridgeController alloc] initWithChatnetRec:rec] autorelease];
 
  // Needs some KVC glue here to make sure things get told we've added a chatnet
  [self willChangeValueForKey:@"chatnetArray"];
  [chatnetArray addObject:controller];
  [self didChangeValueForKey:@"chatnetArray"];
}

- (void)deleteChatnetWithIndexSet:(NSIndexSet*)indexSet
{
  IrcnetBridgeController *controller = [chatnetArray objectAtIndex:[indexSet firstIndex]];
  NSLog(@"%@", [controller name]);
  
  IRC_CHATNET_REC *rec = [controller rec];
  chatnet_remove(CHATNET(rec));
  
  [self willChangeValueForKey:@"chatnetArray"];
  [chatnetArray removeObject:controller];
  [self didChangeValueForKey:@"chatnetArray"];
}

#pragma mark Irssi Settings KVC/KVO Proxies

- (NSString*)nick
{
  return [NSString stringWithCString:settings_get_str("nick")];
}

- (void)setNick:(NSString*)nick
{
  char *irssiCString = [IrssiBridge irssiCStringWithString:nick];
	if (strcmp(irssiCString, settings_get_str("nick")) != 0)
		settings_set_str("nick", irssiCString);
}

- (NSString*)alternateNick
{
  return [NSString stringWithCString:settings_get_str("alternate_nick")];
}

- (void)setAlternateNick:(NSString*)nick
{
  char *irssiCString = [IrssiBridge irssiCStringWithString:nick];
  if (strcmp(irssiCString, settings_get_str("alternate_nick")) != 0)
  {
    settings_set_str("alternate_nick", irssiCString);
  }
}

- (NSString*)username
{
  return [NSString stringWithCString:settings_get_str("user_name")];
}

- (void)setUsername:(NSString*)username
{
  char *irssiCString = [IrssiBridge irssiCStringWithString:username];
  if (strcmp(irssiCString, settings_get_str("user_name")) != 0)
  {
    settings_set_str("user_name", irssiCString);
  }
}

- (NSString*)realName
{
  return [NSString stringWithCString:settings_get_str("real_name")];
}

- (void)setRealName:(NSString*)name
{
  char *irssiCString = [IrssiBridge irssiCStringWithString:name];
  if (strcmp(irssiCString, settings_get_str("real_name")) != 0)
  {
    settings_set_str("real_name", irssiCString);
  }
}

@end
