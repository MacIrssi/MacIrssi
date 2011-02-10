/*
 IrssiRunloop.m
 Copyright (c) 2011 Matt Wright.
 
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

#import "IrssiRunloop.h"
#import <pthread.h>
#import <sys/socket.h>
#import <sys/types.h>
#import <sys/time.h>
#import <Glib/glib.h>

@interface IrssiRunloop ()

- (id)init;
- (void)dealloc;

- (void)_installRunloopSource;
- (void)_startKeventThread;
- (void)_installGlibPoll;

- (gint)_poll:(GPollFD*)fds count:(guint)nfds timeout:(gint)timeout;
- (void)_kevent;

@end

static IrssiRunloop *runloop = nil;
static pthread_once_t once = PTHREAD_ONCE_INIT;

static void MainRunloopInitOnce(void)
{
  runloop = [[IrssiRunloop alloc] init];
  if (runloop == nil)
  {
    [runloop release];
    NSLog(@"+[IrssiRunloop mainRunloop]: failed to instantiate shared runloop object.");
  }
}

static void RunLoopPerform(void *info)
{
  [[IrssiRunloop mainRunloop] _kevent];
}

static void RunLoopObserve(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
  /* Before we sleep, we need to ticket the glib runloop to make sure its not bored */
  [[IrssiRunloop mainRunloop] run];
}

static gint GlibPollReplacement(GPollFD *fds, guint nfds, gint timeout)
{
  /* Pass it off to the object */
  return [[IrssiRunloop mainRunloop] _poll:fds count:nfds timeout:timeout];
}

@implementation IrssiRunloop

+ (id)mainRunloop
{
  pthread_once(&once, MainRunloopInitOnce);
  return runloop;
}

- (id)init
{
  self = [super init];
  if (self != nil)
  {
    /* 
     * The plan:
     *
     *   1. Create a CFRunloopSource.
     *   2. Put the CFRunloopSource in the main run loop.
     *   3. Spool up a thread to wait in kqueue.
     *   4. Call g_main_context_iteration once, to get the timeout and fd's
     *   4a.  Always return no fd's, and return immediately
     *   4b.  When the kevent fires, signal the CFRunloopSource
     *   4c.  From the source, re-enter g_main_context_iteration.
     *   4d.  Return the kevent fd's, set the kevent to timeout in the new time.
     *   4e.  Return from the poll function immediately back to Cocoa.
     */
    
    mainRunloopRef = (CFRunLoopRef)CFRetain(CFRunLoopGetMain());
    timeout_valid = NO;
    kFD = kqueue();
    
    if (socketpair(AF_UNIX, SOCK_STREAM, 0, notifyPorts) != 0)
    {
      NSLog(@"-[%@ %@] unable to open kevent socketpair (%d, %s).", [self className], NSStringFromSelector(_cmd), errno, strerror(errno));
      [self release];
      return nil;
    }
    
    [self _installRunloopSource];
    
    [NSThread detachNewThreadSelector:@selector(_startKeventThread) toTarget:self withObject:nil];
    
    [self _installGlibPoll];
  }
  return self;
}

- (void)dealloc
{  
  if (notificationSourceRef) {
    CFRunLoopRemoveSource(mainRunloopRef, notificationSourceRef, kCFRunLoopCommonModes);
    CFRelease(notificationSourceRef);
  }
  
  if (preWaitingObserverRef) {
    CFRunLoopRemoveObserver(mainRunloopRef, preWaitingObserverRef, kCFRunLoopCommonModes);
    CFRelease(preWaitingObserverRef);
  }
  
  if (mainRunloopRef) {
    CFRelease(mainRunloopRef);
  }  
  
  [super dealloc];
}

- (void)_installRunloopSource
{
  CFRunLoopSourceContext context = {
    .version = 0,
    .info = self,
    /* the source is owned by the object, so we don't need to manage retains */
    .perform = RunLoopPerform,
  };
  
  notificationSourceRef = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
  CFRunLoopAddSource(mainRunloopRef, notificationSourceRef, kCFRunLoopCommonModes);
  
  preWaitingObserverRef = CFRunLoopObserverCreate(kCFAllocatorDefault, 
                                                  kCFRunLoopBeforeWaiting, 
                                                  TRUE, 
                                                  0, 
                                                  RunLoopObserve, 
                                                  NULL);
  CFRunLoopAddObserver(mainRunloopRef, preWaitingObserverRef, kCFRunLoopCommonModes);
}

