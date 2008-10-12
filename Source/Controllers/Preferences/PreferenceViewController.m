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

//*****************************************************************
// MacIrssi - PreferenceController
// Nils Hjelte, c01nhe@cs.umu.se
//
// Controls the preference panel
//*****************************************************************

#import "PreferenceViewController.h"
#import "IrssiBridge.h"
#import <Foundation/Foundation.h>
#import "settings.h"
#import "common.h"
#import "signals.h"
#import "ThemePreviewDaemon.h"
#include <unistd.h>
#include "themes.h"
#import "TextEncodings.h"

	
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
    
    int i;
    
    colorSet = colors;
    shortcutCommands = malloc(12 * sizeof(NSString *));
    for (i = 0; i < 12; i++)
    {
      shortcutCommands[i] = nil;
    }
    
    availibleThemes = [[NSMutableArray alloc] init];
    themePreviewDaemon = nil;
    previewTimer = nil;
    appController = controller;
    eventController = [appController eventController];
    
    [self initTextEncodingPopUpButton];
    [self initChatEventsPopUpButton];
    [self initSoundListPopUpButton];
    
    [[NSColorPanel sharedColorPanel] setShowsAlpha:TRUE];
    [[NSColorPanel sharedColorPanel] setContinuous:TRUE];  
  }
	return self;
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
  
  /* By default open the general tab and resize the window around it */
  [self switchPreferenceWindowTo:generalPreferencesTab animate:NO];
  [preferencesToolbar setSelectedItemIdentifier:@"General"];
  
	/* Make preferencepanel reflect current settings */
	[self updateColorWells];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
//	[F1Field setStringValue:[defaults objectForKey:@"shortcut1"]];
//	[F2Field setStringValue:[defaults objectForKey:@"shortcut2"]];
//	[F3Field setStringValue:[defaults objectForKey:@"shortcut3"]];
//	[F4Field setStringValue:[defaults objectForKey:@"shortcut4"]];
//	[F5Field setStringValue:[defaults objectForKey:@"shortcut5"]];
//	[F6Field setStringValue:[defaults objectForKey:@"shortcut6"]];
//	[F7Field setStringValue:[defaults objectForKey:@"shortcut7"]];
//	[F8Field setStringValue:[defaults objectForKey:@"shortcut8"]];
//	[F9Field setStringValue:[defaults objectForKey:@"shortcut9"]];
//	[F10Field setStringValue:[defaults objectForKey:@"shortcut10"]];
//	[F11Field setStringValue:[defaults objectForKey:@"shortcut11"]];
//	[F12Field setStringValue:[defaults objectForKey:@"shortcut12"]];
	
	[self updateTextEncodingPopUpButton];
  [self updateSoundListPopUpButton];
  [self updateChatEventsPopUpButton];
  
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
  
  // We want to release here.
  [generalPreferencesTab release];
  [notificationsPreferencesTab release];
  [coloursPreferencesTab release];
  [networksPreferencesTab release];
  [serversPreferencesTab release];
  
  [channetPanelWindow release];
  
  [self release];
}

