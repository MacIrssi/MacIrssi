/*
 PreferenceViewController.m
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

//*****************************************************************
// MacIrssi - PreferenceController
// Nils Hjelte, c01nhe@cs.umu.se
//
// Controls the preference panel
//*****************************************************************

#import "PreferenceViewController.h"
#import "NSAttributedStringAdditions.h"
#import "IrssiBridge.h"
#import <Foundation/Foundation.h>
#import "settings.h"
#import "common.h"
#import "signals.h"
#include <unistd.h>
#include "themes.h"
#import "TextEncodings.h"

#import "AIMenuAdditions.h"
#import "NSString+Additions.h"

@interface NSFontManager (StupidHeaderFixes)

- (void)setTarget:(id)target;

@end

@implementation PreferenceViewController

//-------------------------------------------------------------------
// initWithColorSet:
// Initializer for this class
//
// "colors" - The colorset to use
//
// Returns: self
//-------------------------------------------------------------------
- (id)initWithColorSet:(ColorSet *)colors appController:(AppController*)controller
{
  if (self = [super init])
  {
    if (![NSBundle loadNibNamed:@"Preferences" owner:self])
    {
      [self release];
      return nil;
    }
    
    // We want to receive window{Did,Will}*: messages
    [preferenceWindow setDelegate:self];
    
    // Allocate a preference proxy controller and assign it to the bindings controllers
    preferenceObjectController = [[PreferenceObjectController alloc] init];
    [irssiObjectController setContent:preferenceObjectController];
    [networksArrayController setContent:[preferenceObjectController chatnetArray]];
    [serversArrayController setContent:[preferenceObjectController serverArray]];
    [shortcutsArrayController setContent:[preferenceObjectController shortcutArray]];
    
    // Shortcuts tableview needs a doubleAction
    [shortcutsTableView setDoubleAction:@selector(editShortcutAction:)];
    [shortcutsTableView setTarget:self];
    
    // We need to setup the shortcut recorder properly
    [shortcutRecorderControl setDelegate:self];
    
    // defaults for appearances
    [themePreviewTextView setContinuousSpellCheckingEnabled:NO];
    [mainWindowFontField setShowFontFace:YES];
    [mainWindowFontField setShowPointSize:YES];
    [nickListFontField setShowFontFace:YES];
    [nickListFontField setShowPointSize:YES];
    
    // Some things we need to bind to preferences I can't do in IB
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
    
    colorSet = colors;
    availableThemes = [[NSMutableArray alloc] init];
    appController = controller;
    eventController = [appController eventController];
    
    [themePreviewTextView setBackgroundColor:[ColorSet channelBackgroundColor]];
    
    [self initTextEncodingPopUpButton];
    [self initTabShortcutPopUpButton];
    [self initChatEventsPopUpButton];
    [self initSoundListPopUpButton];
    
    [[NSColorPanel sharedColorPanel] setShowsAlpha:TRUE];
    [[NSColorPanel sharedColorPanel] setContinuous:TRUE];  
  }
	return self;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
  [irssiObjectController setContent:nil];
  [networksArrayController setContent:nil];
  [serversArrayController setContent:nil];
  [themesArrayController setContent:nil];
  [preferenceObjectController release];
  
  [availableThemes release];
  [super dealloc];
}

#pragma mark Window Functions

- (void)switchPreferenceWindowTo:(NSWindow*)preferencePane animate:(BOOL)animate
{
  if (currentPreferenceTab)
  {
    NSView *oldView = [[preferencesWindowView contentView] retain];
    [oldView removeFromSuperview];
    [currentPreferenceTab setContentView:oldView];
    [oldView release];
  }
  
  currentPreferenceTab = preferencePane;
  NSView *paneView = [preferencePane contentView];
  NSRect newWindowFrame;
  
  newWindowFrame.origin.x = [preferenceWindow frame].origin.x;
  newWindowFrame.origin.y = [preferenceWindow frame].origin.y;
  newWindowFrame.size.width = [paneView bounds].size.width + 40;
  newWindowFrame.size.height = [paneView bounds].size.height + [self toolbarHeightForWindow:preferenceWindow] + 62;
  
  newWindowFrame.origin.y += [preferenceWindow frame].size.height - newWindowFrame.size.height;
  
  [preferenceWindow setFrame:newWindowFrame display:YES animate:animate];
  [preferencesWindowView setContentView:paneView];
  
  [preferenceWindow setTitle:[preferencePane title]];
}

//-------------------------------------------------------------------
// showWindow
// Updates the preference panel to reflect current settings
//-------------------------------------------------------------------
- (void)showWindow:(id)sender
{
  preferencesToolbar = [[NSToolbar alloc] initWithIdentifier:@"MacIrssiPreferences"];
  [preferencesToolbar setDelegate:self];
  [preferenceWindow setToolbar:preferencesToolbar];
  
	colorChanged = FALSE;
  
  // Allocate a preference proxy controller and assign it to the bindings controllers
  if (preferenceObjectController)
  {
    [preferenceObjectController release];
    preferenceObjectController = nil;
  }
  
  preferenceObjectController = [[PreferenceObjectController alloc] init];
  [irssiObjectController setContent:preferenceObjectController];
  [networksArrayController setContent:[preferenceObjectController chatnetArray]];
  [serversArrayController setContent:[preferenceObjectController serverArray]];
  [shortcutsArrayController setContent:[preferenceObjectController shortcutArray]];
  
  /* By default open the general tab and resize the window around it */
  [self switchPreferenceWindowTo:generalPreferencesTab animate:NO];
  [preferencesToolbar setSelectedItemIdentifier:@"General"];
	
  /* General */
	[self updateTextEncodingPopUpButton];
  [self updateTabShortcutPopUpButton];
  
  /* Notifications */
  [self updateSoundListPopUpButton];
  [self updateChatEventsPopUpButton];

  /* Themes */
  [self updateMainWindowFontLabel];
  [self updateNickFontLabel];
  [self findAvailableThemes];
  [themesArrayController setSelectedObjects:[NSArray arrayWithObjects:[preferenceObjectController theme], nil]];
  [self previewTheme:self];
  
  [preferenceWindow makeKeyAndOrderFront:self];
  [preferenceWindow center];
}

