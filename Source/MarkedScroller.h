#import <Cocoa/Cocoa.h>


@interface MarkedScroller : NSScroller {
	float maxPos;
	NSMutableArray *markers;
	NSColor *markerColor;
}

- (void)setMaxPos:(float)max;
- (id)initWithFrame:(NSRect)frameRect;
- (void)dealloc;
- (void)addMarker:(float)pos;
- (void)removeAllMarkers;
- (void)drawRect:(NSRect)rect;

@end
