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

#import "AppController.h"
#import "EventController.h"

#import "PreferenceObjectController.h"
#import "ShortcutBridgeController.h"

#import "SRRecorderControl.h"

@interface PreferenceViewController : NSObject
{
	IBOutlet NSWindow *preferenceWindow;
	
  /* Preference Tabs */
  IBOutlet NSBox *preferencesWindowView;
  NSToolbar *preferencesToolbar;
  
  NSWindow *currentPreferenceTab;
  IBOutlet NSWindow *generalPreferencesTab;
  IBOutlet NSWindow *notificationsPreferencesTab;
  IBOutlet NSWindow *coloursPreferencesTab;
  IBOutlet NSWindow *networksPreferencesTab;
  IBOutlet NSWindow *serversPreferencesTab;
  IBOutlet NSWindow *themePreferencesTab;
  IBOutlet NSWindow *shortcutsPreferencesTab;
  
  /* Irssi Settings Object Controller */
  IBOutlet NSObjectController *irssiObjectController;
  PreferenceObjectController *preferenceObjectController;
	
	/* Colors tab */
  IBOutlet NSColorWell *channelBGColorWell;
  IBOutlet NSColorWell *channelFGColorWell;
  IBOutlet NSColorWell *channelListBGColorWell;
  IBOutlet NSColorWell *channelListFGNoActivityColorWell;
  IBOutlet NSColorWell *channelListFGActionColorWell;
  IBOutlet NSColorWell *channelListFGPublicMessageColorWell;
  IBOutlet NSColorWell *channelListFGPrivateMessageColorWell;
  IBOutlet NSColorWell *inputTextFieldBGColorWell;
  IBOutlet NSColorWell *inputTextFieldFGColorWell;
  IBOutlet NSColorWell *nickListBGColorWell;
  IBOutlet NSColorWell *nickListFGHalfOpColorWell;
  IBOutlet NSColorWell *nickListFGNormalColorWell;
  IBOutlet NSColorWell *nickListFGOpColorWell;
  IBOutlet NSColorWell *nickListFGServerOpColorWell;
  IBOutlet NSColorWell *nickListFGVoiceColorWell;
	
	/* Main settings tab */
	IBOutlet NSTextField *defaultNickField;
	IBOutlet NSTextField *defaultAltNickField;
	IBOutlet NSTextField *defaultUsernameField;
	IBOutlet NSTextField *defaultRealnameField;
	IBOutlet NSTextField *defaultQuitMessageField;

	IBOutlet NSButton *askQuitCheckBox;
	IBOutlet NSPopUpButton *textEncodingPopUpButton;
  
  /* Notifications tab */
  IBOutlet NSPopUpButton *chatEventPopUpButton;
  IBOutlet NSButton *playSoundButton;
  IBOutlet NSPopUpButton *soundListPopUpButton;
  IBOutlet NSButton *playSoundBackgroundButton;
  IBOutlet NSButton *bounceIconButton;
  IBOutlet NSButton *bounceIconUntilFrontButton;
  IBOutlet NSButton *growlEventButton;
  IBOutlet NSButton *growlEventBackgroundButton;
  IBOutlet NSButton *growlEventUntilFrontButton;
  
  /* Networks tab */
	IBOutlet NSArrayController *networksArrayController;
  IBOutlet NSArrayController *channelsArrayController;
  IBOutlet NSButton *addNetworkButton;
  IBOutlet NSButton *deleteNetworkButton;
  IBOutlet NSButton *addChannelButton;
  IBOutlet NSButton *deleteChannelButton;
  
  /* Channel/Networks panel */
  IBOutlet NSWindow *channetPanelWindow;
  IBOutlet NSTextField *channetPanelLabel; 
  IBOutlet NSTextField *channetPanelTextField;
  BOOL isChannetPanelNetwork;
  
  /* Servers tab */
  IBOutlet NSArrayController *serversArrayController;
  
  /* Themes tab */
  IBOutlet NSTextView *themePreviewTextView;
  IBOutlet NSArrayController *themesArrayController;
  IBOutlet NSTextField *mainWindowFontField;
  IBOutlet NSTextField *nickListFontField;
  NSMutableArray *availableThemes;
  NSMutableAttributedString *themeRenderLineBuffer;
  