//-------------------------------------------------------------------
// windowWillClose
// Closes the color panel and floater when preference panel is closed
//-------------------------------------------------------------------
- (void)windowWillClose:(NSNotification *)aNotification
{
	if ([[NSColorPanel sharedColorPanel] isVisible])
  {
    [[NSColorPanel sharedColorPanel] close];
  }
}

//-------------------------------------------------------------------
// windowDidLoad
// Updates the preference panel to reflect current settings
//-------------------------------------------------------------------
- (void)windowDidLoad
{
  NSLog(@"Fart");
	
	[self initTextEncodingPopUpButton];
  [self initChatEventsPopUpButton];
  [self initSoundListPopUpButton];
  
	[preferenceWindow setOpaque:FALSE];
  
  [self chatEventPopup:self];
}

- (float)toolbarHeightForWindow:(NSWindow*)window
{
  NSToolbar *bar;
  float toolbarHeight = 0.0;
  NSRect windowFrame;
  
  bar = [window toolbar];
  
  if(bar && [bar isVisible])
  {
    windowFrame = [NSWindow contentRectForFrameRect:[window frame]
                                          styleMask:[window styleMask]];
    toolbarHeight = NSHeight(windowFrame)
    - NSHeight([[window contentView] frame]);
  }
  
  return toolbarHeight;
}

- (void)userDefaultsChanged:(NSNotification*)notification
{
  [themePreviewTextView setShouldAntialias:[[NSUserDefaults standardUserDefaults] boolForKey:@"antiAliasFonts"]];
}

#pragma mark Channel Bar

//-------------------------------------------------------------------
// revertColorsToDefaults:
// Changes colors back to defaults
//-------------------------------------------------------------------
- (IBAction)revertColorsToDefaults:(id)sender
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [ColorSet revertToDefaults];
  
	[nc postNotificationName:@"channelColorChanged" object:nil];
	[nc postNotificationName:@"channelListColorChanged" object:nil];
	[nc postNotificationName:@"nickListColorChanged" object:nil];
	[nc postNotificationName:@"inputTextFieldColorChanged" object:nil];
}

#pragma mark Text Encodings

/**
 * Inserts all text encodings into the text encoding popup button
 */
- (void)initTextEncodingPopUpButton
{
  [textEncodingPopUpButton removeAllItems];
  
  NSArray *encodings = [MITextEncoding encodings];
  NSEnumerator *encodingsEnumerator = [encodings objectEnumerator];
  MITextEncoding *enc;
  
  while (enc = [encodingsEnumerator nextObject])
  {
    NSMenuItem *item = [[textEncodingPopUpButton menu] addItemWithTitle:[enc name] action:nil keyEquivalent:@""];
    [item setRepresentedObject:enc];
    [item setTag:[enc CFStringEncoding]];
  }
}

/**
 * Updates text encoding popup button with current settings.
 */
- (void)updateTextEncodingPopUpButton
{
  NSStringEncoding textEncoding = [[MITextEncoding irssiEncoding] CFStringEncoding];
  [textEncodingPopUpButton selectItemWithTag:textEncoding];
  [textEncodingPopUpButton setNeedsDisplay:YES];
}

- (IBAction)encodingPopup:(id)sender
{
  NSMenuItem *selectedItem = [textEncodingPopUpButton selectedItem];
  MITextEncoding *enc = [selectedItem representedObject];
  [MITextEncoding setIrssiEncoding:enc];
}

#pragma mark Tab Shortcuts

- (void)initTabShortcutPopUpButton
{
  [tabShortcutPopUpButton removeAllItems];
  
  
  NSString *upLeftArrow = ( [[NSUserDefaults standardUserDefaults] integerForKey:@"channelBarOrientation"] == MIChannelBarHorizontalOrientation ) ? SRChar(KeyboardLeftArrowGlyph) : SRChar(KeyboardUpArrowGlyph);
  NSString *downRightArrow = ( [[NSUserDefaults standardUserDefaults] integerForKey:@"channelBarOrientation"] == MIChannelBarHorizontalOrientation ) ? SRChar(KeyboardRightArrowGlyph) : SRChar(KeyboardDownArrowGlyph);
  
  // Arrows, so Apple+left/right (or up/down, all the arrow based ones will switch if you change orientation)
  NSMenu *menu = [[[NSMenu allocWithZone:[NSMenu menuZone]] init] autorelease];;
  [menu addItemWithTitle:[NSString stringWithFormat:@"Arrows (%@%@ and %@%@)", SRChar(KeyboardCommandGlyph), upLeftArrow, SRChar(KeyboardCommandGlyph), downRightArrow]
                  target:nil
                  action:nil 
           keyEquivalent:@""
                     tag:TabShortcutArrows];
  [menu addItemWithTitle:[NSString stringWithFormat:@"Shift-Arrows (%@%@%@ and %@%@%@)", SRChar(KeyboardShiftGlyph), SRChar(KeyboardCommandGlyph), upLeftArrow, SRChar(KeyboardShiftGlyph), SRChar(KeyboardCommandGlyph), downRightArrow]
                  target:nil
                  action:nil
           keyEquivalent:@""
                     tag:TabShortcutShiftArrows];
  [menu addItemWithTitle:[NSString stringWithFormat:@"Option-Arrows (%@%@%@ and %@%@%@)", SRChar(KeyboardOptionGlyph), SRChar(KeyboardCommandGlyph), upLeftArrow, SRChar(KeyboardOptionGlyph), SRChar(KeyboardCommandGlyph), downRightArrow]
                  target:nil
                  action:nil
           keyEquivalent:@"" 
                     tag:TabShortcutOptionArrows];
  [menu addItemWithTitle:[NSString stringWithFormat:@"Brackets (%@%@ and %@%@)", SRChar(KeyboardCommandGlyph), @"[", SRChar(KeyboardCommandGlyph), @"]"]
                  target:nil
                  action:nil
           keyEquivalent:@"" 
                     tag:TabShortcutBrackets];
  [menu addItemWithTitle:[NSString stringWithFormat:@"Curly-Bracers (%@%@ and %@%@)", SRChar(KeyboardCommandGlyph), @"{", SRChar(KeyboardCommandGlyph), @"}"]
                  target:nil
                  action:nil
           keyEquivalent:@"" 
                     tag:TabShortcutBraces];
  
  [tabShortcutPopUpButton setMenu:menu];
}

