/*
 IrcnetBridgeController.m
 Copyright (c) 2008, 2009 Matt Wright.
 
 MacIrssi is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
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
#import "IrssiBridge.h"

/* Irssi Headers */
#import "channels-setup.h"

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
  return [IrssiBridge stringWithIrssiCString:rec->name];
}

- (NSString*)nick
{
  return [IrssiBridge stringWithIrssiCString:rec->nick];
}

- (void)setNick:(NSString*)value
{
  rec->nick = [IrssiBridge irssiCStringWithString:value];
  chatnet_create((CHATNET_REC*)rec);
}

- (NSString*)username
{
  return [IrssiBridge stringWithIrssiCString:rec->username];
}

- (void)setUsername:(NSString*)value
{
  rec->username = [IrssiBridge irssiCStringWithString:value];
  chatnet_create((CHATNET_REC*)rec);
}

- (NSString*)realname
{
  return [IrssiBridge stringWithIrssiCString:rec->realname];
}

- (void)setRealname:(NSString*)value
{
  rec->realname = [IrssiBridge irssiCStringWithString:value];
  chatnet_create((CHATNET_REC*)rec);
}

- (NSString*)autoCommand
{
  return [IrssiBridge stringWithIrssiCString:rec->autosendcmd];
}

- (void)setAutoCommand:(NSString*)value
{
  rec->autosendcmd = [IrssiBridge irssiCStringWithString:value];
  chatnet_create((CHATNET_REC*)rec);
}

@end
