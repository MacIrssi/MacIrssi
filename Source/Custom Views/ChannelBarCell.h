/*
 ChannelBarCell.h
 Copyright (c) 2008, 2009 Matt Wright, 2008 Nils Hjelte.
 
 MacIrssi is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <Cocoa/Cocoa.h>
#import "common.h"


@interface ChannelBarCell : NSView
{
	WINDOW_REC *windowRec;
	NSMutableDictionary *highlightAttributes;
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
