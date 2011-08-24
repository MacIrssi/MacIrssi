/*
 AppController.h
 Copyright (c) 2008, 2009 Matt Wright, 2008 Nils Hjelte.
 
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
#import "UKCrashReporter.h"
#import "Growl/Growl.h"
#import "ChannelBar.h"
#import "MISplitView.h"
#import "MIResizingTextView.h"

#import <unistd.h>
#import "glib.h"
#import "common.h"

#import "channels.h"

#import "printtext.h"
#import "common.h"
#import "themes.h"
#import "irssi.h"
#import "queries.h"
#import "servers-setup.h"
#import "channels-setup.h"
#import "servers-reconnect.h"
#import <Sparkle/Sparkle.h>

@class ChannelController;
@class EventController;
@class CustomTableView;
@class ColorSet;
@class myNetwork;

extern int argc;
extern char **argv;

#define MIChannelBarHorizontalOrientation 0
#define MIChannelBarVerticalOrientation   1

@interface AppController : NSObject <GrowlApplicationBridgeDelegate, NSSplitViewDelegate> {
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSTabView *tabView;
  
  IBOutlet NSScrollView *channelTableScrollView;
	IBOutlet CustomTableView *channelTableView;
  MISplitView *channelTableSplitView;
  IBOutlet MISplitView *tabViewTextEntrySplitView;
  
  IBOutlet NSBox *inputTextFieldBox;
	IBOutlet MIResizingTextView *inputTextField;
  
	IBOutlet NSMenuItem *_closeChannelItem;
  IBOutlet NSMenuItem *_closeWindowItem;
  
  IBOutlet NSMenu *channelMenu;
	IBOutlet NSMenu *shortcutsMenu;
  IBOutlet NSMenu *serversMenu;
	IBOutlet NSWindow *reasonWindow;
	IBOutlet NSTextField *reasonTextField;
	IBOutlet NSWindow *errorWindow;
	IBOutlet NSTextField *errorTextField;
	IBOutlet ChannelBar *channelBar;
	IBOutlet SUUpdater *updateChecker;
	
	IBOutlet NSWindow *aboutBox;
	IBOutlet NSTextField *aboutVersionLabel;
	IBOutlet NSTextView *copyrightTextView;
  
	IBOutlet NSView *joinChannelAccessoryView;
	IBOutlet NSPopUpButton *joinChannelServersPopup;
	IBOutlet NSTextField *joinChannelTextField;
	
	ChannelController *currentChannelController;
	EventController *eventController;
  
	NSMutableDictionary *highlightAttributes;
	NSString *queryObject;
	BOOL timeToQuit;
	NSMutableArray *networks;
	bool quitting;
	bool sleeping;
	NSImage *iconOnPriv;
	int hilightChannels;
	NSString **shortcutCommands;
  
  NSMutableArray *_windowsMenuItems;
  NSMutableArray *_serversMenuItems;
  IBOutlet NSMenuItem *_lastServersMenuItem;
	
	NSMutableArray *_shortcutsMenuItems;
	IBOutlet NSMenuItem *_lastShortcutsMenuItem;
	
	GSList *sleepList;
  BOOL isRestartingForUpdate;
}

#pragma mark - Menu Actions
#pragma mark -- Application Menu

- (IBAction)showAbout:(id)sender;
- (IBAction)showPreferencePanel:(id)sender;

#pragma mark -- File Menu

- (IBAction)joinChannel:(id)sender;
- (IBAction)performDisconnect:(id)sender;
- (IBAction)changeIrssiServerConsole:(id)sender;
- (IBAction)performCloseChannel:(id)sender;

#pragma mark -- Edit Menu

- (IBAction)performFind:(id)sender;
- (IBAction)performJumpToSelection:(id)sender;

#pragma mark -- Channel Menu

- (IBAction)showFontPanel:(id)sender;
- (IBAction)editCurrentChannel:(id)sender;

#pragma mark -- Shortcut Menu

- (IBAction)showShortcutsPreferences:(id)sender;
- (IBAction)performShortcut:(id)sender;

#pragma mark -- Window Menu

- (IBAction)nextChannel:(id)sender;
- (IBAction)activeChannel:(id)sender;
- (IBAction)previousChannel:(id)sender;

#pragma mark -- Help Menu

- (IBAction)showMacIrssiFAQHelp:(id)sender;
- (IBAction)showIrssiSettingsHelp:(id)sender;

#pragma mark - Invisible Actions

- (IBAction)sendCommand:(id)sender;

#pragma mark - Irssi
#pragma mark -- Bridge Calls

- (void)highlightChanged:(WINDOW_REC *)wind;
- (void)windowActivity:(WINDOW_REC *)wind oldLevel:(int)old;
- (void)setServer:(NSString *)serverName;
- (void)newTabWithWindowRec:(WINDOW_REC *)wind;
- (void)windowChanged:(WINDOW_REC *)wind withOldWind:(WINDOW_REC *)oldwind;
- (void)refnumChanged:(WINDOW_REC *)wind old:(int)old;
- (void)windowNameChanged:(WINDOW_REC*)wind;
- (void)removeTabWithWindowRec:(WINDOW_REC *)wind;
- (void)queryCreated:(QUERY_REC *)qr automatically:(int)automatic;
- (void)channelJoined:(WINDOW_REC *)rec;

#pragma mark - Menu Builders

- (void)buildServersMenu;
- (void)buildWindowsMenu;
- (void)buildShortcutsMenu;
- (void)checkAndConvertOldShortcuts;

#pragma mark -

- (WINDOW_REC *)currentWindowRec;
- (void)historyUp;
- (void)historyDown;

- (void)changeMainWindowFont:(NSFont*)font;
- (void)changeNicklistFont:(NSFont*)font;

- (void)setNicklistHidden:(BOOL)flag;

- (void)channelBarOrientationDidChange:(NSNotification*)notification;

- (void)irssiQuit;

#pragma mark - Other Actions


- (IBAction)endReasonWindow:(id)sender;
- (IBAction)endErrorWindow:(id)sender;

#pragma mark Server Change Notifications

- (void)irssiServerChangedNotification:(NSNotification*)notification;

- (SERVER_REC*)serverRecordFromServerMenu:(id)sender;

- (void)inputTextFieldColorChanged:(NSNotification *)note;
- (void)channelListColorChanged:(NSNotification *)note;
- (void)awakeFromNib;

- (void)setNotificationIcon;
- (void)setDefaultIcon;
- (void)presentUnexpectedEvent:(NSString *)description;
- (NSInteger)presentCertificateTrustPanel:(SecTrustRef)trust;

- (NSArray *)themeLocations;
- (void)loadTheme:(NSString *)theme;
- (NSArray *)splitCommand:(NSString *)command;

- (ChannelController*)currentChannelController;
- (EventController*)eventController;

/* Growl delegate */
- (NSDictionary *) registrationDictionaryForGrowl;
- (void) growlNotificationWasClicked:(id)clickContext;

/* for NSTableView's dataSource */
- (int)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;

/* for NSTableView's delegate */
- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(int)rowIndex;
- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;

/* for NSApplication's delegate */
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)app;

@end
