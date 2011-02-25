/*
 AppController.m
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

#import <SecurityInterface/SFCertificateTrustPanel.h>
#import <Growl/GrowlApplicationBridge.h>
#import <objc/objc-runtime.h>

#import "AppController.h"
#import "ChannelController.h"
#import "PreferenceViewController.h"
#import "EventController.h"
#import "DebugController.h"
#import "AppcastVersionComparator.h"
#import "CustomWindow.h"
#import "CustomTableView.h"
#import "ColorSet.h"
#import "ConnectivityMonitor.h"
#import "IrssiBridge.h"
#import "IrssiRunloop.h"
#import "PreferenceVersionHelper.h"

#import "AIMenuAdditions.h"
#import "NSString+Additions.h"

// For shortcuts
#import "SRHacks.h"
#import "SRCommon.h"
#import "SRKeyCodeTransformer.h"
#import "ShortcutBridgeController.h"

// For iChooons
#import "iTunes.h"

#import "chatnets.h"
#import "irc.h"
#import "irc-chatnets.h"
#import "irc-servers-setup.h"
#import "fe-common-core.h"
#import "command-history.h"

#define PASTE_WARNING_THRESHOLD 4

void setRefToAppController(AppController *a);
void textui_deinit();
int argc;
char **argv;

@interface NSFontManager (StupidHeaderFixes)

- (void)setTarget:(id)target;

@end

static PreferenceViewController *_sharedPrefsWindowController = nil;

static char *kMIJoinChannelAlertKey = "kMIJoinChannelAlertKey";

@implementation AppController

#pragma mark - Menu Actions
#pragma mark -- Application Menu

- (IBAction)showAbout:(id)sender
{
  [aboutVersionLabel setStringValue:[NSString stringWithFormat:@"Version %@ (%@)",
                                     [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],
                                     [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSGitRevision"]]];
  
  [copyrightTextView setString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSHumanReadableCopyright"]];
  [copyrightTextView setAlignment:NSCenterTextAlignment range:NSMakeRange(0, [[copyrightTextView textStorage] length])];
  
  [aboutBox center];
  [aboutBox makeKeyAndOrderFront:sender];
}

//-------------------------------------------------------------------
// showPreferencePanel:
// Brings up the preference panel
//
// "sender" - A menu item
//-------------------------------------------------------------------
- (IBAction)showPreferencePanel:(id)sender
{
	if (!_sharedPrefsWindowController) {
    _sharedPrefsWindowController = [[PreferenceViewController alloc] initWithColorSet:nil appController:self];
  }
	[_sharedPrefsWindowController showWindow:self];
}

#pragma mark -- File Menu

- (IBAction)joinChannel:(id)sender
{
  NSAlert *alert = [NSAlert alertWithMessageText:@"Join Channel"
                                   defaultButton:@"Join"
                                 alternateButton:@"Cancel"
                                     otherButton:nil
                       informativeTextWithFormat:@"Enter the name of the channel to join."];
  
  [joinChannelServersPopup removeAllItems];
  [joinChannelTextField setStringValue:@""];
  
  GSList *tmp;
  for (tmp = servers; tmp; tmp = tmp->next) {
    NSString *hostname = [NSString stringWithFormat:@"%s", ((SERVER_REC*)tmp->data)->connrec->address];
    [joinChannelServersPopup addItemWithTitle:hostname];
    
    NSMenuItem *item = [joinChannelServersPopup itemWithTitle:hostname];
    [item setRepresentedObject:[NSValue valueWithPointer:tmp->data]];
    [item setImage:[NSImage imageNamed:NSImageNameNetwork]];
    [[item image] setSize:NSMakeSize(16, 16)];
    
    if (tmp->data == [currentChannelController windowRec]->active_server) {
      [joinChannelServersPopup selectItem:item];
    }
  }
  
  [alert setAccessoryView:joinChannelAccessoryView];
  [alert layout]; /* force things to exist so we can set the responder */
  [[alert window] makeFirstResponder:joinChannelTextField];
  
  /* Make sure we set the Join button to reflect it's correct state */
  [[[alert buttons] objectAtIndex:0] setEnabled:([[joinChannelTextField stringValue] length] > 0)];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(joinChannelFieldDidChange:)
                                               name:NSControlTextDidChangeNotification
                                             object:joinChannelTextField];
  
  objc_setAssociatedObject(joinChannelTextField, kMIJoinChannelAlertKey, alert, OBJC_ASSOCIATION_RETAIN);
  
  [alert beginSheetModalForWindow:mainWindow
                    modalDelegate:self
                   didEndSelector:@selector(joinChannelEnded:returnCode:context:)
                      contextInfo:nil];
}

- (IBAction)performDisconnect:(id)sender
{
  SERVER_REC *server = [self serverRecordFromServerMenu:sender];
  
  if (server)
  {
    signal_emit("command disconnect", 2, "* Disconnecting", server);
  }
}

- (IBAction)changeIrssiServerConsole:(id)sender
{
  SERVER_REC *ptr = [self serverRecordFromServerMenu:sender];
  
  // This means the pointer we got given in representedObject is still valid.
  if (ptr != NULL) {
    // We should check use_status_window in validation, if we don't have one, then we don't have a server
    // console to change the active server to.
    WINDOW_REC *wnd = window_find_name("(status)");
    if (wnd) {
      // The official signal way checks to see if you're looking at this window when you do it,
      // I'd rather not restrict the user that way so I'm calling w_c_s directly. Also, poke
      // irssiServerChangedNotification: to force the menu to regenerate with a new selected
      // server.
      window_change_server(wnd, ptr);
      [self irssiServerChangedNotification:nil];
    }
  }
}

