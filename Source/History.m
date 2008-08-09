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
*
* MacIrssi - History.c
* Nils Hjelte, c01nhe@cs.umu.se
*
* A list of strings that can be iterated forward and backward.
*/

#import "History.h"

#define NEXT(x) ((x == maxSize - 1) ? 0 : x+1)
#define PREV(x) ((x == 0) ? maxSize - 1 : x-1)
#define INC(x) (x = NEXT(x))
#define DEC(x) (x = PREV(x))

@implementation History

/**
 * Returns the previous command in the history.
 * @return The previous command, nil if empty or if iterator is "done"
 */ 
- (NSString *)previousCommand
{
	if ([self isEmpty] || ![self indexIteratorIsValid] || indexIterator == back)
		return nil;
	
	DEC(indexIterator);
	return commands[indexIterator];
}

/**
 * Returns the next command in the history.
 * @return The next command, nil if empty or if iterator is "done"
 */ 
- (NSString *)nextCommand
{
	if ([self isEmpty] || ![self indexIteratorIsValid] || [self iteratorAtFront]) {
		[self resetIterator];
		return nil;
	}
		
	INC(indexIterator);
	NSString *next = commands[indexIterator];
	return next;
}

/* Wrappers */
- (void)addCommand:(NSString *)command { [self addCommand:command isTemporary:FALSE]; }
- (void)setTemporaryCommand:(NSString *)command
{
	[self addCommand:command isTemporary:TRUE];
	DEC(indexIterator);
}

/**
 * Returns true if the history is empty
 */
- (BOOL)isEmpty
{
	return size == 0;
}


/**
 * Returns true if the iterator is at the front
 */
- (BOOL)iteratorAtFront
{
	return indexIterator == front || NEXT(indexIterator) == front;
}

/* Initializer */
- (id)initWithCapacity:(int)c
{
	if (![super init])
		return nil;
	
	maxSize = c+2; // 1 dummy cell + 1 temp command
	size = 0;
	front = 0;
	back = 0;
	indexIterator = 0;
	[self setHasTemporaryCommand:FALSE];
	commands = (NSString **)malloc( sizeof(NSString *) * maxSize);
  memset(commands, '\0', sizeof(NSString*) * maxSize);

	return self;
}

/* Dealloc */
- (void)dealloc
{
	int i;

	for(i = 0; i < maxSize; i++)
		if (commands[i] != NULL)
			[commands[i] release];
	
	free(commands);
	[super dealloc];
}

#pragma mark Private
/**
 * Resets the iterator to the top of the stack
 */
- (void)resetIterator
{
	indexIterator = front;
	//INC(indexIterator);
}

/**
 * Getter/setter for hasTemporaryCommand
 */
- (BOOL)hasTemporaryCommand { return hasTemporaryCommand; }
- (void)setHasTemporaryCommand:(BOOL)flag { hasTemporaryCommand = flag; }

/**
 * Adds a command to the history, overwriting existing temporary command.
 * It also resets the iteratorIndex to point to the top of the stack.
 * @param command The command to add
 * @param isTemp If the command is temporary
 */
- (void)addCommand:(NSString *)command isTemporary:(BOOL)isTemp
{
	if ([self hasTemporaryCommand])
		[self popCommand];
	
	if ([self pushCommand:command])
		[self setHasTemporaryCommand:isTemp];
		
	[self resetIterator];
}

/**
 * Returns true if the iterator is valid (pointing on a command between back and front).
 */
- (BOOL)indexIteratorIsValid
{
	if (indexIterator > front && indexIterator < back && back >= front)
		return FALSE;
	
	if ( (indexIterator < back || indexIterator > front) && back < front)
		return FALSE;

	return TRUE;
}

/**
 * Pops the top command from the stack
 * @return The command, nil if stack is empty
 */
- (NSString *)popCommand
{
	if ([self isEmpty])
		return nil;
	
	DEC(front);
	size--;
	return [commands[front] autorelease];
}

/**
 * Push a command to the history stack.
 * @param command The command
 * @param True if pushed, false if a dupe (which is ignored)
 */
- (BOOL)pushCommand:(NSString *)command
{
	/* Don't insert dupes */
	if (![self isEmpty] && [commands[PREV(front)] isEqual:command])
		return FALSE;
	
	/* If we have filled the history we must remove commands from the back */
	if (front == PREV(back)) {
		[commands[back] release];
		INC(back);
	}
	else
		size++;
		
	commands[front] = [command retain];
	INC(front);
	return TRUE;
}

@end
