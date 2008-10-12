//
//  ServerBridgeController.h
//  MacIrssi
//
//  Created by Matt Wright on 11/10/2008.
//  Copyright 2008 Matt Wright Consulting. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/* Irssi Headers */
#import "common.h"
#import "servers-setup.h"

@interface ServerBridgeController : NSObject {
  SERVER_SETUP_REC *rec;
}

- (id)initWithServerSetupRec:(SERVER_SETUP_REC*)rec;

- (SERVER_SETUP_REC*)rec;

- (NSString*)address;
- (void)setAddress:(NSString*)value;

- (NSString*)chatnet;
- (void)setChatnet:(NSString*)value;

- (int)port;
- (void)setPort:(int)port;

- (BOOL)autoconnect;
- (void)setAutoconnect:(BOOL)flag;

@end
