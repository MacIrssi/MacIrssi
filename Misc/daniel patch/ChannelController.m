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
// MacIrssi - ChannelController
// Nils Hjelte, c01nhe@cs.umu.se
//
// Controls the GUI of a channel.
//*****************************************************************

#import "ChannelController.h"
#import "AppController.h"
#import "window-activity.h"
#import "CocoaBridge.h"
#import "ColorSet.h"
#import "NSAttributedStringAdditions.h"
@implementation ChannelController

#pragma mark IBAction methods
//-------------------------------------------------------------------
// modeChanged:
// Sets a flag so we know topic window has been edited. 
//
// "sender" - The edited object
//-------------------------------------------------------------------
- (IBAction)modeChanged:(id)sender
{
	modeChanged = TRUE;
}


//-------------------------------------------------------------------
// endTopicWindow:
// Closes the topic window and change channelmode to conform to changes made. 
//
// "sender" - The "Save" or "Cancel" button
//-------------------------------------------------------------------
- (IBAction)endTopicWindow:(id)sender
{
	/* Check if changes has been made */
	if ([[sender title] isEqual:@"Save"] && ownnick->op) {
		if ([[topicEditableTextField stringValue] isEqual:[topicTextField stringValue]] == FALSE) {
			NSString *cmd = [NSString stringWithFormat:@"/topic %@", [topicEditableTextField stringValue]];
			char *tmp = [CocoaBridge irssiCStringWithString:cmd];
			signal_emit("send command", 3, tmp, windowRec->active_server, windowRec->active);
			free(tmp);
		}
		
		/* mode-parser */
		if (modeChanged) {
			NSMutableString *removeMode = [[NSMutableString alloc] initWithFormat:@"/mode %@ -", name];
			NSMutableString *addMode = [[NSMutableString alloc] initWithString:@"+"];
			
			/* invite */
			if ([inviteCheckBox state] == NSOnState)
				[addMode appendString:@"i"];
			else
				[removeMode appendString:@"i"];
			
			/* moderated */
			if ([moderatedCheckBox state] == NSOnState)
				[addMode appendString:@"m"];
			else
				[removeMode appendString:@"m"];
			
			/* private */
			if ([privateCheckBox state] == NSOnState)
				[addMode appendString:@"p"];
			else
				[removeMode appendString:@"p"];
			
			/* secret */
			if ([secretCheckBox state] == NSOnState)
				[addMode appendString:@"s"];
			else
				[removeMode appendString:@"s"];
			
			/* no external messages */
			if ([noExternalMessagesCheckBox state] == NSOnState)
				[addMode appendString:@"n"];
			else
				[removeMode appendString:@"n"];
			
			/* only ops can change topic */
			if ([onlyOpsCanChangeTopicCheckBox state] == NSOnState)
				[addMode appendString:@"t"];
			else
				[removeMode appendString:@"t"];
			
			/* limit */
			if ([maxUsersTextField intValue] != 0)
				[addMode appendFormat:@"l %d ", [maxUsersTextField intValue]];
			else
				[removeMode appendString:@"l"];
			
			/* key (special treatment) */
			if ([[keyTextField stringValue] isEqual:@""] && ([mode rangeOfString:@"k"].location != NSNotFound))
				[removeMode appendString:@"k"];
			else if (![[keyTextField stringValue] isEqual:@""]) {
				if ([mode rangeOfString:@"k"].location != NSNotFound) {
					/* Remove old key */
					NSString *removeKey = [NSString stringWithFormat:@"/mode %@ -k", name];
					char *tmp = [CocoaBridge irssiCStringWithString:removeKey];
					signal_emit("send command", 3, tmp, windowRec->active_server, windowRec->active);
					free(tmp);
				}
				[addMode appendFormat:@"+k %@", [keyTextField stringValue]];
			}
			
			[removeMode appendString:addMode];
			NSLog(removeMode);
			char *tmp2 = [CocoaBridge irssiCStringWithString:removeMode];
			signal_emit("send command", 3, tmp2, windowRec->active_server, windowRec->active);
			free(tmp2);
			[addMode release];
			[removeMode release];
			modeChanged = FALSE;
		}
	}
	
	/* Check floater setting wether or not we're op */
	if ([[sender title] isEqual:@"Save"])
		useFloater = ([floaterCheckBox state] == NSOnState);
	
	/* Remove sheet */
	[topicWindow orderOut:sender];
	[NSApp endSheet:topicWindow returnCode:1];
}


