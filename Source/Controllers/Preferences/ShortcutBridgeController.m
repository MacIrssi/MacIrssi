/*
 ShortcutBridgeController.m
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

#import "ShortcutBridgeController.h"
#import "SRCommon.h"

@implementation ShortcutBridgeController

+ (NSArray*)shortcutsFromDefaults
{
  NSArray *shortcuts = [[[NSUserDefaults standardUserDefaults] valueForKey:@"shortcutDict"] allValues];
  NSEnumerator *shortcutEnumerator = [shortcuts objectEnumerator];
  NSDictionary *shortcutDict;
  
  NSMutableArray *ret = [NSMutableArray array];
  
  while (shortcutDict = [shortcutEnumerator nextObject])
  {
    [ret addObject:[[[ShortcutBridgeController alloc] initWithDictionary:shortcutDict] autorelease]];
  }
  
  return ret;
}

- (id)init
{
  if (self = [super init])
  {
    dict = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (id)initWithDictionary:(NSDictionary*)dictionary
{
  if (self = [self init])
  {
    [dict addEntriesFromDictionary:dictionary];
  }
  return self;
}

- (void)dealloc
{
  [dict release];
  [super dealloc];
}

- (NSString*)command
{
  return [dict valueForKey:@"command"];
}

- (void)setCommand:(NSString*)command
{
  [dict setValue:command forKey:@"command"];
  [self _store];
}

- (NSString*)displayString
{
  return SRStringForCocoaModifierFlagsAndKeyCode([self flags], [self keyCode]);
}

- (int)flags
{
  return [dict valueForKey:@"flags"] ? [[dict valueForKey:@"flags"] intValue] : 0;
}

- (void)setFlags:(int)flags
{
  [self _invalidateOld];
  [dict setValue:SRInt(flags) forKey:@"flags"];
  [self _store];
}

- (int)keyCode
{
  return [dict valueForKey:@"keyCode"] ? [[dict valueForKey:@"keyCode"] intValue] : -1;
}
                                          
- (void)setKeyCode:(int)code
{
  [self _invalidateOld];
  [dict setValue:SRInt(code) forKey:@"keyCode"];
  [self _store];
}

#pragma mark Internal

- (BOOL)_isValid
{
  return (([self command] && [[self command] isNotEqualTo:@""]) && ([self keyCode] != -1));
}

- (void)_invalidateOld
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSMutableDictionary *currentShortcuts = [NSMutableDictionary dictionaryWithDictionary:[defaults valueForKey:@"shortcutDict"]];
  
  [currentShortcuts removeObjectForKey:[self displayString]];
  [defaults setValue:currentShortcuts forKey:@"shortcutDict"];
  [defaults synchronize];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:@"shortcutChanged" object:self];
}

- (void)_store
{
  if ([self _isValid])
  {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *currentShortcuts = [NSMutableDictionary dictionaryWithDictionary:[defaults valueForKey:@"shortcutDict"]];
    
    // We've got the old dict, update it with our dict in place of the current shortcut
    [currentShortcuts setValue:dict forKey:[self displayString]];
    [defaults setValue:currentShortcuts forKey:@"shortcutDict"];
    [defaults synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"shortcutChanged" object:self];
  }
}

@end
