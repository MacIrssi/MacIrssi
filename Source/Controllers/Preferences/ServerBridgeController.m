/*
 ServerBridgeController.m
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

#import "ServerBridgeController.h"
#import "Irssi.h"

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
  return [NSString stringWithCString:CSTR(rec->address) encoding:NSUTF8StringEncoding];
}

- (void)setAddress:(NSString*)value
{
  if (rec->address) {
    g_free_and_null(rec->address);
  }
  if (value) {
    rec->address = g_strdup([value cStringUsingEncoding:NSUTF8StringEncoding]);
  }
  server_setup_add(rec);
}

- (NSString*)chatnet
{
  return [NSString stringWithCString:CSTR(rec->chatnet) encoding:NSUTF8StringEncoding];
}

- (void)setChatnet:(NSString*)value
{
  if (rec->chatnet) {
    g_free_and_null(rec->chatnet);
  }
  if (value) {
    rec->chatnet = g_strdup([value cStringUsingEncoding:NSUTF8StringEncoding]);
  }
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

- (BOOL)useSSL
{
  return rec->use_ssl;
}

- (void)setUseSSL:(BOOL)flag
{
  rec->use_ssl = flag;
  server_setup_add(rec);
}

@end
