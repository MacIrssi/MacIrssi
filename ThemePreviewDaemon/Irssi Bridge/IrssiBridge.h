#import <Foundation/Foundation.h>
#import "config.h"
#import "common.h"
#import "formats.h"
#import "printd.h"
#import "fe-channels.h"
#import "fe-windows.h"
#import "nicklist.h"


#include "module.h"
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
#include "ThemePreviewDaemon.h"

void irssi_bridge_set_current_theme_preview_daemon(ThemePreviewDaemon *deamon);
void irssibridge_gui_exit(void);
void irssibridge_window_created(WINDOW_REC *wind);
void irssibridge_server_disconnected(SERVER_REC *server);
void irssibridge_server_connected(SERVER_REC *server);
void irssibridge_print_text(WINDOW_REC *wind, int fg, int bg, int flags, char *text, TEXT_DEST_REC *dest_rect);
void irssibridge_print_text_finished(WINDOW_REC *wind);
