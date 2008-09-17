
#import "ChannelBarCell.h"
#import "ChannelController.h"
#import "fe-windows.h"
#import "servers.h"

@implementation ChannelBarCell

//-------------------------------------------------------------------
// initWithWindowRec:rec
// Designated initializer
//-------------------------------------------------------------------
- (id)initWithWindowRec:(WINDOW_REC *)rec
{
	NSRect frame;
	self = [super initWithFrame:frame];
  
	highlightAttributes = [[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Monaco" size:9.0], NSFontAttributeName, nil] retain];
	highlightColors[0] = [[NSColor whiteColor] retain];
	highlightColors[1] = [[NSColor yellowColor] retain];
	highlightColors[2] = [[NSColor orangeColor] retain];
	highlightColors[3] = [[NSColor redColor] retain];
	
	//[self setDataLevel:rec->data_level];
	isActive = false;
	windowRec = rec;
	bezierPath = [[NSBezierPath alloc] init];
	[bezierPath setLineWidth:2];
	[bezierPath setLineCapStyle:NSSquareLineCapStyle];
	[bezierPath setLineJoinStyle:NSMiterLineJoinStyle];
	return self;
}

/* Dealloc */
- (void)dealloc
{
	int i;
	
	for (i = 0; i < 4; i++)
		[highlightColors[i] release];
	
	[highlightAttributes release];
	[bezierPath release];
	[super dealloc];
}

//-------------------------------------------------------------------
// stringWidth
// Returns the width of the string.
//-------------------------------------------------------------------
- (float)stringWidth
{
	if ([self name])
		return [[self name] sizeWithAttributes:highlightAttributes].width;
	else
		return 0;
}

//-------------------------------------------------------------------
// setFrame:frame
// Adjusts the tooltip area to the new frame.
//-------------------------------------------------------------------
#define equalRects(a, b) ((a).origin.x == (b).origin.x && (a).origin.y == (b).origin.y && (a).size.width == (b).size.width && (a).size.height == (b).size.height)
- (void)setFrame:(NSRect)frame
{
	NSRect oldFrame = [self frame];
	[super setFrame:frame];
  
	if ( !equalRects(frame, oldFrame))
	{
		[self removeAllToolTips];
		[self addToolTipRect:[self bounds] owner:self userData:nil];
	}
}

//-------------------------------------------------------------------
// view:stringForToolTip:point:userData:
// Returns the string to be displayed in a tooltip for a nick in the
// userlist.
//-------------------------------------------------------------------
- (NSString *)view:(NSView *)view stringForToolTip:(NSToolTipTag)tag point:(NSPoint)point userData:(void *)userData
{
	NSArray *nicks = [(ChannelController *)windowRec->gui_data nicks];
	int nickCount = [nicks count];
	int serverOpCount = 0;
	int opCount = 0;
	int halfOpCount = 0;
	int voiceCount = 0;
	int normalCount = 0;
	int i;
	NICK_REC *nick;
	
	for (i = 0; i < nickCount; i++) {
		nick = (NICK_REC *)[[nicks objectAtIndex:i] pointerValue];
    
		if (nick->serverop)
			serverOpCount++;
		else if (nick->op)
			opCount++;
		else if (nick->halfop)
			halfOpCount++;
		else if (nick->voice)
			voiceCount++;
		else
			normalCount++;
	}
	
	SERVER_REC *server = windowRec->active_server;
	char *serverName = (server && server->tag) ? server->tag : "";
	
	NSMutableString *toolTip = [NSMutableString stringWithFormat:@"Name: %@\nServer: %s", [self name], serverName];
	NSString *mode = [(ChannelController *)windowRec->gui_data mode];
	if (mode)
		[toolTip appendFormat:@"\nMode: %@", mode];
	if (nickCount > 0)
		[toolTip appendFormat:@"\nNicks: %d (%d serverops, %d ops, %d halfops, %d voices, %d normal)", nickCount, serverOpCount, opCount, halfOpCount, voiceCount, normalCount];
	return toolTip;
}

//-------------------------------------------------------------------
// borderWidth
// Returns the border width
//-------------------------------------------------------------------
+ (float)borderWidth
{
	return 6.0;
}

//-------------------------------------------------------------------
// name
// Returns the name of the channel
//-------------------------------------------------------------------
- (NSString *)name
{
	return [(ChannelController *)windowRec->gui_data name];
}

//-------------------------------------------------------------------
// windowRec
// Returns the window rec of the channel
//-------------------------------------------------------------------
- (WINDOW_REC *)windowRec
{
	return windowRec;
}

#if 0
/**
 * Sets data level. Clamps to max and min
 */
- (void)setDataLevel:(int)level
{
	if (level > 3)
		level = 3;
	else if (level < 0)
		level = 0;
	
	dataLevel = level;
}
#endif

//-------------------------------------------------------------------
// drawRect:rect
// Draws the cell
//-------------------------------------------------------------------
- (void)drawRect:(NSRect)rect
{	
  
	/* Draw background */
	NSRect r1 = [self bounds];
	r1.origin.x += 2;
	r1.origin.y += 2;
	r1.size.width -= 4;
	r1.size.height -= 4;
	
	if (isActive) {
		[[NSColor clearColor] set];
		NSRectFillUsingOperation([self bounds], NSCompositeDestinationOver);	
		[[NSColor  colorWithCalibratedRed:246.0/255 green:249.0/255 blue:232.0/255 alpha:1.0] set];
	}
	else
  {
    [[NSColor grayColor] set];
  }
  
	NSRectFillUsingOperation(r1, NSCompositeCopy);	
	
	/* Draw channel name */
	NSRect r2 = [self bounds];
	r2.origin.y += 1;
	r2.origin.x += [ChannelBarCell borderWidth];
  
	if (isActive)
  {
    [highlightAttributes setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
  }
	else 
  {
		int dataLevel = windowRec->data_level;
		if (dataLevel > 3)//TODO: ugly fix
			dataLevel = 3;
		[highlightAttributes setObject:highlightColors[dataLevel] forKey:NSForegroundColorAttributeName];
	}
	
	[[self name] drawAtPoint:r2.origin withAttributes:highlightAttributes];
	
	if ([self stringWidth] > [self bounds].size.width - 2 * [ChannelBarCell borderWidth]) {
		NSRect removeRect = r1;
		removeRect.origin.x += [self bounds].size.width - [ChannelBarCell borderWidth];
		removeRect.size.width = [ChannelBarCell borderWidth];
		
		if (isActive)
    {
      [[NSColor colorWithCalibratedRed:246.0/255 green:249.0/255 blue:232.0/255 alpha:1.0] set];
    }
		else
    {
      [[NSColor grayColor] set];
    }
    
		[NSBezierPath fillRect:removeRect];
	}		
  
	/* Draw border */
	if (!isActive) {
		[[NSColor whiteColor] set];
		[bezierPath removeAllPoints];
		NSPoint p = [self bounds].origin;
		[bezierPath moveToPoint:p];
		p.x += [self bounds].size.width;
		[bezierPath lineToPoint:p];
		p.y += [self bounds].size.height;
		[bezierPath lineToPoint:p];
		p.x -= [self bounds].size.width;
		[bezierPath lineToPoint:p];
		[bezierPath closePath];
		[bezierPath stroke];
	}
}

//-------------------------------------------------------------------
// setActive:flag
// Sets active attribute
//-------------------------------------------------------------------
- (void)setActive:(BOOL)flag
{
	isActive = flag;
	[self setNeedsDisplay:TRUE];
}

//-------------------------------------------------------------------
// mouseDown:theEvent
// Switch active channel to the channel of the cell
//-------------------------------------------------------------------
- (void)mouseDown:(NSEvent *)theEvent
{
	window_set_active(windowRec);
}

@end
