//
//  ServerBridgeController.m
//  MacIrssi
//
//  Created by Matt Wright on 11/10/2008.
//  Copyright 2008 Matt Wright Consulting. All rights reserved.
//

#import "ServerBridgeController.h"
#import "IrssiBridge.h"

@implementation ServerBridgeController

- (id)initWithServerSetupRec:(SERVER_SETUP_REC*)serverrec
{
  if (self = [super init])
  {
    rec = serverrec;
  }
  return self;
}

- (SERVER_SETUP_REC*)rec
{
  return rec;
}

- (NSString*)address
{
  return [IrssiBridge stringWithIrssiCString:rec->address];
}

- (void)setAddress:(NSString*)value
{
  rec->address = g_strdup([IrssiBridge irssiCStringWithString:value]);
  server_setup_add(rec);
}

- (NSString*)chatnet
{
  return [IrssiBridge stringWithIrssiCString:rec->chatnet];
}

- (void)setChatnet:(NSString*)value
{
  rec->chatnet = g_strdup([IrssiBridge irssiCStringWithString:value]);
  server_setup_add(rec);
}

- (int)port
{
  return rec->port;
}

- (void)setPort:(int)port
{
  rec->port = port;
  server_setup_add(rec);
}

- (BOOL)autoconnect
{
  return rec->autoconnect;
}

- (void)setAutoconnect:(BOOL)flag
{
  rec->autoconnect = flag;
  server_setup_add(rec);
}

@end
