/*
 ServerBridgeController.m
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
