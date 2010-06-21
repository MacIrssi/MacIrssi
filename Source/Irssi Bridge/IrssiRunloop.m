//
//  IrssiRunloop.m
//  MacIrssi
//
//  Created by Matt Wright on 6/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "IrssiRunloop.h"

#import "glib.h"

@interface IrssiRunloop ()
- (void)_executeSingleIteration;
@end


@implementation IrssiRunloop

- (id)init
{
  // Could maybe clean this up later, originally I had used a non-NULL context for
  // creating the main loop. As it stands, this class makes more sense as a singleton
  // or class-method only class. CBA changing it now though.
  if (self = [super init]) {
    runloop = g_main_loop_new(NULL, TRUE);
  }
  return self;
}

- (void)dealloc
{
  [self uninstallFromCurrentRunloop];
  g_main_loop_unref(runloop);
  [super dealloc];
}

- (void)installInCurrentRunloop
{
  // Sadly, I can't really do this any better. CF/NSRunloops are normally woken
  // by some kind of pending signal. A mach port message, for instance.
  
  // The glib runloop primarily handles doing the same job, so while I can check
  // if there is work to do in the runloop, I can't get notified when this is the
  // case.
  
  // Therefore, the runloop is just going in a timer.
  
  runloopTimer = [[NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(_executeSingleIteration) userInfo:nil repeats:YES] retain];
}

- (void)uninstallFromCurrentRunloop
{
  [runloopTimer invalidate];
  [runloopTimer release];
  runloopTimer = nil;
}
                                                                                   
- (void)_executeSingleIteration
{
  // run current context, MAY NOT BLOCK.
  g_main_context_iteration(NULL, FALSE);
}

@end
