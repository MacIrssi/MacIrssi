//
//  PreferenceObjectController.h
//  MacIrssi
//
//  Created by Matt Wright on 10/10/2008.
//  Copyright 2008 Matt Wright Consulting. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IrcnetBridgeController.h"
#import "ChannelBridgeController.h"
#import "ServerBridgeController.h"

@interface PreferenceObjectController : NSObject {
  NSMutableArray *chatnetArray;
  NSMutableArray *serverArray;
}

- (NSMutableArray*)chatnetArray;
- (NSMutableArray*)serverArray;

- (IrcnetBridgeController*)addChatnetWithName:(NSString*)string;
- (void)deleteChatnetWithIndex:(int)index;

- (ChannelBridgeController*)addChannelWithName:(NSString*)name toChatnet:(IrcnetBridgeController*)controller;
- (void)deleteChannelWithIndex:(int)index fromChatnet:(IrcnetBridgeController*)ircController;

- (ServerBridgeController*)addServerWithAddress:(NSString*)name port:(int)port;
- (void)deleteServerWithIndex:(int)index;

- (NSString*)nick;
- (void)setNick:(NSString*)nick;

- (NSString*)alternateNick;
- (void)setAlternateNick:(NSString*)nick;

- (NSString*)username;
- (void)setUsername:(NSString*)username;

- (NSString*)realName;
- (void)setRealName:(NSString*)name;

@end
