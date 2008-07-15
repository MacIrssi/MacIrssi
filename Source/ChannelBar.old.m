#import "ChannelBar.h"

@implementation ChannelBar

- (id)initWithFrame:(NSRect)frameRect
{
	if (![super initWithFrame:frameRect])
		return nil;

	bgColor = [[NSColor  colorWithCalibratedRed:103.0/255 green:103.0/255 blue:103.0/255 alpha:0.82] retain];
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
	[bgColor release];
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
	
	[bgColor set];
	NSRectFillUsingOperation([self bounds], NSCompositeCopy);	

	NSEnumerator *enumerator = [channelBarCells objectEnumerator];
	ChannelBarCell *cell;

	//NSLog(@"Drawing %d cells in thread %p", [channelBarCells count], [NSThread currentThread]);
	while (cell = (ChannelBarCell *)[enumerator nextObject])
		[cell setNeedsDisplay:TRUE];
}

@end
