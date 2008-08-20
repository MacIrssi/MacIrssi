#import <Foundation/Foundation.h>
#import "common.h"
#import "formats.h"
#import "printd.h"
#import "fe-channels.h"
#import "fe-windows.h"
#import "nicklist.h"


#include "common.h"
#include "module-formats.h"
#include "modules-load.h"
#include "args.h"
#include "signals.h"
#include "levels.h"
#include "channels.h"
#include "core.h"
#include "settings.h"
#include "session.h"
#include "servers.h"
#include "queries.h"
#include "window-items.h"
#include "irc-servers-setup.h"
#include "iconfig.h"

#undef MODULE_NAME
#define MODULE_NAME "fe-aqua"

@class AppController;
@class ChannelController;

@interface IrssiBridge : NSObject {}
+ (char *)irssiCStringWithString:(NSString *)string encoding:(CFStringEncoding)encoding;
+ (char *)irssiCStringWithString:(NSString *)string;
+ (NSString *)stringWithIrssiCString:(char *)string;
+ (NSString *)stringWithIrssiCStringNoCopy:(char *)string;
@end

void irssibridge_channel_mode_changed(CHANNEL_REC *channel, char *setby);
void irssibridge_nick_mode_changed(CHANNEL_REC *channel, NICK_REC *nick, char *setby, char *mode, char *type);
void irssibridge_user_mode_changed(SERVER_REC *server, char *old);
void irssibridge_away_mode_changed(SERVER_REC *server);

void irssibridge_server_disconnected(SERVER_REC *server);
void irssibridge_server_connected(SERVER_REC *server);

void irssibridge_event_connected(void);

void setRefToAppController(AppController *a);
void get_nicks(gpointer key, NICK_REC *rec, gpointer unused);
void irssibridge_server_setup_read(IRC_SERVER_SETUP_REC *rec, CONFIG_NODE *node);
void irssibridge_display_nicks(CHANNEL_REC *channel, int flags);
void irssibridge_print_text(WINDOW_REC *wind, int fg, int bg, int flags, char *text, TEXT_DEST_REC *dest_rect);
void irssibridge_print_text_finished(WINDOW_REC *wind);
void irssibridge_window_created(WINDOW_REC *wind);
void irssibridge_window_changed(WINDOW_REC *wind, WINDOW_REC *oldwind);
void irssibridge_window_refnum_changed(WINDOW_REC *wind, int old);
void irssibridge_window_history_changed(WINDOW_REC *wind, char *oldname);
void irssibridge_window_changed_automatic(WINDOW_REC *wind);
void irssibridge_window_destroyed(WINDOW_REC *wind);
void irssibridge_window_item_new(WINDOW_REC *wind, WI_ITEM_REC *wir);
void irssibridge_window_item_changed(WINDOW_REC *wind, WI_ITEM_REC *wir);
void irssibridge_window_name_changed(WINDOW_REC *wind);
void irssibridge_channel_topic_changed(CHANNEL_REC * chan);
void irssibridge_query_created(QUERY_REC *qr, int automatic);
void irssibridge_window_server_changed(WINDOW_REC *wind, SERVER_REC *serv);
void irssibridge_window_level_changed(WINDOW_REC *wind);
void irssibridge_window_activity(WINDOW_REC *wind, int old_level);
void irssibridge_window_hilight(WINDOW_REC *wind);
void irssibridge_gui_exit(void);
void irssibridge_nicklist_new(CHANNEL_REC *channel, NICK_REC *nick);
void irssibridge_nicklist_remove(CHANNEL_REC *channel, NICK_REC *nick);
void irssibridge_nicklist_changed(CHANNEL_REC *channel, NICK_REC *nick, char *old_nick);
void irssibridge_nicklist_host_changed(CHANNEL_REC *channel, NICK_REC *nick);
void irssibridge_nicklist_gone_changed(CHANNEL_REC *channel, NICK_REC *nick);
void irssibridge_nicklist_serverop_changed(CHANNEL_REC *channel, NICK_REC *nick);

void irssibridge_message_join(SERVER_REC *server, const char *channel, const char *nick, const char *address);
void irssibridge_message_part(SERVER_REC *server, const char *channel, const char *nick, const char *address, const char *reason);
void irssibridge_message_quit(SERVER_REC *server, const char *nick, const char *address, const char *reason);
void irssibridge_message_kick(SERVER_REC *server, const char *channel, const char *nick, const char *kicker, const char *address, const char *reason);

void irssibridge_message_channel(SERVER_REC *server, char *msg, char *nick, char *address, char *target);
void irssibridge_message_notice(SERVER_REC *server, const char *msg, const char *nick, const char *address, const char *target);
void irssibridge_message_private(SERVER_REC *server, char *msg, char *nick, char *address);

void irssibridge_channel_joined(CHANNEL_REC *channel);
void irssibridge_channel_wholist(CHANNEL_REC *channel);
void irssibridge_channel_destroyed(CHANNEL_REC *channel);