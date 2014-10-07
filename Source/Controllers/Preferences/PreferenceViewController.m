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
#include "Defaults.h"
#include "Util.h"

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
    [preferenceWindow setOpaque:NO];
    
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
    
    // Make sure we apply these defaults to the current window
    [self userDefaultsChanged:nil];
    
    // Check the Feed URL to see if we're beta or normal.
    BOOL checkForBetas = [[[[[SUUpdater sharedUpdater] feedURL] path] lastPathComponent] isEqual:@"beta.php"];
    [checkForBetasCheckBox setState:checkForBetas];
    
    colorSet = colors;
    availableThemes = [[NSMutableArray alloc] init];
    appController = controller;
    eventController = [appController eventController];
    
    [themePreviewTextView setBackgroundColor:[ColorSet channelBackgroundColor]];
    [[themePreviewTextView enclosingScrollView] setBackgroundColor:[ColorSet channelBackgroundColor]];
    
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

- (void)switchPreferenceWindowToNamed:(NSString*)preferencePaneName animate:(BOOL)animate
{
  /* Cheating slightly */
  NSToolbarItem *item = nil;
  for (NSToolbarItem *possible in [preferencesToolbar items]) {
    if ([[possible label] isEqualToString:preferencePaneName]) {
      item = possible;
    }
  }
  
  if (item) {
    [preferencesToolbar setSelectedItemIdentifier:preferencePaneName];
    [self changeViewFromToolbar:item];
  }
}

