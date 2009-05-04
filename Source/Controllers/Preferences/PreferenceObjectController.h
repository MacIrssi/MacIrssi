/*
 PreferenceObjectController.h
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

#import <Cocoa/Cocoa.h>

#import "IrcnetBridgeController.h"
#import "ChannelBridgeController.h"
#import "ServerBridgeController.h"
#import "ShortcutBridgeController.h"

@interface PreferenceObjectController : NSObject {
  NSMutableArray *chatnetArray;
  NSMutableArray *serverArray;
  NSMutableArray *shortcutArray;
}

- (NSMutableArray*)chatnetArray;
- (NSMutableArray*)serverArray;
- (NSMutableArray*)shortcutArray;

- (IrcnetBridgeController*)addChatnetWithName:(NSString*)string;
- (void)deleteChatnetWithIndex:(int)index;

- (ChannelBridgeController*)addChannelWithName:(NSString*)name toChatnet:(IrcnetBridgeController*)controller;
- (void)deleteChannelWithIndex:(int)index fromChatnet:(IrcnetBridgeController*)ircController;

- (ServerBridgeController*)addServerWithAddress:(NSString*)name port:(int)port;
- (void)deleteServerWithIndex:(int)index;

- (ShortcutBridgeController*)addShortcutWithKeyCode:(int)keyCode flags:(int)flags;
- (void)deleteShortcutWithKeyCode:(int)keyCode flags:(int)flags;

- (NSString*)nick;
- (void)setNick:(NSString*)nick;

- (NSString*)alternateNick;
- (void)setAlternateNick:(NSString*)nick;

- (NSString*)username;
- (void)setUsername:(NSString*)username;

- (NSString*)realName;
- (void)setRealName:(NSString*)name;

- (NSString*)theme;
- (void)setTheme:(NSString*)theme;

- (BOOL)windowHistory;
- (void)setWindowHistory:(BOOL)flag;

@end
