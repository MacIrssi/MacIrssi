//
//  ChannelBridgeController.m
//  MacIrssi
//
//  Created by Matt Wright on 11/10/2008.
//  Copyright 2008 Matt Wright Consulting. All rights reserved.
//

#import "ChannelBridgeController.h"
#import "IrssiBridge.h"

@implementation ChannelBridgeController

- (id)initWithChannelRec:(CHANNEL_SETUP_REC*)chanrec
{
  if (self = [super init])
  {
    rec = chanrec;
  }
  return self;
}

- (CHANNEL_SETUP_REC*)rec
{
  return rec;
}

- (NSString*)name
{
  return [IrssiBridge stringWithIrssiCString:rec->name];
}

- (void)setName:(NSString*)value
{
  rec->name = g_strdup([IrssiBridge irssiCStringWithString:value]);
  channel_setup_create(rec);
}

- (BOOL)autoJoin
{
  return rec->autojoin;
}

- (void)setAutoJoin:(BOOL)flag
{
  rec->autojoin = flag;
  channel_setup_create(rec);
}

@end
