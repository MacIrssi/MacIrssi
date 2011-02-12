/*
 IrcnetBridgeController.h
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

#import <Cocoa/Cocoa.h>

/* Irssi Headers */
#import "common.h"
#import "irc.h"
#import "irc-chatnets.h"

/**
 This is a stub class to bridge irssi's IRC_CHATNET_REC into something we can
 attach to the preferences panel with KVC bindings.
 **/

@interface IrcnetBridgeController : NSObject {
  IRC_CHATNET_REC *rec;
  NSMutableArray *channelArray;
}

- (id)initWithChatnetRec:(IRC_CHATNET_REC*)chatrec;

- (IRC_CHATNET_REC*)rec;
- (NSMutableArray*)channelArray;

- (NSString*)name;
- (void)setName:(NSString*)value;

- (NSString*)nick;
- (void)setNick:(NSString*)value;

- (NSString*)username;
- (void)setUsername:(NSString*)value;

- (NSString*)realname;
- (void)setRealname:(NSString*)value;

- (NSString*)autoCommand;
- (void)setAutoCommand:(NSString*)value;

@end
