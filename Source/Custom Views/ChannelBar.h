/*
 ChannelBar.h
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
