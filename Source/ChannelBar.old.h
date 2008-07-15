/* ChannelBar */

#import <Cocoa/Cocoa.h>
#import "common.h"
#import "ChannelBarCell.h"

@interface ChannelBar : NSView
{
	NSMutableArray *channelBarCells;
	float totalStringWidth;
	float totalWidth;
	NSColor *bgColor;
	ChannelBarCell *activeCell;
}

- (void)addChannel:(WINDOW_REC *)rec;
- (void)removeChannel:(WINDOW_REC *)rec;
- (void)fitCells;
- (void)drawRect:(NSRect)rect;
- (void)selectCell:(ChannelBarCell *)cell;
- (void)selectCellWithWindowRec:(WINDOW_REC *)rec;

@end
