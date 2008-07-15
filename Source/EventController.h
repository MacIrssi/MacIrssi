//
//  EventController.h
//  MacIrssi
//
//  Created by Matt Wright on 04/07/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EventController : NSObject {
  NSNotificationCenter *notificationCenter;
  
  NSArray *availableEvents;
  NSDictionary *availableEventNames;
  
  NSMutableDictionary *changedEventSettings;
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
