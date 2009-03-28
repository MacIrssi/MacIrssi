//
//  PreferenceObjectController.m
//  MacIrssi
//
//  Created by Matt Wright on 10/10/2008.
//  Copyright 2008 Matt Wright Consulting. All rights reserved.
//

#import "PreferenceObjectController.h"
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
    shortcutArray = [[ShortcutBridgeController shortcutsFromDefaults] retain];
    
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

- (void)dealloc
{
  [shortcutArray release];
  [serverArray release];
  [chatnetArray release];
  [super dealloc];
}

- (NSMutableArray*)chatnetArray
{
  return chatnetArray;
}

- (NSMutableArray*)serverArray
{
  return serverArray;
}

- (NSMutableArray*)shortcutArray
{
  return shortcutArray;
}

- (IrcnetBridgeController*)addChatnetWithName:(NSString*)string
{
  IRC_CHATNET_REC *rec = g_new0(IRC_CHATNET_REC, 1);
  rec->name = g_strdup([IrssiBridge irssiCStringWithString:string]);
  ircnet_create(rec);
  
  IrcnetBridgeController *controller = [[[IrcnetBridgeController alloc] initWithChatnetRec:rec] autorelease];
 
  // Needs some KVC glue here to make sure things get told we've added a chatnet
  [self willChangeValueForKey:@"chatnetArray"];
  [chatnetArray addObject:controller];
  [self didChangeValueForKey:@"chatnetArray"];
  
  return controller;
}

- (void)deleteChatnetWithIndex:(int)index
{
  IrcnetBridgeController *controller = [chatnetArray objectAtIndex:index];
  
  // First bin all the channel_setups that this network owns
  while ([[controller channelArray] count])
  {
    [self deleteChannelWithIndex:0 fromChatnet:controller];
  }
  
  IRC_CHATNET_REC *rec = [controller rec];
  chatnet_remove(CHATNET(rec));
  
  [self willChangeValueForKey:@"chatnetArray"];
  [chatnetArray removeObject:controller];
  [self didChangeValueForKey:@"chatnetArray"];
}

- (ChannelBridgeController*)addChannelWithName:(NSString*)name toChatnet:(IrcnetBridgeController*)controller
{
  CHANNEL_SETUP_REC *rec = g_new0(CHANNEL_SETUP_REC, 1);
  rec->name = g_strdup([IrssiBridge irssiCStringWithString:name]);
  rec->chatnet = g_strdup([controller rec]->name);
  channel_setup_create(rec);
  
  ChannelBridgeController *channelController = [[[ChannelBridgeController alloc] initWithChannelRec:rec] autorelease];
  [[controller channelArray] addObject:channelController];
  
  return channelController;
}

- (void)deleteChannelWithIndex:(int)index fromChatnet:(IrcnetBridgeController*)ircController
{
  ChannelBridgeController *channelController = [[ircController channelArray] objectAtIndex:index];
  
  CHANNEL_SETUP_REC *rec = [channelController rec];
  channel_setup_remove(rec);
  
  [ircController willChangeValueForKey:@"channelArray"];
  [[ircController channelArray] removeObject:channelController];
  [ircController didChangeValueForKey:@"channelArray"];
}

- (ServerBridgeController*)addServerWithAddress:(NSString*)name port:(int)port
{
  SERVER_SETUP_REC *rec = g_new0(SERVER_SETUP_REC, 1);
  rec->address = g_strdup([IrssiBridge irssiCStringWithString:name]);
  rec->port = port;
  rec->chat_type = chat_protocol_get_default()->id;
  server_setup_add(rec);
  
  ServerBridgeController *serverController = [[[ServerBridgeController alloc] initWithServerSetupRec:rec] autorelease];
  [self willChangeValueForKey:@"serverArray"];
  [serverArray addObject:serverController];
  [self didChangeValueForKey:@"serverArray"];
  
  return serverController;
}

- (void)deleteServerWithIndex:(int)index
{
  ServerBridgeController *controller = [serverArray objectAtIndex:index];
  
  SERVER_SETUP_REC *rec = [controller rec];
  server_setup_remove(rec);
  
  [self willChangeValueForKey:@"serverArray"];
  [serverArray removeObject:controller];
  [self didChangeValueForKey:@"serverArray"];
}

- (ShortcutBridgeController*)addShortcutWithKeyCode:(int)keyCode flags:(int)flags
{
  ShortcutBridgeController *controller = [[[ShortcutBridgeController alloc] init] autorelease];
  
  [controller setKeyCode:keyCode];
  [controller setFlags:flags];
  
  [self willChangeValueForKey:@"shortcutArray"];
  [shortcutArray addObject:controller];
  [self didChangeValueForKey:@"shortcutArray"];
  
  return controller;
}

- (void)deleteShortcutWithKeyCode:(int)keyCode flags:(int)flags
{
  NSEnumerator *enumerator = [shortcutArray objectEnumerator];
  ShortcutBridgeController *controller;
  
  while (controller = [enumerator nextObject])
  {
    if (([controller keyCode] == keyCode) && ([controller flags] == flags))
    {
      // kk, this is cheating but WTH
      [controller _invalidateOld];
      [self willChangeValueForKey:@"shortcutArray"];
      [shortcutArray removeObject:controller];
      [self didChangeValueForKey:@"shortcutArray"];
    }
  }
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

- (NSString*)theme
{
  return [NSString stringWithCString:settings_get_str("theme")];
}

- (void)setTheme:(NSString*)theme
{
  char *irssiCString = [IrssiBridge irssiCStringWithString:theme];
  if (strcmp(irssiCString, settings_get_str("theme")) != 0)
  {
    settings_set_str("theme", irssiCString);
    themes_reload();
  }  
}

- (BOOL)windowHistory
{
  return settings_get_bool("window_history");
}

- (void)setWindowHistory:(BOOL)flag
{
  settings_set_bool("window_history", flag);
  signal_emit("setup changed", 0);
}

@end