- (IBAction)performCloseChannel:(id)sender
{
  if (![mainWindow isKeyWindow]) {
    [[NSApp keyWindow] performClose:sender];
    return;
  }
  
  if ([[IrssiBridge channels] count] == 1) {
    // Last window, actually we want to perform a window close
    [mainWindow performClose:sender];
    return;
  }
  
  WINDOW_REC *rec = [currentChannelController windowRec];
  signal_emit("command window close", 3, "", rec->active_server, rec->active);
}

#pragma mark -- Edit Menu

- (IBAction)performFind:(id)sender
{
  // Find simply defers to the current channel controller's searchController.
  [[currentChannelController searchController] performFind:sender];
}

- (IBAction)performJumpToSelection:(id)sender
{
  [[currentChannelController textView] scrollRangeToVisible:[[currentChannelController textView] selectedRange]];
}

#pragma mark -- Channel Menu

- (IBAction)showFontPanel:(id)sender
{
  NSFont *channelFont = [NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] valueForKey:@"channelFont"]];
  
  [[NSFontManager sharedFontManager] setAction:@selector(specialFontChange:)];
  [[NSFontManager sharedFontManager] setTarget:self];
  [[NSFontManager sharedFontManager] orderFrontFontPanel:sender];
  [[NSFontManager sharedFontManager] setSelectedFont:channelFont isMultiple:FALSE];
}

- (IBAction)editCurrentChannel:(id)sender
{
  [currentChannelController raiseTopicWindow:sender];
}

#pragma mark -- Shortcut Menu

- (IBAction)showShortcutsPreferences:(id)sender
{
  if (!_sharedPrefsWindowController) {
    _sharedPrefsWindowController = [[PreferenceViewController alloc] initWithColorSet:nil appController:self];
  }
  [_sharedPrefsWindowController showWindow:self];
  [_sharedPrefsWindowController switchPreferenceWindowToNamed:@"Shortcuts" animate:YES];
}

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
  char *tmp;
  
  while (command = [enumerator nextObject]) {
    tmp = (char*)[command cStringUsingEncoding:NSUTF8StringEncoding];
    
    /* Skip whitespaces */
    while (*tmp == ' ')
      tmp++;
    signal_emit("send command", 3, tmp, rec->active_server, rec->active);
  }
}

#pragma mark -- Window Menu

- (IBAction)nextChannel:(id)sender
{
  WINDOW_REC *tmp = [currentChannelController windowRec];
  signal_emit("command window next", 3, "", tmp->active_server, tmp->active);
}

- (IBAction)previousChannel:(id)sender
{
  WINDOW_REC *tmp = [currentChannelController windowRec];
  signal_emit("command window previous", 3, "", tmp->active_server, tmp->active);
}

- (IBAction)activeChannel:(id)sender
{
  WINDOW_REC *tmp = [currentChannelController windowRec];
  signal_emit("command window goto", 3, "active", tmp->active_server, tmp->active);
}

#pragma mark -- Help Menu

- (IBAction)showMacIrssiFAQHelp:(id)sender
{
  NSURL *url = [[NSBundle mainBundle] URLForResource:@"FAQ" withExtension:@"html"];
  if (url) {
    [[NSWorkspace sharedWorkspace] openURL:url];
  }
}

- (IBAction)showIrssiSettingsHelp:(id)sender
{
  NSURL *url = [NSURL URLWithString:@"http://irssi.org/documentation/settings"];
  if (url) {
    [[NSWorkspace sharedWorkspace] openURL:url];
  }
}

#pragma mark - Invisible Actions

- (IBAction)sendCommand:(id)sender
{
  int i;
  NSString *cmd = [NSString stringWithString:[sender string]];  
  if ([cmd length] == 0)
    return;
  
  WINDOW_REC *rec = [currentChannelController windowRec];
  
  command_history_add(command_history_current(rec), [cmd UTF8String]);
  command_history_clear_pos(rec);
  
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
        NSString *albumText = @"";
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"showAlbumInSlashiTunes"]) {
          albumText = [NSString stringWithFormat:@" from %@", [it currentAlbum]];
        }
        nowPlaying = [NSString stringWithFormat:@"/me is listening to %@ by %@%@.", [it currentTitle], [it currentArtist], albumText];
      }
      else if ([it isRunning] && ![it isPlaying])
      {
        nowPlaying = @"/me is listening to silence!";
      }
      else
      {
        nowPlaying = @"/me typed /itunes when it wasn't even open. Doh!";
      }
      
      const char *tmp = [nowPlaying UTF8String];
      signal_emit("send command", 3, tmp, rec->active_server, rec->active);
      
      continue;
    }
    
    /* Else normal command */
    const char *tmp = [[commands objectAtIndex:i] UTF8String];
    signal_emit("send command", 3, tmp, rec->active_server, rec->active);
  }
}

- (IBAction)endReasonWindow:(id)sender
{
  [reasonWindow orderOut:sender];
  [NSApp endSheet:reasonWindow returnCode:1];
  if ([[sender title] isEqual:@"Ok"]) {
    NSString *str = [reasonTextField stringValue];
    signal_emit("command quit", 1, [str UTF8String]);
    [NSApp replyToApplicationShouldTerminate:YES];
  }
  [reasonTextField setStringValue:@""];
}

- (IBAction)endErrorWindow:(id)sender
{
  [errorWindow orderOut:sender];
  [NSApp endSheet:errorWindow returnCode:1];
  
  if ([[sender title] isEqual:@"Quit"])
  {
    signal_emit("command quit", 1, [[[NSUserDefaults standardUserDefaults] stringForKey:@"defaultQuitMessage"] UTF8String]);
  }
}