//-------------------------------------------------------------------
// windowDidLoad
// Updates the preference panel to reflect current settings
//-------------------------------------------------------------------
- (void)windowDidLoad
{
  NSLog(@"Fart");
	[self updateColorWells];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
//	[F1Field setStringValue:[defaults objectForKey:@"shortcut1"]];
//	[F2Field setStringValue:[defaults objectForKey:@"shortcut2"]];
//	[F3Field setStringValue:[defaults objectForKey:@"shortcut3"]];
//	[F4Field setStringValue:[defaults objectForKey:@"shortcut4"]];
//	[F5Field setStringValue:[defaults objectForKey:@"shortcut5"]];
//	[F6Field setStringValue:[defaults objectForKey:@"shortcut6"]];
//	[F7Field setStringValue:[defaults objectForKey:@"shortcut7"]];
//	[F8Field setStringValue:[defaults objectForKey:@"shortcut8"]];
//	[F9Field setStringValue:[defaults objectForKey:@"shortcut9"]];
//	[F10Field setStringValue:[defaults objectForKey:@"shortcut10"]];
//	[F11Field setStringValue:[defaults objectForKey:@"shortcut11"]];
//	[F12Field setStringValue:[defaults objectForKey:@"shortcut12"]];
	
	NSTextContainer *textContainer = [previewTextView textContainer];
  NSSize theSize = [textContainer containerSize];
  theSize.width = 1.0e7;
  [textContainer setContainerSize:theSize];
  [textContainer setWidthTracksTextView:NO];
	[self initTextEncodingPopUpButton];
  [self initChatEventsPopUpButton];
  [self initSoundListPopUpButton];
  
	[previewTextView setBackgroundColor:[colorSet channelBGColor]];
	[previewTextView setNeedsDisplay:TRUE];
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

#pragma mark Channel Bar

- (IBAction)switchChannelBar:(id)sender
{
	if ([sender selectedTag] == 0) {
		[appController useHorizontalChannelBar:TRUE];
		[appController useVerticalChannelBar:FALSE];
    [appController setChannelNavigationShortcuts:1];
	}
	else {
		[appController useHorizontalChannelBar:FALSE];
		[appController useVerticalChannelBar:TRUE];
    [appController setChannelNavigationShortcuts:0];
	}
	
	[[NSUserDefaults standardUserDefaults] setInteger:[sender selectedTag] forKey:@"channelBarOrientation"]; //TODO
}

//-------------------------------------------------------------------
// revertColorsToDefaults:
// Changes colors back to defaults
//-------------------------------------------------------------------
- (IBAction)revertColorsToDefaults:(id)sender
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[colorSet revertToDefaultColors];
	[colorSet registerColorDefaults:TRUE];
	[self updateColorWells];
	[nc postNotificationName:@"channelColorChanged" object:nil];
	[nc postNotificationName:@"channelListColorChanged" object:nil];
	[nc postNotificationName:@"nickListColorChanged" object:nil];
	[nc postNotificationName:@"inputTextFieldColorChanged" object:nil];
}



- (IBAction)buttonChange:(id)sender
{
  if (sender != self && sender != chatEventPopUpButton) // we didn't trigger our own update
  {
    NSString *event = [eventController eventCodeForName:[[chatEventPopUpButton selectedItem] title]];
    [eventController setBoolForEvent:event alert:@"playSound" value:[playSoundButton state]];
    
    [eventController setBoolForEvent:event alert:@"playSoundBackground" value:[playSoundBackgroundButton state]];
    [eventController setBoolForEvent:event alert:@"bounceIcon" value:[bounceIconButton state]];
    [eventController setBoolForEvent:event alert:@"bounceIconUntilFront" value:[bounceIconUntilFrontButton state]];
    [eventController setBoolForEvent:event alert:@"growlEvent" value:[growlEventButton state]];
    [eventController setBoolForEvent:event alert:@"growlEventBackground" value:[growlEventBackgroundButton state]];
    [eventController setBoolForEvent:event alert:@"growlEventUntilFront" value:[growlEventUntilFrontButton state]];
  }
  
  [soundListPopUpButton setEnabled:[playSoundButton state]];
  [playSoundBackgroundButton setEnabled:[playSoundButton state]];
  
  [bounceIconUntilFrontButton setEnabled:[bounceIconButton state]];
  
  [growlEventBackgroundButton setEnabled:[growlEventButton state]];
  [growlEventUntilFrontButton setEnabled:[growlEventButton state]];
}

#pragma mark Text Encodings

/**
 * Inserts all text encodings into the text encoding popup button
 */
- (void)initTextEncodingPopUpButton
{
	int i;
	
	[textEncodingPopUpButton removeAllItems];
	
	for (i = 0; i < NUM_TEXT_ENCODINGS; i++)
		[textEncodingPopUpButton addItemWithTitle:textEncodings[i]];
}

/**
 * Updates text encoding popup button with current settings.
 */
