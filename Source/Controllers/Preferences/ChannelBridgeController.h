//
//  ChannelBridgeController.h
//  MacIrssi
//
//  Created by Matt Wright on 11/10/2008.
//  Copyright 2008 Matt Wright Consulting. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/* Irssi Headers */
#import "common.h"
#import "channels-setup.h"

@interface ChannelBridgeController : NSObject {
  CHANNEL_SETUP_REC *rec;
}

- (id)initWithChannelRec:(CHANNEL_SETUP_REC*)chanrec;

- (CHANNEL_SETUP_REC*)rec;

- (NSString*)name;
- (void)setName:(NSString*)value;

- (BOOL)autoJoin;
- (void)setAutoJoin:(BOOL)flag;

@end