#pragma mark - Irssi
#pragma mark -- Bridge Calls

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
  // Pick up the object count of the window and bump it
  ChannelController *cc = wind->gui_data;
  
  // If we don't actually have a channel controller, it'll be the hook interface from
  // the preview window. If so, just eject.
  if (![cc isKindOfClass:[ChannelController class]])
  {
    return;
  }
  
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
  ChannelController *c = (ChannelController *)[[tabView tabViewItemAtIndex:0] identifier];
  [c setName:tmp];
  
  [self buildServersMenu];
  [self buildWindowsMenu];
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
    [tabViewItem release];
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
  
  [self buildWindowsMenu];
  
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
  
  if (oldwind)
  {
    ChannelController *oldWindowController = (ChannelController *)(oldwind->gui_data);
    [oldWindowController setPartialCommand:[[[inputTextField string] copy] autorelease]];
    [oldWindowController setPartialCommandSelection:[inputTextField selectedRange]];
  }
  
  /* Do the window switch */
  NSTabViewItem *tmp = [currentChannelController tabViewItem];
  [(CustomWindow *)[tabView window] setCurrentChannelTextView:textView];
  
  [currentChannelController beginTextUpdates];
  [tabView selectTabViewItem:tmp];
  [currentChannelController endTextUpdates];
  
  [channelBar selectCellWithWindowRec:wind];
  [channelTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:[tabView indexOfTabViewItem:tmp]] byExtendingSelection:FALSE];
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
  
  if (settings_get_bool("window_history"))
  {
    if ([currentChannelController partialCommand])
    {
      [inputTextField setString:[currentChannelController partialCommand]];
      [(NSTextView *)[mainWindow firstResponder] setSelectedRange:[currentChannelController partialCommandSelection]];
    }
    else
    {
      [inputTextField setString:@""];
    }
  }
}

//-------------------------------------------------------------------
// refnumChanged:
//-------------------------------------------------------------------
- (void)refnumChanged:(WINDOW_REC *)wind old:(int)old
{
  [channelBar moveChannel:wind fromRefNum:old toRefNum:wind->refnum];
  
  NSTabViewItem *item = [(ChannelController*)(wind->gui_data) tabViewItem];
  
  [item retain]; // keep hold while we move it
  [tabView removeTabViewItem:item];
  [tabView insertTabViewItem:item atIndex:(wind->refnum-1)];
  [tabView selectTabViewItem:[currentChannelController tabViewItem]];
  [item release];
  
  [channelTableView reloadData];
  [channelTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:[tabView indexOfTabViewItem:[currentChannelController tabViewItem]]] byExtendingSelection:NO];
}

//-------------------------------------------------------------------
// windowNameChanged:
// fired on "window name changed"
//-------------------------------------------------------------------
- (void)windowNameChanged:(WINDOW_REC*)wind
{
  ChannelController *controller = (ChannelController*)wind->gui_data;  
  NSString *newName = wind->name ? [NSString stringWithUTF8String:wind->name] : @"";
  [controller setName:newName];
  
  [self buildWindowsMenu];
  [channelTableView reloadData];
  [channelBar setNeedsDisplay:TRUE];
  
  // Update the window title, just in case the channel that just joined was showing "joining..." in the title bar
  NSString *titleString = ([[NSUserDefaults standardUserDefaults] boolForKey:@"channelInTitle"]) ? [NSString stringWithFormat:@"MacIrssi - %@", [currentChannelController name]] : @"MacIrssi";
  [mainWindow setTitle:titleString];  
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
  
  [self buildWindowsMenu];
  
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
  [self buildWindowsMenu];
  [channelTableView reloadData];
  [channelBar setNeedsDisplay:TRUE];
  
  // Update the window title, just in case the channel that just joined was showing "joining..." in the title bar
  NSString *titleString = ([[NSUserDefaults standardUserDefaults] boolForKey:@"channelInTitle"]) ? [NSString stringWithFormat:@"MacIrssi - %@", [currentChannelController name]] : @"MacIrssi";
  [mainWindow setTitle:titleString];
  if (rec->name) {
    [self windowNameChanged:rec];
  }
}

#pragma mark -- History

- (void)historyUp
{
  const char *str = [[inputTextField string] UTF8String];
  char *next = (char*)command_history_prev([currentChannelController windowRec], str);
  
  [inputTextField setString:[NSString stringWithUTF8String:next]];
  [(NSTextView*)[mainWindow firstResponder] setSelectedRange:NSMakeRange([[inputTextField string] length], 0)];
}

- (void)historyDown
{
  const char *str = [[inputTextField string] UTF8String];
  char *next = (char*)command_history_next([currentChannelController windowRec], str);
  
  [inputTextField setString:[NSString stringWithUTF8String:next]];
  [(NSTextView*)[mainWindow firstResponder] setSelectedRange:NSMakeRange([[inputTextField string] length], 0)];
}

#pragma mark - Menu Builders

- (void)buildShortcutsMenu
{
  NSMenu *_shortcutsMenu = [[[NSApp mainMenu] itemWithTitle:@"Shortcuts"] submenu];
  for (NSMenuItem *item in _shortcutsMenuItems) {
    _lastShortcutsMenuItem = [_shortcutsMenu itemAtIndex:[_shortcutsMenu indexOfItem:item]-1];
    [_shortcutsMenu removeItem:item];
  }
  [_shortcutsMenuItems removeAllObjects];
  
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
      
      [_shortcutsMenu insertItem:item atIndex:[_shortcutsMenu indexOfItem:_lastShortcutsMenuItem]+1];
      [_shortcutsMenuItems addObject:item];
      _lastShortcutsMenuItem = item;
    }
  }
  else
  {
    NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:@"No Shortucts." action:nil keyEquivalent:@""] autorelease];
    [_shortcutsMenu insertItem:item atIndex:[_shortcutsMenu indexOfItem:_lastShortcutsMenuItem]+1];
    [_shortcutsMenuItems addObject:item];
    _lastShortcutsMenuItem = item;
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