//-------------------------------------------------------------------
// endReasonWindow
// Closes the reason window and performs action with entered reason. 
//
// "sender" - The reason text field
//-------------------------------------------------------------------
- (IBAction)endReasonWindow:(id)sender
{
	[commandWithReason appendString:[sender stringValue]];
	char *tmp = [CocoaBridge irssiCStringWithString:commandWithReason];
	signal_emit("send command", 3, tmp, windowRec->active_server, windowRec->active);
	free(tmp);
	[commandWithReason release];
				
	/* Remove sheet */
	[reasonWindow orderOut:sender];
	[NSApp endSheet:reasonWindow returnCode:1];
	[sender setStringValue:@""];
}


//-------------------------------------------------------------------
// nickViewMenuClicked:
// Performes the apropriate action for the context menu item selected. 
//
// "sender" - The context menu item
//-------------------------------------------------------------------
- (IBAction)nickViewMenuClicked:(id)sender
{
	int row = [nickTableView selectedRow];
	
	if (row == -1)
		return;
	
	NSString *nick = [NSString stringWithCString:((NICK_REC *)[[nicks objectAtIndex:row] pointerValue])->nick];
	NSString *command;
	NSString *host;
	
	switch ([sender tag]) {
		case Query:
			command = [NSString stringWithFormat:@"/query %@", nick];
			break;
		case Whois:
			command = [NSString stringWithFormat:@"/whois %@", nick];
			break;
		case Who:
			command = [NSString stringWithFormat:@"/who %@", nick];
			break;
			/* Control */
		case Ignore:
			/* todo */
			return;
		case Op:
			command = [NSString stringWithFormat:@"/op %@", nick];
			break;
		case Deop:
			command = [NSString stringWithFormat:@"/deop %@", nick];
			break;
		case Voice:
			command = [NSString stringWithFormat:@"/voice %@", nick];
			break;
		case Devoice:
			command = [NSString stringWithFormat:@"/devoice %@", nick];
			break;
		case Kick:
			commandWithReason = [[NSMutableString alloc] initWithFormat:@"/kick %@ ", nick];
			[NSApp beginSheet:reasonWindow modalForWindow:[wholeView window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
			return;
		case Ban:
			command = [NSString stringWithFormat:@"/ban %@", nick];
			break;
		case KickBan:
			commandWithReason = [[NSMutableString alloc] initWithFormat:@"/kickban %@ ", nick];
			[NSApp beginSheet:reasonWindow modalForWindow:[wholeView window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
			return;
			/* CTCP */
		case Ping:
			command = [NSString stringWithFormat:@"/ctcp %@ ping", nick];
			break;
		case Finger:
			command = [NSString stringWithFormat:@"/ctcp %@ finger", nick];
			break;
		case Version:
			command = [NSString stringWithFormat:@"/ctcp %@ version", nick];
			break;
		case Time:
			command = [NSString stringWithFormat:@"/ctcp %@ time", nick];
			break;
		case Userinfo:
			command = [NSString stringWithFormat:@"/ctcp %@ userinfo", nick];
			break;
		case Clientinfo:
			command = [NSString stringWithFormat:@"/ctcp %@ clientinfo", nick];
			break;
			/* DCC */
		case Send:
			/* todo */
			return;
		case Chat:
			/* todo */
			return;
		case List:
			command = [NSString stringWithFormat:@"/msg %@ xdcc list", nick];
			break;
		case CopyIP:
			host = [CocoaBridge stringWithIrssiCString:((NICK_REC *)[[nicks objectAtIndex:row] pointerValue])->host];
			NSArray *tmp = [host componentsSeparatedByString:@"@"];
			
			if ([tmp count] < 2)
				command = [NSString stringWithFormat:@"/echo Error: Couldn't copy IP address!"];
			else {
				[[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
				[[NSPasteboard generalPasteboard] setString:[tmp lastObject] forType:NSStringPboardType];
				return;
			}
				break;
		default:
			printf("Error: Unknown menu item\n");
			return;
	}
	
	//printf("Menu: %s\n", [command lossyCString]);
	signal_emit("send command", 3, [command lossyCString], windowRec->active_server, windowRec->active);
	
}

//-------------------------------------------------------------------
// mainTextViewMenuClicked:
// Not yet implemented 
//
// "sender" - A menu item
//-------------------------------------------------------------------
- (IBAction)mainTextViewMenuClicked:(id)sender
{
	NSLog([sender title]);
}


//-------------------------------------------------------------------
// raiseTopicWindow:
// Brings up the topic window. 
//
// "sender" - The "Edit channel" button
//-------------------------------------------------------------------
- (IBAction)raiseTopicWindow:(id)sender
{
	
	/* If op, allow editing, else disallow */
	if (ownnick->op) {
		[topicEditableTextField setEditable:TRUE];
		[inviteCheckBox setEnabled:TRUE];
		[moderatedCheckBox setEnabled:TRUE];
		[privateCheckBox setEnabled:TRUE];
		[secretCheckBox setEnabled:TRUE];
		[noExternalMessagesCheckBox setEnabled:TRUE];
		[onlyOpsCanChangeTopicCheckBox setEnabled:TRUE];
		[maxUsersTextField setEnabled:TRUE];
		[keyTextField setEnabled:TRUE];
		//[saveButton setEnabled:TRUE];
	}
	else {
		[topicEditableTextField setEditable:FALSE];
		[inviteCheckBox setEnabled:FALSE];
		[moderatedCheckBox setEnabled:FALSE];
		[privateCheckBox setEnabled:FALSE];
		[secretCheckBox setEnabled:FALSE];
		[noExternalMessagesCheckBox setEnabled:FALSE];
		[onlyOpsCanChangeTopicCheckBox setEnabled:FALSE];
		[maxUsersTextField setEnabled:FALSE];
		[keyTextField setEnabled:FALSE];
		//[saveButton setEnabled:FALSE];
	}
	
	/* Make sheet reflect current channel settings */
	[topicEditableTextField setStringValue:[topicTextField stringValue] ? [topicTextField stringValue] : @""];
	[topicByTextField setStringValue:topic_by ? [[topic_by componentsSeparatedByString:@"!"] objectAtIndex:0]: @""];
	
	NSString *topicTime;
	if (topic_time == 0)
		topicTime = @"";
	else
		topicTime = [NSString stringWithCString:ctime(&topic_time)];
	[topicTimeTextField setStringValue:topicTime];
	[maxUsersTextField setIntValue:limit];
	[floaterCheckBox setState:(useFloater ? NSOnState : NSOffState)];
	
	/* mode-parser */
	NSString *tmp = [[mode componentsSeparatedByString:@" "] objectAtIndex:0]; // Don't include the key
	[inviteCheckBox setState:([tmp rangeOfString:@"i"].location == NSNotFound) ? NSOffState : NSOnState];
	[moderatedCheckBox setState:([tmp rangeOfString:@"m"].location == NSNotFound) ? NSOffState : NSOnState];
	[privateCheckBox setState:([tmp rangeOfString:@"p"].location == NSNotFound) ? NSOffState : NSOnState];
	[secretCheckBox setState:([tmp rangeOfString:@"s"].location == NSNotFound) ? NSOffState : NSOnState];
	[noExternalMessagesCheckBox setState:([tmp rangeOfString:@"n"].location == NSNotFound) ? NSOffState : NSOnState];
	[onlyOpsCanChangeTopicCheckBox setState:([tmp rangeOfString:@"t"].location == NSNotFound) ? NSOffState : NSOnState];
	[maxUsersTextField setIntValue:limit];
	[keyTextField setStringValue:key ? key : @""];
	
	/* Bring up sheet */
	[NSApp beginSheet:topicWindow modalForWindow:[wholeView window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
}


//-------------------------------------------------------------------
// nickListRowDoubleClicked:
// Starts a query with the nick that was double-clicked
//
// "sender" - The table view containing the row
//-------------------------------------------------------------------
- (void)nickListRowDoubleClicked:(id)sender
{
	int row = [nickTableView selectedRow];
	NSString *command = [NSString stringWithFormat:@"/query %s", ((NICK_REC *)[[nicks objectAtIndex:row] pointerValue])->nick];
	signal_emit("send command", 3, [command lossyCString], windowRec->active_server, windowRec->active);
}


#pragma mark Indirect receivers of irssi signals
//-------------------------------------------------------------------
// clearNickView
// Clears the nick view. 
//-------------------------------------------------------------------
- (void)clearNickView
{
	[nicks removeAllObjects];
	[nickTableView removeAllToolTips]; 
	[nickTableView reloadData];
}


//-------------------------------------------------------------------
// queryCreated
// Initializes a query. 
//
// "rec" - A QUERY_REC with info concerning the query
//-------------------------------------------------------------------
- (void)queryCreated:(QUERY_REC *)rec
{
	//printf("Hi\n");
}


//-------------------------------------------------------------------
// channelJoined:
// Initializes a channel. 
//
// "rec" - The channel that was joined
//-------------------------------------------------------------------
- (void)channelJoined:(CHANNEL_REC *)rec
{
	if (rec == NULL)
		return;
	
	isChannel = TRUE;
	
	/* Make nicklist into a NSMutableArray and sort by nickname */
	nicks = [[NSMutableArray alloc] initWithCapacity:g_hash_table_size(rec->nicks)];
	g_hash_table_foreach(rec->nicks, (GHFunc)personFromNickRec, nicks);
	[self sortNicks];
	
	/* Make NSString objects from (char *) */
	name = rec->name ? [[NSString alloc] initWithData:[NSData dataWithBytesNoCopy:rec->name length:strlen(rec->name) freeWhenDone:FALSE] encoding:NSISOLatin1StringEncoding] : @"";
	topic_by = [[NSString alloc] initWithCString:rec->topic_by ? rec->topic_by : ""];
	mode = [[NSString alloc] initWithCString:rec->mode ? rec->mode : ""];
	key = [[NSString alloc] initWithCString:rec->key ? rec->key : ""];
	
	
	/* Copy rest of the values */
	topic_time = rec->topic_time;
	ownnick = rec->ownnick;
	limit = rec->limit;
	no_modes = (BOOL)rec->no_modes;
	chanop = (BOOL)rec->chanop;
	names_got = (BOOL)rec->names_got;
	wholist = (BOOL)rec->wholist;
	synced = (BOOL)rec->synced;
	joined = (BOOL)rec->joined;
	justLeft = (BOOL)rec->left;
	kicked = (BOOL)rec->kicked;
	session_rejoin = (BOOL)rec->session_rejoin;
	destroying = (BOOL)rec->destroying;
	
	/* Update GUI */
	[tabViewItem setLabel:name];
	[nickTableView removeAllToolTips];
	[nickTableView reloadData];
	[editChannelButton setEnabled:TRUE];
}


//-------------------------------------------------------------------
// changeServerOpForNickRec:
// Changes the serverop status for a nick in the nick list. 
//
// "rec" - The nick
//-------------------------------------------------------------------
- (void)changeServerOpForNickRec:(NICK_REC *)rec
{
	/* First undo modechange so we can find him */
	rec->serverop = (rec->serverop) ? FALSE : TRUE;
	
	int i = [self findNick:rec];
	if(i == -1) {
		printf("[changeServerOpForNickRec] Error: \"%s\" not found!\n", rec->nick);
		return;
	}
	[nicks removeObjectAtIndex:i];
	
	/* Redo modechange */
	rec->serverop = (rec->serverop) ? FALSE : TRUE;
	
	/* Insert into new position */
	i = [self findInsertionPositionForNick:rec];
	
	[nicks insertObject:[NSValue valueWithPointer:rec] atIndex:i];
	[nickTableView removeAllToolTips]; 
	[nickTableView reloadData];
}


//-------------------------------------------------------------------
// setMode:type:forNickRec:
// Updates a nicks apperance in nick view when mode is changed. 
//
// "mode" - The mode (@,+)
// "type" - If the mode is added (+) or removed (-)
// "nick" - The affected nick
//-------------------------------------------------------------------
- (void)setMode:(char *)mode1 type:(char *)type forNickRec:(NICK_REC *)nick
{
	int index;
	
	/* First undo modechange so we can find him */
	if (*mode1 == '@')
		nick->op = (*type == '-') ? TRUE : FALSE;
	else if (*mode1 == '+')
		nick->voice = (*type == '-') ? TRUE : FALSE;
	else
		printf("Invalid mode: %s???\n", mode1);
	
	if ( (index = [self findNick:nick]) == -1) {
		printf("Error: nick not found!\n");
		return;
	}
	
	[nicks removeObjectAtIndex:index];
	
	/* Redo modechange so we can insert him in new position */
	if (*mode1 == '@')
		nick->op = (*type == '+') ? TRUE : FALSE;
	else if (*mode1 == '+')
		nick->voice = (*type == '+') ? TRUE : FALSE;
	else
		printf("Invalid mode: %s/n", mode1);
	
	index = [self findInsertionPositionForNick:nick];
	[nicks insertObject:[NSValue valueWithPointer:nick] atIndex:index];
	
	[nickTableView removeAllToolTips]; 
	[nickTableView reloadData];	
}


//-------------------------------------------------------------------
// addNickRec:
// Adds a nick to the channel list. 
//
// "nick" - The nick to be added
//-------------------------------------------------------------------
- (void)addNickRec:(NICK_REC *)nick
{
	int i = [self findInsertionPositionForNick:nick];
	[nicks insertObject:[NSValue valueWithPointer:nick] atIndex:i];
	[nickTableView removeAllToolTips]; 
	[nickTableView reloadData];
}


//-------------------------------------------------------------------
// removeNickRec:
// Remove a nick from the nick list. 
//
// "nick" - The nick to be removed
//-------------------------------------------------------------------
- (void)removeNickRec:(NICK_REC *)nick
{
	int i = [self findNick:nick];
	if (i == -1) {
		printf("Error: nick not found!\n");
		return;
	}
	[nicks removeObjectAtIndex:i];
	[nickTableView removeAllToolTips]; 
	[nickTableView reloadData];
}


//-------------------------------------------------------------------
// changeNickForNickRec:fromNick:
// Changes the 'nick' of a nick. 
//
// "oldNick" - The old 'nick'
// "rec" - The new nick
//-------------------------------------------------------------------
- (void)changeNickForNickRec:(NICK_REC *)rec fromNick:(char *)oldNick
{
	/* First undo nickchange so we can find him */
	char *newNick = rec->nick;
	rec->nick = oldNick;
	int i = [self findNick:rec];
	if(i == -1) {
		printf("Error: nick not found!\n");
		return;
	}
	
	/* Remove from from nicks-array */
	[nicks removeObjectAtIndex:i];
	
	/* Redo nickchange */
	rec->nick = newNick;
	
	/* Insert into new position */
	i = [self findInsertionPositionForNick:rec];
	
	[nicks insertObject:[NSValue valueWithPointer:rec] atIndex:i];
	
	[nickTableView removeAllToolTips];
	[nickTableView reloadData];
}


//-------------------------------------------------------------------
// channelModeChanged:setBy:
// Chages the mode of the channel
//
// "rec" - The channel that changed
// "setter" - The nick that set the mode
//-------------------------------------------------------------------
- (void)channelModeChanged:(CHANNEL_REC *)rec setBy:(char *)setter
{
	[mode release];
	[key release];
	mode = [[NSString alloc] initWithCString:rec->mode ? rec->mode : ""];
	key = [[NSString alloc] initWithCString:rec->key ? rec->key : ""];
	limit = rec->limit;
}


//-------------------------------------------------------------------
// printText:forground:background:flags:
// Adds a text section to the linebuffer. Called for each new
// text-color-section. Currenlty ignores flags <-- FIX =)
//
// "text" - The text to print
// "fg" - The foreground color
// "bg" - The background color
// "flags" - Some flags =)
//-------------------------------------------------------------------
- (void)printText:(char *)text forground:(int)fg background:(int)bg flags:(int)flags
{
	int len = strlen(text);
	len = (len > MAX_LINE-linebufIndex) ? (MAX_LINE-linebufIndex) : len;
	strncpy(linebuf + linebufIndex, text, len);
	linebufIndex += len;
	(attrRanges+attrRangesIndex)->length = len;
	(attrRanges+attrRangesIndex)->location = fg; // location is unused, save fg color in it
	attrRangesIndex++;
}

NSRange findURL(NSString* string)
{
    NSRange		theRange;
    
    theRange = [string rangeOfString:@"http://"];
    if( theRange.location != NSNotFound && theRange.length != 0 )
        return theRange;
    
	theRange = [string rangeOfString:@"ftp://"];
    if( theRange.location != NSNotFound && theRange.length != 0 )
        return theRange;
    
    return theRange;
}



//-------------------------------------------------------------------
// finishLine
// Called after a series of printText when the current line should be
// put out to screen. TODO: better parsing (html, underlines ...)
//-------------------------------------------------------------------
- (void)finishLine
{
	int i, loc = linebuf[0] == '\n';
	linebuf[linebufIndex] = 0;
	
	decodedString = (NSString *)CFStringCreateWithCStringNoCopy(NULL, linebuf, kCFStringEncodingISOLatin1, kCFAllocatorNull);
	outputString = [[NSMutableAttributedString alloc] initWithString:decodedString];
	
	for (i = 0; i < attrRangesIndex; i++) {
		NSRange tmp = attrRanges[i];
		[textAttributes setObject:fg_colors[tmp.location] forKey:NSForegroundColorAttributeName];
		tmp.location = loc;
		[outputString setAttributes:textAttributes range:tmp];
		loc += tmp.length;
	}
	
	[outputString detectURLs:[NSColor yellowColor]];
	[[mainTextView textStorage] appendAttributedString:outputString];
	linebufIndex = 1;
	linebuf[0] = '\n';
	attrRangesIndex = 0;
	
	if (![NSApp isActive]) {
		if (currentDataLevel > 2) {
			/* Check if floater is to be activated */
			if ([appController useFloaterOnPriv])
				[appController enqueueFloaterString:[decodedString substringFromIndex:1] fromChannel:name ? name : @"" refnum:windowRec->refnum dataLevel:currentDataLevel];
			
			/* Check if we are supposed to bounce the icon */
			if ([appController bounceIconOnPriv])
				[appController bounceIcon];
			
			[appController setIcon:[appController iconOnPriv]];
		}
		else if (currentDataLevel > 1) {
			/* Check if floater is to be activated */
			if (useFloater)
				[appController enqueueFloaterString:[decodedString substringFromIndex:1] fromChannel:name ? name : @"" refnum:windowRec->refnum dataLevel:currentDataLevel];
		}
	}
	
	/* Don't scroll to bottom if user is reading somewhere higher up */
	if ([scroller floatValue] == 1.0) {
		endRange.location = [[mainTextView textStorage] length];
		[mainTextView scrollRangeToVisible:endRange];
	}
	
	[decodedString release];
	[outputString release];
}



#pragma mark Public methods
//-------------------------------------------------------------------
// setFont:
// Set font in main text view
//
// "font" - The font to use
//-------------------------------------------------------------------
- (void)setFont:(NSFont *)font
{
	NSRange range = {0, [[mainTextView textStorage] length]};
	[textAttributes setObject:font forKey:NSFontAttributeName];
	[[mainTextView textStorage] addAttribute:NSFontAttributeName value:font range:range];
}


//-------------------------------------------------------------------
// validateMenuItem:
// Controls if context-menu item should be enabled/disabled
//
// "menuItem" - The menu item to be validated
//
// Returns: TRUE if enabled, FALSE if not
//-------------------------------------------------------------------
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	/* Control sub-menu are only for ops */
	if ([[[menuItem menu] title] isEqual:@"Control"] && !ownnick->op)
		return FALSE;
	else
		return TRUE;
}


//-------------------------------------------------------------------
// setTopic:setBy:atTime:
// Updates the topic text field. 
//
// "newTopic" - The new topic in the channel
// "setBy" - The nick who set the topic
// "time" - The time the change was made
//-------------------------------------------------------------------
- (void)setTopic:(char *)newTopic setBy:(char *)setter atTime:(time_t)time
{
	if (!newTopic)
		newTopic = "";
	if (!setter)
		setter = "";
	NSString *topic = [[NSString alloc] initWithData:[NSData dataWithBytesNoCopy:newTopic length:strlen(newTopic) freeWhenDone:FALSE] encoding:NSISOLatin1StringEncoding];
	
	[topic_by release];
	topic_by = [[NSString alloc] initWithCString:setter];
	topic_time = time;
	[topicTextField setStringValue:topic];
	[topic release];
}


//-------------------------------------------------------------------
// setTabViewItem:colors:appController:
// Get reference to various items. TODO: Fix this ugly mess :P 
//
// "newTabViewItem" - The tab view associated with the channel
// "colors" - The colors used
// "ref" - The app controller
//-------------------------------------------------------------------
- (void)setTabViewItem:(NSTabViewItem *)newTabViewItem colors:(ColorSet *)colors appController:(AppController *)ref;
{
	appController = ref;
	tabViewItem = newTabViewItem;
	colorSet = colors;
	fg_colors = [colorSet refToChannelFGColors];
	defaultTextColor = [[colorSet channelFGDefaultColor] retain];
	defaultColor = [[colorSet nickListFGColorOfStatus:normalStatus] retain];
	voiceColor = [[colorSet nickListFGColorOfStatus:voiceStatus] retain];
	halfOpColor = [[colorSet nickListFGColorOfStatus:halfOpStatus] retain];
	opColor = [[colorSet nickListFGColorOfStatus:opStatus] retain];
	serverOpColor = [[colorSet nickListFGColorOfStatus:serverOpStatus] retain];
	[mainTextView setBackgroundColor:[colorSet channelBGColor]];
	[nickTableView setBackgroundColor:[colorSet nickListBGColor]];
	
	/* Set up fonts and attributes */
	NSFont *font = [appController channelFont];
	textAttributes = [[NSMutableDictionary alloc] init];
	nickAttributes = [[NSMutableDictionary alloc] init];
	[textAttributes setObject:font forKey:NSFontAttributeName];
	[topicTextField setFont:font];
	[topicEditableTextField setFont:font];
	[maxUsersTextField setFont:font];
	[keyTextField setFont:font];
	
}


#pragma mark Delegate & notification receiver methods
//-------------------------------------------------------------------
// numberOfRowsInTableView:
// NSTableView delegate method. Returns the number of nicks. 
//
// "aTableView" - The table view
//
// Returns: The number of nicks
//-------------------------------------------------------------------
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [nicks count];
}


//-------------------------------------------------------------------
// tableView:objectValueForTableColumn:row:
// NSTableView delegate method. Returns a nick at a specific index. 
//
// "aTableView" - The table view
// "aTableColumn" - The column
// "rowIndex" - The row
//
// Returns: A string representation of the nick at index rowIndex.
//-------------------------------------------------------------------
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	NICK_REC *nick = (NICK_REC *)[[nicks objectAtIndex:rowIndex] pointerValue];
	NSColor *color;
	
	if (nick->serverop)
		color = serverOpColor;
	else if (nick->op)
		color = opColor;
	else if (nick->halfop)
		color = halfOpColor;
	else if (nick->voice)
		color = voiceColor;
	else
		color = defaultColor;
	
	[nickAttributes setObject:color forKey:NSForegroundColorAttributeName];
	return [[[NSAttributedString alloc] initWithString:[NSString stringWithCString:nick->nick] attributes:nickAttributes] autorelease];
}


//-------------------------------------------------------------------
// tableView:willDisplayCell:forTableColumn:tableColumn:rowIndex:
// Adds a tooltip rect on the cell to be diplayed. 
//
// "tableView" - The nick table view
// "cell" - The cell that will be displayed
// "tableColum" - Ignored
// "rowIndex" - The row that contains the cell
//-------------------------------------------------------------------
- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)rowIndex {
//	[nickTableView addToolTipRect:[nickTableView frameOfCellAtColumn:0 row:rowIndex] 
//owner:self userData:(void *)rowIndex];
}


//-------------------------------------------------------------------
// view:stringForToolTip:point:userData:
// Returns the string to be displayed in a tooltip for a nick in the
// userlist.
//-------------------------------------------------------------------
- (NSString *)view:(NSView *)view stringForToolTip:(NSToolTipTag)tag point:(NSPoint)point userData:(void *)userData
{
	NICK_REC *nick = (NICK_REC *)[[nicks objectAtIndex:(int)userData] pointerValue];
	if (!nick || !nick->host || !nick->realname)
		return @"User info not received!";
	
	return [NSString stringWithFormat:@"%@ -- [%@]\n%@", [CocoaBridge stringWithIrssiCString:nick->nick], [CocoaBridge stringWithIrssiCString:nick->realname], [CocoaBridge stringWithIrssiCString:nick->host]];
}


//-------------------------------------------------------------------
// channelColorChanged:
// Updates the colors in the main channel text area.
//
// "note" - Ignored
//-------------------------------------------------------------------
- (void)channelColorChanged:(NSNotification *)note
{
	[defaultTextColor release];
	defaultTextColor = [[colorSet channelFGDefaultColor] retain];
	[mainTextView setBackgroundColor:[colorSet channelBGColor]];
	[mainTextView setNeedsDisplay:TRUE];
}


//-------------------------------------------------------------------
// nickListColorChanged
// Updates the colors in the nick list. 
//
// "note" - Ignored
//-------------------------------------------------------------------
- (void)nickListColorChanged:(NSNotification *)note
{
	[defaultColor release];
	[voiceColor release];
	[halfOpColor release];
	[opColor release];
	[serverOpColor release];
	
	defaultColor = [[colorSet nickListFGColorOfStatus:normalStatus] retain];
	voiceColor = [[colorSet nickListFGColorOfStatus:voiceStatus] retain];
	halfOpColor = [[colorSet nickListFGColorOfStatus:halfOpStatus] retain];
	opColor = [[colorSet nickListFGColorOfStatus:opStatus] retain];
	serverOpColor = [[colorSet nickListFGColorOfStatus:serverOpStatus] retain];
	
	[nickTableView setBackgroundColor:[colorSet nickListBGColor]];
	[nickTableView removeAllToolTips]; 
	[nickTableView reloadData];
}


#pragma mark [De]Initializers
//-------------------------------------------------------------------
// awakeFromNib
// Initializer 
//-------------------------------------------------------------------
- (void)awakeFromNib
{
	/* Register for color notifications */
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(channelColorChanged:) name:@"channelColorChanged" object:nil];
	[nc addObserver:self selector:@selector(nickListColorChanged:) name:@"nickListColorChanged" object:nil];

	/* Set up context-menus */
	[nickTableView setMenu:nickViewMenu];
	//[mainTextView setMenu:mainTextViewMenu];
	[mainTextView setUsesFontPanel:FALSE];

	/* Other */
	scroller = [mainTextScrollView verticalScroller];
	[nickTableView setTarget:self];
	[nickTableView setDoubleAction:@selector(nickListRowDoubleClicked:)];
}


//-------------------------------------------------------------------
// initWithWindowRec:
// Designated initializer. 
//
// "rec" - A WINDOW_REC representing a window (tab in this case)
//
// Returns: self
//-------------------------------------------------------------------
- (id)initWithWindowRec:(WINDOW_REC *)rec
{
	[super init];
	if (rec == NULL) {
		NSLog(@"Warning: WINDOW_REC is NULL");
		return self;
	}
	
	windowRec = rec;
	isChannel = FALSE;
	useFloater = FALSE;
	return self;
}


/* Wrapper */
- (id)init {return [self initWithWindowRec:NULL]; }


//-------------------------------------------------------------------
// dealloc
// Deallocates the resources used by this instance
// TODO: Yes this currently leaks memory
//-------------------------------------------------------------------
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[wholeView release];
	[topicWindow release];
	//[mainTextViewMenu release];
	[nickViewMenu release];
	
	[opColor release];
	[halfOpColor release];
	[voiceColor release];
	[defaultColor release];
	[serverOpColor release];

	[defaultTextColor release];

	[nicks release];
	[name release];
	[topic_by release];
	[mode release];
	[key release];

	[textAttributes release];
	[nickAttributes release];
	
	[super dealloc];
}

#pragma mark Instance variables
//-------------------------------------------------------------------
// The current tab view item.
//-------------------------------------------------------------------
- (NSTabViewItem *)tabViewItem { return tabViewItem; }


//-------------------------------------------------------------------
// The current channel text view. 
//-------------------------------------------------------------------
- (NSTextView *)mainTextView { return mainTextView; }


//-------------------------------------------------------------------
// The WINDOW_REC this tab is representing. 
//-------------------------------------------------------------------
- (WINDOW_REC *)windowRec { return windowRec; }


//-------------------------------------------------------------------
// The view of the tab. 
//-------------------------------------------------------------------
- (NSView *)view { return wholeView; }


//-------------------------------------------------------------------
// The current data level 
//-------------------------------------------------------------------
#if 0
- (void)setCurrentDataLevel:(int)level { currentDataLevel = level; }
#endif


//-------------------------------------------------------------------
// The current channel topic 
//-------------------------------------------------------------------
- (NSString *)topic { return [topicTextField stringValue]; }


//-------------------------------------------------------------------
// The name of the channel. 
//-------------------------------------------------------------------
- (NSString *)name { return name; }

- (void)setName:(NSString *)newName
{
	[newName retain];
	[name release];
	name = newName;
}

#pragma mark Private methods
/* Wrapper - Start recursion */
- (void)sortNicks { [self sortNicksWithLeftBound:0 rightBound:[nicks count] - 1]; }


//-------------------------------------------------------------------
// sortNicksWithLeftBound:rightBound:
// Sorts the nicks in the channel based on name (case insensitive) 
// and status (op, voice...). Sorts using quicksort (recursive).
//
// "left" - The left bound
// "right" - The right bound
//-------------------------------------------------------------------
- (void)sortNicksWithLeftBound:(int)left rightBound:(int)right
{
	int i, last;

	/* Check if sorted (base case) */
	if (left >= right)
		return;

	[nicks exchangeObjectAtIndex:left withObjectAtIndex:(left + right)/2];
	last = left;
	for (i = left+1; i <= right; i++)
		if (nicklist_compare((NICK_REC *)[[nicks objectAtIndex:i] pointerValue], (NICK_REC *)[[nicks objectAtIndex:left] pointerValue]) < 0)
			[nicks exchangeObjectAtIndex:++last withObjectAtIndex:i];
	[nicks exchangeObjectAtIndex:left withObjectAtIndex:last];

	/* Recursive call */
	[self sortNicksWithLeftBound:left rightBound:last-1];
	[self sortNicksWithLeftBound:last+1 rightBound:right];
}


//-------------------------------------------------------------------
// findNick
// Finds the array-index of an nick. 
//
// "nick" - The nick to be located
//
// Returns: If found, the index of the nick, else -1
//-------------------------------------------------------------------
- (int)findNick:(NICK_REC *)nick
{
	int mid, result, low = 0, high = [nicks count] - 1;

	
	while (low <= high) {
		mid = (low + high) / 2;
		result = nicklist_compare((NICK_REC *)[[nicks objectAtIndex:mid] pointerValue], nick);
		if (result < 0)
			low = mid + 1;
		else if (result > 0)
			high = mid - 1;
		else
			return mid; // Found
	}

	/* Not found */
	return -1;
}


//-------------------------------------------------------------------
// findInsertionPositionForNick
// Finds the position a new nick should be inserted into.
// To keep the nicks sorted. 
//
// "nick" - The nick to be inserted
//
// Returns: The position
//-------------------------------------------------------------------
- (int)findInsertionPositionForNick:(NICK_REC *)nick
{
	int mid = 0, result, low = 0, high = [nicks count] - 1;

	while (low < high) {
		mid = (low + high) / 2;
		result = nicklist_compare((NICK_REC *)[[nicks objectAtIndex:mid] pointerValue], nick);
		if (result < 0)
			low = mid + 1;
		else if (result > 0)
			high = mid - 1;
		else {
			printf("Error: Two identical nicks in channel!\n");
			return mid;
		}
	}
	/* Find free slot when inserting */
	if (low == high) {
		mid = (low + high) / 2;
		if (nicklist_compare((NICK_REC *)[[nicks objectAtIndex:mid] pointerValue], nick) < 0)
			mid++;
	}

	return mid;
}


//-------------------------------------------------------------------
// controlTextDidChange
// Called to mark change in topic sheet 
//
// "aNotification" - Ignored
//-------------------------------------------------------------------
- (void)controlTextDidChange:(NSNotification *)aNotification
{
	[self modeChanged:nil];
}

//-------------------------------------------------------------------
// personFromNickRec (C function)
// Called using glibs hash iterator. Used after joining a channel, 
// adding the nick from the hash table to our nick list
//
// "key" - The hashing key
// "rec" - The nick
// "nicks" - The array of nicks
//-------------------------------------------------------------------
void personFromNickRec(gpointer key, NICK_REC *rec, NSMutableArray *nicks)
{
	[nicks addObject:[NSValue valueWithPointer:rec]];
}

@end
