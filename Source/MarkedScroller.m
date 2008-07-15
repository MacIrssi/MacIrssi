#import "MarkedScroller.h"

@implementation MarkedScroller

//-------------------------------------------------------------------
// initWithWindowRec:rec
// Designated initializer
//-------------------------------------------------------------------
- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	markerColor = [[NSColor redColor] retain];
	markers = [[NSMutableArray alloc] init];
	maxPos = 1;
	return self;
}

/* Dealloc */
- (void)dealloc
{
	[markerColor release];
	[markers release];
	[super dealloc];
}

//-------------------------------------------------------------------
// setMaxPos:max
// Sets the maximum marker position.
//
// max - The new max position
//-------------------------------------------------------------------
- (void)setMaxPos:(float)max
{
	maxPos = max;
}

//-------------------------------------------------------------------
// addMarker:pos
// Adds a marker.
//
// pos - the pos to add a new marker
//-------------------------------------------------------------------
- (void)addMarker:(float)pos
{	
	[markers addObject:[NSNumber numberWithFloat:pos]];
}

//-------------------------------------------------------------------
// removeAllMarkers
// Removes all markers.
//-------------------------------------------------------------------
- (void)removeAllMarkers
{
	[markers removeAllObjects];
}

//-------------------------------------------------------------------
// drawRect:rect
// Draws the scroller.
//-------------------------------------------------------------------
- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
	
	NSRect slotRect =  [self rectForPart:NSScrollerKnobSlot];
	NSRect knobRect = [self rectForPart:NSScrollerKnob];
	float knobMin = knobRect.origin.y + 3;
	float knobMax = knobMin + knobRect.size.height - 6;
	NSEnumerator *e = [markers objectEnumerator];
	NSNumber *n;
	NSPoint p1, p2;
	p1.x = slotRect.origin.x;
	p2.x = p1.x + slotRect.size.width;
	
	[markerColor set];
	
	while (n = [e nextObject]) {
		p1.y = p2.y = slotRect.origin.y + slotRect.size.height * ([n floatValue] / maxPos);
		
		/* Only draw markers outside knob */
		if ( !(knobMin < p1.y && knobMax > p1.y))
			[NSBezierPath strokeLineFromPoint:p1 toPoint:p2];
	}
}
@end