- (void)updateTextEncodingPopUpButton
{
	CFStringEncoding textEncoding = [[NSUserDefaults standardUserDefaults] integerForKey:@"defaultTextEncoding"];
	
	/* Reverse lookup of user readable name by using linear search */
	int i;
	for (i = 0; i < NUM_TEXT_ENCODINGS; i++) {
		if (textEncodingTable[i] == textEncoding) {
			[textEncodingPopUpButton selectItemAtIndex:i];
			[textEncodingPopUpButton setNeedsDisplay:TRUE];
			return;
		}
	}
	
	NSLog(@"Reverse lookup of default text encoding failed!");
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
  NSString *file;
  
  NSDirectoryEnumerator *dirEnumerator = [fileManager enumeratorAtPath:[resourcePath stringByAppendingPathComponent:@"Sounds"]];
  while (file = [dirEnumerator nextObject])
  {
    NSMenuItem *item = [[NSMenuItem alloc] init];
    [item setTitle:[file stringByDeletingPathExtension]];
    [item setImage:[NSImage imageNamed:@"sound"]]; 
    [[soundListPopUpButton menu] addItem:[item autorelease]];
  }
  
  [[soundListPopUpButton menu] addItem:[NSMenuItem separatorItem]];
  
  dirEnumerator = [fileManager enumeratorAtPath:@"/System/Library/Sounds"];
  while (file = [dirEnumerator nextObject])
  {
    NSMenuItem *item = [[NSMenuItem alloc] init];
    [item setTitle:[file stringByDeletingPathExtension]];
    [item setImage:[NSImage imageNamed:@"sound"]]; 
    [[soundListPopUpButton menu] addItem:[item autorelease]];
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
  [growlEventButton setState:[eventController boolForEvent:eventCode alert:@"growlEvent"]];
  [growlEventBackgroundButton setState:[eventController boolForEvent:eventCode alert:@"growlEventBackground"]];
  [growlEventUntilFrontButton setState:[eventController boolForEvent:eventCode alert:@"growlEventUntilFront"]];
  
  [self buttonChange:sender];
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
}

#pragma mark Themes

- (IBAction)updateThemeList:(id)sender
{
	[self findAvailibleThemes];
}

/**
 * Selects the currently used theme in the theme table view
 */
- (void)selectCurrentTheme
{
	int i;
	
	if (!current_theme)
		return;
	
	NSString *currentTheme = [NSString stringWithCString:current_theme->name];
	for (i = 0; i < [availibleThemes count]; i++) {
		if ([[availibleThemes objectAtIndex:i] caseInsensitiveCompare:currentTheme] == NSOrderedSame) {
			[themeTableView selectRow:i byExtendingSelection:FALSE];
			[themeTableView scrollRowToVisible:i];
			
			previewTimer = [[NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(requestPreview:) userInfo:currentTheme repeats:FALSE] retain];
			return;
		}
	}
}

/**
 * Finds all availible themes
 */
- (void)findAvailibleThemes
{
	[availibleThemes removeAllObjects];
	
	NSArray *locations = [appController themeLocations];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	int i, j;
	for (i = 0; i < [locations count]; i++) {
		NSArray *files = [fileManager directoryContentsAtPath:[locations objectAtIndex:i]];
		
		if (!files)
			continue;
		
		for (j = 0; j < [files count]; j++) {
			NSString *file = [files objectAtIndex:j];
			
			/** Remove .theme suffix and add to array */
			if ([file hasSuffix:@".theme"])
				[availibleThemes addObject:[file substringToIndex:[file length] - 6]];
		}			
	}

	[themeTableView reloadData];
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
	NSString *key;
	
	colorChanged = TRUE;
	
	if (sender == channelBGColorWell) {
		key = @"channelBGColor";
		[colorSet setChannelBGColor:color];
		[nc postNotificationName:@"channelColorChanged" object:color];
		[previewTextView setBackgroundColor:color];
		[previewTextView setNeedsDisplay:TRUE];
	}
	else if (sender == channelFGColorWell) {
		key = @"channelFGDefaultColor";
		[colorSet setChannelFGDefaultColor:color];
		[nc postNotificationName:@"channelColorChanged" object:color];
	}
	else if (sender == channelListBGColorWell) {
		key = @"channelListBGColor";
		[colorSet setChannelListBGColor:color];
		[nc postNotificationName:@"channelListColorChanged" object:color];
	}
	else if (sender == channelListFGNoActivityColorWell) {
		key = @"channelListFGNoActivityColor";
		[colorSet setChannelListFGColorOfLevel:0 toColor:color];
		[nc postNotificationName:@"channelListColorChanged" object:color];
	}
	else if (sender == channelListFGActionColorWell) {
		key = @"channelListFGActionColor";
		[colorSet setChannelListFGColorOfLevel:1 toColor:color];
		[nc postNotificationName:@"channelListColorChanged" object:color];
	}
	else if (sender == channelListFGPublicMessageColorWell) {
		key = @"channelListFGPublicMessageColor";
		[colorSet setChannelListFGColorOfLevel:2 toColor:color];
		[nc postNotificationName:@"channelListColorChanged" object:color];
	}
	else if (sender == channelListFGPrivateMessageColorWell) {
		key = @"channelListFGPrivateMessageColor";
		[colorSet setChannelListFGColorOfLevel:3 toColor:color];
		[nc postNotificationName:@"channelListColorChanged" object:color];
	}
	else if (sender == inputTextFieldBGColorWell) {
		key = @"inputTextFieldBGColor";
		[colorSet setInputTextFieldBGColor:color];
		[nc postNotificationName:@"inputTextFieldColorChanged" object:color];
	}
	else if (sender == inputTextFieldFGColorWell) {
		key = @"inputTextFieldFGColor";
		[colorSet setInputTextFieldFGColor:color];
		[nc postNotificationName:@"inputTextFieldColorChanged" object:color];
	}
	else if (sender == nickListBGColorWell) {
		key = @"nickListBGColor";
		[colorSet setNickListBGColor:color];
		[nc postNotificationName:@"nickListColorChanged" object:color];
	}
	else if (sender == nickListFGHalfOpColorWell) {
		key = @"nickListFGHalfOpColor";
		[colorSet setNickListFGColorOfStatus:halfOpStatus toColor:color];
		[nc postNotificationName:@"nickListColorChanged" object:color];
	}
	else if (sender == nickListFGNormalColorWell) {
		key = @"nickListFGNormalColor";
		[colorSet setNickListFGColorOfStatus:normalStatus toColor:color];
		[nc postNotificationName:@"nickListColorChanged" object:color];
	}
	else if (sender == nickListFGOpColorWell) {
		key = @"nickListFGOpColor";
		[colorSet setNickListFGColorOfStatus:opStatus toColor:color];
		[nc postNotificationName:@"nickListColorChanged" object:color];
	}
	else if (sender == nickListFGServerOpColorWell) {
		key = @"nickListFGServerOpColor";
		[colorSet setNickListFGColorOfStatus:serverOpStatus toColor:color];
		[nc postNotificationName:@"nickListColorChanged" object:color];
	}
	else if (sender == nickListFGVoiceColorWell) {
		key = @"nickListFGVoiceColor";
		[colorSet setNickListFGColorOfStatus:voiceStatus toColor:color];
		[nc postNotificationName:@"nickListColorChanged" object:color];
	}
  
  // Update the colors
  NSData *colorAsData = [NSArchiver archivedDataWithRootObject:color];
  [[NSUserDefaults standardUserDefaults] setObject:colorAsData forKey:key];
}

//-------------------------------------------------------------------
// saveColorChanges
// Saves the colors selected in preference panel
//-------------------------------------------------------------------
  - (void)saveColorChanges
{
	if (!colorChanged)
		return;
	
	NSData *colorAsData;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	colorAsData = [NSArchiver archivedDataWithRootObject:[channelBGColorWell color]];
	[defaults setObject:colorAsData forKey:@"channelBGColor"];
	
	colorAsData = [NSArchiver archivedDataWithRootObject:[channelFGColorWell color]];
	[defaults setObject:colorAsData forKey:@"channelFGDefaultColor"];
	
	colorAsData = [NSArchiver archivedDataWithRootObject:[channelListBGColorWell color]];
	[defaults setObject:colorAsData forKey:@"channelListBGColor"];
		
	colorAsData = [NSArchiver archivedDataWithRootObject:[channelListFGNoActivityColorWell color]];
	[defaults setObject:colorAsData forKey:@"channelListFGNoActivityColor"];
	
	colorAsData = [NSArchiver archivedDataWithRootObject:[channelListFGActionColorWell color]];
	[defaults setObject:colorAsData forKey:@"channelListFGActionColor"];
	
	colorAsData = [NSArchiver archivedDataWithRootObject:[channelListFGPublicMessageColorWell color]];
	[defaults setObject:colorAsData forKey:@"channelListFGPublicMessageColor"];
	
	colorAsData = [NSArchiver archivedDataWithRootObject:[channelListFGPrivateMessageColorWell color]];
	[defaults setObject:colorAsData forKey:@"channelListFGPrivateMessageColor"];
	
	colorAsData = [NSArchiver archivedDataWithRootObject:[inputTextFieldBGColorWell color]];
	[defaults setObject:colorAsData forKey:@"inputTextFieldBGColor"];
	
	colorAsData = [NSArchiver archivedDataWithRootObject:[inputTextFieldFGColorWell color]];
	[defaults setObject:colorAsData forKey:@"inputTextFieldFGColor"];
	
	colorAsData = [NSArchiver archivedDataWithRootObject:[nickListBGColorWell color]];
	[defaults setObject:colorAsData forKey:@"nickListBGColor"];
	
	colorAsData = [NSArchiver archivedDataWithRootObject:[nickListFGHalfOpColorWell color]];
	[defaults setObject:colorAsData forKey:@"nickListFGHalfOpColor"];
	
	colorAsData = [NSArchiver archivedDataWithRootObject:[nickListFGNormalColorWell color]];
	[defaults setObject:colorAsData forKey:@"nickListFGNormalColor"];
	
	colorAsData = [NSArchiver archivedDataWithRootObject:[nickListFGOpColorWell color]];
	[defaults setObject:colorAsData forKey:@"nickListFGOpColor"];
	
	colorAsData = [NSArchiver archivedDataWithRootObject:[nickListFGServerOpColorWell color]];
	[defaults setObject:colorAsData forKey:@"nickListFGServerOpColor"];
	
	colorAsData = [NSArchiver archivedDataWithRootObject:[nickListFGVoiceColorWell color]];
	[defaults setObject:colorAsData forKey:@"nickListFGVoiceColor"];
	
}

//-------------------------------------------------------------------
// cancelColorChanges
// Revert colors to their 'pre-preferenced' state
//-------------------------------------------------------------------
- (void)cancelColorChanges
{
	if (!colorChanged)
		return;

	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSColor *color;
	
	color = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"channelBGColor"]];
	[colorSet setChannelBGColor:color];
	color = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"channelFGDefaultColor"]];
	[colorSet setChannelFGDefaultColor:color];
	
	color = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"channelListBGColor"]];
	[colorSet setChannelListBGColor:color];
	color = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"channelListFGNoActivityColor"]];
	[colorSet setChannelListFGColorOfLevel:0 toColor:color];
	color = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"channelListFGActionColor"]];
	[colorSet setChannelListFGColorOfLevel:1 toColor:color];
	color = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"channelListFGPublicMessageColor"]];
	[colorSet setChannelListFGColorOfLevel:2 toColor:color];
	color = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"channelListFGPrivateMessageColor"]];
	[colorSet setChannelListFGColorOfLevel:3 toColor:color];
	
	color = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"inputTextFieldBGColor"]];
	[colorSet setInputTextFieldBGColor:color];
	color = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"inputTextFieldFGColor"]];
	[colorSet setInputTextFieldFGColor:color];
	
	color = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"nickListBGColor"]];
	[colorSet setNickListBGColor:color];
	color = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"nickListFGHalfOpColor"]];
	[colorSet setNickListFGColorOfStatus:halfOpStatus toColor:color];
	color = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"nickListFGNormalColor"]];
	[colorSet setNickListFGColorOfStatus:normalStatus toColor:color];
	color = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"nickListFGOpColor"]];
	[colorSet setNickListFGColorOfStatus:opStatus toColor:color];
	color = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"nickListFGServerOpColor"]];
	[colorSet setNickListFGColorOfStatus:serverOpStatus toColor:color];
	color = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"nickListFGVoiceColor"]];
	[colorSet setNickListFGColorOfStatus:voiceStatus toColor:color];
	
	[nc postNotificationName:@"inputTextFieldColorChanged" object:color];
	[nc postNotificationName:@"channelListColorChanged" object:color];
	[nc postNotificationName:@"channelColorChanged" object:color];
	[nc postNotificationName:@"nickListColorChanged" object:color];
}

