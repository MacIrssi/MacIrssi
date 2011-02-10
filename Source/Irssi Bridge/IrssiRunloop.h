/*
 IrssiRunloop.h
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

#import <Cocoa/Cocoa.h>
#import <CoreFoundation/CoreFoundation.h>
#import <sys/event.h>
#import <pthread.h>

@interface IrssiRunloop : NSObject {
  CFRunLoopSourceRef notificationSourceRef;
  CFRunLoopObserverRef preWaitingObserverRef;
  CFRunLoopTimerRef wakeupTimerRef;
  CFRunLoopRef mainRunloopRef;
  int kFD;
  
  pthread_t kevent_thread;
}

+ (IrssiRunloop*)mainRunloop;

- (void)run;
- (void)stop;

@end
