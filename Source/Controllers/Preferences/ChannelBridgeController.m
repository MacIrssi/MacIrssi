/*
 ChannelBridgeController.m
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
