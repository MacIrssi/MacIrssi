//
//  IrcnetBridgeController.m
//  MacIrssi
//
//  Created by Matt Wright on 11/10/2008.
//  Copyright 2008 Matt Wright Consulting. All rights reserved.
//

#import "IrcnetBridgeController.h"
#import "IrssiBridge.h"

@implementation IrcnetBridgeController

- (id)initWithChatnetRec:(IRC_CHATNET_REC*)chatrec
{
  if (self = [super init])
  {
    rec = chatrec;
  }
  return self;
}

- (IRC_CHATNET_REC*)rec
{
  return rec;
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
