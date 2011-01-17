/*
 CustomWindow.m
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

//	Redirects all keyboard events to input text field.

#import "CustomWindow.h"
#import "servers.h"
#import "signals.h"
#import "IrssiBridge.h"

char *word_complete(WINDOW_REC *window, const char *line, int *pos, int erase);

@implementation CustomWindow

/**
 * If we are key window and search field is not selected, then
 */
- (void)paste:(id)sender
{
	if ([self isKeyWindow] && interceptKeys)
		[self makeInputTextFieldFirstResponder];
	
	/* Check so first responder has paste method */
	id firstResponder = [[NSApp keyWindow] firstResponder];
	if ([firstResponder respondsToSelector:@selector(paste:)])
		[firstResponder paste:sender];
}

/***
*	Name: setCurrentChannelTextView
*	Purpose: Sets reference to current channel text view.
*	Param: ref - The text view
*	Return: -
*/
- (void)setCurrentChannelTextView:(NSTextView *)ref
{
	currentChannelTextView = ref;
}

/**
 * Normaly all keypresses are redirected to the command field. Only exception is when
 * the search field is selected.
 * @param aResponder The responder requesting focus
 */
- (BOOL)makeFirstResponder:(NSResponder *)aResponder
{
	interceptKeys = TRUE;
	
	if ([aResponder isKindOfClass:[NSView class]]) {
		NSView *view = (NSView *)aResponder;
		while (view = [view superview]) {
			if ([view isMemberOfClass:[NSSearchField class]]) {
				interceptKeys = FALSE;
				break;
			}
		}
	}
	
	return [super makeFirstResponder:aResponder];
}

/**
 * Sets the input text field as first responder
 */
- (void)makeInputTextFieldFirstResponder
{
	if (interceptKeys && (![[self firstResponder] respondsToSelector:@selector(isDescendantOf:)] || ![(NSTextView *)[self firstResponder] isDescendantOf:inputTextField])) {
		[self makeFirstResponder:inputTextField];
		endRange.location = [[(NSTextView *)[self firstResponder] textStorage] length];
		[(NSTextView *)[self firstResponder] setSelectedRange:endRange];
	}	
}

/***
*	Name: sendEvent
*	Purpose: Overrides method from NSResponder to recieve events.
*			 All keyboard events are redirected to input text field.
*	Param: theEvent - The event.
*	Return: -
*/
- (void)sendEvent:(NSEvent *)theEvent
{
	if ([theEvent type] != NSKeyDown) {
		[super sendEvent:theEvent];
		return;
	}

	NSString *str = [theEvent charactersIgnoringModifiers];
	unichar uchar = [str length] ? [str characterAtIndex:0] : 0;
	unsigned int flags = [theEvent modifierFlags];
	
	/* If some page-scrolling key -> make current channel text view first responder */
	if (([[NSUserDefaults standardUserDefaults] boolForKey:@"homeEndGoesToTextView"] && (uchar == NSHomeFunctionKey || uchar == NSEndFunctionKey)) ||
      uchar == NSPageUpFunctionKey || uchar == NSPageDownFunctionKey) {
		[self makeFirstResponder:currentChannelTextView];
	}
	else
  {
		[self makeInputTextFieldFirstResponder];
		
		/* Handle special key */
		if (interceptKeys && [self handleSpecialKey:uchar withModifierFlags:flags])
			return;
	}
	
	/* Continue with the event */
	[super sendEvent:theEvent];
}

/* tab = word completion, arrow up/down = history up/down, esc = clear field */
- (bool)handleSpecialKey:(unichar)uchar withModifierFlags:(unsigned int)flags
{
	switch (uchar) {
		char *old_s, *new_s;
		
		case NSUpArrowFunctionKey:
			/********************************/
			/* Move back in command history */
			/********************************/
			if (flags & NSShiftKeyMask)
				break;
			[controller historyUp];
			//[(NSTextView *)[self firstResponder] setSelectedRange:endRange];
			return TRUE;
			
		case NSDownArrowFunctionKey:
			/***********************************/
			/* Move forward in command history */
			/***********************************/
			if (flags & NSShiftKeyMask)
				break;
			[controller historyDown];
			//[(NSTextView *)[self firstResponder] setSelectedRange:endRange];
			return TRUE;
			
		case '\t':
			/******************/
			/* Tab completion */
			/******************/
      old_s = (char*)[[(NSTextView*)[self firstResponder] string] UTF8String];
			int i = strlen(old_s);
			new_s = word_complete([controller currentWindowRec], old_s, &i, 0);
			if (!new_s)
				return TRUE;
				
      NSString *decodedString = [[NSString stringWithUTF8String:new_s] retain];
			
			[(NSTextView *)[self firstResponder] setString:decodedString];
			[decodedString release];
			free(new_s);
			return TRUE;
      
    case 0x0d:
    case 0x03:
      if (flags & NSControlKeyMask)
      {
        break;
      }
      [controller sendCommand:inputTextField];
      [inputTextField _resetCacheAndPostSizeChanged];
      return TRUE;
      
		case 0x1b:
			/****************************/
			/* ESC -> clear input field */
			/****************************/
			[(NSTextView *)[self firstResponder] setString:@""];
			return TRUE;
			
		case 'x':
			/*****************************************/
			/* ctrl-x -> Change server (irssi style) */
			/*****************************************/
			if ( !(flags & NSControlKeyMask))
				break;
			[self changeServer:self];
			return TRUE;			
	}
	
	/* No special key */
	return FALSE;
}

/* From gui-readline.c */
- (IBAction)changeServer:(id)sender
{
	SERVER_REC *server;

	if (active_win->items != NULL) {
		signal_emit("command window item next", 3, "",
					active_win->active_server, active_win->active);
	} else if (servers != NULL || lookup_servers != NULL) {
		/* change server */
		server = active_win->active_server;
		if (server == NULL)
			server = active_win->connect_server;
		server = [self getNextServer:server];
		signal_emit("command window server", 3, server->tag,
					active_win->active_server, active_win->active);
	}
}

/* From gui-readline.c */
- (SERVER_REC *)getNextServer:(SERVER_REC *)current
{
	GSList *pos;
	
	if (current == NULL) {
		return servers != NULL ? servers->data :
		lookup_servers != NULL ? lookup_servers->data : NULL;
	}
	
	/* server1 -> server2 -> connect1 -> connect2 -> server1 -> .. */
	
	pos = g_slist_find(servers, current);
	if (pos != NULL) {
		if (pos->next != NULL)
			return pos->next->data;
		if (lookup_servers != NULL)
			return lookup_servers->data;
		return servers->data;
	}
	
	pos = g_slist_find(lookup_servers, current);
	g_assert(pos != NULL);
	
	if (pos->next != NULL)
		return pos->next->data;
	if (servers != NULL)
		return servers->data;
	return lookup_servers->data;
}

@end
