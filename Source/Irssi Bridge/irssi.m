/*
 irssi.m
 Copyright (c) 2008, 2009 Matt Wright, 
               2008 Nils Hjelte,
               1999-2000 Timo Sirainen.
 
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

#import "IrssiBridge.h"
#import "fe-common-core.h"
#import "commands.h"
#import "printtext.h"
#import "irssi-version.h"

#include "irssi.h"

#include <signal.h>
#include <locale.h>

#include "printd.h"

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

void gui_expandos_init(void);
void gui_expandos_deinit(void);

void textbuffer_commands_init(void);
void textbuffer_commands_deinit(void);

void lastlog_init(void);
void lastlog_deinit(void);

void mainwindow_activity_init(void);
void mainwindow_activity_deinit(void);

void mainwindows_layout_init(void);
void mainwindows_layout_deinit(void);

void term_dummy_init(void);
void term_dummy_deinit(void);

static int dirty, full_redraw, dummy;

//static GMainLoop *main_loop;
//int quitting;

static int display_firsttimer = FALSE;


#if 0
static void sig_exit(void)
{
        quitting = TRUE;
}
#endif

/* redraw irssi's screen.. */
void irssi_redraw(void)
{
	dirty = TRUE;
        full_redraw = TRUE;
}

void irssi_set_dirty(void)
{
        dirty = TRUE;
}

static void textui_init(void)
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

	//signal_add_last("gui exit", (SIGNAL_FUNC) sig_exit);
}

#pragma mark GLib glog
void nslog_glog_func(const char *log_domain, GLogLevelFlags log_level, const char *message)
{
	switch (log_level) {
		case G_LOG_LEVEL_WARNING:
			NSLog(@"GLog warning: %s", message);
			break;
		case G_LOG_LEVEL_CRITICAL:
			NSLog(@"GLog critical: %s", message);
			break;
		default:
			NSLog(@"GLog error: %s", message);
			break;
	}
}

