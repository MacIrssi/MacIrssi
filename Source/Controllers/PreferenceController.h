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
#import "Protocols.h"

@interface PreferenceController : NSWindowController <ThemePreviewClientProtocol>
{
	IBOutlet NSWindow *preferenceWindow;
	
  /* Preference Tabs */
  IBOutlet NSBox *preferencesWindowView;
  IBOutlet NSWindow *generalPreferencesTab;
  
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
	
	AppController *appController;
  EventController *eventController;
	NSString **shortcutCommands;
	NSString *oldAddress;
	ColorSet *colorSet;
	bool colorChanged;
	id themePreviewDaemon;
}

- (float)toolbarHeightForWindow:(NSWindow*)window;
- (void)switchPreferenceWindowTo:(NSWindow*)preferencePane animate:(BOOL)animate;

- (IBAction)swithChannelBar:(id)sender;
- (IBAction)changeColor:(id)sender;
- (IBAction)revertColorsToDefaults:(id)sender;
- (IBAction)saveChanges:(id)sender;
- (IBAction)cancelChanges:(id)sender;
- (IBAction)buttonChange:(id)sender;
- (IBAction)chatEventPopup:(id)sender;
- (IBAction)soundListPopUp:(id)sender;

- (void)saveColorChanges;
- (void)cancelColorChanges;
- (void)showWindow:(id)sender;
- (void)windowDidLoad;
- (void)updateColorWells;
- (id)initWithColorSet:(ColorSet *)colors;
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

@end
