//
//  IrssiRunloop.h
//  MacIrssi
//
//  Created by Matt Wright on 6/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

struct _GMainLoop;
struct _GMainContext;

@interface IrssiRunloop : NSObject {
  struct _GMainLoop *runloop;
  struct _GMainContext *context;
  
  NSTimer *runloopTimer;
}

- (id)init;
- (void)dealloc;

- (void)installInCurrentRunloop;
- (void)uninstallFromCurrentRunloop;

@end
