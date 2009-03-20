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
// MacIrssi - AppController
// Nils Hjelte, c01nhe@cs.umu.se
//
// Main application controller
//*****************************************************************

#import <Growl/GrowlApplicationBridge.h>

#import "AppController.h"
#import "ChannelController.h"
#import "PreferenceViewController.h"
#import "EventController.h"
#import "AppcastVersionComparator.h"
#import "CustomWindow.h"
#import "CustomTableView.h"
#import "History.h"
#import "ColorSet.h"
#import "ConnectivityMonitor.h"
#import "IrssiBridge.h"

// For shortcuts
#import "SRCommon.h"
#import "SRKeyCodeTransformer.h"
#import "ShortcutBridgeController.h"

// For iChooons
#import "iTunes.h"

// For encodings
#import "TextEncodings.h"

#import "chatnets.h"
#import "irc.h"
#import "irc-chatnets.h"
#import "irc-servers-setup.h"
#import "fe-common-core.h"

#define PASTE_WARNING_THRESHOLD 4

void setRefToAppController(AppController *a);
void textui_deinit();
static GMainLoop *main_loop;
int argc;
char **argv;

@interface NSFontManager (StupidHeaderFixes)

- (void)setTarget:(id)target;

@end

@implementation AppController

#pragma mark IBAction methods
- (IBAction)findNext:(id)sender
{
  [currentChannelController moveToNextSearchMatch];
}

- (IBAction)findPrevious:(id)sender
{
  [currentChannelController moveToPreviousSearchMatch];
}

- (IBAction)useSelectionForFind:(id)sender
{
  if (![[mainWindow firstResponder] isKindOfClass:[NSTextView class]])
    return;
  
  NSTextView *textView = (NSTextView *)[mainWindow firstResponder];
  NSString *selectedText = [[textView string] substringWithRange:[textView selectedRange]];
  
  [currentChannelController searchForString:selectedText];
}

//-------------------------------------------------------------------
// editCurrentChannel:
// Brings up the channel edit sheet for the current channel. 
//
// "sender" - A menu item
//-------------------------------------------------------------------
- (IBAction)editCurrentChannel:(id)sender
{
  [currentChannelController raiseTopicWindow:sender];
}

//-------------------------------------------------------------------
// makeSearchFieldFirstResponder:
// Makes the searchfield first responder. 
//
// "sender" - A menu item
//-------------------------------------------------------------------
- (IBAction)makeSearchFieldFirstResponder:(id)sender
{
  [currentChannelController makeSearchFieldFirstResponder];
}

//-------------------------------------------------------------------
// showFontPanel:
// Brings up the font panel.
//
// "sender" - A menu item
//-------------------------------------------------------------------
- (IBAction)showFontPanel:(id)sender
{
  NSFont *channelFont = [NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] valueForKey:@"channelFont"]];
  
  [[NSFontManager sharedFontManager] setAction:@selector(specialFontChange:)];
  [[NSFontManager sharedFontManager] setTarget:self];
  [[NSFontManager sharedFontManager] orderFrontFontPanel:sender];
  [[NSFontManager sharedFontManager] setSelectedFont:channelFont isMultiple:FALSE];
}


//-------------------------------------------------------------------
// gotoChannel:
// Called when user selects channel in channel menu. Makes that
// channel active
//
// "sender" - The menu item selected
//-------------------------------------------------------------------
- (IBAction)gotoChannel:(id)sender
{
  WINDOW_REC *tmp = [currentChannelController windowRec];
  int index = [channelMenu indexOfItem:sender] - 7;
  NSString *cmd = [NSString stringWithFormat:@"/window %d", index];
  signal_emit("send command", 3, [cmd cStringUsingEncoding:NSASCIIStringEncoding], tmp->active_server, tmp->active);
}


//-------------------------------------------------------------------
// activeChannel:
// Goes to the channel with the highest activity (data level).
//
// "sender" - The menu item selected
//-------------------------------------------------------------------
- (IBAction)activeChannel:(id)sender
{
  WINDOW_REC *tmp = [currentChannelController windowRec];
  signal_emit("command window goto", 3, "active", tmp->active_server, tmp->active);
}

- (NSArray *)splitCommand:(NSString *)command
{
  int i, j;
  NSMutableArray *commands = [[NSMutableArray alloc] initWithCapacity:100];
  NSArray *firstSplit = [command componentsSeparatedByString:@"\n"];
  for (i = 0; i < [firstSplit count]; i++) {
    
    /* Also need to remove carriage returns */
    NSArray *secondSplit = [[firstSplit objectAtIndex:i] componentsSeparatedByString:@"\r"];
    
    for (j = 0; j < [secondSplit count]; j++)
      [commands addObject:[secondSplit objectAtIndex:j]];
  }
  
  return [commands autorelease];
}

//-------------------------------------------------------------------
// sendCommand:
// Receives commands from user and passes them on to irssi engine
//
// "sender" - The input text field
//-------------------------------------------------------------------
- (IBAction)sendCommand:(id)sender
{
  int i;
  NSString *cmd = [NSString stringWithString:[sender string]];
  
  if ([cmd length] == 0)
    return;
  
  WINDOW_REC *rec = [currentChannelController windowRec];
  CFStringEncoding enc = [[MITextEncoding irssiEncoding] encoding];
  [[currentChannelController commandHistory] addCommand:cmd];
  
  NSArray *commands = [self splitCommand:cmd];
  
  /* Check with user before sending multiple lines */
  if ([commands count] > PASTE_WARNING_THRESHOLD) {
    int button = [[NSAlert alertWithMessageText:@"Confirmation request" defaultButton:@"Ok" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@"Do you really want to paste %d lines?", [commands count]] runModal];
    
    if (button == 0)
      return;
  }
  
  [sender setString:@""];
  
  for (i = 0; i < [commands count]; i++) {
    /* Test if clear command (special case) */
    if ([[commands objectAtIndex:i] isEqualToString:@"/clear"]) {
      [currentChannelController clearTextView];
      continue;
    }
    
    /* Test for iTunes command */
    if ([[[commands objectAtIndex:i] lowercaseString] isEqualToString:@"/itunes"])
    {
      iTunes *it = [[[iTunes alloc] init] autorelease];
      NSString *nowPlaying;
      
      if ([it isRunning] && [it isPlaying])
      {
        nowPlaying = [NSString stringWithFormat:@"/me is listening to %@ by %@ from %@.", [it currentTitle], [it currentArtist], [it currentAlbum]];
      }
      else if ([it isRunning] && ![it isPlaying])
      {
        nowPlaying = @"/me is listening to silence!";
      }
      else
      {
        nowPlaying = @"/me typed /itunes when it wasn't even open. Doh!";
      }

      char *tmp = [IrssiBridge irssiCStringWithString:nowPlaying encoding:enc];
      signal_emit("send command", 3, tmp, rec->active_server, rec->active);
      free(tmp);
      
      continue;
    }
    
    /* Else normal command */
    char *tmp = [IrssiBridge irssiCStringWithString:[commands objectAtIndex:i] encoding:enc];
    signal_emit("send command", 3, tmp, rec->active_server, rec->active);
    free(tmp);
  }
}

