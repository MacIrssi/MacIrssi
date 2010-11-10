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

#import "glib.h"
#import "commands.h"
#import "printtext.h"
#import "irssi-version.h"
#import "fe-common-core.h"

#define IRSSI_GUI_AQUA 6

#ifdef HAVE_STATIC_PERL
void perl_core_init(void);
void perl_core_deinit(void);

void fe_perl_init(void);
void fe_perl_deinit(void);
#endif

void irc_init(void);
void irc_deinit(void);

void fe_common_irc_init(void);
void fe_common_irc_deinit(void);

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

static void version_cmd_overwrite(const char *data, SERVER_REC *server, void *item)
{
	char time[10];
	
	g_return_if_fail(data != NULL);
	
	if (*data == '\0') {
		
		g_snprintf(time, sizeof(time), "%04d", IRSSI_VERSION_TIME);
    printtext(NULL, NULL, MSGLEVEL_CLIENTNOTICE,
              "Client: MacIrssi %s (Core:"PACKAGE_TARNAME" " PACKAGE_VERSION" %d %s)",
              [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] cStringUsingEncoding:NSASCIIStringEncoding],
              IRSSI_VERSION_DATE, time);
	}
	signal_stop();
}

// caller assumes need for release
char* macirssi_find_theme(const char* theme, void* context)
{
  IrssiCore *core = (IrssiCore*)context;
  
  NSString *themeName = [NSString stringWithCString:theme encoding:NSUTF8StringEncoding];
  NSString *res = [core findThemeByName:themeName];
  
  if (res) {
    return strdup([res cStringUsingEncoding:NSUTF8StringEncoding]);
  }
  return NULL;
}

static pthread_once_t globalIrssiOnce = PTHREAD_ONCE_INIT;
static IrssiCore *globalIrssiCore = nil;

@interface IrssiCore ()
- (void)_initialiseInterfaceSignals;
- (void)_destroyInterfaceSignals;
- (void)_overrideVersionInformation;
- (void)_unregisterVersionInformation;

- (void)_initialiseUI;
- (void)_destroyUI;

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

+ (void)deinitialiseCore
{
  // This needs to happen prescisely once, at the close of MI
  [globalIrssiCore release];
  globalIrssiCore = nil;
}

+ (id)sharedCore
{
  return globalIrssiCore;
}

- (id)init
{
  if (self = [super init]) {
    GOptionEntry options[] = {
      { NULL }
    };
    
#ifdef MACIRSSI_DEBUG
    char *irssi_argv[] = {"irssi", "--config=~/.irssi/config_debug", NULL};
    int irssi_argc = 2;
#else
    char *irssi_argv[] = { "irssi", NULL };
    int irssi_argc = 1;
#endif    
    
    core_register_options();
    fe_common_core_register_options();
    
    args_register(options);
    args_execute(irssi_argc, irssi_argv);
    
    core_preinit(irssi_argv[0]);
    
    setlocale(LC_CTYPE, "");
    
    theme_macirssi_set_callback(macirssi_find_theme, self);
    
    [self _initialiseUI];
    [self _overrideVersionInformation];
    
    glibRunloop = g_main_loop_new(NULL, TRUE);
  }
  return self;
}

- (void)dealloc
{
  g_main_loop_unref(glibRunloop);
  [self _unregisterVersionInformation];
  [self _destroyInterfaceSignals];
  [self _destroyUI];
  [super dealloc];
}

- (void)runloopOneshot
{
  g_main_context_iteration(NULL, FALSE);
}

#pragma mark GLib Logging

void glib_log_NSLog(const char *domain, GLogLevelFlags level, const char *message, void* userdata)
{
  switch (level) {
    case G_LOG_LEVEL_WARNING:
      NSLog(@"glib: WARNING: %s", message);
      break;
    case G_LOG_LEVEL_CRITICAL:
      NSLog(@"glib: CRITICAL: %s", message);
      break;
    default:
      NSLog(@"glib: %s", message);
      break;
  }
}

#pragma mark Irssi Bringup/Teardown

- (void)_initialiseUI
{
#ifdef SIGTRAP
  struct sigaction act;
  sigemptyset(&act.sa_mask);
  act.sa_flags = 0;
  act.sa_handler = SIG_IGN;
  sigaction(SIGTRAP, &act, NULL);
#endif
  
  irssi_gui = IRSSI_GUI_AQUA;
  core_init();
  irc_init();
  fe_common_core_init();
  fe_common_irc_init();
  
  NSString *bundle = [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"Scripts"];
  settings_add_str("perl", "macirssi_lib", [bundle cStringUsingEncoding:NSUTF8StringEncoding]);
  
  [self _initialiseInterfaceSignals];
  
  module_register("core", "fe-aqua");
  
#ifdef HAVE_STATIC_PERL
  perl_core_init();
  fe_perl_init();
#endif
  
  fe_common_core_finish_init();
  
  /* Used to guard this with an #ifdef, but I control the fate of glib in MI */
  g_log_set_default_handler(glib_log_NSLog, NULL);

  signal_emit("irssi init finished", 0);
}

- (void)_destroyUI
{
  signal(SIGINT, SIG_DFL);
  while (modules != NULL) {
    module_unload(modules->data);
  }
  
#ifdef HAVE_STATIC_PERL
  perl_core_deinit();
  fe_perl_deinit();
#endif
  
  [self _destroyInterfaceSignals];
  
  fe_common_irc_deinit();
  fe_common_core_deinit();
  irc_deinit();
  core_deinit();
}

- (void)_overrideVersionInformation
{
  command_bind_first("version", NULL, (SIGNAL_FUNC)version_cmd_overwrite);
  
  SETTINGS_REC *rec = settings_get_record("ctcp_version_reply");
  g_free(rec->default_value.v_string);
  
  NSString *ctcpVersion = [NSString stringWithFormat:@"MacIrssi %@ (Core: "PACKAGE_TARNAME" "PACKAGE_VERSION")", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
  rec->default_value.v_string = g_strdup([ctcpVersion cStringUsingEncoding:NSUTF8StringEncoding]);
  
  NSString *sayVersion = [NSString stringWithFormat:@"sv say %@ - http://www.sysctl.co.uk/projects/macirssi/", ctcpVersion];
  signal_emit("command alias", 1, [sayVersion cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (void)_unregisterVersionInformation
{
  command_unbind("version", (SIGNAL_FUNC)version_cmd_overwrite);
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
    i++;
  }
}

#pragma mark Themes

- (NSString*)findThemeByName:(NSString*)name
{
  NSBundle *bundle = [NSBundle mainBundle];
  NSString *resource = [bundle pathForResource:name ofType:@"theme" inDirectory:@"Themes"];
  return resource;
}

@end