- (NSMenu*)buildServerSubmenu:(SERVER_REC*)srv
{
  // Build the server submenu
  NSMenu *serverMenu = [[[NSMenu alloc] initWithTitle:@""] autorelease];
  if (srv->connection_lost) {
    [serverMenu addItem:[[[NSMenuItem alloc] initWithTitle:@"Stop Reconnecting" target:self action:nil keyEquivalent:@""] autorelease]];
  } else {
    [serverMenu addItem:[[[NSMenuItem alloc] initWithTitle:@"Disconnect" target:self action:@selector(performDisconnect:) keyEquivalent:@""] autorelease]];
  }
  
  [serverMenu addItem:[NSMenuItem separatorItem]];
  
  [serverMenu addItem:[[[NSMenuItem alloc] initWithTitle:@"Make Active Server" target:self action:@selector(changeIrssiServerConsole:) keyEquivalent:@""] autorelease]];
  
  WINDOW_REC *console = window_find_name("(status)");
  if (console && (console->active_server == srv)) {
    NSMenuItem *item = [serverMenu itemWithTitle:@"Make Active Server"];
    [item setState:YES];
  }
  
  return serverMenu;
}

- (void)buildServersMenu
{
  NSMenu *fileMenu = [[[NSApp mainMenu] itemWithTitle:@"File"] submenu];
  for (NSMenuItem *item in _serversMenuItems) {
    _lastServersMenuItem = [fileMenu itemAtIndex:[fileMenu indexOfItem:item]-1];
    [fileMenu removeItem:item];
  }
  [_serversMenuItems removeAllObjects];
  
  if (servers) {
    GSList *tmp;
    int count = 1;
    
    for (tmp = servers; tmp != NULL; tmp = tmp->next) {
      SERVER_REC *srv = tmp->data;
      if (srv->disconnected) {
        // disconnected meant we're actually dying, we should just
        // stop showing it to the user now.
        continue;
      }
      
      if (srv->connrec) {
        NSString *title = [NSString stringWithFormat:@"%s", srv->connrec->address];
        if (srv->connrec->chatnet) {
          title = [title stringByAppendingFormat:@" [%s]", srv->connrec->chatnet];
        }
        NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:title action:nil keyEquivalent:@""] autorelease];
        
        NSValue *srvPointerValue = [NSValue valueWithPointer:srv];
        [item setRepresentedObject:srvPointerValue];
        
        NSMenu *menu = [self buildServerSubmenu:srv];
        [item setSubmenu:menu];
        
        [fileMenu insertItem:item atIndex:[fileMenu indexOfItem:_lastServersMenuItem]+1];
        [_serversMenuItems addObject:item];
        _lastServersMenuItem = item;
        
        count++;
      }
    }
    
    if (count > 1) {
      NSMenuItem *sep = [[NSMenuItem separatorItem] copy];
      [fileMenu insertItem:sep atIndex:[fileMenu indexOfItem:_lastServersMenuItem]+1];
      [_serversMenuItems addObject:sep];
      _lastServersMenuItem = sep;
    }
  }
}

- (SERVER_REC*)serverRecordFromServerMenu:(id)sender
{
  NSMenu *menu = [(NSMenuItem*)sender menu];
  NSMenuItem *item = [[menu supermenu] itemAtIndex:[[menu supermenu] indexOfItemWithSubmenu:menu]];
  
  SERVER_REC *ptr = [(NSValue*)[item representedObject] pointerValue];
  
  // Next impossible thing before breakfast ...
  GSList *tmp;
  for (tmp = servers; tmp != NULL; tmp = tmp->next) {
    if ((SERVER_REC*)tmp->data == ptr) {
      break;
    }
  }
  
  return (tmp ? ptr : NULL);
}

- (void)buildWindowsMenu
{
  NSMenu *windowMenu = [NSApp windowsMenu];
  for (NSMenuItem *item in _windowsMenuItems) {
    [windowMenu removeItem:item];
  }
  [_windowsMenuItems removeAllObjects];
  
  NSMenuItem *sep = [NSMenuItem separatorItem];
  [_windowsMenuItems addObject:sep];
  [windowMenu addItem:sep];
  
  NSArray *channels = [IrssiBridge channels];
  if ([channels count] > 0) {
    NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:@"Channels" action:nil keyEquivalent:@""] autorelease];
    [_windowsMenuItems addObject:item];
    [windowMenu addItem:item];
  }
  
  for (ChannelController *channel in channels) {
    NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:[channel name] target:channel action:@selector(makeChannelKey:) keyEquivalent:@""] autorelease];
    if ([channels count] > 0) {
      [item setIndentationLevel:1];
    }
    
    if ([channel windowRec]->refnum < 10) {
      [item setKeyEquivalent:[NSString stringWithFormat:@"%d", [channel windowRec]->refnum]];
    } else if ([channel windowRec]->refnum == 10) {
      [item setKeyEquivalent:@"0"];
    }
    
    if ([channel isEqual:currentChannelController]) {
      [item setState:YES];
    }
    
    [_windowsMenuItems addObject:item];
    [windowMenu addItem:item];
  }
}

#pragma mark - PanelDidEnd Callbacks

- (void)joinChannelFieldDidChange:(NSNotification*)notification
{
  NSTextField *field = [notification object];
  NSAlert *alert = objc_getAssociatedObject(field, kMIJoinChannelAlertKey);
  NSButton *joinButton = [[alert buttons] objectAtIndex:0];
  
  [joinButton setEnabled:[[field stringValue] length] > 0];
}

