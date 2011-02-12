/*
 IrcnetBridgeController.m
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

#import "IrcnetBridgeController.h"
#import "ChannelBridgeController.h"
#import "Irssi.h"

/* Irssi Headers */
#import "channels-setup.h"
#import "settings.h"

@implementation IrcnetBridgeController

- (id)initWithChatnetRec:(IRC_CHATNET_REC*)chatrec
{
  if (self = [super init])
  {
    channelArray = [[NSMutableArray alloc] init];
    rec = chatrec;
    
    // We've just been initialised, go see what channels we've got assigned to us
    GSList *tmp, *next;
    for (tmp = setupchannels; tmp != NULL; tmp = next)
    {
      CHANNEL_SETUP_REC *channelrec = CHANNEL_SETUP(tmp->data);
      
      if (channel_chatnet_match(channelrec->chatnet, rec->name))
      {
        ChannelBridgeController *controller = [[[ChannelBridgeController alloc] initWithChannelRec:channelrec] autorelease];
        [channelArray addObject:controller];
      }
      
      next = tmp->next;
    }
  }
  return self;
}

- (void)dealloc
{
  [channelArray release];
  [super dealloc];
}

- (IRC_CHATNET_REC*)rec
{
  return rec;
}

- (NSMutableArray*)channelArray
{
  return channelArray;
}

- (NSString*)name
{
  return [NSString stringWithCString:CSTR(rec->name) encoding:NSUTF8StringEncoding];
}

- (void)setName:(NSString*)value
{
  NSString *oldname = [NSString stringWithUTF8String:rec->name];
  if (rec->name) {
    signal_emit("chatnet removed", 1, rec);
    chatnet_config_remove((CHATNET_REC*)rec);
    g_free_and_null(rec->name);
  }
  if (value) {
    rec->name = g_strdup([value cStringUsingEncoding:NSUTF8StringEncoding]);
  }
  chatnet_create((CHATNET_REC*)rec);
  settings_save(NULL, TRUE);
  
  NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:value, kMINetworkChangeNewName, oldname, kMINetworkChangeOldName, nil];
  [[NSNotificationCenter defaultCenter] postNotificationName:kMINetworkDidChangeNameNotification object:self userInfo:userInfo];
}

- (NSString*)nick
{
  return [NSString stringWithCString:CSTR(rec->nick) encoding:NSUTF8StringEncoding];
}

- (void)setNick:(NSString*)value
{
  if (rec->nick) {
    g_free_and_null(rec->nick);
  }
  if (value) {
    rec->nick = g_strdup([value cStringUsingEncoding:NSUTF8StringEncoding]);
  }
  chatnet_create((CHATNET_REC*)rec);
}

- (NSString*)username
{
  return [NSString stringWithCString:CSTR(rec->username) encoding:NSUTF8StringEncoding];
}

- (void)setUsername:(NSString*)value
{
  if (rec->username) {
    g_free_and_null(rec->username);
  }
  if (value) {
    rec->username = g_strdup([value cStringUsingEncoding:NSUTF8StringEncoding]);
  }
  chatnet_create((CHATNET_REC*)rec);
}

- (NSString*)realname
{
  return [NSString stringWithCString:CSTR(rec->realname) encoding:NSUTF8StringEncoding];
}

- (void)setRealname:(NSString*)value
{
  if (rec->realname) {
    g_free_and_null(rec->realname);
  }
  if (value) {
    rec->realname = g_strdup([value cStringUsingEncoding:NSUTF8StringEncoding]);
  }
  chatnet_create((CHATNET_REC*)rec);
}

- (NSString*)autoCommand
{
  return [NSString stringWithCString:CSTR(rec->autosendcmd) encoding:NSUTF8StringEncoding];
}

- (void)setAutoCommand:(NSString*)value
{
  if (rec->autosendcmd) {
    g_free_and_null(rec->autosendcmd);
  }
  if (value) {
    rec->autosendcmd = g_strdup([value cStringUsingEncoding:NSUTF8StringEncoding]);
  }
  chatnet_create((CHATNET_REC*)rec);
}

@end