static void textui_finish_init(void)
{
	//quitting = FALSE;
  signal_add("server setup read", (SIGNAL_FUNC) irssibridge_server_setup_read);

  signal_add("server disconnected", (SIGNAL_FUNC) irssibridge_server_disconnected);
  signal_add("server connected", (SIGNAL_FUNC) irssibridge_server_connected);
  signal_add("gui print text", (SIGNAL_FUNC) irssibridge_print_text);
  signal_add("gui print text finished", (SIGNAL_FUNC) irssibridge_print_text_finished);

  signal_add_last("window created", (SIGNAL_FUNC) irssibridge_window_created);
  signal_add("window destroyed", (SIGNAL_FUNC) irssibridge_window_destroyed);
  signal_add("window changed", (SIGNAL_FUNC) irssibridge_window_changed);
  signal_add("window changed automatic", (SIGNAL_FUNC) irssibridge_window_changed_automatic);
  signal_add("window server changed", (SIGNAL_FUNC) irssibridge_window_server_changed);
  signal_add("window refnum changed", (SIGNAL_FUNC) irssibridge_window_refnum_changed);
  signal_add("window name changed", (SIGNAL_FUNC) irssibridge_window_name_changed);
  //signal_add("window history changed", (SIGNAL_FUNC) irssibridge_window_history_changed);
  //signal_add("window level changed", (SIGNAL_FUNC) irssibridge_window_level_changed);

  signal_add("channel topic changed", (SIGNAL_FUNC) irssibridge_channel_topic_changed);
  //signal_add("window item new", (SIGNAL_FUNC) irssibridge_window_item_new);
  //signal_add("window item changed", (SIGNAL_FUNC) irssibridge_window_item_changed);
  signal_add("window activity", (SIGNAL_FUNC) irssibridge_window_activity);
  signal_add("window hilight", (SIGNAL_FUNC) irssibridge_window_hilight);
  signal_add("query created", (SIGNAL_FUNC) irssibridge_query_created);
  signal_add_last("gui exit", (SIGNAL_FUNC) irssibridge_gui_exit);
  signal_add("nicklist new", (SIGNAL_FUNC) irssibridge_nicklist_new);
  signal_add("nicklist remove", (SIGNAL_FUNC) irssibridge_nicklist_remove);
  signal_add("nicklist changed", (SIGNAL_FUNC) irssibridge_nicklist_changed);
  //signal_add("nicklist host changed", (SIGNAL_FUNC) irssibridge_nicklist_host_changed);
  signal_add("nicklist gone changed", (SIGNAL_FUNC) irssibridge_nicklist_gone_changed);
  signal_add("nicklist serverop changed", (SIGNAL_FUNC) irssibridge_nicklist_serverop_changed);

  signal_add("channel mode changed", (SIGNAL_FUNC) irssibridge_channel_mode_changed);
  signal_add("nick mode changed", (SIGNAL_FUNC) irssibridge_nick_mode_changed);
  //signal_add("user mode changed", (SIGNAL_FUNC) irssibridge_user_mode_changed);
  //signal_add("away mode changed", (SIGNAL_FUNC) irssibridge_away_mode_changed);

  signal_add("message join", (SIGNAL_FUNC) irssibridge_message_join);
  signal_add("message part", (SIGNAL_FUNC) irssibridge_message_part);
  signal_add("message quit", (SIGNAL_FUNC) irssibridge_message_quit);
  signal_add("message kick", (SIGNAL_FUNC) irssibridge_message_kick);
  
  signal_add("message public", (SIGNAL_FUNC) irssibridge_message_channel);
  
  signal_add("message irc notice", (SIGNAL_FUNC) irssibridge_message_notice);
  signal_add_first("message private", (SIGNAL_FUNC) irssibridge_message_private);
  
  signal_add_last("channel joined", (SIGNAL_FUNC) irssibridge_channel_joined);
  signal_add_last("channel wholist", (SIGNAL_FUNC) irssibridge_channel_wholist);
  signal_add_first("channel destroyed", (SIGNAL_FUNC) irssibridge_channel_destroyed);

  signal_add("event connected", (SIGNAL_FUNC) irssibridge_event_connected);

  module_register("core", "fe-aqua");
  
#ifdef HAVE_STATIC_PERL
	perl_core_init();
	fe_perl_init();
#endif

	fe_common_core_finish_init();
	
#if GLIB_CHECK_VERSION(2,6,0)
	g_log_set_default_handler((GLogFunc) nslog_glog_func, NULL);
#else
	g_log_set_handler(G_LOG_DOMAIN,
					  (GLogLevelFlags) (G_LOG_LEVEL_CRITICAL |
										G_LOG_LEVEL_WARNING),
					  (GLogFunc) nslog_glog_func, NULL);
	g_log_set_handler("GLib",
					  (GLogLevelFlags) (G_LOG_LEVEL_CRITICAL |
										G_LOG_LEVEL_WARNING),
					  (GLogFunc) nslog_glog_func, NULL); /* send glib errors to the same place */
#endif
	
	signal_emit("irssi init finished", 0);
}