- (void)updateTabShortcutPopUpButton
{
  [tabShortcutPopUpButton selectItemWithTag:[[NSUserDefaults standardUserDefaults] integerForKey:@"tabShortcuts"]];
}

- (IBAction)tabShortcutPopUpAction:(id)sender
{
  [[NSUserDefaults standardUserDefaults] setInteger:[tabShortcutPopUpButton selectedTag] forKey:@"tabShortcuts"];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"channelBarOrientationDidChange" object:self];
}

#pragma mark Chat Notifications

- (void)initChatEventsPopUpButton
{
  [chatEventPopUpButton removeAllItems];
  NSArray *events = [eventController availableEvents];
  NSEnumerator *eventEnumerator = [events objectEnumerator];
  NSString *event;
  
  while ((event = [eventEnumerator nextObject]) != nil)
  {
    NSString *eventName = [eventController eventNameForCode:event];
    if ([eventName isEqual:@""])
    {
      [[chatEventPopUpButton menu] addItem:[NSMenuItem separatorItem]];
    }
    else
    {
      [chatEventPopUpButton addItemWithTitle:eventName];  
    }
  }
}

- (void)updateChatEventsPopUpButton
{  
  [self chatEventPopup:self];
}

- (void)initSoundListPopUpButton
{
  [soundListPopUpButton removeAllItems];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
  NSString *lib, *file;
  
  NSDirectoryEnumerator *dirEnumerator = [fileManager enumeratorAtPath:[resourcePath stringByAppendingPathComponent:@"Sounds"]];
  while (file = [dirEnumerator nextObject])
  {
    NSMenuItem *item = [[NSMenuItem alloc] init];
    [item setTitle:[file stringByDeletingPathExtension]];
    [item setImage:[NSImage imageNamed:@"sound"]]; 
    [[soundListPopUpButton menu] addItem:[item autorelease]];
  }
  
  [[soundListPopUpButton menu] addItem:[NSMenuItem separatorItem]];
  
  NSArray *pathsToLibraries = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSAllDomainsMask, YES);
  NSEnumerator *libraryEnumerator = [pathsToLibraries objectEnumerator];

  while (lib = [libraryEnumerator nextObject]) {
    NSString *path = [NSString pathWithComponents:[NSArray arrayWithObjects:lib, @"Sounds", nil]];
    
    dirEnumerator = [fileManager enumeratorAtPath:path];
    while (file = [dirEnumerator nextObject])
    {
      NSMenuItem *item = [[NSMenuItem alloc] init];
      [item setTitle:[file stringByDeletingPathExtension]];
      [item setImage:[NSImage imageNamed:@"sound"]]; 
      [[soundListPopUpButton menu] addItem:[item autorelease]];
    }
    
  }
  
}

- (void)updateSoundListPopUpButton
{
  NSString *event = [eventController eventCodeForName:[[chatEventPopUpButton selectedItem] title]];
  [soundListPopUpButton selectItemWithTitle:[eventController stringForEvent:event alert:@"playSoundSound"]];
}

- (IBAction)chatEventPopup:(id)sender
{
  NSString *eventCode = [eventController eventCodeForName:[[chatEventPopUpButton selectedItem] title]];
  
  [soundListPopUpButton selectItemAtIndex:0];
  
  [playSoundButton setState:[eventController boolForEvent:eventCode alert:@"playSound"]];
  [playSoundBackgroundButton setState:[eventController boolForEvent:eventCode alert:@"playSoundBackground"]];
  if ([eventController stringForEvent:eventCode alert:@"playSoundSound"])
  {
    [soundListPopUpButton selectItemWithTitle:[eventController stringForEvent:eventCode alert:@"playSoundSound"]];
  }
  [bounceIconButton setState:[eventController boolForEvent:eventCode alert:@"bounceIcon"]];
  [bounceIconUntilFrontButton setState:[eventController boolForEvent:eventCode alert:@"bounceIconUntilFront"]];
  [bounceShowCountOnDock setState:[eventController boolForEvent:eventCode alert:@"bounceShowCountOnDock"]];
  [growlEventButton setState:[eventController boolForEvent:eventCode alert:@"growlEvent"]];
  [growlEventBackgroundButton setState:[eventController boolForEvent:eventCode alert:@"growlEventBackground"]];
  [growlEventUntilFrontButton setState:[eventController boolForEvent:eventCode alert:@"growlEventUntilFront"]];
  
  [self notificationButtonChanged:sender];
}

- (IBAction)soundListPopUp:(id)sender
{
  NSString *event = [eventController eventCodeForName:[[chatEventPopUpButton selectedItem] title]];
  NSSound *selectedSound = [NSSound soundNamed:[[soundListPopUpButton selectedItem] title]];
  if (!selectedSound) // one of our own sounds, not found by soundNamed:
  {
    NSString *soundPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Sounds"];
    soundPath = [soundPath stringByAppendingPathComponent:[[soundListPopUpButton selectedItem] title]];
    soundPath = [soundPath stringByAppendingPathExtension:@"aiff"];
    selectedSound = [[[NSSound alloc] initWithContentsOfFile:soundPath byReference:YES] autorelease];
  }
  [selectedSound play];
  
  [eventController setStringForEvent:event alert:@"playSoundSound" value:[[soundListPopUpButton selectedItem] title]];
  
  [eventController commitChanges];
}

