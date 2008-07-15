
#import <Cocoa/Cocoa.h>
#import "common.h"


@interface ChannelBarCell : NSView
{
	WINDOW_REC *windowRec;
	NSMutableDictionary *highlightAttributes;
	NSColor *highlightColors[4];
	NSBezierPath *bezierPath;
	BOOL isActive;
	//int dataLevel;
}
- (id)initWithWindowRec:(WINDOW_REC *)rec;

//- (void)setDataLevel:(int)level;
- (float)stringWidth;
- (NSString *)name;
- (WINDOW_REC *)windowRec;
+ (float)borderWidth;
- (void)setActive:(BOOL)flag;
- (void)setFrame:(NSRect)frame;
- (NSString *)view:(NSView *)view stringForToolTip:(NSToolTipTag)tag point:(NSPoint)point userData:(void *)userData;

@end