void textui_deinit(void)
{
	signal(SIGINT, SIG_DFL);
	while (modules != NULL)
  {
		module_unload(modules->data);
  }

#ifdef HAVE_STATIC_PERL
  perl_core_deinit();
  fe_perl_deinit();
#endif

  //signal_remove("gui exit", (SIGNAL_FUNC) sig_exit);

  signal_remove("server setup read", (SIGNAL_FUNC) irssibridge_server_setup_read);

  /* Whooohaa */
  signal_remove("server disconnected", (SIGNAL_FUNC) irssibridge_server_disconnected);
  signal_remove("server connected", (SIGNAL_FUNC) irssibridge_server_connected);
  signal_remove("gui print text", (SIGNAL_FUNC) irssibridge_print_text);
  signal_remove("gui print text finished", (SIGNAL_FUNC) irssibridge_print_text_finished);

  signal_remove("window created", (SIGNAL_FUNC) irssibridge_window_created);
  signal_remove("window destroyed", (SIGNAL_FUNC) irssibridge_window_destroyed);
  signal_remove("window changed", (SIGNAL_FUNC) irssibridge_window_changed);
  signal_remove("window changed automatic", (SIGNAL_FUNC) irssibridge_window_changed_automatic);
  signal_remove("window server changed", (SIGNAL_FUNC) irssibridge_window_server_changed);
  signal_remove("window refnum changed", (SIGNAL_FUNC) irssibridge_window_refnum_changed);
  signal_remove("window name changed", (SIGNAL_FUNC) irssibridge_window_name_changed);
  //signal_add("window history changed", (SIGNAL_FUNC) irssibridge_window_history_changed);
  //signal_add("window level changed", (SIGNAL_FUNC) irssibridge_window_level_changed);

  signal_remove("channel topic changed", (SIGNAL_FUNC) irssibridge_channel_topic_changed);
  //signal_add("window item new", (SIGNAL_FUNC) irssibridge_window_item_new);
  //signal_add("window item changed", (SIGNAL_FUNC) irssibridge_window_item_changed);
  signal_remove("window activity", (SIGNAL_FUNC) irssibridge_window_activity);
  signal_remove("window hilight", (SIGNAL_FUNC) irssibridge_window_hilight);
  signal_remove("query created", (SIGNAL_FUNC) irssibridge_query_created);
  signal_remove("gui exit", (SIGNAL_FUNC) irssibridge_gui_exit);
  signal_remove("nicklist new", (SIGNAL_FUNC) irssibridge_nicklist_new);
  signal_remove("nicklist remove", (SIGNAL_FUNC) irssibridge_nicklist_remove);
  signal_remove("nicklist changed", (SIGNAL_FUNC) irssibridge_nicklist_changed);
  //signal_add("nicklist host changed", (SIGNAL_FUNC) irssibridge_nicklist_host_changed);
  signal_remove("nicklist gone changed", (SIGNAL_FUNC) irssibridge_nicklist_gone_changed);
  signal_remove("nicklist serverop changed", (SIGNAL_FUNC) irssibridge_nicklist_serverop_changed);

  signal_remove("channel mode changed", (SIGNAL_FUNC) irssibridge_channel_mode_changed);
  signal_remove("nick mode changed", (SIGNAL_FUNC) irssibridge_nick_mode_changed);
  //signal_add("user mode changed", (SIGNAL_FUNC) irssibridge_user_mode_changed);
  //signal_add("away mode changed", (SIGNAL_FUNC) irssibridge_away_mode_changed);

  signal_remove("message join", (SIGNAL_FUNC) irssibridge_message_join);
  signal_remove("message part", (SIGNAL_FUNC) irssibridge_message_part);
  signal_remove("message quit", (SIGNAL_FUNC) irssibridge_message_quit);
  signal_remove("message kick", (SIGNAL_FUNC) irssibridge_message_kick);
  
  signal_remove("message public", (SIGNAL_FUNC) irssibridge_message_channel);
  
  signal_remove("message irc notice", (SIGNAL_FUNC) irssibridge_message_notice);
  signal_remove("message private", (SIGNAL_FUNC) irssibridge_message_private);
  
  signal_remove("channel joined", (SIGNAL_FUNC) irssibridge_channel_joined);
  signal_remove("channel wholist", (SIGNAL_FUNC) irssibridge_channel_wholist);
  signal_remove("channel destroyed", (SIGNAL_FUNC) irssibridge_channel_destroyed);

  signal_remove("event connected", (SIGNAL_FUNC) irssibridge_event_connected);
  /*end whhohahaa */
		
	//signal_remove("gui print text", (SIGNAL_FUNC) irssibridge_print_text);
	//signal_remove("gui print text finished", (SIGNAL_FUNC) irssibridge_print_text_finished);
	fe_common_irc_deinit();
	fe_common_core_deinit();
	irc_deinit();
	core_deinit();
}

static void check_oldcrap(void)
{
        FILE *f;
	char *path, str[256];
        int found;

        /* check that default.theme is up-to-date */
	path = g_strdup_printf("%s/default.theme", get_irssi_dir());
	f = fopen(path, "r+");
	if (f == NULL) {
		g_free(path);
                return;
	}
        found = FALSE;
	while (!found && fgets(str, sizeof(str), f) != NULL)
                found = strstr(str, "abstracts = ") != NULL;
	fclose(f);

	if (found) {
		g_free(path);
		return;
	}

	printf("\nYou seem to have old default.theme in %s/ directory.\n", get_irssi_dir());
        printf("Themeing system has changed a bit since last irssi release,\n");
        printf("you should either delete your old default.theme or manually\n");
        printf("merge it with the new default.theme.\n\n");
	printf("Do you want to delete the old theme now? (Y/n)\n");

	str[0] = '\0';
	fgets(str, sizeof(str), stdin);
	if (i_toupper(str[0]) == 'Y' || str[0] == '\n' || str[0] == '\0')
                remove(path);
	g_free(path);
}

