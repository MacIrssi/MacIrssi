//
//  IrcnetBridgeController.h
//  MacIrssi
//
//  Created by Matt Wright on 11/10/2008.
//  Copyright 2008 Matt Wright Consulting. All rights reserved.
//

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

- (NSString*)nick;
- (void)setNick:(NSString*)value;

- (NSString*)username;
- (void)setUsername:(NSString*)value;

- (NSString*)realname;
- (void)setRealname:(NSString*)value;

- (NSString*)autoCommand;
- (void)setAutoCommand:(NSString*)value;

@end