//-------------------------------------------------------------------
// updateColorWells
// Updates the color wells to reflect current settings
//-------------------------------------------------------------------
- (void)updateColorWells
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData *colorAsData;

	colorAsData = [defaults objectForKey:@"channelFGDefaultColor"];
	[channelFGColorWell setColor:[NSUnarchiver unarchiveObjectWithData:colorAsData]];

	colorAsData = [defaults objectForKey:@"channelBGColor"];
	[channelBGColorWell setColor:[NSUnarchiver unarchiveObjectWithData:colorAsData]];

	colorAsData = [defaults objectForKey:@"channelListBGColor"];
	[channelListBGColorWell setColor:[NSUnarchiver unarchiveObjectWithData:colorAsData]];

	colorAsData = [defaults objectForKey:@"channelListFGNoActivityColor"];
	[channelListFGNoActivityColorWell setColor:[NSUnarchiver unarchiveObjectWithData:colorAsData]];

	colorAsData = [defaults objectForKey:@"channelListFGActionColor"];
	[channelListFGActionColorWell setColor:[NSUnarchiver unarchiveObjectWithData:colorAsData]];

	colorAsData = [defaults objectForKey:@"channelListFGPublicMessageColor"];
	[channelListFGPublicMessageColorWell setColor:[NSUnarchiver unarchiveObjectWithData:colorAsData]];

	colorAsData = [defaults objectForKey:@"channelListFGPrivateMessageColor"];
	[channelListFGPrivateMessageColorWell setColor:[NSUnarchiver unarchiveObjectWithData:colorAsData]];

	colorAsData = [defaults objectForKey:@"nickListBGColor"];
	[nickListBGColorWell setColor:[NSUnarchiver unarchiveObjectWithData:colorAsData]];

	colorAsData = [defaults objectForKey:@"nickListFGNormalColor"];
	[nickListFGNormalColorWell setColor:[NSUnarchiver unarchiveObjectWithData:colorAsData]];

	colorAsData = [defaults objectForKey:@"nickListFGVoiceColor"];
	[nickListFGVoiceColorWell setColor:[NSUnarchiver unarchiveObjectWithData:colorAsData]];

	colorAsData = [defaults objectForKey:@"nickListFGHalfOpColor"];
	[nickListFGHalfOpColorWell setColor:[NSUnarchiver unarchiveObjectWithData:colorAsData]];

	colorAsData = [defaults objectForKey:@"nickListFGOpColor"];
	[nickListFGOpColorWell setColor:[NSUnarchiver unarchiveObjectWithData:colorAsData]];

	colorAsData = [defaults objectForKey:@"nickListFGServerOpColor"];
	[nickListFGServerOpColorWell setColor:[NSUnarchiver unarchiveObjectWithData:colorAsData]];

	colorAsData = [defaults objectForKey:@"inputTextFieldFGColor"];
	[inputTextFieldFGColorWell setColor:[NSUnarchiver unarchiveObjectWithData:colorAsData]];

	colorAsData = [defaults objectForKey:@"inputTextFieldBGColor"];
	[inputTextFieldBGColorWell setColor:[NSUnarchiver unarchiveObjectWithData:colorAsData]];
	
}