- (void)joinChannelEnded:(NSAlert*)alert returnCode:(NSInteger)code context:(void*)context
{
  NSTextField *field = (NSTextField*)[alert accessoryView];
  
  objc_setAssociatedObject(field, kMIJoinChannelAlertKey, nil, OBJC_ASSOCIATION_RETAIN);
  
  if (code == NSOKButton) {
    NSMenuItem *item = [joinChannelServersPopup selectedItem];
    SERVER_REC *server = [[item representedObject] pointerValue];
    signal_emit("command join", 2, [[joinChannelTextField stringValue] UTF8String], server);
  }
  
  [joinChannelServersPopup removeAllItems];
}

#pragma mark - Leftover Crap

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

- (NSInteger)presentCertificateTrustPanel:(SecTrustRef)trust
{
  SFCertificateTrustPanel *panel = [SFCertificateTrustPanel sharedCertificateTrustPanel];
  [panel setAlternateButtonTitle:@"Cancel"];
  
  NSString *message = [NSString stringWithFormat:@"MacIrssi was unable to verify the certificate of the server."];
  NSString *infoText = [NSString stringWithFormat:@"You may choose to continue, or cancel. You may also adjust your preferences to avoid this message in the future."];
  
  [panel setInformativeText:infoText];
  
  return [panel runModalForTrust:trust message:message];
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
// specialFontChange:
// Changes the font of all channels
//
// "sender" - The font panel
//-------------------------------------------------------------------
- (void)specialFontChange:(id)sender
{
  NSFont *channelFont = [(NSFontManager*)sender convertFont:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"channelFont"]]];
  [self changeMainWindowFont:channelFont];
  
  /* Save change in user defaults */
  [[NSUserDefaults standardUserDefaults] setObject:[NSArchiver archivedDataWithRootObject:channelFont] forKey:@"channelFont"];
}

- (void)changeMainWindowFont:(NSFont*)font
{  
  NSEnumerator *enumerator = [[tabView tabViewItems] objectEnumerator];
  NSTabViewItem *tmp;
  
  if (![[NSUserDefaults standardUserDefaults] boolForKey:@"useSmallTextEntryFont"])
  {
    /* Set the input text box to this font too */
    [inputTextField setFont:font];
    /* Also force the input box to resize itself */
    [inputTextField textDidChange:nil];
  }
  
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

- (void)setNicklistHidden:(BOOL)flag
{
  NSEnumerator *enumerator = [[tabView tabViewItems] objectEnumerator];
  NSTabViewItem *tmp;
  
  /* Iterate through all channels */
  while (tmp = [enumerator nextObject])
  {
    [[tmp identifier] setNicklistHidden:flag];
  }
}

//-------------------------------------------------------------------
// irssiQuit
// Set a flag for termination.
//-------------------------------------------------------------------
- (void)irssiQuit
{
  if (!quitting)
  {
    // make sure we don't double ask for quit
    quitting = YES;
    // we prolly want to terminate too
    [NSApp performSelector:@selector(terminate:) withObject:self afterDelay:0.0];
  }
}

#pragma mark - Themes
#pragma mark -- (Why are these here?)

/**
 * Sets a irssi theme
 */
- (void)loadTheme:(NSString *)theme
{
  WINDOW_REC *rec = [currentChannelController windowRec];
  NSString *cmd = [NSString stringWithFormat:@"/set theme %@", theme];
  signal_emit("send command", 3, [cmd cStringUsingEncoding:NSASCIIStringEncoding], rec->active_server, rec->active);      
}

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
    [tmp addObject:[NSString stringWithCString:get_irssi_dir() encoding:NSUTF8StringEncoding]];
    [tmp addObject:[NSString stringWithFormat:@"%s/%@", get_irssi_dir(), @"themes"]];
  }
  
  [tmp addObject:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], @"Contents/Resources/Themes"]];
  
  return [tmp autorelease];
}

- (ChannelController*)currentChannelController
{
  return currentChannelController;
}

- (EventController*)eventController
{
  return eventController;
}

#pragma mark - Notifications and Delegates

- (void)windowDidBecomeKey:(NSNotification *)notification
{
  [_closeChannelItem setKeyEquivalent:@"w"];
  [_closeWindowItem setKeyEquivalent:@"W"];
}

- (void)windowDidResignKey:(NSNotification *)notification
{
  [_closeChannelItem setKeyEquivalent:@"W"];
  [_closeWindowItem setKeyEquivalent:@"w"];
}

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem
{
  if ([anItem action] == @selector(editCurrentChannel:)) {
    return [currentChannelController isChannel];
  }
  if ([anItem action] == @selector(performCloseChannel:)) {
    return !([currentChannelController windowRec]->immortal);
  }
  if ([anItem action] == @selector(performFind:)) {
    return ([[currentChannelController searchController] canPerformFindForTag:[anItem tag]]);
  }
  if ([anItem action] == @selector(performJumpToSelection:)) {
    return ([[currentChannelController textView] selectedRange].length > 0);
  }
  if ([anItem action] == @selector(changeIrssiServerConsole:)) {
    return settings_get_bool("use_status_window");
  }
  if ([anItem action] == @selector(joinChannel:)) {
    return ([currentChannelController windowRec]->active_server != NULL);
  }
  return YES;
}