#if 0
//-------------------------------------------------------------------
// paste:
// Makes sure all pastes go into the input text field
//
// "sender" - The paste menu item
//-------------------------------------------------------------------
- (IBAction)paste:(id)sender
{
  if (![mainWindow isKeyWindow]) {
    [[[NSApp keyWindow] fieldEditor:FALSE forObject:nil] paste:sender];
    return;
  }
  
  if (![[mainWindow firstResponder] respondsToSelector:@selector(isDescendantOf:)] || ![(NSTextView *)[mainWindow firstResponder] isDescendantOf:inputTextField]) {
    NSRange tmp;
    [mainWindow makeFirstResponder:inputTextField];
    tmp.location = [[(NSTextView *)[mainWindow firstResponder] textStorage] length];
    [(NSTextView *)[mainWindow firstResponder] setSelectedRange:tmp];
  }
  
  [[mainWindow fieldEditor:FALSE forObject:nil] paste:sender];
}
#endif

//-------------------------------------------------------------------
// closeChannel:
// Closes the current channel
//
// "sender" - A menu item
//-------------------------------------------------------------------
- (IBAction)closeChannel:(id)sender
{
  if (![mainWindow isKeyWindow])
  {
    // Probably the preference window, redirect the command there instead.
    [[NSApp keyWindow] close];
    return;
  }
  
  WINDOW_REC *tmp = [currentChannelController windowRec];
  signal_emit("command window close", 3, "", tmp->active_server, tmp->active);
}

//-------------------------------------------------------------------
// nextChannel:
// Goes to the next channel
//
// "sender" - A menu item
//-------------------------------------------------------------------
- (IBAction)nextChannel:(id)sender
{
  WINDOW_REC *tmp = [currentChannelController windowRec];
  signal_emit("command window next", 3, "", tmp->active_server, tmp->active);
}


//-------------------------------------------------------------------
// previousChannel:
// Goes to the previous channel
//
// "sender" - A menu item
//-------------------------------------------------------------------
- (IBAction)previousChannel:(id)sender
{
  WINDOW_REC *tmp = [currentChannelController windowRec];
  signal_emit("command window previous", 3, "", tmp->active_server, tmp->active);
}


//-------------------------------------------------------------------
// endReasonWindow:
// Removes the reason window
//
// "sender" - A button on the reason window
//-------------------------------------------------------------------
- (IBAction)endReasonWindow:(id)sender
{
  [reasonWindow orderOut:sender];
  [NSApp endSheet:reasonWindow returnCode:1];
  if ([[sender title] isEqual:@"Ok"]) {
    NSString *str = [reasonTextField stringValue];
    signal_emit("command quit", 1, [IrssiBridge irssiCStringWithString:str]);
    [NSApp replyToApplicationShouldTerminate:YES];
  }
  [reasonTextField setStringValue:@""];
}

//-------------------------------------------------------------------
// endErrorWindow:
// Removes the error window
//
// "sender" - A button on the reason window
//-------------------------------------------------------------------
- (IBAction)endErrorWindow:(id)sender
{
  [errorWindow orderOut:sender];
  [NSApp endSheet:errorWindow returnCode:1];
  
  if ([[sender title] isEqual:@"Quit"])
  {
    signal_emit("command quit", 1, [IrssiBridge irssiCStringWithString:[[NSUserDefaults standardUserDefaults] stringForKey:@"defaultQuitMessage"]]);
  }
}

//-------------------------------------------------------------------
// showPreferencePanel:
// Brings up the preference panel
//
// "sender" - A menu item
//-------------------------------------------------------------------
- (IBAction)showPreferencePanel:(id)sender
{
  PreferenceViewController *preferenceController = [[PreferenceViewController alloc] initWithColorSet:nil appController:self]; 
  [preferenceController showWindow:self];
}