#pragma mark Daemon Crap

/**
 * Called when ThemePreviewDaemon is ready for connections.
 */
- (void)daemonInitiationComplete
{	
	/* Set up connection to ThemePreviewDaemon */
	themePreviewDaemon = [NSConnection rootProxyForConnectionWithRegisteredName:@"ThemePreviewDaemon" host:nil];
	
	if (!themePreviewDaemon) {
		NSLog(@"Unable to connect to ThemePreviewDaemon!");
		return;
	}
	
	[themePreviewDaemon retain];
	[themePreviewDaemon setProtocolForProxy:@protocol(ThemePreviewDaemonProtocol)];	
	[self selectCurrentTheme];
}

- (void)returnPreview:(NSAttributedString *)result
{
	[[previewTextView textStorage] setAttributedString:result];
}

/**
 * Initiates connection to theme preivew daemon
 */
- (void)connectToThemePreviewDaemon
{
	/* first kill old daemon if running */
	system("killall ThemePreviewDaemon textserver");
	
	/* Launch daemon as a NSTask */
	NSTask *task = [[NSTask alloc] init];
	NSString *launchPath = @"Contents/ThemePreviewDaemon/ThemePreviewDaemon";
	[task setLaunchPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], launchPath]];
	[task setArguments:[NSArray array]];
	[task launch];	//TODO: release task when done	
}