- (void)channelBarOrientationDidChange:(NSNotification*)notification
{
  // Right, we don't post anything useful with the notification but we need to re-read the config var and
  // possibly re-orientate.
  
  // Remove everything from the content view. All the important shit is retained.
  [channelTableScrollView removeFromSuperview];
  [channelTableSplitView removeFromSuperview];
  [channelBar removeFromSuperview];
  [tabViewTextEntrySplitView removeFromSuperview];
  //[tabView removeFromSuperview];
  //[inputTextFieldBox removeFromSuperview];
  
  int orientation = [[NSUserDefaults standardUserDefaults] integerForKey:@"channelBarOrientation"];
  
  switch (orientation)
  {
    case MIChannelBarHorizontalOrientation:
    {
      // So, horitonzal operation. We want the channelBar and tabView.
      NSRect channelBarFrame = NSMakeRect(0.0, [[mainWindow contentView] frame].size.height - [channelBar frame].size.height + 1.0, [[mainWindow contentView] frame].size.width, [channelBar frame].size.height);
      NSRect splitViewFrame = NSMakeRect(0.0, 0.0, [[mainWindow contentView] frame].size.width, channelBarFrame.origin.y);
      
      [[mainWindow contentView] addSubview:channelBar];
      [channelBar setFrame:channelBarFrame];
      [channelBar setNeedsDisplay:YES];
      
      [[mainWindow contentView] addSubview:tabViewTextEntrySplitView];
      [tabViewTextEntrySplitView setFrame:splitViewFrame];
      [tabViewTextEntrySplitView setNeedsDisplay:YES];
      [tabViewTextEntrySplitView adjustSubviews];
      
      // Now adjust the views internally
      NSRect inputBoxFrame = [inputTextFieldBox frame];
      inputBoxFrame.size.height = [[inputTextField layoutManager] usedRectForTextContainer:[inputTextField textContainer]].size.height + 6.0;
      [inputTextFieldBox setFrame:inputBoxFrame];
      
      break;
    }
    case MIChannelBarVerticalOrientation:
    {
      // Ok, for vertical channel bars, put the tableView in a split view and go from there
      NSRect channelTableSplitViewFrame = [[mainWindow contentView] frame];
      channelTableSplitView = [[MISplitView alloc] initWithFrame:channelTableSplitViewFrame];
      [channelTableSplitView setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
      [channelTableSplitView setDividerThickness:2.0f];
      [channelTableSplitView setDrawLowerBorder:YES];
      [channelTableSplitView setVertical:YES];
      [channelTableSplitView setDelegate:self];
      
      [[mainWindow contentView] addSubview:channelTableSplitView];
      [channelTableSplitView setFrame:channelTableSplitViewFrame];
      [channelTableSplitView setNeedsDisplay:YES];
      
      NSRect channelTableFrame = NSMakeRect(0, 0, 120.0, channelTableSplitViewFrame.size.height);
      [channelTableSplitView addSubview:channelTableScrollView];
      [channelTableScrollView setFrame:channelTableFrame];
      [channelTableScrollView setNeedsDisplay:YES];
      
      NSRect containerTableFrame = NSMakeRect(channelTableFrame.size.width, 0.0, channelTableSplitViewFrame.size.width - channelTableFrame.size.width, channelTableSplitViewFrame.size.height);
      [channelTableSplitView addSubview:tabViewTextEntrySplitView];
      [tabViewTextEntrySplitView setFrame:containerTableFrame];
      [tabViewTextEntrySplitView setNeedsDisplay:YES];
      
      [tabViewTextEntrySplitView adjustSubviews];
      [channelTableSplitView adjustSubviews];
      
      [channelTableSplitView restoreLayoutUsingName:@"ChannelTableViewSplit"];      
      break;
    }
  }
  
  // We'll do the shortcuts here now instead. We've got several choices that the user can pick for their,
  // left/right keystrokes. So lets set it up.
  NSMenuItem *previousMenuItem = [[NSApp windowsMenu] itemAtIndex:[[NSApp windowsMenu] indexOfItemWithTarget:self andAction:@selector(previousChannel:)]];
  NSMenuItem *nextMenuItem = [[NSApp windowsMenu] itemAtIndex:[[NSApp windowsMenu] indexOfItemWithTarget:self andAction:@selector(nextChannel:)]];
  
  switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"tabShortcuts"])
  {
    case TabShortcutArrows:
      [previousMenuItem setKeyEquivalent:((orientation == MIChannelBarHorizontalOrientation) ? [NSString stringWithUnicodeCharacter:NSLeftArrowFunctionKey] : [NSString stringWithUnicodeCharacter:NSUpArrowFunctionKey])];
      [previousMenuItem setKeyEquivalentModifierMask:NSCommandKeyMask];
      [nextMenuItem setKeyEquivalent:((orientation == MIChannelBarHorizontalOrientation) ? [NSString stringWithUnicodeCharacter:NSRightArrowFunctionKey] : [NSString stringWithUnicodeCharacter:NSDownArrowFunctionKey])];
      [nextMenuItem setKeyEquivalentModifierMask:NSCommandKeyMask];
      break;
    case TabShortcutShiftArrows:
      [previousMenuItem setKeyEquivalent:((orientation == MIChannelBarHorizontalOrientation) ? [NSString stringWithUnicodeCharacter:NSLeftArrowFunctionKey] : [NSString stringWithUnicodeCharacter:NSUpArrowFunctionKey])];
      [previousMenuItem setKeyEquivalentModifierMask:NSCommandKeyMask|NSShiftKeyMask];
      [nextMenuItem setKeyEquivalent:((orientation == MIChannelBarHorizontalOrientation) ? [NSString stringWithUnicodeCharacter:NSRightArrowFunctionKey] : [NSString stringWithUnicodeCharacter:NSDownArrowFunctionKey])];
      [nextMenuItem setKeyEquivalentModifierMask:NSCommandKeyMask|NSShiftKeyMask];
      break;
    case TabShortcutOptionArrows:
      [previousMenuItem setKeyEquivalent:((orientation == MIChannelBarHorizontalOrientation) ? [NSString stringWithUnicodeCharacter:NSLeftArrowFunctionKey] : [NSString stringWithUnicodeCharacter:NSUpArrowFunctionKey])];
      [previousMenuItem setKeyEquivalentModifierMask:NSCommandKeyMask|NSAlternateKeyMask];
      [nextMenuItem setKeyEquivalent:((orientation == MIChannelBarHorizontalOrientation) ? [NSString stringWithUnicodeCharacter:NSRightArrowFunctionKey] : [NSString stringWithUnicodeCharacter:NSDownArrowFunctionKey])];
      [nextMenuItem setKeyEquivalentModifierMask:NSCommandKeyMask|NSAlternateKeyMask];
      break;
    case TabShortcutBrackets:
      [previousMenuItem setKeyEquivalent:@"["];
      [previousMenuItem setKeyEquivalentModifierMask:NSCommandKeyMask];
      [nextMenuItem setKeyEquivalent:@"]"];
      [nextMenuItem setKeyEquivalentModifierMask:NSCommandKeyMask];
      break;
    case TabShortcutBraces:
      [previousMenuItem setKeyEquivalent:@"{"];
      [previousMenuItem setKeyEquivalentModifierMask:NSCommandKeyMask];
      [nextMenuItem setKeyEquivalent:@"}"];
      [nextMenuItem setKeyEquivalentModifierMask:NSCommandKeyMask];
      break;
    default:
      NSLog(@"channelBarOrientationDidChange: Uh, what? Invalid tabShortcuts value.");
  }
}

