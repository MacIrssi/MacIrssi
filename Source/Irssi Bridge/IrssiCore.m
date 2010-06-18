/*
 IrssiCore.m
 Copyright (c) 2010 Matt Wright.
 
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

#import "IrssiCore.h"
#import <pthread.h>
#import "signals.h"

#import "IrssiBridge.h"

typedef enum {
  SIGNAL_NONE = 0,
  SIGNAL_NORMAL,
  SIGNAL_FIRST,
  SIGNAL_LAST,
} ICSignalType;

typedef struct {
  const char *signal;
  ICSignalType type;
  SIGNAL_FUNC func;
} ICSignal;

static ICSignal irssiSignals[] = {
  { "server setup read", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_server_setup_read },

  { "server disconnected", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_server_disconnected },
  { "server connected", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_server_connected },
  
  { "gui print text", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_print_text },
  { "gui print text finished", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_print_text_finished },
  
  { "window created", SIGNAL_LAST, (SIGNAL_FUNC)irssibridge_window_created },
  { "window destroyed", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_window_destroyed },
  { "window changed", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_window_changed },
  { "window changed automatic", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_window_changed_automatic },
  { "window server changed", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_window_server_changed },
  { "window refnum changed", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_window_refnum_changed },
  { "window name changed", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_window_name_changed },
  // { "window history changed", SIGNAL_NORMAL, (SIGNAL_FUNC) irssibridge_window_history_changed },
  // { "window level changed", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_window_level_changed },

  { "channel topic changed", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_channel_topic_changed },
  // { "window item new", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_window_item_new },
  // { "window item changed", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_window_item_changed },
  { "window activity", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_window_activity, },
  
  { "window hilight", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_window_hilight },
  { "query created", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_query_created },
  { "gui exit", SIGNAL_LAST, (SIGNAL_FUNC)irssibridge_gui_exit },
  { "nicklist new", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_nicklist_new },
  { "nicklist remove", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_nicklist_remove },
  { "nicklist changed", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_nicklist_changed },
  // { "nicklist host changed", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_nicklist_host_changed },
  { "nicklist gone changed", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_nicklist_gone_changed },
  { "nicklist serverop changed", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_nicklist_serverop_changed },
  
  { "channel mode changed", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_channel_mode_changed },
  { "nick mode changed", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_nick_mode_changed },
  // { "user mode changed", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_user_mode_changed },
  // { "away mode changed", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_away_mode_changed },
  
  { "message join", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_message_join },
  { "message part", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_message_part },
  { "message quit", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_message_quit },
  { "message kick", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_message_kick },
  
  { "message public", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_message_channel },
  
  { "message irc notice", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_message_notice },
  { "message private", SIGNAL_FIRST, (SIGNAL_FUNC)irssibridge_message_private },
  
  { "channel joined", SIGNAL_LAST, (SIGNAL_FUNC)irssibridge_channel_joined },
  { "channel wholist", SIGNAL_LAST, (SIGNAL_FUNC)irssibridge_channel_wholist },
  { "channel destroyed", SIGNAL_FIRST, (SIGNAL_FUNC)irssibridge_channel_destroyed },
  
  { "event connected", SIGNAL_NORMAL, (SIGNAL_FUNC)irssibridge_event_connected },
  
  { NULL, 0, NULL }
};

static pthread_once_t globalIrssiOnce = PTHREAD_ONCE_INIT;
static IrssiCore *globalIrssiCore = nil;

@interface IrssiCore ()
- (void)_initialiseInterfaceSignals;
- (void)_destroyInterfaceSignals;
@end


@implementation IrssiCore

void initialiseCoreOnce()
{
  globalIrssiCore = [[IrssiCore alloc] init];
}

+ (id)initialiseCore
{
  pthread_once(&globalIrssiOnce, initialiseCoreOnce);
  return globalIrssiCore;
}

+ (id)sharedCore
{
  return globalIrssiCore;
}

- (id)init
{
  if (self = [super init]) {
    
  }
  return self;
}

- (void)dealloc
{
  [super dealloc];
}

- (void)runloopOneshot
{
  
}

#pragma mark Irssi Signals

- (void)_initialiseInterfaceSignals
{
  int i = 0;
  while (irssiSignals[i].signal != NULL) {
    switch (irssiSignals[i].type) {
      case SIGNAL_NORMAL:
        signal_add(irssiSignals[i].signal, irssiSignals[i].func);
        break;
      case SIGNAL_FIRST:
        signal_add_first(irssiSignals[i].signal, irssiSignals[i].func);
        break;
      case SIGNAL_LAST:
        signal_add_last(irssiSignals[i].signal, irssiSignals[i].func);
        break;
      default:
        break;
    }
    i++;
  }
}

- (void)_destroyInterfaceSignals
{
  int i = 0;
  while (irssiSignals[i].signal != NULL) {
    signal_remove(irssiSignals[i].signal, irssiSignals[i].func);
  }
}

@end
