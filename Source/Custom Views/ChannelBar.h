/* ChannelBar */

#import <Cocoa/Cocoa.h>
#import "common.h"
#import "ChannelBarCell.h"

@interface ChannelBar : NSView
{
	//NSString *name;
	NSMutableArray *channelBarCells;
	float totalStringWidth;
	float totalWidth;
	ChannelBarCell *activeCell;
}

- (void)addChannel:(WINDOW_REC *)rec;
- (void)moveChannel:(WINDOW_REC *)rec fromRefNum:(int)refNum toRefNum:(int)toRefNum;
- (void)removeChannel:(WINDOW_REC *)rec;

- (void)fitCells;

- (void)drawRect:(NSRect)rect;

- (void)selectCell:(ChannelBarCell *)cell;
- (void)selectCellWithWindowRec:(WINDOW_REC *)rec;

@end
