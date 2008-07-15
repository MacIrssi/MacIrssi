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

void get_mirc_color(const char **str, int *fg_ret, int *bg_ret);


@implementation ChannelController

#pragma mark IBAction methods
- (IBAction)searchForString:(id)sender
{
	/* First remove old search */
	if ([searchString length] > 0) {
		NSEnumerator *e = [searchRanges objectEnumerator];
		NSValue *value;
		
		while (value = [e nextObject])
			[textStorage removeAttribute:NSBackgroundColorAttributeName range:[value rangeValue]];

		[searchRanges removeAllObjects];
		[scroller removeAllMarkers];
		[scroller setNeedsDisplay:TRUE];
	}
	
	[searchString release];
	searchString = [[sender stringValue] retain];
	
	if ([searchString length] == 0)
		return;
	
	NSString *string = [textStorage string];
	NSRange searchRange;
	searchRange.location = 0;
	searchRange.length = [string length];
	NSRange r;
	searchColor = [NSColor redColor];
	
	while (TRUE) {
		r = [string rangeOfString:searchString options:NSCaseInsensitiveSearch range:searchRange]; 
		if (r.location == NSNotFound)
			break;

		[searchRanges addObject:[NSValue valueWithRange:r]];
		[textStorage addAttribute:NSBackgroundColorAttributeName value:searchColor range:r];
		
		[scroller addMarker:[self yPositionInTextView:r]];
		
		searchRange.location = r.location + r.length;
		searchRange.length = [string length] - searchRange.location;
	}
	
	[scroller setMaxPos:[mainTextView bounds].size.height];
	[scroller setNeedsDisplay:TRUE];
}


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
			else if (![[keyTextField stringValue] isEqual:key]) {
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
	NSIndexSet *indexSet = [nickTableView selectedRowIndexes];
	unsigned int row = [indexSet firstIndex];
	
	while (row != NSNotFound) {
		
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
		row = [indexSet indexGreaterThanIndex:row];
	}
	
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
	
	//NSString *topic = [[NSString alloc] initWithData:[NSData dataWithBytesNoCopy:newTopic length:strlen(newTopic) freeWhenDone:FALSE] encoding:NSISOLatin1StringEncoding];
	
	[topic_by release];
	topic_by = [[NSString alloc] initWithCString:setter];
	topic_time = time;
	//[topicTextField setStringValue:topic];
	[topicTextField setAttributedStringValue:[self parseTopic:newTopic]];
	//[topic release];
}

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
		
	[mainTextScrollView retain];
	[nickTableScrollView retain];
	
	[mainTextScrollView removeFromSuperview];
	[nickTableScrollView removeFromSuperview];
	
	[nickTableScrollView setHidden:FALSE];
	NSRect frame = NSUnionRect([mainTextScrollView frame],[nickTableScrollView frame]);
	
	splitView = [[NSSplitView alloc] initWithFrame:frame];
	[splitView setVertical:TRUE];
	[splitView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
	[splitView addSubview:mainTextScrollView];
	[splitView addSubview:nickTableScrollView];
	
	[mainTextScrollView release];
	[nickTableScrollView release];

	frame.size.width -= [nickTableScrollView frame].size.width;	
	[mainTextScrollView setFrame:frame];
	
	[wholeView addSubview:splitView];
	[splitView setNeedsDisplay:TRUE];
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
		NSLog(@"[changeServerOpForNickRec] Error: \"%s\" not found!\n", rec->nick);
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
	else if (*mode1 == '%')
		nick->halfop = (*type == '-') ? TRUE : FALSE;
	else
		[appController presentUnexpectedEvent:[NSString stringWithFormat:@"Nick \"%@\" received unknown mode!", [CocoaBridge stringWithIrssiCString:nick->nick]]];
	
	if ( (index = [self findNick:nick]) == -1) {
		NSLog(@"Find nick failed, trying linear!");
		/* The nick was not found! The reason for this could be a double mode change.
		So we also try a linear search */
		if ( (index = [self findNickLinear:nick]) == -1) {
			
			/* If we still have not found it, then something is not right */
			[appController presentUnexpectedEvent:[NSString stringWithFormat:@"Unable to locate nick \"%@\" in channel \"%@\"!", [CocoaBridge stringWithIrssiCString:nick->nick], name]];
			return;
		}
		NSLog(@"Success!");
	}
	
	[nicks removeObjectAtIndex:index];
	
	/* Redo modechange so we can insert him in new position */
	if (*mode1 == '@')
		nick->op = (*type == '+') ? TRUE : FALSE;
	else if (*mode1 == '+')
		nick->voice = (*type == '+') ? TRUE : FALSE;
	else if (*mode1 == '%')
		nick->halfop = (*type == '+') ? TRUE : FALSE;
	else
		[appController presentUnexpectedEvent:[NSString stringWithFormat:@"Nick \"%@\" received unknown mode!", [CocoaBridge stringWithIrssiCString:nick->nick]]];
	
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
		NSLog(@"Error: nick not found!\n");
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
		NSLog(@"Error: nick not found!\n");
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

int mirc_colors[] = { 15, 0, 1, 2, 12, 4, 5, 6, 14, 10, 3, 11, 9, 13, 8, 7 };

//-------------------------------------------------------------------
// printText:forground:background:flags:
// Adds a text section to the linebuffer. Called for each new
// text-color-section. Currenlty ignores flags <-- FIX =)
//
// "text" - The text to print
// "fg" - The foreground color
// "bg" - The background color
// "flags" - Some flags
//-------------------------------------------------------------------
- (void)printText:(char *)text forground:(int)fg background:(int)bg flags:(int)flags
{
	int len = strlen(text);
	len = (len > MAX_LINE-linebufIndex) ? (MAX_LINE-linebufIndex) : len;
	strncpy(linebuf + linebufIndex, text, len);
	linebufIndex += len;
	(attrRanges+attrRangesIndex)->length = len;
	
	if (flags & GUI_PRINT_FLAG_MIRC_COLOR) {
		/* mirc colors - real range is 0..15, but after 16
		colors wrap to 0, 1, ... */
		//if (bg >= 0) *bg = mirc_colors[*bg % 16];
		if (fg >= 0) fg = mirc_colors[fg % 16];
	}
		
	(attrRanges+attrRangesIndex)->location = fg; // location is unused, save fg color in it
	attrRangesIndex++;
}


//-------------------------------------------------------------------
// finishLine
// Called after a series of printText when the current line should be
// put out to screen. TODO: better parsing (html, underlines ...)
//-------------------------------------------------------------------
- (void)finishLine
{
	BOOL scroll = [scroller usableParts] != NSAllScrollerParts || [scroller floatValue] == 1.0;
	int i, loc = linebuf[0] == '\n';
	linebuf[linebufIndex] = 0;
	decodedString = (NSString *)CFStringCreateWithCStringNoCopy(NULL, linebuf, kCFStringEncodingISOLatin1, kCFAllocatorNull);
	outputString = [[NSMutableAttributedString alloc] initWithString:decodedString];
	[outputString beginEditing];
	
	for (i = 0; i < attrRangesIndex; i++) {
		NSRange tmp = attrRanges[i];
		int fg = tmp.location;
		if (fg < 0 || fg > 15)
			[textAttributes setObject:defaultTextColor forKey:NSForegroundColorAttributeName];
		else
			[textAttributes setObject:fg_colors[fg] forKey:NSForegroundColorAttributeName];
		tmp.location = loc;
		[outputString setAttributes:textAttributes range:tmp];
		loc += tmp.length;
	}
			
	[outputString endEditing];
	
	[outputString detectURLs:[NSColor yellowColor]];
	[textStorage appendAttributedString:outputString];
	linebufIndex = 1;
	linebuf[0] = '\n';
	attrRangesIndex = 0;
	
	/* Check if we are in search mode */
	if ([searchString length] > 0) {
		NSRange searchRange = {0, [outputString length]};
		NSRange r = [[outputString string] rangeOfString:searchString options:NSCaseInsensitiveSearch range:searchRange]; 
		if (r.location != NSNotFound) {
			r.location += [textStorage length] - [outputString length];
			[textStorage addAttribute:NSBackgroundColorAttributeName value:searchColor range:r];
			
			[searchRanges addObject:[NSValue valueWithRange:r]];
			[scroller addMarker:[self yPositionInTextView:r]];
		}
		
		[scroller setMaxPos:[mainTextView bounds].size.height];
		[scroller setNeedsDisplay:TRUE];
	}

	/* Check floater */
	if (![NSApp isActive]) {
		if (currentDataLevel > 2) {
			/* Check if floater is to be activated */
			if ([appController useFloaterOnPriv])
				[appController addFloaterString:[decodedString substringFromIndex:1] fromChannel:name ? name : @"" refnum:windowRec->refnum dataLevel:currentDataLevel];
			
			/* Check if we are supposed to bounce the icon */
			if ([appController bounceIconOnPriv])
				[appController bounceIcon];
			
			[appController setIcon:[appController iconOnPriv]];
		}
		else if (currentDataLevel > 1) {
			/* Check if floater is to be activated */
			if (useFloater)
				[appController addFloaterString:[decodedString substringFromIndex:1] fromChannel:name ? name : @"" refnum:windowRec->refnum dataLevel:currentDataLevel];
		}
	}
	
	/* Don't scroll to bottom if user is reading somewhere higher up */
	if (scroll && active_win == windowRec) {
		endRange.location = [textStorage length];
		[mainTextView scrollRangeToVisible:endRange];
	}
	
	[decodedString release];
	[outputString release];
}


#pragma mark Public methods
//-------------------------------------------------------------------
// makeSearchFieldFirstResponder
// Makes search field first responder.
//-------------------------------------------------------------------
- (void)makeSearchFieldFirstResponder
{
	[[mainTextView window] makeFirstResponder:searchField];
}

//-------------------------------------------------------------------
// clearTextView:
// Clears the text view
//-------------------------------------------------------------------
- (void)clearTextView
{
	NSRange range;
	range.location = 0;
	range.length = [textStorage length];
	[textStorage deleteCharactersInRange:range];
}

//-------------------------------------------------------------------
// saveScrollState:
// Saves the state of the scroller. TRUE if at the bottom, FALSE else
//-------------------------------------------------------------------
- (void)saveScrollState
{
	//if ([scroller floatValue] == 0.0)
	//	NSLog(@"[%@] scroller:%f, knob:%f", name, [scroller floatValue], [scroller knobProportion]);
	scrollState = [scroller usableParts] != NSAllScrollerParts || [scroller floatValue] == 1.0;
}

//-------------------------------------------------------------------
// setFont:
// Set font in main text view
//
// "font" - The font to use
//-------------------------------------------------------------------
- (void)setFont:(NSFont *)font
{
	NSRange range = {0, [textStorage length]};
	[textAttributes setObject:font forKey:NSFontAttributeName];
	[textStorage addAttribute:NSFontAttributeName value:font range:range];
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
#if 0
	[nickTableView addToolTipRect:[nickTableView frameOfCellAtColumn:0 row:rowIndex] 
							owner:self userData:(void *)rowIndex];
#endif
}


//-------------------------------------------------------------------
// view:stringForToolTip:point:userData:
// Returns the string to be displayed in a tooltip for a nick in the
// userlist.
//-------------------------------------------------------------------
- (NSString *)view:(NSView *)view stringForToolTip:(NSToolTipTag)tag point:(NSPoint)point userData:(void *)userData
{
	NICK_REC *nick = (NICK_REC *)[[nicks objectAtIndex:(int)userData] pointerValue];
		
	if (!nick || !nick->nick) {
		[appController presentUnexpectedEvent:@"Can't create tooltip when nick is NULL!"];
		return @"";
	}
	
	if (!nick->realname || !nick->host) {
		/* If we don't have all info, do a who lookup */
		char tmp[strlen(nick->nick) + 5];
		sprintf(tmp, "/who %s", nick->nick);
		signal_emit("send command", 3, tmp, windowRec->active_server, windowRec->active);
	}
	
	return [NSString stringWithFormat:@"%@ -- [%@]\n%@", [CocoaBridge stringWithIrssiCString:nick->nick], nick->realname ? [CocoaBridge stringWithIrssiCString:nick->realname] : @"real name not received", nick->host ? [CocoaBridge stringWithIrssiCString:nick->host] : @"host name not received"];
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
	scroller = [[MarkedScroller alloc] initWithFrame:[[mainTextScrollView verticalScroller] frame]];
	[mainTextScrollView setVerticalScroller:scroller];
	textStorage = [mainTextView textStorage];
	searchRanges = [[NSMutableArray alloc] init];

	[self saveScrollState];
	[nickTableView setTarget:self];
	[nickTableView setDoubleAction:@selector(nickListRowDoubleClicked:)];

	[nickTableScrollView setHidden:TRUE];
	NSRect frame = [mainTextScrollView frame];
	frame.size.width += [nickTableScrollView frame].size.width + 8;
	[mainTextScrollView setFrame:frame];
	[mainTextScrollView setNeedsDisplay:TRUE];
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
	[searchRanges release];
	
	[super dealloc];
}

#pragma mark Instance variables
//-------------------------------------------------------------------
// The nick array
//-------------------------------------------------------------------
- (NSArray *)nicks { return nicks; }

//-------------------------------------------------------------------
// The mode of the channel
//-------------------------------------------------------------------
- (NSString *)mode { return mode; }

//-------------------------------------------------------------------
// The state of the scroller when the window of the channel became
// inactive.
//-------------------------------------------------------------------
- (bool)scrollState { return scrollState; }

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
	[tabViewItem setLabel:name];
}

