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

#import "AppController.h"
#import "ChannelController.h"
#import "PreferenceController.h"
#import "EventController.h"
#import "CustomWindow.h"
#import "CustomTableView.h"
#import "History.h"
#import "ColorSet.h"
#import "chatnets.h"
#import "irc.h"
#import "irc-chatnets.h"
#import "irc-servers-setup.h"
#import "fe-common-core.h"
#import "IrssiBridge.h"
#import "GrowlApplicationBridge.h"

#define PASTE_WARNING_THRESHOLD 4

void setRefToAppController(AppController *a);
void textui_deinit();
static GMainLoop *main_loop;
int argc;
char **argv;

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
// performShortcut:
// Performes the command that is bound to the selected menu item 
//
// "sender" - A menu item
//-------------------------------------------------------------------
- (IBAction)performShortcut:(id)sender
{
	if (!shortcutCommands)
		return;
	
	WINDOW_REC *rec = [currentChannelController windowRec];
	NSArray *commands = [shortcutCommands[[sender tag]] componentsSeparatedByString:@";"];
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


//-------------------------------------------------------------------
// showFontPanel:
// Brings up the font panel.
//
// "sender" - A menu item
//-------------------------------------------------------------------
- (IBAction)showFontPanel:(id)sender
{
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
	NSString *cmd = [sender stringValue];

	if ([cmd length] == 0)
		return;
	
	WINDOW_REC *rec = [currentChannelController windowRec];
	[commandHistory addCommand:cmd];
	[sender setStringValue:@""];

	NSArray *commands = [self splitCommand:cmd];

	/* Check with user before sending multiple lines */
	if ([commands count] > PASTE_WARNING_THRESHOLD) {
		int button = [[NSAlert alertWithMessageText:@"Confirmation request" defaultButton:@"Ok" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@"Do you really want to paste %d lines?", [commands count]] runModal];
		
		if (button == 0)
			return;
	}
	
	for (i = 0; i < [commands count]; i++) {
		/* Test if clear command (special case) */
		if ([[commands objectAtIndex:i] isEqualToString:@"/clear"]) {
			[currentChannelController clearTextView];
			continue;
		}
		
		/* Else normal command */
		CFStringEncoding currentEncoding = [currentChannelController textEncoding];
		char *tmp = [IrssiBridge irssiCStringWithString:[commands objectAtIndex:i] encoding:currentEncoding];
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
	if ([[preferenceController window] isKeyWindow])
		return;

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
		signal_emit("command quit", 1, [IrssiBridge irssiCStringWithString:defaultQuitMessage]);
}

//-------------------------------------------------------------------
// showPreferencePanel:
// Brings up the preference panel
//
// "sender" - A menu item
//-------------------------------------------------------------------
- (IBAction)showPreferencePanel:(id)sender
{
	if (!preferenceController)
		preferenceController = [[PreferenceController alloc] initWithColorSet:macIrssiColors];
	
	[preferenceController showWindow:self];
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
	[owner setTabViewItem:tabViewItem colors:macIrssiColors appController:self];
	
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
		[(ChannelController *)(oldwind->gui_data) saveScrollState];
	
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
	
	NSRange r;
	if ([[mainWindow firstResponder] isMemberOfClass:[NSTextView class]]) {
		r = [(NSTextView *)[mainWindow firstResponder] selectedRange];
		[mainWindow makeFirstResponder:inputTextField];
		[(NSTextView *)[mainWindow firstResponder] setSelectedRange:r];
	}
	else
		[mainWindow makeFirstResponder:inputTextField];
}

//-------------------------------------------------------------------
// refnumChanged:
//-------------------------------------------------------------------
- (void)refnumChanged:(WINDOW_REC *)wind old:(int)old
{
	//printf("[REFNUM] old:%d new:%d\n", old, wind->refnum);
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
// setShortcutCommands:
// Set up the shortcuts menu.
//
// "commands" - An array of commands
//-------------------------------------------------------------------
- (void)setShortcutCommands:(NSString **)commands
{
	if (!commands)
		return;
	
	shortcutCommands = commands;
	
	NSMenuItem *menuItem;
	int i;
	
	for (i = 0; i < 12; i++) {
		menuItem = (NSMenuItem *)[shortcutsMenu itemAtIndex:i];
		if (!commands[i] || [commands[i] length] == 0) {
			[menuItem setTitle:@"Nothing"];
			[menuItem setTarget:nil];
			[menuItem setAction:nil];
		}
		else {
			[menuItem setTitle:commands[i]];
			[menuItem setTarget:self];
			[menuItem setAction:@selector(performShortcut:)];
		}
	}
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
	NSString *currentCommand = [inputTextField stringValue];
	if ([commandHistory iteratorAtFront] && ![currentCommand isEqualToString:@""])
		[commandHistory setTemporaryCommand:currentCommand];
	
	NSString *command = [commandHistory previousCommand];
	
	if (!command)
		return;
	
	[inputTextField setStringValue:command];
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
	NSString *command = [commandHistory nextCommand];
	[inputTextField setStringValue:command ? command : @""];
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
	NSEnumerator *enumerator = [[tabView tabViewItems] objectEnumerator];
	NSTabViewItem *tmp;
	channelFont = [sender convertFont:channelFont];

	/* Iterate through all channels */
	while (tmp = [enumerator nextObject])
		[[tmp identifier] setFont:channelFont];
	
	/* Save change in user defaults */
	[[NSUserDefaults standardUserDefaults] setObject:[NSArchiver archivedDataWithRootObject:channelFont] forKey:@"channelFont"];
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

/**
 * Bring application to front and select the channel from which the priv was received
 * @param clickContext The refnum of the channel
 */
- (void) growlNotificationWasClicked:(id)clickContext
{
	[NSApp activateIgnoringOtherApps:TRUE];
	WINDOW_REC *rec = [currentChannelController windowRec];
	NSString *cmd = [NSString stringWithFormat:@"/window %d", [(NSNumber *)clickContext intValue]];
	signal_emit("send command", 3, [cmd cStringUsingEncoding:NSASCIIStringEncoding], rec->active_server, rec->active);		
}

/**
 * Growl registration delegate
 */
- (NSDictionary *) registrationDictionaryForGrowl
{
	NSArray *growlNotifications = [NSArray arrayWithObjects:@"Version check", nil];
  growlNotifications = [[eventController availableEventNames] arrayByAddingObjectsFromArray:growlNotifications];
	return [NSDictionary dictionaryWithObjectsAndKeys:growlNotifications, GROWL_NOTIFICATIONS_ALL, growlNotifications, GROWL_NOTIFICATIONS_DEFAULT, nil];
}

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
	
	/* Else, check if we should bring up quit sheet */
	if (askQuit) {
		[reasonTextField setStringValue:defaultQuitMessage];
		[NSApp beginSheet:reasonWindow modalForWindow:mainWindow modalDelegate:nil didEndSelector:nil contextInfo:nil];
		return NSTerminateLater; // Handle termination after reason is recieved
	}
	
	/* Else quit with default quit message */
	signal_emit("command quit", 1, [IrssiBridge irssiCStringWithString:defaultQuitMessage]);
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
		[tmp clearNickView];
	
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
		[mainWindow makeKeyAndOrderFront:self];
		
	/* If icon was changed to notify user of priv in active channel when the
		app was inactive while no other channel needs notification, then we
		must revert icon to normal */
	if (hilightChannels == 0)
		[self setIcon:defaultIcon];
}

// Handles waking and sleeping, need to disconnect cleanly before sleeping.
- (void)workspaceWillSleep:(NSNotification*)notification
{
  sleeping = true;
	WINDOW_REC *tmp = [currentChannelController windowRec];
	signal_emit("command disconnect", 2, " * Computer has gone to sleep", tmp->active_server);
  NSLog(@"Sleeping");
}

- (void)workspaceDidWake:(NSNotification*)notification
{
  if (sleeping)
  {
    sleeping = false;
    fe_common_core_finish_init(); // AWFUL HACK. but...it is the only way to get the frontend to do an
                                  // autoconnect without hacking my way into the backend.
  }
}


//-------------------------------------------------------------------
// inputTextFieldColorChanged:
// Updates the color of the input text field.
//
// "note" - Ignored
//-------------------------------------------------------------------
- (void)inputTextFieldColorChanged:(NSNotification *)note
{
	[inputTextField setTextColor:[macIrssiColors inputTextFieldFGColor]];
	[inputTextField setBackgroundColor:[macIrssiColors inputTextFieldBGColor]];
}


//-------------------------------------------------------------------
// channelListColorChanged:
// Updates the color of the channel list
//
// "note" - Ignored
//-------------------------------------------------------------------
- (void)channelListColorChanged:(NSNotification *)note
{
	[channelTableView setBackgroundColor:[macIrssiColors channelListBGColor]];
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

	[highlightAttributes setObject:[highlightColors objectAtIndex:tmp->data_level] forKey:NSForegroundColorAttributeName];
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
#if 0
	static char num[3];
	//[tabView selectTabViewItemAtIndex:rowIndex];
	sprintf(num, "%d", rowIndex+1);
	signal_emit("command window goto", 3, num, active_win->active_server, active_win->active);
#endif
//	ChannelController *tmp = [[tabView tabViewItemAtIndex:rowIndex] identifier];
//	if (tmp)
//		window_set_active([tmp windowRec]);
	return TRUE;
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
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	//char *argv[2] = {"MacIrssi", NULL};
	//char *argv[4] = {"MacIrssi", "--config=tmp", "--nick=g1m0", NULL};
	setRefToAppController(self);
	highlightAttributes = [[NSMutableDictionary alloc] init];
	quitting = FALSE;
	hilightChannels = 0;
	mainRunLoop = [NSRunLoop currentRunLoop];

	const char *path = [[[NSBundle mainBundle] bundlePath] fileSystemRepresentation];
	if (chdir(path) == -1)
		NSLog(@"Can't set path!");

#if 0
	char *filename = "stdout.txt";
	int fd;
	if ( (fd = open(filename, O_WRONLY | O_CREAT | O_APPEND, S_IRUSR | S_IWUSR)) == -1)
		NSLog(@"Can't open file %s!", filename);

	if (dup2(fd, STDOUT_FILENO) == -1)
		NSLog(@"Can't redirect stdout!");
	
	filename = "stderr.txt";
	if ( (fd = open(filename, O_WRONLY | O_CREAT | O_APPEND, S_IRUSR | S_IWUSR)) == -1)
		NSLog(@"Can't open file %s!", filename);
	
	if (dup2(fd, STDERR_FILENO) == -1)
		NSLog(@"Can't redirect stderr!");
	
	NSLog(@"--- STARTING UP ---");
#endif
	
	[[NSFontManager sharedFontManager] setAction:@selector(specialFontChange:)];
  eventController = [[EventController alloc] init];

	/* Register defaults */
	NSFont *defaultChannelFont = [NSFont fontWithName:@"Monaco" size:9.0];
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSArchiver archivedDataWithRootObject:defaultChannelFont], @"channelFont",
		[NSNumber numberWithInt:kCFStringEncodingISOLatin1], @"defaultTextEncoding",
		[NSNumber numberWithBool:TRUE], @"useFloaterOnPriv",
		[NSNumber numberWithBool:TRUE], @"askQuit",
		[NSNumber numberWithBool:FALSE], @"bounceIconOnPriv",
		[NSNumber numberWithInt:0], @"channelBarOrientation",
    [EventController defaults], @"eventDefaults",
		nil];
  
		
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults registerDefaults:dict];

	/* Read settings */
	channelFont = [[NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"channelFont"]] retain];
	askQuit = [defaults boolForKey:@"askQuit"];
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
  
	int i;
	NSString *keyArray[12];
	NSString *valueArray[12];
	for (i = 0; i < 12; i++) {
		keyArray[i] = [NSString stringWithFormat:@"shortcut%d", i+1];
		valueArray[i] = @"";
	}
	
	NSDictionary *shortcuts = [NSDictionary dictionaryWithObjects:(id *)valueArray forKeys:(id *)keyArray count:12];
	[defaults registerDefaults:shortcuts];
	shortcutCommands = malloc(12 * sizeof(NSString *));
	
	NSMenuItem *menuItem;
	for (i = 0; i < 12; i++) {
		shortcutCommands[i] = [[defaults objectForKey:[NSString stringWithFormat:@"shortcut%d", i+1]] retain];
		menuItem = [[shortcutsMenu itemArray] objectAtIndex:i];
		if ([shortcutCommands[i] length] > 0) {
			[menuItem setTitle:shortcutCommands[i]];
			[menuItem setTarget:self];
			[menuItem setAction:@selector(performShortcut:)];
		}
	}
	
	currentIcon = defaultIcon = [[NSApp applicationIconImage] copy];
	iconOnPriv = [[NSImage alloc] initWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/Contents/Resources/MacIrssi-Alert.png"]];
	if (!iconOnPriv) {
		NSLog(@"Can't load 'icon-dot' image!");
		iconOnPriv = [[NSApp applicationIconImage] retain];
	}
	
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:@"Get MacIrssi - http://www.g1m0.se/macirssi/ " forKey:@"defaultQuitMessage"]];
	defaultQuitMessage = [[defaults objectForKey:@"defaultQuitMessage"] retain];
	if (!channelFont)
		channelFont = [NSFont fontWithName:@"Monaco" size:9.0];

	/* Delete first tab */
	[tabView removeTabViewItem:[tabView tabViewItemAtIndex:0]];
	/* Yes please =) */
	[[tabView window] useOptimizedDrawing:TRUE];
	/* Enable parts of window to be transparent */
	[[tabView window] setOpaque:FALSE];

	commandHistory = [[History alloc] initWithCapacity:150];
	[nc addObserver:self selector:@selector(inputTextFieldColorChanged:) name:@"inputTextFieldColorChanged" object:nil];
	[nc addObserver:self selector:@selector(channelListColorChanged:) name:@"channelListColorChanged" object:nil];

	/* Set up colors */
	macIrssiColors = [[ColorSet alloc] init];
	highlightColors = [macIrssiColors channelListFGColors];
	[inputTextField setTextColor:[macIrssiColors inputTextFieldFGColor]];
	[inputTextField setBackgroundColor:[macIrssiColors inputTextFieldBGColor]];
	[channelTableView setBackgroundColor:[macIrssiColors channelListBGColor]];
	//[((NSTextView *)inputTextField) setInsertionPointColor:[NSColor whiteColor]]; //TODO: preference
	
	/* Init Growl */
	[GrowlApplicationBridge setGrowlDelegate:self];
	[updateChecker safeInit]; // To make sure growl is regitred before update check tries to send growl notification
  
  /* Sleep registration */
  [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(workspaceWillSleep:) name:NSWorkspaceWillSleepNotification object:nil];
  [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(workspaceDidWake:) name:NSWorkspaceDidWakeNotification object:nil];
		
	/* Init theme dirs */
	const char *tmp;
	
	NSArray *dirs = [self themeLocations];
	num_theme_dirs = [dirs count];
	theme_dirs = (char **)malloc(num_theme_dirs * sizeof(char *));
	for (i = 0; i < [dirs count]; i++) {
		tmp = [[dirs objectAtIndex:i] lossyCString];
		theme_dirs[i] = (char *)malloc(strlen(tmp)+1);
		strcpy(theme_dirs[i], tmp);
	}	

	/* Start up irssi code */
	
	/* Double clicking an app gives a "-psn..." argument which irssi does
		not like, remove if present */
	if ( argc > 1 && strncmp(argv[1], "-psn", 4) == 0)
	{
		argc--;
		argv[1] = argv[0];
		irssi_main(argc, argv+1);
	}
	else
		irssi_main(argc, argv);
	
	main_loop = g_main_new(TRUE);

	/* Create new thread to run main irssi loop */
	[NSThread detachNewThreadSelector:@selector(runGlibLoopIteration:) toTarget:self withObject:nil];
}


#pragma mark Instance variables
//-------------------------------------------------------------------
// The current channel font.
//-------------------------------------------------------------------
- (NSFont *)channelFont { return channelFont; }

//-------------------------------------------------------------------
// The default quit message
//-------------------------------------------------------------------
- (void)setDefaultQuitMessage:(NSString *)msg { defaultQuitMessage = [msg retain]; }


//-------------------------------------------------------------------
// If the user wants an quit message dialog when quitting
//-------------------------------------------------------------------
- (void)setAskQuit:(bool)set { askQuit = set; }

@end