- (void)resizingTextViewUpdated:(NSNotification*)notification
{
  // Need to resize the two views.
  NSRect textViewRect = NSMakeRect(0, 0, [inputTextField frame].size.width, [inputTextField desiredSize].height);
  NSRect tabViewRect = NSMakeRect(0, 0, [tabView frame].size.width, [tabViewTextEntrySplitView frame].size.height - textViewRect.size.height - [tabViewTextEntrySplitView dividerThickness]);
  
  [inputTextFieldBox setFrame:textViewRect];
  [tabView setFrame:tabViewRect];
  [tabViewTextEntrySplitView adjustSubviews];
  
  // Scroll the view to the bottom
  NSScrollView *view = (NSScrollView*)[[[currentChannelController mainTextView] superview] superview];
  
  NSPoint newScrollPoint = [[view documentView] isFlipped] ? NSMakePoint(0.0, NSMaxY([[view documentView] frame])) : NSZeroPoint;
  [[view documentView] scrollPoint:newScrollPoint];
}

- (void)irssiServerChangedNotification:(NSNotification*)notification
{
	[self buildServersMenu];
}

#pragma mark SplitView Delegates

- (void)splitViewDidResizeSubviews:(NSNotification *)aNotification
{
  if ([[aNotification object] isEqual:channelTableSplitView])
  {
    [(MISplitView*)[aNotification object] saveLayoutUsingName:@"ChannelTableViewSplit"];
  }
  else if ([[aNotification object] isEqual:tabViewTextEntrySplitView])
  {
    ChannelController *c = [[tabView selectedTabViewItem] identifier];
    if ([c isKindOfClass:[ChannelController class]])
    {
      NSScrollView *view = (NSScrollView*)[[[c mainTextView] superview] superview];

      NSPoint newScrollPoint;
      if ([[view documentView] isFlipped])
      {
        newScrollPoint = NSMakePoint(0.0, NSMaxY([[view documentView] frame]));
      }
      else
      {
        newScrollPoint = NSMakePoint(0.0, 0.0);
      }
      [[view documentView] scrollPoint:newScrollPoint];
    }
  }
}

- (CGFloat)splitView:(NSSplitView *)sender constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)offset
{
  if ([sender isEqual:tabViewTextEntrySplitView])
  {
    // max position for the split view should be the text field contents + 6 + the divider size
    return ([sender frame].size.height - [[inputTextField layoutManager] usedRectForTextContainer:[inputTextField textContainer]].size.height - 6.0);
  }
  return proposedMax;
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

- (void)userDefaultsChanged:(NSNotification*)notification
{

}

#pragma mark - NSApp notifications

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
  
  // Save out some useful shit
  [[NSUserDefaults standardUserDefaults] setBool:[inputTextField isContinuousSpellCheckingEnabled] forKey:@"inputTextEntrySpellCheck"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  // And this
  signal_emit("command save", 1, "");

  /* Else, check if we should bring up quit sheet */
  if (askQuit) {
    [reasonTextField setStringValue:quitMessage];
    [NSApp beginSheet:reasonWindow modalForWindow:mainWindow modalDelegate:nil didEndSelector:nil contextInfo:nil];
    return NSTerminateLater; // Handle termination after reason is recieved
  }
  
  /* Else quit with default quit message */
  signal_emit("command quit", 1, [quitMessage cStringUsingEncoding:NSUTF8StringEncoding]);
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
  [IrssiCore deinitialiseCore];
}


//-------------------------------------------------------------------
// applicationDidBecomeActive:
// Called when becominxg active. Removes some notification systems
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

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
  if (![mainWindow isVisible]) {
    [mainWindow makeKeyAndOrderFront:self];
  }
  /* we're not NSDocument based, so don't let AppKit try */
  return NO;
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
  [[channelTableView enclosingScrollView] setBackgroundColor:[ColorSet channelListBackgroundColor]];
  [channelTableView reloadData];
  [channelBar setNeedsDisplay:YES];
}

// Changing the background colour affects the channel bar
- (void)channelBackgroundColorChanged:(NSNotification*)note
{
  [channelBar setNeedsDisplay:YES];
}

#pragma mark - Channel TableView Datasource

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


