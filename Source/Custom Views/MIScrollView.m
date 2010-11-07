/*
 MIScrollView.m
 Copyright (c) 2010 Matt Wright.
 
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

#import "MIScrollView.h"


@implementation MIScrollView

- (void)awakeFromNib 
{
  scrollerAtBottom = YES;
}

- (void)scrollWheel:(NSEvent *)theEvent
{
  if ([[self verticalScroller] usableParts] == NSAllScrollerParts) {
    if (([theEvent deltaY] > 0) && scrollerAtBottom) {
      // If the user scrolled up, regardless of position, we're no longer at the bottom.
      scrollerAtBottom = NO;
    } else if (([theEvent deltaY] < 0) && ([[self verticalScroller] floatValue] == 1.0) && !scrollerAtBottom) {
      // If the user scrolled down, and we hit the bottom, then we're at the bottom.
      scrollerAtBottom = YES;
    }
  }
  [super scrollWheel:theEvent];
}

- (BOOL)isScrollerAtBottom
{
  return scrollerAtBottom;
}

- (void)reflectScrolledClipView:(NSClipView *)aClipView
{
  if (scrollerAtBottom) {
    [aClipView scrollToPoint:[aClipView constrainScrollPoint:NSMakePoint(0, [[self documentView] bounds].size.height)]];
  }
  [super reflectScrolledClipView:aClipView];
}

@end
