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

@interface MIScrollView ()
- (void)documentViewFrameDidChangeNotification:(NSNotification*)notification;
@end


@implementation MIScrollView

- (void)awakeFromNib 
{
  scrollerAtBottom = YES;
  previousDocumentRect = [[[self contentView] documentView] frame];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentViewFrameDidChangeNotification:) name:NSViewFrameDidChangeNotification object:[[self contentView] documentView]];  
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:[[self contentView] documentView]];
  [super dealloc];
}

- (void)documentViewFrameDidChangeNotification:(NSNotification*)notification
{
  previousDocumentRect = [[[self contentView] documentView] frame];
  if ([self isScrollerAtBottom]) {
    NSPoint point = [[self contentView] constrainScrollPoint:NSMakePoint(0, [[self documentView] bounds].size.height)];
    [[self contentView] scrollToPoint:point];
    [self reflectScrolledClipView:[self contentView]];
  }
}

- (BOOL)isScrollerAtBottom
{
  return scrollerAtBottom;
}

- (void)forceScrollToBottom
{
  NSPoint point = [[self contentView] constrainScrollPoint:NSMakePoint(0, [[self documentView] bounds].size.height)];
  [[self contentView] scrollToPoint:point];
  [self reflectScrolledClipView:[self contentView]];
  
  scrollerAtBottom = YES;
}

- (void)reflectScrolledClipView:(NSClipView *)aClipView
{
  [super reflectScrolledClipView:aClipView];
  
  // Don't do any logic processing if we're redrawing because the scroller changed in size
  if (NSEqualRects([[[self contentView] documentView] frame], previousDocumentRect) && ([[self verticalScroller] usableParts] == NSAllScrollerParts))
  {
    if (!NSEqualRects([[self contentView] documentVisibleRect], previousClipRect)) 
    {
      float yOffset = [[self contentView] documentVisibleRect].origin.y - previousClipRect.origin.y;

      if ((yOffset < 0) && scrollerAtBottom) {
        scrollerAtBottom = NO;
      } else if ((yOffset > 0) && !scrollerAtBottom) {
        scrollerAtBottom = YES;
      }
      
      // Make sure we store where we are for next time
      previousClipRect = [[self contentView] documentVisibleRect];
    } 
  }
}

@end
