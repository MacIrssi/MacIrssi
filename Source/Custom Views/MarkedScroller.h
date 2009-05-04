/*
 MarkedScroller.h
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
