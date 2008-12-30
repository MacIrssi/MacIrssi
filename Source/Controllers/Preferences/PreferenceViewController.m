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
#import "NSAttributedStringAdditions.h"
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
    
    availableThemes = [[NSMutableArray alloc] init];
    appController = controller;
    eventController = [appController eventController];
    
    [themePreviewTextView setBackgroundColor:[ColorSet channelBackgroundColor]];
    
    [self initTextEncodingPopUpButton];
    [self initChatEventsPopUpButton];
    [self initSoundListPopUpButton];
    
    [[NSColorPanel sharedColorPanel] setShowsAlpha:TRUE];
    [[NSColorPanel sharedColorPanel] setContinuous:TRUE];  
  }
	return self;
}

- (void)dealloc
{
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
  
  /* By default open the general tab and resize the window around it */
  [self switchPreferenceWindowTo:generalPreferencesTab animate:NO];
  [preferencesToolbar setSelectedItemIdentifier:@"General"];
	
	[self updateTextEncodingPopUpButton];
  [self updateSoundListPopUpButton];
  [self updateChatEventsPopUpButton];

  [self findAvailableThemes];
  [themesArrayController setSelectedObjects:[NSArray arrayWithObjects:[preferenceObjectController theme], nil]];
  [self previewTheme:[preferenceObjectController theme]];
  
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

  [self release];
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
  [ColorSet revertToDefaults];
  
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

#pragma mark Themes Preference Panel

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
  NSString *theme = [[themesArrayController selectedObjects] objectAtIndex:0];
  [self renderPreviewTheme:theme];
  [preferenceObjectController setTheme:theme];
}

- (void)renderPreviewTheme:(NSString*)themeName
{
  WINDOW_REC windowRec;
  TEXT_DEST_REC dest;
  
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
  
  windowRec.theme = theme_load([IrssiBridge irssiCStringWithString:themeName]);
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

  signal_remove("gui print text", (SIGNAL_FUNC)(SIGNAL_FUNC)_preferences_bridge_print_text);
  signal_remove("gui print text finished", (SIGNAL_FUNC)_preferences_bridge_print_text_finished);
  
  free(windowRec.hilight_color);
}

- (void)printTextCallback:(char*)cText foreground:(int)fg background:(int)bg flags:(int)flags
{
  NSString *text = [IrssiBridge stringWithIrssiCString:cText];
  
  NSFont *channelFont = [NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] valueForKey:@"channelFont"]];
  NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:channelFont, NSFontAttributeName,nil];
  
  themeRenderLineBuffer = [themeRenderLineBuffer attributedStringByAppendingString:text foreground:fg background:bg flags:flags attributes:attributes];
}

- (void)printTextFinishedCallback
{
  [themeRenderLineBuffer appendAttributedString:[[[NSMutableAttributedString alloc] initWithString:@"\n"] autorelease]];
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
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
  return [NSArray arrayWithObjects:@"General", @"Notifications", @"Colours", @"Networks", @"Servers", @"Themes", nil];
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
    [toolbarItem setLabel:@"Themes"];
    [toolbarItem setImage:[NSImage imageNamed:@"Themes"]];
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
		
	/****************
   * Text encoding *
   ****************/
	int selectedEncodingIndex = [textEncodingPopUpButton indexOfSelectedItem];
	if (selectedEncodingIndex < 0 || selectedEncodingIndex >= NUM_TEXT_ENCODINGS)
		NSLog(@"selectedEncodingIndex out of bounds!");
	else
		[[NSUserDefaults standardUserDefaults] setInteger:textEncodingTable[selectedEncodingIndex] forKey:@"defaultTextEncoding"];
  
  [eventController commitChanges];
  
}

//-------------------------------------------------------------------
// cancelChanges:
// Cancel the changes made in preference panel (only need to fix
// colors)
//-------------------------------------------------------------------
- (IBAction)cancelChanges:(id)sender
{
  [eventController cancelChanges];
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