  /* Shortcuts tab */
  IBOutlet NSWindow *shortcutRecorderWindow;
  IBOutlet SRRecorderControl *shortcutRecorderControl;
  
  IBOutlet NSArrayController *shortcutsArrayController;
  IBOutlet NSTableView *shortcutsTableView;
  IBOutlet NSButton *addShortcutButton;
  IBOutlet NSButton *deleteShortcutButton;
  
	AppController *appController;
  EventController *eventController;
	NSString *oldAddress;
	ColorSet *colorSet;
	bool colorChanged;
}

- (id)initWithColorSet:(ColorSet *)colors appController:(AppController*)controller;

- (float)toolbarHeightForWindow:(NSWindow*)window;
- (void)switchPreferenceWindowTo:(NSWindow*)preferencePane animate:(BOOL)animate;

- (IBAction)changeColor:(id)sender;
- (IBAction)revertColorsToDefaults:(id)sender;
- (IBAction)buttonChange:(id)sender;
- (IBAction)chatEventPopup:(id)sender;
- (IBAction)soundListPopUp:(id)sender;

- (void)showWindow:(id)sender;
- (void)windowDidLoad;
- (void)windowWillClose:(NSNotification *)aNotification;

#pragma mark Text Encodings

- (void)updateTextEncodingPopUpButton;
- (void)initTextEncodingPopUpButton;
- (IBAction)encodingPopup:(id)sender;

#pragma mark Notifications

- (void)initChatEventsPopUpButton;
- (void)updateChatEventsPopUpButton;

- (void)initSoundListPopUpButton;
- (void)updateSoundListPopUpButton;

#pragma mark Network Preference Panel

- (IBAction)addNetworkAction:(id)sender;
- (IBAction)deleteNetworkAction:(id)sender;

- (IBAction)addChannelAction:(id)sender;
- (IBAction)deleteChannelAction:(id)sender;

#pragma mark Network/Channel Panel

- (void)showChannelPanel:(id)sender;
- (void)showNetworkPanel:(id)sender;

- (IBAction)channetPanelOKAction:(id)sender;
- (IBAction)channetPanelCancelAction:(id)sender;

#pragma mark Servers Preference Panel

- (IBAction)addServerAction:(id)sender;
- (IBAction)deleteServerAction:(id)sender;

#pragma mark Appearance Preference Panel

- (void)updateMainWindowFontLabel;
- (void)updateNickFontLabel;

- (IBAction)changeMainWindowFont:(id)sender;
- (IBAction)changeNickFont:(id)sender;

- (void)findAvailableThemes;
- (IBAction)previewTheme:(id)sender;
- (void)renderPreviewTheme:(NSString*)themeName;

- (void)printTextCallback:(char*)text foreground:(int)fg background:(int)bg flags:(int)flags;
- (void)printTextFinishedCallback;

- (IBAction)switchChannelBarOrientation:(id)sender;
- (IBAction)showHideNicklist:(id)sender;

#pragma mark Shortcuts Preference Panel

- (IBAction)addShortcutAction:(id)sender;
- (IBAction)deleteShortcutAction:(id)sender;
- (IBAction)editShortcutAction:(id)sender;

#pragma mark Shortcut Recorder Panel

- (void)showShortcutRecorderPanel:(id)sender controller:(ShortcutBridgeController*)controller;
- (void)shortcutRecorderPanelDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

- (IBAction)shortcutRecorderPanelOKAction:(id)sender;
- (IBAction)shortcutRecorderPanelCancelAction:(id)sender;

- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder isKeyCode:(signed short)keyCode andFlagsTaken:(unsigned int)flags reason:(NSString **)aReason;

#pragma mark Window

- (NSWindow*)window;

#pragma mark Toolbar Delegates

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar;
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar;
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag;

@end

#pragma mark Internal C Functions

void _preferences_printformat(const char* module, TEXT_DEST_REC* dest, int formatnum, ...);
void _preferences_bridge_print_text(WINDOW_REC *wind, int fg, int bg, int flags, char *text, TEXT_DEST_REC *dest_rect);
void _preferences_bridge_print_text_finished(WINDOW_REC *wind);