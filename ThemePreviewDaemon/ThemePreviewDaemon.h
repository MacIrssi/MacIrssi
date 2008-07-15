/*
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */


#import <Cocoa/Cocoa.h>
#import "ColorSet.h"
#import "glib.h"
#import "config.h"
#import "common.h"
#import "Protocols.h"

extern BOOL tpd_quitting;

@interface ThemePreviewDaemon : NSObject <ThemePreviewDaemonProtocol> {
	GMainLoop *main_loop;
	NSMutableAttributedString *themePreview;
	NSAttributedString *newLine;
	NSMutableArray *fg_colors;
	NSMutableArray *bg_colors;
	NSColor *defaultTextColor;
	NSMutableDictionary *textAttributes;
	int serverPort;
	WINDOW_REC *windowRec;
	id prefController;
	int currentLineNumber;
	NSTask *textServerTask;
}

- (void)runIrssiMainLoop:(id)loop;

/* Irssi signals */
- (void)irssiTerminationComplete;
- (void)serverConnected:(SERVER_REC *)server;
- (void)serverDisconnected:(SERVER_REC *)server;
- (void)printText:(char *)text forground:(int)fg background:(int)bg flags:(int)flags;
- (void)finishLine;
- (void)setWindowRec:(WINDOW_REC *)rec;

/* Remote methods */
- (void)requestPreviewForThemeNamed:(in NSString *)theme usingColorSet:(in ColorSet *)set font:(NSFont *)font;
- (void)shutDown;

/* Private */
- (int)findAvailiblePort;
- (void)launchFakeIRCServer;
- (void)registerDistributedObject;
- (void)connectToMacIrssi;

@end