/**
 * Registers self as a distributed object. Then launches the Theme Preview Daemon in a subprocess.
 */
- (void)registerDistributedObject
{
	/* Register as distributed object */
	NSConnection *connection = [NSConnection defaultConnection];
	[connection setRootObject:self];
	
	if (![connection registerName:@"MacIrssi"]) {
		NSLog(@"Unable to register name!");
		//[[NSAlert alertWithMessageText:@"Another copy of MacIrssi is running" defaultButton:@"Quit" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Unable to register remote object used for theme preview funcionality!"] runModal];
		//[NSApp terminate:self];
    return;
	}
	
	[connection retain]; //TODO release
	[connection setDelegate:self];
}

/**
 * Shuts down theme preview daemon and closes window
 */
- (void)close
{
	@try {
		[themePreviewDaemon shutDown];
	}
	@catch (NSException *e) {
		NSLog(@"Unable to shut down ThemePreviewDaemon");
	}
}

#pragma mark TableView delegate/data source
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [availibleThemes count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	NSAssert(aTableView == themeTableView, @"aTableView != themeTableView");
	
	if (rowIndex >= [availibleThemes count]) {
		NSLog(@"Theme table is requesting a row that is out of bounds!");
		return nil;
	}
	
	return [availibleThemes objectAtIndex:rowIndex];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	//NSAssert([aNotification object] == themeTableView, @"[aNotification object] != themeTableView");
  if ([aNotification object] == themeTableView)
  {
    int row = [themeTableView selectedRow];
    
    if (!themePreviewDaemon || row < 0 || row >= [availibleThemes count])
      return;
    
    /* If we have a old request waiting to be processed, remove it */
    if ([previewTimer isValid])
      [previewTimer invalidate];
    
    
    /* Wait at least a small time intervall between preview requests */
    NSString *theme = [availibleThemes objectAtIndex:row];
    [previewTimer release];
    previewTimer = [[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(requestPreview:) userInfo:theme repeats:FALSE] retain];
  }	
}

