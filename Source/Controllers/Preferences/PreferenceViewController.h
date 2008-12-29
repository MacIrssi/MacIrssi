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
#import "Protocols.h"

#import "AppController.h"
#import "EventController.h"
#import "PreferenceObjectController.h"

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
  
  /* Irssi Settings Object Controller */
  IBOutlet NSObjectController *irssiObjectController;
  PreferenceObjectController *preferenceObjectController;
  
	/* Themes tab */
	IBOutlet NSTextView *previewTextView;
	IBOutlet NSTableView *themeTableView;
	NSMutableArray *availibleThemes;
	NSTimer *previewTimer;
	
	/* Key bindings tab */
	IBOutlet NSTextField *F1Field;
	IBOutlet NSTextField *F2Field;
	IBOutlet NSTextField *F3Field;
	IBOutlet NSTextField *F4Field;
	IBOutlet NSTextField *F5Field;
	IBOutlet NSTextField *F6Field;
	IBOutlet NSTextField *F7Field;
	IBOutlet NSTextField *F8Field;
	IBOutlet NSTextField *F9Field;
	IBOutlet NSTextField *F10Field;
	IBOutlet NSTextField *F11Field;
	IBOutlet NSTextField *F12Field;
	
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
  
	AppController *appController;
  EventController *eventController;
	NSString **shortcutCommands;
	NSString *oldAddress;
	ColorSet *colorSet;
	bool colorChanged;
	id themePreviewDaemon;
}

- (id)initWithColorSet:(ColorSet *)colors appController:(AppController*)controller;

- (float)toolbarHeightForWindow:(NSWindow*)window;
- (void)switchPreferenceWindowTo:(NSWindow*)preferencePane animate:(BOOL)animate;

- (IBAction)switchChannelBar:(id)sender;
- (IBAction)changeColor:(id)sender;
- (IBAction)revertColorsToDefaults:(id)sender;
- (IBAction)saveChanges:(id)sender;
- (IBAction)cancelChanges:(id)sender;
- (IBAction)buttonChange:(id)sender;
- (IBAction)chatEventPopup:(id)sender;
- (IBAction)soundListPopUp:(id)sender;

- (void)showWindow:(id)sender;
- (void)windowDidLoad;
- (void)windowWillClose:(NSNotification *)aNotification;

- (IBAction)updateThemeList:(id)sender;
- (void)findAvailibleThemes;
- (void)registerDistributedObject;
- (void)connectToThemePreviewDaemon;
- (void)selectCurrentTheme;

- (void)updateTextEncodingPopUpButton;
- (void)initTextEncodingPopUpButton;

- (void)initChatEventsPopUpButton;
- (void)updateChatEventsPopUpButton;

- (void)initSoundListPopUpButton;
- (void)updateSoundListPopUpButton;

- (void)daemonInitiationComplete;
- (void)returnPreview:(NSAttributedString *)result;
- (void)requestPreview:(NSTimer*)theTimer;

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

#pragma mark Window

- (NSWindow*)window;
- (void)close;

#pragma mark Toolbar Delegates

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar;
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar;
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag;

@end
