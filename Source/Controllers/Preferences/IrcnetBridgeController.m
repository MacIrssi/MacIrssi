//
//  IrcnetBridgeController.m
//  MacIrssi
//
//  Created by Matt Wright on 11/10/2008.
//  Copyright 2008 Matt Wright Consulting. All rights reserved.
//

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