- (IBAction)notificationButtonChanged:(id)sender
{
  if (sender != self && sender != chatEventPopUpButton) // we didn't trigger our own update
  {
    NSString *event = [eventController eventCodeForName:[[chatEventPopUpButton selectedItem] title]];
    [eventController setBoolForEvent:event alert:@"playSound" value:[playSoundButton state]];
    
    [eventController setBoolForEvent:event alert:@"playSoundBackground" value:[playSoundBackgroundButton state]];
    [eventController setBoolForEvent:event alert:@"bounceIcon" value:[bounceIconButton state]];
    [eventController setBoolForEvent:event alert:@"bounceIconUntilFront" value:[bounceIconUntilFrontButton state]];
    [eventController setBoolForEvent:event alert:@"bounceShowCountOnDock" value:[bounceShowCountOnDock state]];
    [eventController setBoolForEvent:event alert:@"growlEvent" value:[growlEventButton state]];
    [eventController setBoolForEvent:event alert:@"growlEventBackground" value:[growlEventBackgroundButton state]];
    [eventController setBoolForEvent:event alert:@"growlEventUntilFront" value:[growlEventUntilFrontButton state]];
  }
  
  [soundListPopUpButton setEnabled:[playSoundButton state]];
  [playSoundBackgroundButton setEnabled:[playSoundButton state]];
  
  [bounceIconUntilFrontButton setEnabled:[bounceIconButton state]];
  [bounceShowCountOnDock setEnabled:[bounceIconButton state]];
  
  [growlEventBackgroundButton setEnabled:[growlEventButton state]];
  [growlEventUntilFrontButton setEnabled:[growlEventButton state]];
  
  [eventController commitChanges];
}

#pragma mark Colour Functions

//-------------------------------------------------------------------
// changeColor:
// Changes the color of an GUI item
//
// "sender" - A color well whose color changed
//-------------------------------------------------------------------
- (IBAction)changeColor:(id)sender
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	NSColor *color = [sender color];
	NSString *key = nil;
	
	colorChanged = TRUE;
	
	if (sender == channelBGColorWell) {
		[nc postNotificationName:@"channelColorChanged" object:color];
		[themePreviewTextView setBackgroundColor:color];
		[themePreviewTextView setNeedsDisplay:TRUE];
	}
	else if (sender == channelFGColorWell) {
		[nc postNotificationName:@"channelColorChanged" object:color];
	}
	else if (sender == channelListBGColorWell) {
		[nc postNotificationName:@"channelListColorChanged" object:color];
	}
	else if (sender == channelListFGNoActivityColorWell) {
		[nc postNotificationName:@"channelListColorChanged" object:color];
	}
	else if (sender == channelListFGActionColorWell) {
		[nc postNotificationName:@"channelListColorChanged" object:color];
	}
	else if (sender == channelListFGPublicMessageColorWell) {
		[nc postNotificationName:@"channelListColorChanged" object:color];
	}
	else if (sender == channelListFGPrivateMessageColorWell) {
		[nc postNotificationName:@"channelListColorChanged" object:color];
	}
	else if (sender == inputTextFieldBGColorWell) {
		[nc postNotificationName:@"inputTextFieldColorChanged" object:color];
	}
	else if (sender == inputTextFieldFGColorWell) {
		[nc postNotificationName:@"inputTextFieldColorChanged" object:color];
	}
	else if (sender == nickListBGColorWell) {
		[nc postNotificationName:@"nickListColorChanged" object:color];
	}
	else if (sender == nickListFGHalfOpColorWell) {
		[nc postNotificationName:@"nickListColorChanged" object:color];
	}
	else if (sender == nickListFGNormalColorWell) {
		[nc postNotificationName:@"nickListColorChanged" object:color];
	}
	else if (sender == nickListFGOpColorWell) {
		[nc postNotificationName:@"nickListColorChanged" object:color];
	}
	else if (sender == nickListFGServerOpColorWell) {
		[nc postNotificationName:@"nickListColorChanged" object:color];
	}
	else if (sender == nickListFGVoiceColorWell) {
		[nc postNotificationName:@"nickListColorChanged" object:color];
	}
  
  // Update the colors
  if (key)
  {
    NSData *colorAsData = [NSArchiver archivedDataWithRootObject:color];
    [[NSUserDefaults standardUserDefaults] setObject:colorAsData forKey:key];
  }
}

#pragma mark Network Preference Panel

- (IBAction)addNetworkAction:(id)sender
{
  [self showNetworkPanel:self];
}

- (IBAction)deleteNetworkAction:(id)sender
{
  IrcnetBridgeController *ircNet = [[networksArrayController selectedObjects] objectAtIndex:0];
  
  NSAlert *confirmationAlert = [NSAlert alertWithMessageText:[NSString stringWithFormat:@"Are you sure you want to delete the %@ chatnet?", [ircNet name]]
                                               defaultButton:@"Delete"
                                             alternateButton:@"Cancel"
                                                 otherButton:nil
                                   informativeTextWithFormat:[NSString stringWithFormat:@"This action will also disassociate %@ from all servers that belong to this chatnet.", [ircNet name]]];
  
  [confirmationAlert beginSheetModalForWindow:preferenceWindow
                                modalDelegate:self
                               didEndSelector:@selector(deleteNetworkActionPanelDidEnd:returnCode:contextInfo:)
                                  contextInfo:nil];
}

- (void)deleteNetworkActionPanelDidEnd:(NSWindow*)sheet returnCode:(int)code contextInfo:(void*)contextInfo
{
  if (code == NSOKButton)
  {
    int index = [networksArrayController selectionIndex];
    IrcnetBridgeController *ircNet = [[networksArrayController selectedObjects] objectAtIndex:0];
    
    ServerBridgeController *server = nil;
    int i = 0;
    
    for (i=0; i < [[serversArrayController content] count]; i++) {
      server = [[serversArrayController content] objectAtIndex:i];
      
      if ([[server chatnet] isEqualToString:[ircNet name]])
      {
        [preferenceObjectController deleteServerWithIndex:i];
      }
    }
    
    [preferenceObjectController deleteChatnetWithIndex:index];
    
    [networksArrayController setContent:[preferenceObjectController chatnetArray]];
    [networksArrayController setSelectionIndex:index];
    
    [serversArrayController setContent:[preferenceObjectController serverArray]];
  }
}

