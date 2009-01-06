//
//  ShortcutBridgeController.h
//  MacIrssi
//
//  Created by Matt Wright on 05/01/2009.
//  Copyright 2009 Matt Wright Consulting. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// Not quite on the same level as the Cocoa<->Irssi pref bridges,
// this class lets me bridge from the NSDictionary stored shortcuts in
// preferences and the arrays needed to do bindings in Tiger

@interface ShortcutBridgeController : NSObject {
  NSMutableDictionary *dict;
}

+ (NSArray*)shortcutsFromDefaults;

- (id)init;
- (id)initWithDictionary:(NSDictionary*)dictionary;

- (NSString*)command;
- (void)setCommand:(NSString*)command;

- (NSString*)displayString;

- (int)flags;
- (void)setFlags:(int)flags;

- (int)keyCode;
- (void)setKeyCode:(int)code;

- (BOOL)_isValid;
- (void)_invalidateOld;
- (void)_store;

@end