#pragma mark - Initializers
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
  
  // Setup the event controller
  eventController = [[EventController alloc] init];
  
  /* Register defaults */
  NSFont *defaultChannelFont = [NSFont fontWithName:@"Monaco" size:9.0];
  NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSDictionary dictionary], @"shortcutDict",
                        [NSArchiver archivedDataWithRootObject:defaultChannelFont], @"channelFont",
                        [NSArchiver archivedDataWithRootObject:defaultChannelFont], @"nickListFont",
                        [NSNumber numberWithBool:TRUE], @"showNicklist",
                        [NSNumber numberWithBool:TRUE], @"useFloaterOnPriv",
                        [NSNumber numberWithBool:NO], @"askQuit",
                        [NSNumber numberWithBool:FALSE], @"bounceIconOnPriv",
                        [NSNumber numberWithInt:0], @"channelBarOrientation",
                        [NSNumber numberWithInt:TabShortcutArrows], @"tabShortcuts",
                        [EventController defaults], @"eventDefaults",
                        [NSDictionary dictionary], @"eventSilences",
                        [NSNumber numberWithBool:YES], @"channelInTitle",
                        [NSNumber numberWithBool:YES], @"homeEndGoesToTextView",
                        [NSNumber numberWithBool:YES], @"inputTextEntrySpellCheck",
                        [NSNumber numberWithBool:YES], @"showAlbumInSlashiTunes",
                        [NSNumber numberWithBool:YES], @"antiAliasFonts",
                        [NSNumber numberWithBool:NO], @"useSmallTextEntryFont",
                        nil];
    
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults registerDefaults:dict];

  /* Check for any preference migrations we need to do. */
  [PreferenceVersionHelper checkVersionAndUpgrade];
  
  /* A small hack, given that we could have migrated window sizes and this window is already loaded. */
  [mainWindow setFrameUsingName:[mainWindow frameAutosaveName]];

  // Setting useSmallTextEntryFont in preferences causes us to use Monaco, 10pt for the text area
  if ([[NSUserDefaults standardUserDefaults] boolForKey:@"useSmallTextEntryFont"])
  {
    [inputTextField setFont:[NSFont fontWithName:@"Monaco" size:10.0]];
  }
  else
  {
    [inputTextField setFont:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] dataForKey:@"channelFont"]]];
  }  
  
  // Register the default colours too.
  [ColorSet registerDefaults];
  
  // Setup sparkle, we're gonna be delegate for sparkle routines. In particular, I want to stop the retarded quit message
  // box appearing when sparkle tries to update the application.
  [[SUUpdater sharedUpdater] setDelegate:self];
  
  // Check the current app version, if we have more than three full-stops in the version then we're a beta build and should
  // enable beta updates.
  if ([[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] componentsSeparatedByString:@"."] count] > 4)
  {
    [[SUUpdater sharedUpdater] setFeedURL:[NSURL URLWithString:@"http://www.sysctl.co.uk/projects/macirssi/beta.php"]];
  }
  
  // Also register the user-defaults check.
  [nc addObserver:self selector:@selector(userDefaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
  
  // Keep hold of the UI elements we give a damn about
  [inputTextFieldBox retain];
  [tabView retain];
  [channelTableScrollView retain];
  [channelBar retain];

  // Split View to hold the main window contents.
  [tabViewTextEntrySplitView retain];
  [tabViewTextEntrySplitView setDelegate:self];
  [tabViewTextEntrySplitView setDividerThickness:2.0f];
  [tabViewTextEntrySplitView setDrawLowerBorder:YES];
  [tabViewTextEntrySplitView adjustSubviews];
  
  // Setup the sidebar frame change notifications
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resizingTextViewUpdated:) name:MIViewDesiredSizeDidChangeNotification object:inputTextField];
  
  // Fire the orientation notification to save us repeating code.
  [self channelBarOrientationDidChange:nil];
  
  // Hook up the observer
  [nc addObserver:self selector:@selector(channelBarOrientationDidChange:) name:@"channelBarOrientationDidChange" object:nil];
  
  /* Window menu management */
  _windowsMenuItems = [[NSMutableArray alloc] init];
  _serversMenuItems = [[NSMutableArray alloc] init];
  _shortcutsMenuItems = [[NSMutableArray alloc] init];
  [mainWindow setExcludedFromWindowsMenu:YES];

  // Convert any shortcuts from the old system and set the menu up
  [self checkAndConvertOldShortcuts];
  [self buildShortcutsMenu];
  
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
  [nc addObserver:self selector:@selector(buildShortcutsMenu) name:kMIShortcutsChangedNotiication object:nil];
  [nc addObserver:self selector:@selector(irssiServerChangedNotification:) name:kMIServerConnectedEvent object:nil];
  [nc addObserver:self selector:@selector(irssiServerChangedNotification:) name:kMIServerDisconnectedEvent object:nil];
  [nc addObserver:self selector:@selector(channelBackgroundColorChanged:) name:@"channelColorChanged" object:nil];
    
  /* Set up colors */
  [inputTextField setTextColor:[ColorSet inputTextForegroundColor]];
  [inputTextField setBackgroundColor:[ColorSet inputTextBackgroundColor]];
  [inputTextField setContinuousSpellCheckingEnabled:[[NSUserDefaults standardUserDefaults] boolForKey:@"inputTextEntrySpellCheck"]];
  [channelTableView setBackgroundColor:[NSColor clearColor]];
  [[channelTableView enclosingScrollView] setBackgroundColor:[ColorSet channelListBackgroundColor]];
  [channelTableView setUsesAlternatingRowBackgroundColors:NO];
  
  /* Init Growl */
  [GrowlApplicationBridge setGrowlDelegate:self];
  
  /* Sleep registration */
  (void)[ConnectivityMonitor sharedMonitor];
  
  [IrssiCore initialiseCore];
  
  [DebugController initialiseDebugController];
  
  /* Fire up the glib runloop integration */
  [[IrssiRunloop mainRunloop] run];
}

@end