#pragma mark Private methods
//-------------------------------------------------------------------
// yPositionInTextView:
// Calculates the y position for the first character in
// a range of characters in the main text view. 
//
// r - The range where the characters are located
//
// return - the y location
//-------------------------------------------------------------------
- (float)yPositionInTextView:(NSRange)r
{
	NSRange glyphRange = [[mainTextView layoutManager] glyphRangeForCharacterRange:r actualCharacterRange:nil];
	NSRect rect = [[mainTextView layoutManager] lineFragmentRectForGlyphAtIndex:glyphRange.location effectiveRange:nil];
	return rect.origin.y+rect.size.height/2;
}

//-------------------------------------------------------------------
// parseTopic:
// Parses a topic string, looking for mirc colors (currently ignores them) and links
//
// "str" - The topic string
//
// Returns: A string with the resulting attributes
//-------------------------------------------------------------------
- (NSAttributedString *)parseTopic:(char *)str
{
#if 0
	const char *p, *start = NULL;
	char tmp[strlen(str)];
	int fg, bg, len;
	NSAttributedString *partialTopic;
	NSMutableDictionary *topicAttributes = [[NSMutableDictionary alloc] init];
	NSMutableAttributedString *attributedTopic = [[NSMutableAttributedString alloc] init];
	
	for (p = str; *p != '\0'; p++) {
		
		/* Only parse mirc colors on first pass */
		if (*p != 3)
			continue;
		/* Check if this is the end of a color range */
		if (start) {
			len = p - start;
			NSAssert(len >= 0, @"Len is subzero =("); //TODO: remove?
			
			tmp = (char *)malloc(len+1);
			bcopy(start, tmp, len);
			tmp[len] = 0;
			
			/* Check foreground color */
			if (fg < 0 || fg > 15)
				[topicAttributes setObject:defaultTextColor forKey:NSForegroundColorAttributeName];
			else
				[topicAttributes setObject:fg_colors[mirc_colors[fg % 16]] forKey:NSForegroundColorAttributeName];

			/* Check background color */
			if (bg < 0 || bg > 15)
				[topicAttributes removeObjectForKey:NSBackgroundColorAttributeName];
			else
				[topicAttributes setObject:fg_colors[mirc_colors[bg % 16]] forKey:NSBackgroundColorAttributeName];

			partialTopic = [[NSAttributedString alloc] initWithString:[CocoaBridge stringWithIrssiCStringNoCopy:tmp] attributes:topicAttributes];
			[attributedTopic appendAttributedString:partialTopic];
			
			free(tmp);
			[partialTopic release];
			
		}
		
		/* get mirc color */
		p++;  
		get_mirc_color(&p, &fg, &bg);
		start = p;
		p--;			
	}
	
	[topicAttributes release];
#endif

	NSMutableAttributedString *attributedTopic = [[NSMutableAttributedString alloc] initWithString:[CocoaBridge stringWithIrssiCStringNoCopy:strip_codes(str)]];
	[attributedTopic detectURLs:[NSColor blueColor]];
	
	return [attributedTopic autorelease];
}

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
	fprintf(logfile, "nick \"%s\" not found in nicklist! s:%d o:%d h:%d v:%d\n", nick->nick, nick->serverop, nick->op, nick->halfop, nick->voice);
	fprintf(logfile, "searchpattern: ");
	low = 0;
	high = [nicks count] - 1;
	
	while (low <= high) {
		mid = (low + high) / 2;
		fprintf(logfile, "%d, ", mid);
		result = nicklist_compare((NICK_REC *)[[nicks objectAtIndex:mid] pointerValue], nick);
		if (result < 0)
			low = mid + 1;
		else if (result > 0)
			high = mid - 1;
		else
			return mid; // Found
	}
	fprintf(logfile, "\n\n");
	[self dumpNickList];
	return -1;
}

- (void)dumpNickList
{
	NSEnumerator *enumerator = [nicks objectEnumerator];
	NICK_REC *nick;
	id anObject;
	int i = 0;
	
	
	while (anObject = [enumerator nextObject]) {
		nick = (NICK_REC *) [anObject pointerValue];
		fprintf(logfile, "[%d]%s - s:%d o:%d h:%d v:%d\n", i++, nick->nick, nick->serverop, nick->op, nick->halfop, nick->voice);
	}
	
	fflush(logfile);
}

//-------------------------------------------------------------------
// findNickLinear
// Finds the array-index of an nick (using linear search). 
//
// "nick" - The nick to be located
//
// Returns: If found, the index of the nick, else -1
//-------------------------------------------------------------------
- (int)findNickLinear:(NICK_REC *)nick
{
	int i;
	
	for (i = 0; i < [nicks count]; i++)
		if (nicklist_compare((NICK_REC *)[[nicks objectAtIndex:i] pointerValue], nick) == 0)
			return i;
	
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