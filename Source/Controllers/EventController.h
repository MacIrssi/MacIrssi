/*
 EventController.h
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

@interface EventController : NSObject {
  NSNotificationCenter *notificationCenter;
  
  NSArray *availableEvents;
  NSDictionary *availableEventNames;
  
  NSMutableDictionary *changedEventSettings;
  
  NSLock *eventControllerLock;
}

+ (NSDictionary*)defaults;

- (NSArray*)availableEvents;
- (NSArray*)availableEventNames;

- (NSString*)eventNameForCode:(NSString*)code;
- (NSString*)eventCodeForName:(NSString*)name;

- (BOOL)boolForEvent:(NSString*)event alert:(NSString*)alert;
- (NSString*)stringForEvent:(NSString*)event alert:(NSString*)alert;

- (void)setBoolForEvent:(NSString*)event alert:(NSString*)alert value:(BOOL)value;
- (void)setStringForEvent:(NSString*)event alert:(NSString*)alert value:(NSString*)value;

- (void)commitChanges;
- (void)cancelChanges;

@end
