//
//  PreferenceObjectController.h
//  MacIrssi
//
//  Created by Matt Wright on 10/10/2008.
//  Copyright 2008 Matt Wright Consulting. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferenceObjectController : NSObject {
  NSMutableArray *chatnetArray;
  NSMutableArray *serverArray;
}

- (NSMutableArray*)chatnetArray;
- (NSMutableArray*)serverArray;

- (void)addChatnetWithName:(NSString*)string;
- (void)deleteChatnetWithIndexSet:(NSIndexSet*)indexSet;

- (NSString*)nick;
- (void)setNick:(NSString*)nick;

- (NSString*)alternateNick;
- (void)setAlternateNick:(NSString*)nick;

- (NSString*)username;
- (void)setUsername:(NSString*)username;

- (NSString*)realName;
- (void)setRealName:(NSString*)name;

@end
