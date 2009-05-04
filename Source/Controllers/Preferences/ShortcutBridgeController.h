/*
 ShortcutBridgeController.h
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