- (IBAction)addChannelAction:(id)sender
{
  [self showChannelPanel:self];
}

- (IBAction)deleteChannelAction:(id)sender
{
  [preferenceObjectController deleteChannelWithIndex:[channelsArrayController selectionIndex] fromChatnet:[[networksArrayController selectedObjects] objectAtIndex:0]];
}

#pragma mark Network/Channel Panel

- (void)showChannelPanel:(id)sender 
{
  [channetPanelLabel setStringValue:@"Channel:"];
  [channetPanelTextField setStringValue:@""];
  isChannetPanelNetwork = NO;
  
  [NSApp beginSheet:channetPanelWindow
     modalForWindow:preferenceWindow 
      modalDelegate:self 
     didEndSelector:@selector(channetPanelDidEnd:returnCode:contextInfo:)
        contextInfo:nil];
}

- (void)showNetworkPanel:(id)sender
{
  [channetPanelLabel setStringValue:@"Network:"];
  [channetPanelTextField setStringValue:@""];
  isChannetPanelNetwork = YES;
  
  [NSApp beginSheet:channetPanelWindow
     modalForWindow:preferenceWindow 
      modalDelegate:self
     didEndSelector:@selector(channetPanelDidEnd:returnCode:contextInfo:)
        contextInfo:nil];
}

- (void)channetPanelDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
  [sheet orderOut:self];
  
  // Firstly, may as well bomb out here if the entry is empty
  if ([[[channetPanelTextField stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])
  {
    return;
  }
  
  // Two code paths here, one if we're a network box. Another if we're a channel box.
  if (isChannetPanelNetwork)
  {
    NSString *networkName = [NSString stringWithString:[channetPanelTextField stringValue]];
    IrcnetBridgeController *controller = [preferenceObjectController addChatnetWithName:networkName];
    [networksArrayController setContent:[preferenceObjectController chatnetArray]];
    [networksArrayController setSelectedObjects:[NSArray arrayWithObject:controller]];
  }
  else
  {
    NSString *channelName = [NSString stringWithString:[channetPanelTextField stringValue]];
    IrcnetBridgeController *ircController = [[networksArrayController selectedObjects] objectAtIndex:0];
    [preferenceObjectController addChannelWithName:channelName toChatnet:ircController];
    [networksArrayController setContent:[preferenceObjectController chatnetArray]];
    [networksArrayController setSelectedObjects:[NSArray arrayWithObject:ircController]];
  }
}

- (IBAction)channetPanelOKAction:(id)sender
{
  [NSApp endSheet:channetPanelWindow returnCode:NSOKButton];
}

- (IBAction)channetPanelCancelAction:(id)sender
{
  [NSApp endSheet:channetPanelWindow returnCode:NSCancelButton];
}

#pragma mark Servers Preference Panel

- (IBAction)addServerAction:(id)sender
{
  ServerBridgeController *controller = [preferenceObjectController addServerWithAddress:@"irc.example.com" port:6667];
  [serversArrayController setContent:[preferenceObjectController serverArray]];
  [serversArrayController setSelectedObjects:[NSArray arrayWithObject:controller]];
}

- (IBAction)deleteServerAction:(id)sender
{
  ServerBridgeController *server = [[serversArrayController selectedObjects] objectAtIndex:0];
  
  NSAlert *confirmationAlert = [NSAlert alertWithMessageText:[NSString stringWithFormat:@"Are you sure you want to delete %@?", [server address]]
                                               defaultButton:@"Delete"
                                             alternateButton:@"Cancel"
                                                 otherButton:nil
                                   informativeTextWithFormat:@"You cannot undo this action."];
  
  [confirmationAlert beginSheetModalForWindow:preferenceWindow
                                modalDelegate:self
                               didEndSelector:@selector(deleteServerActionSheetDidEnd:returnCode:contextInfo:)
                                  contextInfo:nil];
}

- (void)deleteServerActionSheetDidEnd:(NSWindow*)sheet returnCode:(int)code contextInfo:(void*)contextInfo
{
  if (code == NSOKButton)
  {
    int index = [serversArrayController selectionIndex];
    
    [preferenceObjectController deleteServerWithIndex:index];
    
    [serversArrayController setContent:[preferenceObjectController serverArray]];    
    [serversArrayController setSelectionIndex:index];
  }
}

#pragma mark Appearance Preference Panel

- (void)updateMainWindowFontLabel
{
  NSFont *mainWindowFont = [NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] valueForKey:@"channelFont"]];
  [mainWindowFontField setFont:mainWindowFont];
}

- (void)updateNickFontLabel
{
  NSFont *nickListFont = [NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] valueForKey:@"nickListFont"]];
  [nickListFontField setFont:nickListFont];
}

- (IBAction)changeMainWindowFont:(id)sender
{
  NSFontManager *sharedFontManager = [NSFontManager sharedFontManager];
  NSFont *mainWindowFont = [NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] valueForKey:@"channelFont"]];
  
  [sharedFontManager setSelectedFont:mainWindowFont isMultiple:NO];
  [sharedFontManager setTarget:self];
  [sharedFontManager setAction:@selector(newMainWindowFontFromFontManager:)];
  
  [[sharedFontManager fontPanel:YES] orderFrontRegardless];
}

- (IBAction)changeNickFont:(id)sender
{
  NSFontManager *sharedFontManager = [NSFontManager sharedFontManager];
  NSFont *mainWindowFont = [NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] valueForKey:@"nickListFont"]];
  
  [sharedFontManager setSelectedFont:mainWindowFont isMultiple:NO];
  [sharedFontManager setTarget:self];
  [sharedFontManager setAction:@selector(newNicklistFontFromFontManager:)];
  
  [[sharedFontManager fontPanel:YES] orderFrontRegardless];
}