static void check_files(void)
{
	struct stat statbuf;

	if (stat(get_irssi_dir(), &statbuf) != 0) {
		/* ~/.irssi doesn't exist, first time running irssi */
		display_firsttimer = TRUE;
	} else {
                check_oldcrap();
	}
}

static void perl_cmd_override(const char *data, SERVER_REC *server, void *item)
{
  printtext(NULL, NULL, MSGLEVEL_CLIENTERROR, "Perl scripts are only supported on this platform while running Mac OS X 10.5.");
  signal_stop();
}

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

int irssi_main(int argc, char **argv)
{
  GOptionEntry options[] = {
    { NULL }
  };

	dummy = FALSE;
	//quitting = FALSE;
	
	core_register_options();
	fe_common_core_register_options();
	
	args_register(options);
	args_execute(argc, argv);
	
	core_preinit(argv[0]);
	
	check_files();
	
#ifdef HAVE_SOCKS
	SOCKSinit(argv[0]);
#endif
#ifdef ENABLE_NLS
	/* initialize the i18n stuff */
	bindtextdomain(PACKAGE, LOCALEDIR);
	textdomain(PACKAGE);
#endif

	/* setlocale() must be called at the beginning before any calls that
	   affect it, especially regexps seem to break if they're generated
	   before t his call.

	   locales aren't actually used for anything else than autodetection
	   of UTF-8 currently.. */
	setlocale(LC_CTYPE, "");
	
	textui_init();
	
	char *bundleStr = [IrssiBridge irssiCStringWithString:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Scripts"]];
  settings_add_str("perl", "macirssi_lib", bundleStr);
  free(bundleStr);
	
	textui_finish_init();

  long systemVersion;
  Gestalt(gestaltSystemVersion, &systemVersion);
  
  int majorVersion, minorVerson;
  majorVersion = (((systemVersion & 0xF000) >> 12) * 10) + ((systemVersion & 0x0F00) >> 8);
  minorVerson = ((systemVersion & 0x00F0) >> 4);
  
  // FIXME: We never unregister this
  if (!( majorVersion == 10 && minorVerson == 6 ))
  {
    printtext(NULL, NULL, MSGLEVEL_CLIENTERROR, "Not loading perl modules, perl is only supported on Mac OS X 10.6 (Snow Leopard).");
    command_bind_first("script", NULL, (SIGNAL_FUNC)perl_cmd_override);
  }
  else {
    // if we're on the platform we built on. Try loading the perl libraries.
    signal_emit("command load", 1, "perl");
  }

	// Version Overwrite
  command_bind_first("version", NULL, (SIGNAL_FUNC)version_cmd_overwrite);
  SETTINGS_REC *rec = settings_get_record("ctcp_version_reply");
  g_free(rec->default_value.v_string);
  rec->default_value.v_string = g_strdup([[NSString stringWithFormat:@"MacIrssi %@ (Core: "PACKAGE_TARNAME" "PACKAGE_VERSION")", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]] cStringUsingEncoding:NSASCIIStringEncoding]);
  signal_emit("command alias", 1, [[NSString stringWithFormat:@"sv say MacIrssi %@ (Core: "PACKAGE_TARNAME" "PACKAGE_VERSION") - http://www.sysctl.co.uk/projects/macirssi/", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]] cStringUsingEncoding:NSASCIIStringEncoding]);
	
	/* Does the same as g_main_run(main_loop), except we
	   can call our dirty-checker after each iteration */
  return 0;
}

int irssi_exit()
{
  long systemVersion;
  Gestalt(gestaltSystemVersion, &systemVersion);
  
  int majorVersion, minorVerson;
  majorVersion = (((systemVersion & 0xF000) >> 12) * 10) + ((systemVersion & 0x0F00) >> 8);
  minorVerson = ((systemVersion & 0x00F0) >> 4);
  
  if (!( majorVersion == 10 && minorVerson == 6 ))
  {
    command_unbind("script", (SIGNAL_FUNC)perl_cmd_override);
  }
  command_unbind("version", (SIGNAL_FUNC)version_cmd_overwrite);
  
  return 0;
}