- (void)_startKeventThread
{
  /* Ok, we're in the kevent thread now! OMG. */
  
  /* For now, we'll make this an infinite loop */
  do
  {
    struct timeval *t = NULL;
    
    if (timeout_valid) {
      t = &next_timeout;
      __sync_bool_compare_and_swap(&timeout_valid, YES, NO);
    }
    
    /* so going to do launchd's trick and select() on the kevent, with the notifyPorts fd in there too */
    fd_set rfds;
    FD_ZERO(&rfds);
    FD_SET(notifyPorts[1], &rfds);
    FD_SET(kFD, &rfds);
    
    if (select((kFD > notifyPorts[1] ? kFD : notifyPorts[1]) + 1, &rfds, NULL, NULL, t) > 0) {
      if (FD_ISSET(notifyPorts[1], &rfds)) {
        char poke = 0;
        read(notifyPorts[1], &poke, sizeof(poke));
      }

      if (FD_ISSET(kFD, &rfds)) {
        CFRunLoopSourceSignal(notificationSourceRef);
        CFRunLoopWakeUp(mainRunloopRef);
      }
    }
  }
  while (1);
}

- (void)_installGlibPoll
{
  g_main_context_set_poll_func(NULL, GlibPollReplacement);
}

- (void)run
{
  /* We're going to ask to "block" because glib will then call our poll with a timeout */
  g_main_context_iteration(NULL, TRUE);
}

- (gint)_poll:(GPollFD*)fds count:(guint)nfds timeout:(gint)timeout
{
  /* So for the first pass, we'll take their fds and put them into kevents, then set the timeout
   * and signal the kevent via our socket pair. */

  guint i = 0;
  
  /* now we've notified kev of an event, we need to see if we have any to tell them about */
  struct timespec timeoutnow = { 0, 0 };
  struct kevent kev = { 0 };
  int rval = 0;
  
  int handled_events = 0;
  while ((rval = kevent(kFD, NULL, 0, &kev, 1, &timeoutnow)) > 0) {
    for (i=0; i<nfds; i++) {
      if (fds[i].fd != kev.ident) {
        continue;
      }
      
      if (kev.filter == EVFILT_READ) {
        fds[i].revents |= G_IO_IN;
      }
      
      if (kev.filter == EVFILT_WRITE) {
        fds[i].revents |= G_IO_OUT;
      }
      
      handled_events++;
      
      /* dealt with this one, remove it from the kevent */
      kev.flags = EV_DELETE;
      kevent(kFD, &kev, 1, NULL, 0, NULL);
    }
  }
  
  for (i=0; i<nfds; i++)
  {
    /* feed the kevent */
    struct kevent kev = {
      .ident = fds[i].fd,
      .flags = EV_ADD | EV_RECEIPT,
    };
    struct kevent kev_return = { 0 };
    
    if (fds[i].events & G_IO_IN) {
      kev.filter = EVFILT_READ;
      int err = kevent(kFD, &kev, 1, &kev_return, 1, NULL);
      if (err == -1) {
        NSLog(@"-[%@ %@] unable to register fd %d for %@.", [self className], NSStringFromSelector(_cmd), fds[i].fd, (kev.filter == EVFILT_READ ? @"EVFILT_READ" : @"EVFILT_WRITE"));
      }
    }
    
    if (fds[i].events & G_IO_OUT) {
      kev.filter = EVFILT_WRITE;
      int err = kevent(kFD, &kev, 1, &kev_return, 1, NULL);
      if (err == -1) {
        NSLog(@"-[%@ %@] unable to register fd %d for %@.", [self className], NSStringFromSelector(_cmd), fds[i].fd, (kev.filter == EVFILT_READ ? @"EVFILT_READ" : @"EVFILT_WRITE"));
      }      
    }
    
    /* TODO: G_IO_PRI ? */
  }
  
  /* set the timeout */
  next_timeout.tv_sec = timeout / 1000;
  next_timeout.tv_usec = (timeout % 1000) / 1000;
  timeout_valid = YES;
  
  /* poke the kev */
  char poke = 0;
  write(notifyPorts[0], &poke, sizeof(poke));
    
  return handled_events;
}

- (void)_kevent
{
  /* The CFRunloopSource went off to tell us we got prodded */
  g_main_context_iteration(NULL, TRUE);
}

@end