- (IBAction)showAbout:(id)sender
{
  [aboutVersionLabel setStringValue:[NSString stringWithFormat:@"Version %@ (Build %@)", 
                     [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],
                     [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSGitRevision"]]];
  
  [copyrightTextView setString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSHumanReadableCopyright"]];
  [copyrightTextView setAlignment:NSCenterTextAlignment range:NSMakeRange(0, [[copyrightTextView textStorage] length])];
  
  [aboutBox center];
  [aboutBox makeKeyAndOrderFront:sender];
}

- (IBAction)debugAction1:(id)sender
{
//  [[ConnectivityMonitor sharedMonitor] workspaceWillSleep:nil];
  g_log("moo", G_LOG_LEVEL_WARNING, "moo");
}

- (IBAction)debugAction2:(id)sender
{
  [[ConnectivityMonitor sharedMonitor] workspaceDidWake:nil];
}

#pragma mark Shortcuts

//-------------------------------------------------------------------
// setShortcutCommands
// Set up the shortcuts menu.
//-------------------------------------------------------------------
- (void)setShortcutCommands
{
  // Ngg, retarded NSMenu has no removeAllItems
  while ([shortcutsMenu numberOfItems] > 0)
  {
    [shortcutsMenu removeItemAtIndex:0];
  }
  
  // Right, if we've no shortcuts, then display a non-clickable menu item. Else...
  NSArray *shortcuts = [[NSUserDefaults standardUserDefaults] valueForKey:@"shortcutDict"];
  if ([shortcuts count] > 0)
  {
    NSEnumerator *shortcutEnumerator = [shortcuts objectEnumerator];
    NSDictionary *shortcut;
    
    while (shortcut = [shortcutEnumerator nextObject])
    {
      ShortcutBridgeController *controller = [[[ShortcutBridgeController alloc] initWithDictionary:shortcut] autorelease];
      
      NSString *equivKey = (([controller flags] & NSShiftKeyMask) | SRIsSpecialKey([controller keyCode])) ? SRStringForKeyCode([controller keyCode]) : [SRStringForKeyCode([controller keyCode]) lowercaseString];
      if (SRFunctionKeyToString([controller keyCode]))
      {
        equivKey = SRFunctionKeyToString([controller keyCode]);
      }
      
      NSString *title = [controller command];
      if ([title length] > 15)
      {
        title = [NSString stringWithFormat:@"%@...", [title stringByPaddingToLength:15 withString:@"" startingAtIndex:0]];
      }
      
      NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:title action:@selector(performShortcut:) keyEquivalent:equivKey] autorelease];
      
      [item setKeyEquivalentModifierMask:[controller flags]];
      [item setTarget:self];
      [item setTag:[controller keyCode]];
      [shortcutsMenu addItem:item];
    }
  }
  else
  {
    [shortcutsMenu addItemWithTitle:@"Empty" action:nil keyEquivalent:@""];
  }
}

//-------------------------------------------------------------------
// performShortcut:
// Performes the command that is bound to the selected menu item 
//
// "sender" - A menu item
//-------------------------------------------------------------------
- (IBAction)performShortcut:(id)sender
{
  NSMenuItem *item = sender;
  unichar letter = [[item keyEquivalent] characterAtIndex:0];
  NSString *key = SRStringForCocoaModifierFlagsAndKeyCode([item keyEquivalentModifierMask] | ([[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:letter] ? NSShiftKeyMask : 0), [item tag]);
  
  NSDictionary *dict = [[[NSUserDefaults standardUserDefaults] valueForKey:@"shortcutDict"] valueForKey:key];
  ShortcutBridgeController *controller = [[[ShortcutBridgeController alloc] initWithDictionary:dict] autorelease];
  
  WINDOW_REC *rec = [currentChannelController windowRec];
  NSArray *commands = [[controller command] componentsSeparatedByString:@";"];
  NSEnumerator *enumerator = [commands objectEnumerator];
  NSString *command;
  char *tmp, *tmp2;
  
  while (command = [enumerator nextObject]) {
    tmp2 = tmp = [IrssiBridge irssiCStringWithString:command];
    
    /* Skip whitespaces */
    while (*tmp2 == ' ')
      tmp2++;
    signal_emit("send command", 3, tmp2, rec->active_server, rec->active);
    free(tmp);
  }
}

- (void)checkAndConvertOldShortcuts
{
  // We need to iterate through the old F1-F12 shortcuts and convert them to our own
  int i;
  BOOL performedConversion = NO;
  
  for (i = 1; i < 13; i++)
  {
    NSString *key = [NSString stringWithFormat:@"shortcut%d", i];
    NSString *value = [[NSUserDefaults standardUserDefaults] valueForKey:key];
    
    if (value && [value isNotEqualTo:@""])
    {
      SRKeyCodeTransformer *transformer = [[[SRKeyCodeTransformer alloc] init] autorelease];
      ShortcutBridgeController *controller = [[[ShortcutBridgeController alloc] init] autorelease];
      
      [controller setCommand:value];
      [controller setFlags:0];
      [controller setKeyCode:[[transformer reverseTransformedValue:[NSString stringWithFormat:@"F%d", i]] intValue]];
      
      performedConversion = YES;
    }
    // Bin the old one
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
  }
  
  if (performedConversion)
  {
    [[NSAlert alertWithMessageText:@"Shortcut Conversion"
                     defaultButton:@"OK"
                   alternateButton:nil
                       otherButton:nil 
         informativeTextWithFormat:@"Your old shortcuts have been converted to the new shortcut system. You should be able to find them in the Shortcuts menu."] runModal];
  }
}

#pragma mark Indirect receivers of irssi signals
//-------------------------------------------------------------------
// highlightChanged:
// Reloads the channel table view when the hilight of a channel changes
//
// "wind" - The window rec where the change occured
//-------------------------------------------------------------------
- (void)highlightChanged:(WINDOW_REC*)wind
{
  [channelTableView reloadData];
  [channelBar setNeedsDisplay:TRUE];
}


//-------------------------------------------------------------------
// windowActivity:oldLevel:
// Receives a signal when window activity changes. It checks
// if the icon should be marked to notify the user of an event
//
// "wind" - The window rec where the change occured
// "old" - The old data level
//-------------------------------------------------------------------
- (void)windowActivity:(WINDOW_REC *)wind oldLevel:(int)old
{
  if (wind->data_level > 2 && old <= 2) {
    /* Notify user by changing icon */
    hilightChannels++;
    [self setIcon:iconOnPriv];
  }
  else if (wind->data_level == 0 && old > 2) {
    /* Check if all notified channels have been visited */
    hilightChannels--;
    if (hilightChannels == 0)
      [self setIcon:defaultIcon];
  }
}


//-------------------------------------------------------------------
// setServer:
// Indirect reciever of signal "window server changed". Updates the
// channellist to reflect the change.
//
// "serverName" - The name of the server that is now used
//-------------------------------------------------------------------
- (void)setServer:(NSString *)serverName
{
  NSString *tmp = [NSString stringWithFormat:@"Console [%@]", serverName];
  [[channelMenu itemAtIndex:8] setTitle:tmp];
  ChannelController *c = (ChannelController *)[[tabView tabViewItemAtIndex:0] identifier];
  [c setName:tmp];
  [channelTableView reloadData];
  [channelBar setNeedsDisplay:TRUE];
}

//-------------------------------------------------------------------
// newTabFromWindowRec:
// Indirect reciever of signal "window created". Creates a new tab.
//
// "wind" - The window rect that the new tab will represent
//-------------------------------------------------------------------
- (void)newTabWithWindowRec:(WINDOW_REC *)wind
{
  ChannelController *owner = [[ChannelController alloc] initWithWindowRec:wind];
  
  NSTabViewItem *tabViewItem = [[NSTabViewItem alloc] initWithIdentifier:owner];
  
  if (![NSBundle loadNibNamed:@"Tab new.nib" owner:owner]) {
    [owner release];
    printf("can't load Tab new.nib\n");
    return;
  }
  
  /* Set references */
  [owner setTabViewItem:tabViewItem colors:nil appController:self];
  
  wind->gui_data = (void *)owner;
  wind->width = 80;
  wind->height = 24;
  
  NSString *label;
  
  if (queryObject) {
    label = queryObject;
    queryObject = nil;
  }
  else if ([tabView numberOfTabViewItems] == 0)
    label = @"Console [Not connected]";
  else
    label = @"joining...";
  
  [(ChannelController *)[tabViewItem identifier] setName:label];
  [tabViewItem setView:[owner view]];
  [tabView addTabViewItem:tabViewItem];
  [channelBar addChannel:wind];
  
  /* Update up channel menu */
  int channelCount = [tabView numberOfTabViewItems];
  NSString *keyEquivalent = (channelCount < 10) ? [[NSNumber numberWithInt:channelCount] stringValue] : @"";
  NSMenuItem *newMenuItem = [[NSMenuItem alloc] initWithTitle:label action:@selector(gotoChannel:) keyEquivalent:keyEquivalent];
  [newMenuItem setTarget:self];
  [channelMenu addItem:newMenuItem];
  [newMenuItem release];
  [owner release];
  [tabViewItem release];
  [channelTableView reloadData];
  [channelBar setNeedsDisplay:TRUE];
}


//-------------------------------------------------------------------
// windowChanged:withOldWind:
// Indirect reciever of signal "window changed". Brings a window(tab) to front
//
// "wind" - The new window
// "oldwind" - The old window
//-------------------------------------------------------------------
- (void)windowChanged:(WINDOW_REC*)wind withOldWind:(WINDOW_REC*)oldwind
{
  currentChannelController = (ChannelController *)(wind->gui_data);
  NSTextView *textView = [currentChannelController mainTextView];
  NSRange endRange;
  
  /* Since we only update the scrollbar of the front window we must save it's
   state when we switch. Likewise we must also update the new front window with 
   the status it had when it last was active */
  if (oldwind)
  {
    ChannelController *oldWindowController = (ChannelController *)(oldwind->gui_data);
    [oldWindowController saveScrollState];
    [oldWindowController setPartialCommand:[NSString stringWithString:[inputTextField string]]];
  }
  
  if ([currentChannelController scrollState]) {
    endRange.location = [[textView textStorage] length];
    endRange.length = 0;
    [textView scrollRangeToVisible:endRange];
  }
  
  /* Do the window switch */
  NSTabViewItem *tmp = [currentChannelController tabViewItem];
  [(CustomWindow *)[tabView window] setCurrentChannelTextView:textView];
  [tabView selectTabViewItem:tmp];
  [channelBar selectCellWithWindowRec:wind];
  [channelTableView selectRow:[tabView indexOfTabViewItem:tmp] byExtendingSelection:FALSE];
  [currentChannelController setWaitingEvents:0];

  // Update the window title
  NSString *titleString = ([[NSUserDefaults standardUserDefaults] boolForKey:@"channelInTitle"]) ? [NSString stringWithFormat:@"MacIrssi - %@", [currentChannelController name]] : @"MacIrssi";
  [mainWindow setTitle:titleString];
  
  NSRange r;
  if ([[mainWindow firstResponder] isMemberOfClass:[NSTextView class]]) {
    r = [(NSTextView *)[mainWindow firstResponder] selectedRange];
    [mainWindow makeFirstResponder:inputTextField];
    [(NSTextView *)[mainWindow firstResponder] setSelectedRange:r];
  }
  else
    [mainWindow makeFirstResponder:inputTextField];
  
  if ([currentChannelController partialCommand])
  {
    [inputTextField setString:[currentChannelController partialCommand]];
    [(NSTextView *)[mainWindow firstResponder] setSelectedRange:NSMakeRange([[currentChannelController partialCommand] length], 0)];
  }
  else
  {
    [inputTextField setString:@""];
  }
}

//-------------------------------------------------------------------
// refnumChanged:
//-------------------------------------------------------------------
- (void)refnumChanged:(WINDOW_REC *)wind old:(int)old
{
  [channelBar moveChannel:wind fromRefNum:old toRefNum:wind->refnum];
}


//-------------------------------------------------------------------
// removeTabWithWindowRec:
// Indirect reciever of signal "window destroyed". Removes a tab
// from the channels tab view.
//
// "wind" - The window to remove
//-------------------------------------------------------------------
- (void)removeTabWithWindowRec:(WINDOW_REC *)wind
{
  NSTabViewItem *tmp = [(ChannelController *)(wind->gui_data) tabViewItem];
  
  /* Fix channel menu */
  int i, index = [tabView indexOfTabViewItem:tmp] + 8;
  [channelMenu removeItemAtIndex:index];
  for (i = index; i < 10+7 && i < [channelMenu numberOfItems]; i++)
    [[channelMenu itemAtIndex:i] setKeyEquivalent:[[NSNumber numberWithInt:i-7] stringValue]];
  
  
  [channelBar removeChannel:wind];
  [tabView removeTabViewItem:tmp];
  
  [channelTableView reloadData];
  [channelBar setNeedsDisplay:TRUE];
}


//-------------------------------------------------------------------
// queryCreated:automatically:
// Indirect reciever of signal "query created". Marks a query so next
// window created knows it's a query. (ugly hack?)
//
// "qr" - The QUERY_REC
// "automatic" - If the query was automatic
//-------------------------------------------------------------------
- (void)queryCreated:(QUERY_REC *)qr automatically:(int)automatic
{
  queryObject = [[NSString alloc] initWithCString:qr->name];
}


//-------------------------------------------------------------------
// channelJoined:
// Updates the channel menu and channel list when a channel is joined.
//
// "rec" - The window the channel lies within
//-------------------------------------------------------------------
- (void)channelJoined:(WINDOW_REC *)rec
{
  NSTabViewItem *tmp = [(ChannelController *)(rec->gui_data) tabViewItem];
  int index = [tabView indexOfTabViewItem:tmp];
  NSString *channelName = [(ChannelController *)(rec->gui_data) name];
  [[channelMenu itemAtIndex:index+8] setTitle:channelName];
  [channelTableView reloadData];
  [channelBar setNeedsDisplay:TRUE];
}


#pragma mark Public methods
/**
 * Sets a irssi theme
 */
- (void)loadTheme:(NSString *)theme
{
  WINDOW_REC *rec = [currentChannelController windowRec];
  NSString *cmd = [NSString stringWithFormat:@"/set theme %@", theme];
  signal_emit("send command", 3, [cmd cStringUsingEncoding:NSASCIIStringEncoding], rec->active_server, rec->active);      
}

- (void)useHorizontalChannelBar:(BOOL)b
{
  if (b && [channelBar isHidden]) {
    NSRect frame = [tabView frame];
    frame.size.height -= 21;
    [tabView setFrame:frame];
    [tabView setNeedsDisplay:TRUE];
    
    [channelBar setHidden:FALSE];
    [channelBar setNeedsDisplay:TRUE];
  }
  else if (!b && ![channelBar isHidden]) {
    NSRect frame = [tabView frame];
    frame.size.height += 21;
    [tabView setFrame:frame];
    [tabView setNeedsDisplay:TRUE];
    [channelBar setHidden:TRUE];
  }
  
}

- (void)useVerticalChannelBar:(BOOL)b
{
  
  if (b && [channelTableView isHidden]) {
    
    NSRect frame = [tabView frame];
    
    /* Resize tab view */
    frame.size.width -= 160;
    frame.origin.x += 160;
    
    [tabView retain];
    [tabView removeFromSuperview];
    [tabView setFrame:frame];
    [[mainWindow contentView] addSubview:tabView];
    [tabView release];
    [tabView setNeedsDisplay:TRUE];
    
    /* Resize channel bar */  
    frame = [channelBar frame];
    frame.size.width -= 160;
    frame.origin.x += 160;
    
    [channelBar retain];
    [channelBar removeFromSuperview];
    [channelBar setFrame:frame];
    [[mainWindow contentView] addSubview:channelBar];
    [channelBar release];
    [channelBar setNeedsDisplay:TRUE];
    
    /* Resize input field */  
    frame = [box frame];
    frame.size.width -= 160;
    frame.origin.x += 160;
    
    [box retain];
    [box removeFromSuperview];
    [box setFrame:frame];
    [[mainWindow contentView] addSubview:box];
    [box release];
    [box setNeedsDisplay:TRUE];
    [inputTextField setNeedsDisplay:TRUE];
    
    [coverView removeFromSuperview];  
    [channelTableView setHidden:FALSE];
    [channelTableView setNeedsDisplay:TRUE];
  }
  else if (!b && ![channelTableView isHidden]) {
    
    [channelTableView setHidden:TRUE];
    NSRect frame = [tabView frame];
    
    /* Resize tab view */
    frame.size.width += 160;
    frame.origin.x -= 160;
    
    [tabView retain];
    [tabView removeFromSuperview];
    [tabView setFrame:frame];
    [[mainWindow contentView] addSubview:tabView];
    [tabView release];
    [tabView setNeedsDisplay:TRUE];
    
    /* Resize channel bar */  
    frame = [channelBar frame];
    frame.size.width += 160;
    frame.origin.x -= 160;
    
    [channelBar retain];
    [channelBar removeFromSuperview];
    [channelBar setFrame:frame];
    [[mainWindow contentView] addSubview:channelBar];
    [channelBar release];
    [channelBar setNeedsDisplay:TRUE];
    
    /* Resize input field */
    frame = [channelTableView frame];
    frame.size.width += 1;
    frame.size.height -= [tabView frame].size.height + [channelBar frame].size.height;
    
    coverView = [[CoverView alloc] initWithFrame:frame];
    [[mainWindow contentView] addSubview:coverView];
    [coverView setNeedsDisplay:TRUE];
    [coverView release];
    
    frame = [box frame];
    frame.size.width += 160;
    frame.origin.x -= 160;
    
    [box retain];
    [box removeFromSuperview];
    [box setFrame:frame];
    [[mainWindow contentView] addSubview:box];
    [box release];
    [box setNeedsDisplay:TRUE];
    [inputTextField setNeedsDisplay:TRUE];
    
  }
}

- (void)setChannelNavigationShortcuts:(int)direction
{
  if (direction == 0) // up/down
  {
    NSMenuItem *upItem = [channelMenu itemWithTitle:@"Previous"];
    NSMenuItem *downItem = [channelMenu itemWithTitle:@"Next"];
    unichar keyCode = 0xf700; // up
    [upItem setKeyEquivalent:[NSString stringWithCharacters:&keyCode length:sizeof(keyCode)]];
    keyCode = 0xf701;
    [downItem setKeyEquivalent:[NSString stringWithCharacters:&keyCode length:sizeof(keyCode)]];
  }
  else
  {
    NSMenuItem *leftItem = [channelMenu itemWithTitle:@"Previous"];
    NSMenuItem *rightItem = [channelMenu itemWithTitle:@"Next"];
    unichar keyCode = 0xf702; // left;
    [leftItem setKeyEquivalent:[NSString stringWithCharacters:&keyCode length:sizeof(keyCode)]];
    keyCode= 0xf703; // right
    [rightItem setKeyEquivalent:[NSString stringWithCharacters:&keyCode length:sizeof(keyCode)]];
  }
}

//-------------------------------------------------------------------
// presentUnexpectedEvent:
// Presents the user with a error message and a choice to continue
// or quit.
//
// "description" - A description of the error
//-------------------------------------------------------------------
- (void)presentUnexpectedEvent:(NSString *)description
{
  [mainWindow orderFront:self];
  [errorTextField setStringValue:description];
  [NSApp beginSheet:errorWindow modalForWindow:mainWindow modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

//-------------------------------------------------------------------
// currentWindowRec
// Returns the window rec of the current channel
//
// "sender" - The menu item selected
//
// Returns: The window rec of the current channel
//-------------------------------------------------------------------
- (WINDOW_REC *)currentWindowRec
{
  return [currentChannelController windowRec];
}

//-------------------------------------------------------------------
// setIcon:
// Sets the icon in the dock to a specific image.
//
// "icon" - The image
//-------------------------------------------------------------------
- (void)setIcon:(NSImage *)icon
{
  if (icon == iconOnPriv && currentIcon != iconOnPriv) {
    [NSApp setApplicationIconImage:iconOnPriv];
    currentIcon = iconOnPriv;
  }
  else if (icon == defaultIcon && currentIcon != defaultIcon) {
    [NSApp setApplicationIconImage:defaultIcon];
    currentIcon = defaultIcon;
  }
}


//-------------------------------------------------------------------
// historyUp
// Iterates one step back in history and outputs it in the command field.
//
// Returns: The length of the history-command
//-------------------------------------------------------------------
- (void)historyUp
{ 
  /* If we are at the front of the command history we save the current command temporarly in the history if the user wants to return to it */
  NSString *currentCommand = [inputTextField string];
  if ([[currentChannelController commandHistory] iteratorAtFront] && ![currentCommand isEqualToString:@""])
  {
    [[currentChannelController commandHistory] setTemporaryCommand:currentCommand];
  }
  
  NSString *command = [[currentChannelController commandHistory] previousCommand];
  
  if (!command)
    return;
  
  [inputTextField setString:command];
  [(NSTextView *)[mainWindow firstResponder] setSelectedRange:NSMakeRange([command length], 0)];
}


//-------------------------------------------------------------------
// historyDown
// Iterates one step forward in history and outputs it in the command field.
//
// Returns: The length of the history-command
//-------------------------------------------------------------------
- (void)historyDown
{
  NSString *command = [[currentChannelController commandHistory] nextCommand];
  [inputTextField setString:command ? command : @""];
  [(NSTextView *)[mainWindow firstResponder] setSelectedRange:NSMakeRange([command length], 0)];
}


//-------------------------------------------------------------------
// specialFontChange:
// Changes the font of all channels
//
// "sender" - The font panel
//-------------------------------------------------------------------
- (void)specialFontChange:(id)sender
{
  NSFont *channelFont = [sender convertFont:channelFont];
  [self changeMainWindowFont:channelFont];
  
  /* Save change in user defaults */
  [[NSUserDefaults standardUserDefaults] setObject:[NSArchiver archivedDataWithRootObject:channelFont] forKey:@"channelFont"];
}

- (void)changeMainWindowFont:(NSFont*)font
{  
  NSEnumerator *enumerator = [[tabView tabViewItems] objectEnumerator];
  NSTabViewItem *tmp;
  
  /* Iterate through all channels */
  while (tmp = [enumerator nextObject])
  {
    [[tmp identifier] setFont:font];
  }
}

- (void)changeNicklistFont:(NSFont*)font
{
  NSEnumerator *enumerator = [[tabView tabViewItems] objectEnumerator];
  NSTabViewItem *tmp;
  
  /* Iterate through all channels */
  while (tmp = [enumerator nextObject])
  {
    [[tmp identifier] setNicklistFont:font];
  }  
}

//-------------------------------------------------------------------
// irssiQuit
// Set a flag for termination.
//-------------------------------------------------------------------
- (void)irssiQuit
{
  quitting = TRUE;
}


#pragma mark Private methods
/**
 * returns an array of theme locations
 * ~/.irssi/
 * ~/.irssi/themes/
 * MacIrssi.app/Content/Resources/Themes/
 */
- (NSArray *)themeLocations
{
  NSMutableArray *tmp = [[NSMutableArray alloc] init];
  if (get_irssi_dir()) {
    [tmp addObject:[NSString stringWithCString:get_irssi_dir()]];
    [tmp addObject:[NSString stringWithFormat:@"%s/%@", get_irssi_dir(), @"themes"]];
  }
  
  [tmp addObject:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], @"Contents/Resources/Themes"]];
  
  return [tmp autorelease];
}


//-------------------------------------------------------------------
// runGlibLoopIteration
// Runs the irssi main loop in a separate thread.
//
// "anArgument" - Ignored
//-------------------------------------------------------------------
- (void)runGlibLoopIteration:(id)anArgument
{
  NSAutoreleasePool *pool;
  [NSThread setThreadPriority:0.1];
  
  while (!quitting) {
    pool = [[NSAutoreleasePool alloc] init];
    g_main_iteration(TRUE);
    [pool release];
  }
  
  [NSApp terminate:self];
  [NSThread exit];
}

- (void)glibRunLoopTimerEvent:(NSTimer*)timer
{
  g_main_iteration(FALSE);
}

- (EventController*)eventController
{
  return eventController;
}


#pragma mark Delegate & notification receiver methods

/**
 * Makes sure the "Edit Current Channel" menu item only is enabled
 * for actual irc channels.
 */
- (BOOL)validateMenuItem:(NSMenuItem*)item
{
  if (item == editCurrentChannelMenuItem)
    return [currentChannelController isChannel];
  if (item == findNextMenuItem || item == findPreviousMenuItem)
    return [currentChannelController hasActiveSearch];
  
  return YES;
}

#pragma mark Growl Delegates

/**
 * Bring application to front and select the channel from which the priv was received
 * @param clickContext The refnum of the channel
 */
- (void) growlNotificationWasClicked:(id)clickContext
{
  if (!clickContext)
  {
    // I don't think growl would ever deliver a nil context, but just in case
    return;
  }
  
  // One way or another we're gonna find a windowRef
  int windowRef = -1;
  
  // If we're given an NSNumber, then our clickContext is a window refnum
  if ([clickContext isKindOfClass:[NSNumber class]])
  {
    windowRef = [(NSNumber*)clickContext intValue];
  }
  else if ([clickContext isKindOfClass:[NSDictionary class]])
  {
    // Otherwise, if we're given a dict. It means it was harder to find a windowRefNum than it was to just supply
    // the server tag and a channel name.
    NSString *server = [clickContext objectForKey:@"Server"];
    NSString *channel = [clickContext objectForKey:@"Channel"];
    
    // Find the server rec
    SERVER_REC *newServerRec = server_find_tag([server cStringUsingEncoding:NSASCIIStringEncoding]);
    
    // If we got the server rec, ask irssi for the window rec to go with it
    if (newServerRec)
    {
      WINDOW_REC *newWindowRec = window_find_item(newServerRec, [channel cStringUsingEncoding:NSASCIIStringEncoding]);
      windowRef = (newWindowRec) ? newWindowRec->refnum : -1;
    }
  }
  
  // If all went well, then select the window.
  if (windowRef != -1)
  {
    [NSApp activateIgnoringOtherApps:TRUE];
    WINDOW_REC *rec = [currentChannelController windowRec];
    NSString *cmd = [NSString stringWithFormat:@"/window %d", windowRef];
    signal_emit("send command", 3, [cmd cStringUsingEncoding:NSASCIIStringEncoding], rec->active_server, rec->active);    
  }
  
}

/**
 * Growl registration delegate
 */
- (NSDictionary *) registrationDictionaryForGrowl
{
  NSArray *growlNotifications = [eventController availableEventNames];
  return [NSDictionary dictionaryWithObjectsAndKeys:growlNotifications, GROWL_NOTIFICATIONS_ALL, growlNotifications, GROWL_NOTIFICATIONS_DEFAULT, nil];
}

#pragma mark Sparkle Delegates

- (void)updaterWillRelaunchApplication:(SUUpdater *)updater
{
  isRestartingForUpdate = YES;
}

- (id <SUVersionComparison>)versionComparatorForUpdater:(SUUpdater *)updater
{
  return [AppcastVersionComparator defaultComparator];
}

#pragma mark NSApp notifications

//-------------------------------------------------------------------
// applicationShouldTerminate:
// Called when terminating, so we get a clean termination.
//
// "app" - The app to be terminated (this app maybe? =) )
//
// Returns: "NSTerminateNow" if we received a /quit command or if we
// should not bring up the quit dialog, "NSTerminateLater" else 
//-------------------------------------------------------------------
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)app
{
  /* If /quit command */
  if (quitting)
    return NSTerminateNow;
  
  NSString *quitMessage = (isRestartingForUpdate) ? @"Be right back. Restarting after update." : [[NSUserDefaults standardUserDefaults] stringForKey:@"defaultQuitMessage"];
  BOOL askQuit = (isRestartingForUpdate) ? NO : [[NSUserDefaults standardUserDefaults] boolForKey:@"askQuit"];
  
  /* Else, check if we should bring up quit sheet */
  if (askQuit) {
    [reasonTextField setStringValue:quitMessage];
    [NSApp beginSheet:reasonWindow modalForWindow:mainWindow modalDelegate:nil didEndSelector:nil contextInfo:nil];
    return NSTerminateLater; // Handle termination after reason is recieved
  }
  
  /* Else quit with default quit message */
  signal_emit("command quit", 1, [IrssiBridge irssiCStringWithString:quitMessage]);
  return NSTerminateNow;
}


//-------------------------------------------------------------------
// applicationWillTerminate:
// Clean up when terminating
//
// "aNotification" - Ignored
//-------------------------------------------------------------------
- (void)applicationWillTerminate:(NSNotification *)aNotification
{
  NSEnumerator *enumerator = [[tabView tabViewItems] objectEnumerator];
  ChannelController *tmp;
  
  while (tmp = [[enumerator nextObject] identifier])
  {
    [tmp clearNickView];
  }
  
  g_main_destroy(main_loop);
  textui_deinit();  
}


//-------------------------------------------------------------------
// applicationDidBecomeActive:
// Called when becoming active. Removes some notification systems
//
// "aNotification" - Ignored
//-------------------------------------------------------------------
- (void)applicationDidBecomeActive:(NSNotification *)aNotification
{ 
  /* Bring forth the main window if it was ordered out during a hide */
  if (![mainWindow isVisible])
  {
    [mainWindow makeKeyAndOrderFront:self];
  }
  
  /* If icon was changed to notify user of priv in active channel when the
   app was inactive while no other channel needs notification, then we
   must revert icon to normal */
  if (hilightChannels == 0)
    [self setIcon:defaultIcon];
  
  [channelBar setNeedsDisplay:YES];
  
  [currentChannelController setWaitingEvents:0];
}

- (void)applicationDidResignActive:(NSNotification *)aNotification
{

}

//-------------------------------------------------------------------
// inputTextFieldColorChanged:
// Updates the color of the input text field.
//
// "note" - Ignored
//-------------------------------------------------------------------
- (void)inputTextFieldColorChanged:(NSNotification *)note
{
  [inputTextField setTextColor:[ColorSet inputTextForegroundColor]];
  [inputTextField setBackgroundColor:[ColorSet inputTextBackgroundColor]];
}


//-------------------------------------------------------------------
// channelListColorChanged:
// Updates the color of the channel list
//
// "note" - Ignored
//-------------------------------------------------------------------
- (void)channelListColorChanged:(NSNotification *)note
{
  [channelTableView setBackgroundColor:[ColorSet channelListBackgroundColor]];
  [channelTableView reloadData];
  [channelBar setNeedsDisplay:TRUE];  
}


//-------------------------------------------------------------------
// numberOfRowsInTableView
// channelTableView delegate. Returns the number of channels/windows.
//
// "aTableView" - The channel view
//
// Returns: The number of open channels/windows
//-------------------------------------------------------------------
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
  return [tabView numberOfTabViewItems];
}


//-------------------------------------------------------------------
// tableView:objectValueForTableColumn:row:
// channelTableView delegate. Returns the name of a specific channel/window.
//
// "aTableView" - The channel view
// "aTableColumn" - ignored (only one col. used)
// "rowIndex" - The row
//
// Returns: The name of the channel/window at position rowIndex
//-------------------------------------------------------------------
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
  NSTabViewItem *item = [tabView tabViewItemAtIndex:rowIndex];
  WINDOW_REC *tmp = [[item identifier] windowRec];
  
  [highlightAttributes setObject:[ColorSet colorForKey:[[ColorSet channelListForegroundKeys] objectAtIndex:tmp->data_level]] forKey:NSForegroundColorAttributeName];
  return [[[NSAttributedString alloc] initWithString:[item label] attributes:highlightAttributes] autorelease]; 
}