- (void)requestPreview:(NSTimer*)theTimer
{
	@try {
		[themePreviewDaemon requestPreviewForThemeNamed:[theTimer userInfo] usingColorSet:colorSet font:[NSFont fontWithName:@"Monaco" size:9.0]];
	}
	@catch (NSException *e) {
		NSLog(@"Unable to create preivew!");
		[[NSAlert alertWithMessageText:@"Unable to create preivew!" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Exception while contacting Theme Preivew Daemon."] runModal];
	}
}

#pragma mark Network Preference Panel

- (IBAction)addNetworkAction:(id)sender
{
  [self showNetworkPanel:self];
}

- (IBAction)deleteNetworkAction:(id)sender
{
  [preferenceObjectController deleteChatnetWithIndex:[networksArrayController selectionIndex]];
  [networksArrayController setContent:[preferenceObjectController chatnetArray]];
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
  [preferenceObjectController addServerWithAddress:@"irc.example.com" port:6667];
  [serversArrayController setContent:[preferenceObjectController serverArray]];
}

- (IBAction)deleteServerAction:(id)sender
{
  [preferenceObjectController deleteServerWithIndex:[serversArrayController selectionIndex]];
  [serversArrayController setContent:[preferenceObjectController serverArray]];
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
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
  return [NSArray arrayWithObjects:@"General", @"Notifications", @"Colours", @"Networks", @"Servers", nil];
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
  
  return [toolbarItem autorelease];
}

#pragma mark Deprecated

- (IBAction)saveChanges:(id)sender
{
  NSLog(@"saveChanges: should never been here really");
  
	/*************************
   * Identification setting *
   **************************/
	char *tmp = [IrssiBridge irssiCStringWithString:[defaultNickField stringValue]];
	if (strcmp(tmp, settings_get_str("nick")) != 0)
		settings_set_str("nick", tmp);
	
	free(tmp);
	tmp = [IrssiBridge irssiCStringWithString:[defaultAltNickField stringValue]];
	if (strcmp(tmp, settings_get_str("alternate_nick")) != 0)
		settings_set_str("alternate_nick", tmp);
	
	free(tmp);
	tmp = [IrssiBridge irssiCStringWithString:[defaultUsernameField stringValue]];
	if (strcmp(tmp, settings_get_str("user_name")) != 0)
		settings_set_str("user_name", tmp);
  
	free(tmp);
	tmp = [IrssiBridge irssiCStringWithString:[defaultRealnameField stringValue]];
	if (strcmp(tmp, settings_get_str("real_name")) != 0)
		settings_set_str("real_name", tmp);
	
	free(tmp);
	
	/*****************
   * Color	settings * 
   ******************/
	[self saveColorChanges];
	
	/************************
   * Key bindings settings *
   ************************/
	int i;
	for (i = 0; i < 12; i++)
		if (shortcutCommands[i])
			[shortcutCommands[i] release];
	
//	shortcutCommands[0] = [[NSString alloc] initWithString:[F1Field stringValue]];
//	shortcutCommands[1] = [[NSString alloc] initWithString:[F2Field stringValue]];
//	shortcutCommands[2] = [[NSString alloc] initWithString:[F3Field stringValue]];
//	shortcutCommands[3] = [[NSString alloc] initWithString:[F4Field stringValue]];
//	shortcutCommands[4] = [[NSString alloc] initWithString:[F5Field stringValue]];
//	shortcutCommands[5] = [[NSString alloc] initWithString:[F6Field stringValue]];
//	shortcutCommands[6] = [[NSString alloc] initWithString:[F7Field stringValue]];
//	shortcutCommands[7] = [[NSString alloc] initWithString:[F8Field stringValue]];
//	shortcutCommands[8] = [[NSString alloc] initWithString:[F9Field stringValue]];
//	shortcutCommands[9] = [[NSString alloc] initWithString:[F10Field stringValue]];
//	shortcutCommands[10] = [[NSString alloc] initWithString:[F11Field stringValue]];
//	shortcutCommands[11] = [[NSString alloc] initWithString:[F12Field stringValue]];
	
	for (i = 0; i < 12; i++)
		[[NSUserDefaults standardUserDefaults] setObject:shortcutCommands[i] forKey:[NSString stringWithFormat:@"shortcut%d", i+1]];
	
	[appController setShortcutCommands:shortcutCommands];
	
	/********
   * Theme *
   ********/
	[appController loadTheme:[availibleThemes objectAtIndex:[themeTableView selectedRow]]];
	
	/****************
   * Text encoding *
   ****************/
	int selectedEncodingIndex = [textEncodingPopUpButton indexOfSelectedItem];
	if (selectedEncodingIndex < 0 || selectedEncodingIndex >= NUM_TEXT_ENCODINGS)
		NSLog(@"selectedEncodingIndex out of bounds!");
	else
		[[NSUserDefaults standardUserDefaults] setInteger:textEncodingTable[selectedEncodingIndex] forKey:@"defaultTextEncoding"];
  
  [eventController commitChanges];
  
	[self close];
}

//-------------------------------------------------------------------
// cancelChanges:
// Cancel the changes made in preference panel (only need to fix
// colors)
//-------------------------------------------------------------------
- (IBAction)cancelChanges:(id)sender
{
	[self cancelColorChanges];
  [eventController cancelChanges];
	[self close];
}

@end