- (void)switchPreferenceWindowTo:(NSWindow*)preferencePane animate:(BOOL)animate
{
  if (currentPreferenceTab)
  {
    NSView *oldView = [[preferencesWindowView contentView] retain];
    [oldView removeFromSuperview];
    [currentPreferenceTab setContentView:oldView];
    [oldView release];
  }
  
  NSResponder *newFirstResponder = [preferencePane initialFirstResponder];
  
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
  [preferenceWindow makeFirstResponder:newFirstResponder];
  
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

- (IBAction)checkForBetasCheckBoxChanged:(id)sender
{
  if ([checkForBetasCheckBox state])
  {
    [[SUUpdater sharedUpdater] setFeedURL:[NSURL URLWithString:@"http://www.sysctl.co.uk/projects/macirssi/beta.php"]];
  } 
  else
  {
    [[SUUpdater sharedUpdater] setFeedURL:[NSURL URLWithString:@"http://www.sysctl.co.uk/projects/macirssi/feed.php"]];
  }
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

/**
 * via: http://rhult.github.io/articles/making-nsslider-snap/
 */
- (IBAction)sliderValueChanged:(id)sender
{
  // via: http://stackoverflow.com/a/12066378/362042
  NSEvent *event = [[NSApplication sharedApplication] currentEvent];
  BOOL startingDrag = event.type == NSLeftMouseDown;
  BOOL endingDrag = event.type == NSLeftMouseUp;
  BOOL dragging = event.type == NSLeftMouseDragged;
  
  NSAssert(startingDrag || endingDrag || dragging, @"unexpected event type caused slider change: %@", event);

  double range = [sender maxValue] - [sender minValue];
  double tickInterval = range / ([sender numberOfTickMarks] - 1);
  
  double relativeValue = [sender doubleValue] - [sender minValue];
  
  // Get the distance to the nearest tick.
  int nearestTick = round(relativeValue / tickInterval);
  double distance = relativeValue - nearestTick * tickInterval;
  
  // Change the check here depending on how much resistance you
  // want, or if you don't want it to depend on the tick interval.
  if (fabs(distance) < tickInterval / 8)
  {
    [sender setDoubleValue:[sender doubleValue] - distance];
  }

  // if user has let go of the slider, play the current sound
  if (endingDrag)
  {
    playSoundNamed([[soundListPopUpButton selectedItem] title]);
  }
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
  
  playSoundNamed([[soundListPopUpButton selectedItem] title]);
  
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
  NSString *name = [preferenceObjectController uniqueNameForNewChatnet];
  IrcnetBridgeController *controller = [preferenceObjectController addChatnetWithName:name];
  [networksArrayController setContent:[preferenceObjectController chatnetArray]];
  [networksArrayController setSelectedObjects:[NSArray arrayWithObject:controller]];
}

- (IBAction)deleteNetworkAction:(id)sender
{
  NSString *messageText = nil, *informativeText = nil;
  if ([[networksArrayController selectedObjects] count] == 1) {
    IrcnetBridgeController *ircNet = [[networksArrayController selectedObjects] objectAtIndex:0];
    messageText = [NSString stringWithFormat:@"Are you sure you want to delete the %@ network?", [ircNet name]];
    informativeText = [NSString stringWithFormat:@"This action will also disassociate %@ from all servers that belong to this network.", [ircNet name]];
  } else {
    messageText = [NSString stringWithFormat:@"Are you sure you want to delete these %d networks?", [[networksArrayController selectedObjects] count]];
    informativeText = [NSString stringWithFormat:@"This action will disassociate all affected servers from their networks."];
  }
  
  NSAlert *confirmationAlert = [NSAlert alertWithMessageText:messageText
                                               defaultButton:@"Delete"
                                             alternateButton:@"Cancel"
                                                 otherButton:nil
                                   informativeTextWithFormat:informativeText];
  
  [confirmationAlert beginSheetModalForWindow:preferenceWindow
                                modalDelegate:self
                               didEndSelector:@selector(deleteNetworkActionPanelDidEnd:returnCode:contextInfo:)
                                  contextInfo:nil];
}

- (void)deleteNetworkActionPanelDidEnd:(NSWindow*)sheet returnCode:(int)code contextInfo:(void*)contextInfo
{
  if (code == NSOKButton && [[networksArrayController selectedObjects] count] > 0)
  {
    NSIndexSet *set = [networksArrayController selectionIndexes];
    NSUInteger index = [set lastIndex];
    
    do {
      IrcnetBridgeController *network = [[networksArrayController arrangedObjects] objectAtIndex:index];
      
      for (ServerBridgeController *server in [serversArrayController content]) {
        if ([[server chatnet] isEqualToString:[network name]]) {
          [server setChatnet:nil];
        }
      }
      
      [preferenceObjectController deleteChatnetWithIndex:index];
    } while ((index = [set indexLessThanIndex:index]) != NSNotFound);
    
    [networksArrayController setContent:[preferenceObjectController chatnetArray]];
    [networksArrayController setSelectionIndexes:[NSIndexSet indexSet]];
  }
}

- (IBAction)addChannelAction:(id)sender
{
  IrcnetBridgeController *ircController = [[networksArrayController selectedObjects] objectAtIndex:0];
  NSString *name = [NSString stringWithString:[preferenceObjectController uniqueNameForNewChannelInNetwork:ircController]];
  [preferenceObjectController addChannelWithName:name toChatnet:ircController];
  [networksArrayController setContent:[preferenceObjectController chatnetArray]];
  [networksArrayController setSelectedObjects:[NSArray arrayWithObject:ircController]];
}

- (IBAction)deleteChannelAction:(id)sender
{
  NSIndexSet *set = [channelsArrayController selectionIndexes];
  if (!set) {
    return;
  }
  
  NSUInteger index = [set lastIndex];
  IrcnetBridgeController *network = [[networksArrayController selectedObjects] objectAtIndex:0];
  
  do {
    [preferenceObjectController deleteChannelWithIndex:index fromChatnet:network];
  } while ((index = [set indexLessThanIndex:index]) != NSNotFound);
}

#pragma mark Servers Preference Panel

- (IBAction)addServerAction:(id)sender
{
  NSUInteger insertionIndex;
  if ([[serversArrayController selectedObjects] count] == 0) {
    insertionIndex = [[serversArrayController arrangedObjects] count];
  } else {
    insertionIndex = [[serversArrayController selectionIndexes] lastIndex] + 1;
  }
  
  ServerBridgeController *controller = [preferenceObjectController addServerWithAddress:@"irc.example.com" port:6667 atIndex:insertionIndex];
  [serversArrayController setContent:[preferenceObjectController serverArray]];
  [serversArrayController setSelectedObjects:[NSArray arrayWithObject:controller]];
}

- (IBAction)deleteServerAction:(id)sender
{
  NSString *alertMessage = nil;
  if ([[serversArrayController selectedObjects] count] == 1) {
    ServerBridgeController *server = [[serversArrayController selectedObjects] objectAtIndex:0];
    alertMessage = [NSString stringWithFormat:@"Are you sure you want to delete %@?", [server address]];
  } else {
    alertMessage = [NSString stringWithFormat:@"Are you sure you want to delete these %d servers?", [[serversArrayController selectedObjects] count]];
  }
  
  NSAlert *confirmationAlert = [NSAlert alertWithMessageText:alertMessage
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
    NSIndexSet *set = [serversArrayController selectionIndexes];
    NSUInteger index = [set lastIndex];
    
    do {
      [preferenceObjectController deleteServerWithIndex:index];
    } while ((index = [set indexLessThanIndex:index]) != NSNotFound);
    
    [serversArrayController setContent:[preferenceObjectController serverArray]];
    [serversArrayController setSelectionIndexes:[NSIndexSet indexSet]];
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
    NSArray *files = [fileManager contentsOfDirectoryAtPath:location error:nil];
    
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
  
  windowRec.theme = theme_load([themeName UTF8String]);
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
  _preferences_printformat("fe-common/core", &dest, TXT_NICK_CHANGED, "x3ro_", "x3ro", "x3ro", "");

  // The very last character in the preview is a '\n' that we don't really want.
  [themeRenderLineBuffer deleteCharactersInRange:NSMakeRange([themeRenderLineBuffer length]-1, 1)];
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
  
  [themeRenderLineBuffer appendString:text foreground:fg background:bg flags:flags attributes:attributes];
}

- (void)printTextFinishedCallback
{
  [themeRenderLineBuffer replaceCharactersInRange:NSMakeRange([themeRenderLineBuffer length], 0) withString:@"\n"];
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
  for (ShortcutBridgeController *controller in [shortcutsArrayController selectedObjects]) {
    [preferenceObjectController deleteShortcutWithKeyCode:[controller keyCode] flags:[controller flags]];
  }
  [shortcutsArrayController setContent:[preferenceObjectController shortcutArray]];
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