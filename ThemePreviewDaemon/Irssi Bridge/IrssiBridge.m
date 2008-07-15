#include "IrssiBridge.h"

static ThemePreviewDaemon *currentDaemon;

void irssi_bridge_set_current_theme_preview_daemon(ThemePreviewDaemon *deamon)
{
	currentDaemon = deamon;
}

void irssibridge_window_created(WINDOW_REC *wind)
{
	[currentDaemon setWindowRec:wind];
}

void irssibridge_server_disconnected(SERVER_REC *server)
{
	[currentDaemon serverDisconnected:server];
}

void irssibridge_server_connected(SERVER_REC *server)
{
	[currentDaemon serverConnected:server];
}

void irssibridge_print_text(WINDOW_REC *wind, int fg, int bg, int flags, char *text, TEXT_DEST_REC *dest_rect)
{
	[currentDaemon printText:text forground:fg background:bg flags:flags];
}

void irssibridge_print_text_finished(WINDOW_REC *wind)
{
	[currentDaemon finishLine];
}

void irssibridge_gui_exit(void)
{
	[currentDaemon irssiTerminationComplete];
}