//-------------------------------------------------------------------
// tableView:shouldSelectRow:
// channelTableView delegate. Changes active channel when a item in
// the channel list is clicked.
//
// "aTableView" - The channel view
// "rowIndex" - The row
//
// Returns: TRUE
//-------------------------------------------------------------------
- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(int)rowIndex
{
  if (active_win)
  {
    NSString *channelAsString = [NSString stringWithFormat:@"%d", rowIndex + 1];
    signal_emit("command window goto", 3, [channelAsString cStringUsingEncoding:NSASCIIStringEncoding], active_win->active_server, active_win->active);
    return YES;
  }
  return NO;
}


//-------------------------------------------------------------------
// tableView:shouldEditTableColumn:row:
// channelTableView delegate. Disallow editing in channel list.
//
// Returns: FALSE
//-------------------------------------------------------------------
- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
  return FALSE;
}


#pragma mark [De]initializers
//-------------------------------------------------------------------
// awakeFromNib
// The initializer. TODO: Clean up, this is ugly
//-------------------------------------------------------------------
- (void)awakeFromNib
{
  // The crash catcher should be first in the list apparently.
  UKCrashReporterCheckForCrash();
  
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  
  setRefToAppController(self);
  highlightAttributes = [[NSMutableDictionary alloc] init];
  
  quitting = FALSE;
  hilightChannels = 0;
  
  const char *path = [[[NSBundle mainBundle] bundlePath] fileSystemRepresentation];
  if (chdir(path) == -1)
  {
    NSLog(@"Can't set path!");
  }
  
  // All font changes go somewhere global, we need a handler to sort that out.
  [[NSFontManager sharedFontManager] setAction:@selector(specialFontChange:)];
  
  // Doesn't look like you can set this in IB
  [inputTextField setFont:[NSFont fontWithName:@"Monaco" size:10.0]];
  
  // Setup the event controller
  eventController = [[EventController alloc] init];
  
  /* Register defaults */
  NSFont *defaultChannelFont = [NSFont fontWithName:@"Monaco" size:9.0];
  NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSDictionary dictionary], @"shortcutDict",
                        [NSArchiver archivedDataWithRootObject:defaultChannelFont], @"channelFont",
                        [NSArchiver archivedDataWithRootObject:defaultChannelFont], @"nickListFont",
                        [NSNumber numberWithBool:TRUE], @"useFloaterOnPriv",
                        [NSNumber numberWithBool:TRUE], @"askQuit",
                        [NSNumber numberWithBool:FALSE], @"bounceIconOnPriv",
                        [NSNumber numberWithInt:0], @"channelBarOrientation",
                        [EventController defaults], @"eventDefaults",
                        [NSNumber numberWithBool:YES], @"channelInTitle",
                        nil];
    
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults registerDefaults:dict];
  
  // Register the default colours too.
  [ColorSet registerDefaults];
  
  // Setup sparkle, we're gonna be delegate for sparkle routines. In particular, I want to stop the retarded quit message
  // box appearing when sparkle tries to update the application.
  [[SUUpdater sharedUpdater] setDelegate:self];
  
  int channelBarOrientation = [defaults integerForKey:@"channelBarOrientation"];
  
  if (channelBarOrientation == 0) {
    [self useHorizontalChannelBar:TRUE];
    [self useVerticalChannelBar:FALSE];
    [self setChannelNavigationShortcuts:1];
  }
  else {
    [self useVerticalChannelBar:TRUE];
    [self useHorizontalChannelBar:FALSE];
    [self setChannelNavigationShortcuts:0];
  }

  // Convert any shortcuts from the old system and set the menu up
  [self checkAndConvertOldShortcuts];
  [self setShortcutCommands];
  
  currentIcon = defaultIcon = [[NSApp applicationIconImage] copy];
  iconOnPriv = [[NSImage alloc] initWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/Contents/Resources/MacIrssi-Alert.png"]];
  if (!iconOnPriv) {
    NSLog(@"Can't load 'icon-dot' image!");
    iconOnPriv = [[NSApp applicationIconImage] retain];
  }
  
  [defaults registerDefaults:[NSDictionary dictionaryWithObject:@"Get MacIrssi - http://www.sysctl.co.uk/projects/macirssi/ " forKey:@"defaultQuitMessage"]];
  
  /* Delete first tab */
  [tabView removeTabViewItem:[tabView tabViewItemAtIndex:0]];
  /* Yes please =) */
  [[tabView window] useOptimizedDrawing:TRUE];
  /* Enable parts of window to be transparent */
  [[tabView window] setOpaque:FALSE];
  
  [nc addObserver:self selector:@selector(inputTextFieldColorChanged:) name:@"inputTextFieldColorChanged" object:nil];
  [nc addObserver:self selector:@selector(channelListColorChanged:) name:@"channelListColorChanged" object:nil];
  [nc addObserver:self selector:@selector(setShortcutCommands) name:@"shortcutChanged" object:nil];
  
  /* Set up colors */
  [inputTextField setTextColor:[ColorSet inputTextForegroundColor]];
  [inputTextField setBackgroundColor:[ColorSet inputTextBackgroundColor]];
  [channelTableView setBackgroundColor:[ColorSet channelListBackgroundColor]];
  //[((NSTextView *)inputTextField) setInsertionPointColor:[NSColor whiteColor]]; //TODO: preference
  
  /* Init Growl */
  [GrowlApplicationBridge setGrowlDelegate:self];
  
  /* Sleep registration */
  [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:[ConnectivityMonitor sharedMonitor] selector:@selector(workspaceWillSleep:) name:NSWorkspaceWillSleepNotification object:[NSWorkspace sharedWorkspace]];
  [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:[ConnectivityMonitor sharedMonitor] selector:@selector(workspaceDidWake:) name:NSWorkspaceDidWakeNotification object:[NSWorkspace sharedWorkspace]];
  
  /* Init theme dirs */
  const char *tmp;
  int i;
  
  NSArray *dirs = [self themeLocations];
  num_theme_dirs = [dirs count];
  theme_dirs = (char **)malloc(num_theme_dirs * sizeof(char *));
  for (i = 0; i < [dirs count]; i++) {
    tmp = [[dirs objectAtIndex:i] lossyCString];
    theme_dirs[i] = (char *)malloc(strlen(tmp)+1);
    strcpy(theme_dirs[i], tmp);
  } 
  
  /* Start up irssi code */
#ifdef MACIRSSI_DEBUG
  char *irssi_argv[] = {"irssi", "--config=~/.irssi/config_debug", NULL};
  int irssi_argc = 2;
  irssi_main(irssi_argc, irssi_argv);
#else
  [[NSApp mainMenu] removeItem:[[NSApp mainMenu] itemWithTitle:@"Debug"]];
  
  /* Double clicking an app gives a "-psn..." argument which irssi does
   not like, remove if present */
  if ( argc > 1 && strncmp(argv[1], "-psn", 4) == 0)
  {
    argc--;
    argv[1] = argv[0];
    irssi_main(argc, argv+1);
  }
  else
  {
    irssi_main(argc, argv);
  }
#endif
  
  main_loop = g_main_new(TRUE);
  
  // Get rid of the shit old run loop thread and schedule the glib runloop on the NSRunLoop
  [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(glibRunLoopTimerEvent:) userInfo:nil repeats:YES];
}

@end