- (void)fontPreviewField:(JVFontPreviewField *)field didChangeToFont:(NSFont *)font
{
  if ([field isEqualTo:mainWindowFontField])
  {
    [[NSUserDefaults standardUserDefaults] setObject:[NSArchiver archivedDataWithRootObject:font] forKey:@"channelFont"];
    [self previewTheme:self];
    [appController changeMainWindowFont:font];
  }
  else if ([field isEqualTo:nickListFontField])
  {
    [[NSUserDefaults standardUserDefaults] setObject:[NSArchiver archivedDataWithRootObject:font] forKey:@"nickListFont"];
    [appController changeNicklistFont:font];
  }
}

- (void)findAvailableThemes
{
  [availableThemes release];
  availableThemes = [[NSMutableArray alloc] init];
	
	NSArray *locations = [appController themeLocations];
	NSFileManager *fileManager = [NSFileManager defaultManager];
  
  NSString *location, *file;
  NSEnumerator *locationsEnumerator = [locations objectEnumerator];
  
  while (location = [locationsEnumerator nextObject])
  {
    NSArray *files = [fileManager directoryContentsAtPath:location];
    
    if (!files)
    {
      continue;
    }
    
    NSEnumerator *filesEnumerator = [files objectEnumerator];
    while (file = [filesEnumerator nextObject])
    {
      /** Remove .theme suffix and add to array */
			if ([file hasSuffix:@".theme"] && ![availableThemes containsObject:[file stringByDeletingPathExtension]])
      {
        [availableThemes addObject:[file stringByDeletingPathExtension]];
      }
    }
  }
  [themesArrayController setContent:availableThemes];
}

- (IBAction)previewTheme:(id)sender
{
  // Erugh, so if the theme doesn't exist then bad array index stuff happens. This really only happens if
  // the user has "default" as the theme (we don't provide a default.theme) but could happen if someone
  // runs /set theme without a valid theme.
  
  // If all else fails, we'll preview the first object in the index.
  NSArray *themeObjects = [themesArrayController selectedObjects];
  if ([themeObjects count] == 0)
  {
    // Paranoid here, check if we have any themes. If not, best just not bother.
    if ([[themesArrayController arrangedObjects] count] == 0)
    {
      NSLog(@"previewTheme: theme controller's arrangedObjects was empty, this isn't good");
      return;
    }
    
    [themesArrayController setSelectionIndex:0];
    themeObjects = [themesArrayController selectedObjects];
  }
  
  NSString *theme = [themeObjects objectAtIndex:0];
  [self renderPreviewTheme:theme];
  [preferenceObjectController setTheme:theme];
}

- (void)renderPreviewTheme:(NSString*)themeName
{
  WINDOW_REC windowRec;
  TEXT_DEST_REC dest;
  
  // Perl gets uber upset if the windowRec isn't cleared out on allocation,
  // normally we'd g_new0 it, but as I've allocated it above, we need to clear it out.
  memset(&windowRec, 1, sizeof(WINDOW_REC));
  
  /* So the basic plan here is to:
      1.  Create a fake "window", its actually just a variable at the top of this function
      2.  Unlike normal traffic, we can buffer up all the lines in one string till the end
          of the traffic. So we declare an attributed string to use.
      3.  Hook our printText and printTextFinished into the callchain at the top, it needs
          to be first so we can catch this message stream before it hits the normal print
          signal handlers.
      4.  Create a fake stream of traffic, I've got some C functions at the bottom of this
          file that basically call Irssi functions, the traffic is the same as partially-
          processed IRC traffic.
      5.  The signal handlers check if wind->gui_data is actually this class, not a
          ChannelController (as it usually is), if so they call the ObjC callbacks then
          kill the signal from going any further.
      6.  We render the data into a string, the ChannelController print text function has
          been migrated to an NSAttributedString addition so we can call it from both places.
      7.  Once we're done, put the string on screen then kill off our extra hooks and tidy
          up.
   
    This is all to get rid of the theme preview daemon, this is a "relatively" simple way of
    doing theme preview and doesn't rely on external daemons to do the work for us.
   */
   
  // This is hacky but I can't send it through the callbacks. So meh.
  themeRenderLineBuffer = [[NSMutableAttributedString alloc] init];
  [[themePreviewTextView textStorage] setAttributedString:themeRenderLineBuffer];
  
  signal_add_first("gui print text", (SIGNAL_FUNC)_preferences_bridge_print_text);
  signal_add_first("gui print text finished", (SIGNAL_FUNC)_preferences_bridge_print_text_finished);
  
  windowRec.theme = theme_load([themeName cStringUsingEncoding:MICurrentTextEncoding]);
  windowRec.gui_data = self;
  
  // The signal chain reassigns this but it frees it first, so need to put something here.
  windowRec.hilight_color = malloc(1);
  
  // Lets have a conversation with ourself
  format_create_dest(&dest, NULL, "#test", 4, &windowRec);
  _preferences_printformat("fe-common/core", &dest, TXT_PUBMSG, "Obj-Cow", "yeah, it'd never make it into those functions if absoluteURL was NULL", " ");
  _preferences_printformat("fe-common/core", &dest, TXT_JOIN, "xTina", "xTina@vpn2-dynip175.informatik.uni-stuttgart.de", "#macdev");
  _preferences_printformat("fe-common/core", &dest, TXT_PUBMSG, "hennker", "anyone has a guess, why cisco' vpnclient links against the quicktime.framework?", " ");
  _preferences_printformat("fe-common/core", &dest, TXT_PUBMSG, "mikeash", "easter egg?", " ");
  _preferences_printformat("fe-common/core", &dest, TXT_PUBMSG, "hennker", "hehe", " ");
  _preferences_printformat("fe-common/core", &dest, TXT_PUBMSG_ME, "Gruul", "Daagaak: ping", "+");
  _preferences_printformat("fe-common/core", &dest, TXT_QUIT, "CrackBunny", "CrackBun@66-188-151-29.dhcp.stcl.mn.charter.com", "Laptop goes to sleep!", "CrackBunny");
  _preferences_printformat("fe-common/core", &dest, TXT_PUBMSG, "AngryLuke", "what's wrong with it linking to QuickTime?", " ");
	_preferences_printformat("fe-common/core", &dest, TXT_PUBMSG, "hennker", "not wrong, i am just wondering, why they'd need something out of quicktime for a vpn-client", " ");
  _preferences_printformat("fe-common/core", &dest, TXT_PUBMSG, "AngryLuke", "how are you determining that it is loading?", " ");
  _preferences_printformat("fe-common/core", &dest, TXT_PART, "rici2", "rlake@grail1.oxfam.org.uk", "#macdev", "");
  _preferences_printformat("fe-common/core", &dest, TXT_PUBMSG, "AngryLuke", "err, that it is linking to QuickTime, I mean", " ");
  _preferences_printformat("fe-common/core", &dest, TXT_PUBMSG, "hennker", "otool -L", " ");

  [[themePreviewTextView textStorage] appendAttributedString:themeRenderLineBuffer];
  [themeRenderLineBuffer release];

  signal_remove("gui print text", (SIGNAL_FUNC)_preferences_bridge_print_text);
  signal_remove("gui print text finished", (SIGNAL_FUNC)_preferences_bridge_print_text_finished);
  
  free(windowRec.hilight_color);
}

