/*
 PreferenceObjectController.m
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

#import "PreferenceObjectController.h"
#import "Irssi.h"

// Irssi Imports
#import "common.h"
#import "settings.h"
#import "chatnets.h"
#import "themes.h"
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkDidChangeName:) name:kMINetworkDidChangeNameNotification object:nil];
  }
  return self;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kMINetworkDidChangeNameNotification object:nil];
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

- (NSString*)uniqueNameForNewChatnet
{
  NSString *baseTemplate = @"New Network", *name = nil;
  BOOL foundUniqueName = YES;
  NSUInteger count = 0;
  
  do {
    foundUniqueName = YES;
    name = baseTemplate;
    if (count++ > 0) {
      name = [NSString stringWithFormat:@"%@ %lu", baseTemplate, (unsigned long)count];
    }
    for (IrcnetBridgeController *net in chatnetArray) {
      if ([[net name] isEqualToString:name]) {
        foundUniqueName = NO;
      }
    }
  } while (!foundUniqueName);
  
  return name;
}

- (IrcnetBridgeController*)addChatnetWithName:(NSString*)string
{
  IRC_CHATNET_REC *rec = g_new0(IRC_CHATNET_REC, 1);
  rec->name = g_strdup([string cStringUsingEncoding:NSUTF8StringEncoding]);
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

- (void)networkDidChangeName:(NSNotification*)notification
{
  NSString *oldName = [[notification userInfo] objectForKey:kMINetworkChangeOldName];
  NSString *newName = [[notification userInfo] objectForKey:kMINetworkChangeNewName];
  
  for (ServerBridgeController *server in serverArray) {
    if ([[server chatnet] isEqualToString:oldName]) {
      [server setChatnet:newName];
    }
  }
}

- (NSString*)uniqueNameForNewChannelInNetwork:(IrcnetBridgeController*)network
{
  NSString *baseTemplate = @"#newchannel", *name = nil;
  BOOL foundUniqueName = YES;
  NSUInteger count = 0;
  
  do {
    foundUniqueName = YES;
    name = baseTemplate;
    if (count++ > 0) {
      name = [NSString stringWithFormat:@"%@%lu", baseTemplate, (unsigned long)count];
    }
    for (ChannelBridgeController *channel in [network channelArray]) {
      if ([[channel name] isEqualToString:name]) {
        foundUniqueName = NO;
      }
    }
  } while (!foundUniqueName);
  
  return name;
}

- (ChannelBridgeController*)addChannelWithName:(NSString*)name toChatnet:(IrcnetBridgeController*)controller
{
  CHANNEL_SETUP_REC *rec = g_new0(CHANNEL_SETUP_REC, 1);
  rec->name = g_strdup([name cStringUsingEncoding:NSUTF8StringEncoding]);
  rec->chatnet = g_strdup([controller rec]->name);
  rec->autojoin = YES;
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

- (ServerBridgeController*)addServerWithAddress:(NSString*)name port:(int)port atIndex:(NSUInteger)index
{
  SERVER_SETUP_REC *rec = g_new0(SERVER_SETUP_REC, 1);
  rec->address = g_strdup([name cStringUsingEncoding:NSUTF8StringEncoding]);
  rec->port = port;
  rec->chat_type = chat_protocol_get_default()->id;
  server_setup_add(rec);
  
  ServerBridgeController *serverController = [[[ServerBridgeController alloc] initWithServerSetupRec:rec] autorelease];
  [self willChangeValueForKey:@"serverArray"];
  [serverArray insertObject:serverController atIndex:index];
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
  
  NSMutableArray *objectsToRemove = [NSMutableArray array];
  
  while (controller = [enumerator nextObject])
  {
    if (([controller keyCode] == keyCode) && ([controller flags] == flags))
    {
      [objectsToRemove addObject:controller];
    }
  }
  
  enumerator = [objectsToRemove objectEnumerator];
  while (controller = [enumerator nextObject])
  {
    // kk, this is cheating but WTH
    [controller _invalidateOld];
    [self willChangeValueForKey:@"shortcutArray"];
    [shortcutArray removeObject:controller];
    [self didChangeValueForKey:@"shortcutArray"];    
  }
}

#pragma mark Irssi Settings KVC/KVO Proxies

- (NSString*)nick
{
  return [NSString stringWithCString:CSTR(settings_get_str("nick")) encoding:NSUTF8StringEncoding];
}

- (void)setNick:(NSString*)nick
{
  const char *irssiCString = [nick cStringUsingEncoding:NSUTF8StringEncoding];
	if (strcmp(irssiCString, settings_get_str("nick")) != 0)
		settings_set_str("nick", irssiCString);
}

- (NSString*)alternateNick
{
  return [NSString stringWithCString:CSTR(settings_get_str("alternate_nick")) encoding:NSUTF8StringEncoding];
}

- (void)setAlternateNick:(NSString*)nick
{
  const char *irssiCString = [nick cStringUsingEncoding:NSUTF8StringEncoding];
  if (strcmp(irssiCString, settings_get_str("alternate_nick")) != 0)
  {
    settings_set_str("alternate_nick", irssiCString);
  }
}

- (NSString*)username
{
  return [NSString stringWithCString:CSTR(settings_get_str("user_name")) encoding:NSUTF8StringEncoding];
}

- (void)setUsername:(NSString*)username
{
  const char *irssiCString = [username cStringUsingEncoding:NSUTF8StringEncoding];
  if (strcmp(irssiCString, settings_get_str("user_name")) != 0)
  {
    settings_set_str("user_name", irssiCString);
  }
}

- (NSString*)realName
{
  return [NSString stringWithCString:CSTR(settings_get_str("real_name")) encoding:NSUTF8StringEncoding];
}

- (void)setRealName:(NSString*)name
{
  const char *irssiCString = [name cStringUsingEncoding:NSUTF8StringEncoding];
  if (strcmp(irssiCString, settings_get_str("real_name")) != 0)
  {
    settings_set_str("real_name", irssiCString);
  }
}

- (NSString*)theme
{
  return [NSString stringWithCString:CSTR(settings_get_str("theme")) encoding:NSUTF8StringEncoding];
}

- (void)setTheme:(NSString*)theme
{
  const char *irssiCString = [theme cStringUsingEncoding:NSUTF8StringEncoding];
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
