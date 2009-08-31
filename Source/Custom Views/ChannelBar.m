/*
 ChannelBar.m
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

#import "ChannelBar.h"
#import "ColorSet.h"

@implementation ChannelBar

- (id)initWithFrame:(NSRect)frameRect
{
	if (![super initWithFrame:frameRect])
		return nil;

	channelBarCells = [[NSMutableArray alloc] init];
	return self;
}

- (BOOL)isOpaque
{
	return TRUE;
}

- (void)dealloc
{
	[activeCell release];
	[channelBarCells release];
	[super dealloc];
}

- (void)addChannel:(WINDOW_REC *)rec
{
	ChannelBarCell *cell = [[ChannelBarCell alloc] initWithWindowRec:rec];
	
	[channelBarCells addObject:cell];
	[self addSubview:cell];
	[cell release];
}

- (void)moveChannel:(WINDOW_REC *)rec fromRefNum:(int)fromRefNum toRefNum:(int)toRefNum
{
  ChannelBarCell *cell = nil;
  int i;
  
  // Grab the cell before we remove it
  for (i = 0; i < [channelBarCells count]; i++)
  {
    if ([[channelBarCells objectAtIndex:i] windowRec] == rec)
    {
      cell = [[channelBarCells objectAtIndex:i] retain];
      break;
    }
  }
  
  if (cell)
  {
    [cell removeFromSuperview];
    [channelBarCells removeObject:cell];
    
    int index = ((toRefNum-1) < [channelBarCells count]) ? toRefNum - 1 : [channelBarCells count] - 1;
    [channelBarCells insertObject:cell atIndex:index];
    [self addSubview:cell];
    
    [cell release];
  }
  else
  {
    NSLog(@"moveChannel: cell == nil, this is not a good thing really.");
  }
}

#if 0
- (NSString)name
{
	return name;
}

- (void)setName:(NSString)aValue
{
	if (name == aValue)
		return;

	[name release];
	name = [aValue retain];
}
- (int)name
{
	return name;
}

- (void)setName:(int)aValue
{
	int oldName = name;
	name = [aValue retain];
	[oldName release];
}
#endif
- (void)removeChannel:(WINDOW_REC *)rec
{
	int i;

	for (i = 0; i < [channelBarCells count]; i++)
		if (rec == [(ChannelBarCell *)[channelBarCells objectAtIndex:i] windowRec])
			break;

	
	/* Check if found */
	if (i >= [channelBarCells count])
		return;
	
	ChannelBarCell *cell = [channelBarCells objectAtIndex:i];
	[channelBarCells removeObjectAtIndex:i];
	[cell removeFromSuperview];
}

- (void)fitCells
{
	NSRect rect;
	rect.origin = [self bounds].origin;
	rect.size.height = [self bounds].size.height - 6;
	rect.origin.y += 3;
	rect.origin.x += 3;
	
	NSEnumerator *enumerator = [channelBarCells objectEnumerator];
	ChannelBarCell *cell;
	totalStringWidth = totalWidth = 0;
	
	while (cell = (ChannelBarCell *)[enumerator nextObject]) {
		totalStringWidth += [cell stringWidth];
		totalWidth += [cell stringWidth] + 2 * [ChannelBarCell borderWidth] + 3;
	}
	
	totalWidth += 3;
	
	float removeWidth = totalWidth - [self bounds].size.width;
	float removePart;
	
	enumerator = [channelBarCells objectEnumerator];
	while (cell = (ChannelBarCell *)[enumerator nextObject]) {
		
		/* Each cell is shrunk in proportion to the size of the channel name contained in the cell */
		removePart = (removeWidth > 0) ? [cell stringWidth] / totalStringWidth * removeWidth : 0;

		rect.size.width = [cell stringWidth] - removePart + [ChannelBarCell borderWidth]*2;
		[cell setFrame:rect];
		[cell setNeedsDisplay:TRUE];
		rect.origin.x += rect.size.width + 3;
	}
}

- (void)selectCell:(ChannelBarCell *)cell
{
	[activeCell setActive:FALSE];
	[cell setActive:TRUE];
	[cell retain];
	[activeCell release];
	activeCell = cell;
}

- (void)selectCellWithWindowRec:(WINDOW_REC *)rec
{
	int i;
	
	for (i = 0; i < [channelBarCells count]; i++)
		if (rec == [(ChannelBarCell *)[channelBarCells objectAtIndex:i] windowRec])
			break;
	
	
	/* Check if found */
	if (i >= [channelBarCells count])
		return;
	
	ChannelBarCell *cell = [channelBarCells objectAtIndex:i];
	[self selectCell:cell];
}


- (void)drawRect:(NSRect)rect
{
	[self fitCells];
	
	[[ColorSet channelListBackgroundColor] set];
	NSRectFillUsingOperation([self bounds], NSCompositeCopy);	

	NSEnumerator *enumerator = [channelBarCells objectEnumerator];
	ChannelBarCell *cell;

	//NSLog(@"Drawing %d cells in thread %p", [channelBarCells count], [NSThread currentThread]);
	while (cell = (ChannelBarCell *)[enumerator nextObject])
		[cell setNeedsDisplay:TRUE];
}

@end