- (void)printTextCallback:(char*)cText foreground:(int)fg background:(int)bg flags:(int)flags
{
  NSString *text = [NSString stringWithCString:cText encoding:NSUTF8StringEncoding];
  
  NSFont *channelFont = [NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] valueForKey:@"channelFont"]];
  NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:channelFont, NSFontAttributeName,nil];
  
  NSMutableAttributedString *tmp = [themeRenderLineBuffer attributedStringByAppendingString:text foreground:fg background:bg flags:flags attributes:attributes];
  [themeRenderLineBuffer release];
  themeRenderLineBuffer = [tmp retain];
}

- (void)printTextFinishedCallback
{
  [themeRenderLineBuffer appendAttributedString:[[[NSMutableAttributedString alloc] initWithString:@"\n"] autorelease]];
}

- (IBAction)switchChannelBarOrientation:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setInteger:[sender selectedRow] forKey:@"channelBarOrientation"];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"channelBarOrientationDidChange" object:self];
  
  // Re-init the shortcut control. They need to know when the up/down changes to left/right etc.
  [self initTabShortcutPopUpButton];
  [self updateTabShortcutPopUpButton];
}

- (IBAction)showHideNicklist:(id)sender
{
  [appController setNicklistHidden:![[NSUserDefaults standardUserDefaults] boolForKey:@"showNicklist"]];
}

#pragma mark Shortcuts Preference Panel

- (IBAction)addShortcutAction:(id)sender
{
  [self showShortcutRecorderPanel:self controller:nil];
}

- (IBAction)deleteShortcutAction:(id)sender
{
  if ([[shortcutsArrayController selectedObjects] count] > 0)
  {
    ShortcutBridgeController *controller = [[shortcutsArrayController selectedObjects] objectAtIndex:0];
    [preferenceObjectController deleteShortcutWithKeyCode:[controller keyCode] flags:[controller flags]];
    [shortcutsArrayController setContent:[preferenceObjectController shortcutArray]];
  }
}

- (IBAction)editShortcutAction:(id)sender
{
  if ([shortcutsTableView clickedColumn] == 0)
  {
    // Someone actually double-clicked the command bit, we need to send an edit there instead.
    [shortcutsTableView editColumn:[shortcutsTableView clickedColumn] row:[shortcutsTableView clickedRow] withEvent:nil select:YES];
    return;
  }
  
  if ([[shortcutsArrayController selectedObjects] count] > 0)
  {
    [self showShortcutRecorderPanel:self controller:[[shortcutsArrayController selectedObjects] objectAtIndex:0]];
  }
}

#pragma mark Shortcut Recorder Panel

- (void)showShortcutRecorderPanel:(id)sender controller:(ShortcutBridgeController*)controller
{
  if (controller)
  {
    [shortcutRecorderControl setKeyCombo:SRMakeKeyCombo([controller keyCode], [controller flags])];
  }
  else
  {
    // Clear the shortcut control.
    [shortcutRecorderControl setKeyCombo:SRMakeKeyCombo(-1, 0)];
  }
  
  [NSApp beginSheet:shortcutRecorderWindow
     modalForWindow:[self window]
      modalDelegate:self
     didEndSelector:@selector(shortcutRecorderPanelDidEnd:returnCode:contextInfo:)
        contextInfo:controller];
}

- (void)shortcutRecorderPanelDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
  [sheet orderOut:self];
  
  if (returnCode == NSOKButton)
  {
    // No context info + returnOK means we've created a new 'un
    if (!contextInfo)
    {
      KeyCombo keyCombo = [shortcutRecorderControl keyCombo];
      [preferenceObjectController addShortcutWithKeyCode:keyCombo.code flags:keyCombo.flags];
    }
    else
    {
      // Context + OK means we've edited.
      ShortcutBridgeController *controller = contextInfo;
      KeyCombo keyCombo = [shortcutRecorderControl keyCombo];
      [controller setFlags:keyCombo.flags];
      [controller setKeyCode:keyCombo.code];
    }
    [shortcutsArrayController setContent:[preferenceObjectController shortcutArray]];
  }
}

- (IBAction)shortcutRecorderPanelOKAction:(id)sender
{
  [NSApp endSheet:shortcutRecorderWindow returnCode:NSOKButton];
}

- (IBAction)shortcutRecorderPanelCancelAction:(id)sender
{
  [NSApp endSheet:shortcutRecorderWindow returnCode:NSCancelButton];
}

- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder isKeyCode:(signed short)keyCode andFlagsTaken:(unsigned int)flags reason:(NSString **)aReason
{
  switch (keyCode)
  {
    case kSRKeysF1:
    case kSRKeysF2:
    case kSRKeysF3:
    case kSRKeysF4:
    case kSRKeysF5:
    case kSRKeysF6:
    case kSRKeysF7:
    case kSRKeysF8:
    case kSRKeysF9:
    case kSRKeysF10:
    case kSRKeysF11:
    case kSRKeysF12:
    case kSRKeysF13:
    case kSRKeysF14:
    case kSRKeysF15:
    case kSRKeysF16:
    case kSRKeysF17:
    case kSRKeysF18:
    case kSRKeysF19:
      return NO;
    default:
    {
      BOOL error = !(flags & NSCommandKeyMask);
      if (error)
      {
        *aReason = @"shortcut keys must contain the Command key.";
      }
      return error;
    }
  }
}

#pragma mark Window

- (NSWindow*)window
{
  return preferenceWindow;
}

#pragma mark Toolbar Delegates

// Called from toolbar pushes
- (IBAction)changeViewFromToolbar:(id)sender 
{
  NSToolbarItem *toolbarItem = (NSToolbarItem*)sender;
  if ([[toolbarItem itemIdentifier] isEqualToString:@"General"])
  {
    [self switchPreferenceWindowTo:generalPreferencesTab animate:YES];
  }
  else if ([[toolbarItem itemIdentifier] isEqualToString:@"Notifications"])
  {
    [self switchPreferenceWindowTo:notificationsPreferencesTab animate:YES];
  }
  else if ([[toolbarItem itemIdentifier] isEqualToString:@"Colours"])
  {
    [self switchPreferenceWindowTo:coloursPreferencesTab animate:YES];
  }
  else if ([[toolbarItem itemIdentifier] isEqualToString:@"Networks"])
  {
    [self switchPreferenceWindowTo:networksPreferencesTab animate:YES];
  }
  else if ([[toolbarItem itemIdentifier] isEqualToString:@"Servers"])
  {
    [self switchPreferenceWindowTo:serversPreferencesTab animate:YES];
  }
  else if ([[toolbarItem itemIdentifier] isEqualToString:@"Themes"])
  {
    [self switchPreferenceWindowTo:themePreferencesTab animate:YES];
  }
  else if ([[toolbarItem itemIdentifier] isEqualToString:@"Shortcuts"])
  {
    [self switchPreferenceWindowTo:shortcutsPreferencesTab animate:YES];
  }
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
  return [NSArray arrayWithObjects:@"General", @"Themes", @"Notifications", @"Colours", @"Networks", @"Servers", @"Shortcuts", nil];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
  return [self toolbarAllowedItemIdentifiers:toolbar];
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
  return [self toolbarAllowedItemIdentifiers:toolbar];  
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
  NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
  if ([itemIdentifier isEqualToString:@"General"])
  {
    [toolbarItem setImage:[NSImage imageNamed:@"General"]];
    [toolbarItem setLabel:@"General"];
    [toolbarItem setAction:@selector(changeViewFromToolbar:)];
    [toolbarItem setTarget:self];
  }
  else if ([itemIdentifier isEqualToString:@"Notifications"])
  {
    [toolbarItem setLabel:@"Notifications"];
    [toolbarItem setImage:[NSImage imageNamed:@"Notifications"]];
    [toolbarItem setAction:@selector(changeViewFromToolbar:)];
    [toolbarItem setTarget:self];
  }
  else if ([itemIdentifier isEqualToString:@"Colours"])
  {
    [toolbarItem setLabel:@"Colours"];
    [toolbarItem setImage:[NSImage imageNamed:@"Colours"]];
    [toolbarItem setAction:@selector(changeViewFromToolbar:)];
    [toolbarItem setTarget:self];
  }
  else if ([itemIdentifier isEqualToString:@"Networks"])
  {
    [toolbarItem setLabel:@"Networks"];
    [toolbarItem setImage:[NSImage imageNamed:@"Networks"]];
    [toolbarItem setAction:@selector(changeViewFromToolbar:)];
    [toolbarItem setTarget:self];
  }
  else if ([itemIdentifier isEqualToString:@"Servers"])
  {
    [toolbarItem setLabel:@"Servers"];
    [toolbarItem setImage:[NSImage imageNamed:@"Servers"]];
    [toolbarItem setAction:@selector(changeViewFromToolbar:)];
    [toolbarItem setTarget:self];
  }
  else if ([itemIdentifier isEqualToString:@"Themes"])
  {
    [toolbarItem setLabel:@"Appearance"];
    [toolbarItem setImage:[NSImage imageNamed:@"Themes"]];
    [toolbarItem setAction:@selector(changeViewFromToolbar:)];
    [toolbarItem setTarget:self];
  }
  else if ([itemIdentifier isEqualToString:@"Shortcuts"])
  {
    [toolbarItem setLabel:@"Shortcuts"];
    [toolbarItem setImage:[NSImage imageNamed:@"Keyboard"]];
    [toolbarItem setAction:@selector(changeViewFromToolbar:)];
    [toolbarItem setTarget:self];
  }
  
  return [toolbarItem autorelease];
}

@end

#pragma mark Internal C Functions

void _preferences_printformat(const char* module, TEXT_DEST_REC* dest, int formatnum, ...)
{
  va_list va;
  va_start(va, formatnum);
  printformat_module_dest_args(module, dest, formatnum, va);
  va_end(va);
}

void _preferences_bridge_print_text(WINDOW_REC *wind, int fg, int bg, int flags, char *text, TEXT_DEST_REC *dest_rect)
{
  id context = wind->gui_data;
  
  if ([context isKindOfClass:[PreferenceViewController class]])
  {
    [(PreferenceViewController*)context printTextCallback:text foreground:fg background:bg flags:flags];
    signal_stop();
  }
  // Else, carry on.
}

void _preferences_bridge_print_text_finished(WINDOW_REC *wind)
{
  id context = wind->gui_data;
  
  if ([context isKindOfClass:[PreferenceViewController class]])
  {
    [(PreferenceViewController*)context printTextFinishedCallback];
    signal_stop();
  }
  // Else, carry on.
}