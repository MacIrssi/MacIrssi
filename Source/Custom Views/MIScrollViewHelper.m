/*
 MIScrollViewHelper.m
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

#import "MIScrollViewHelper.h"


@implementation MIScrollViewHelper

- (id)initWithScrollView:(NSScrollView*)view
{
  if (self = [super init])
  {
    target = [view retain];
  }
  return self;
}

- (void)dealloc
{
  [target release];
  [super dealloc];
}

- (CGFloat)currentScrollPosition
{
  NSRect documentBounds = [[target documentView] frame];
  NSRect clipViewBounds = [[target contentView] visibleRect];
  
  if (NSMaxY(clipViewBounds) > documentBounds.size.height)
  {
    return 1.0; // at bottom
  }
  else if (NSMinY(clipViewBounds) <= 0.0) 
  {
    return 0.0; // at top
  }
  else
  {
    CGFloat x = documentBounds.size.height - clipViewBounds.size.height;
    if (x > 0.0)
    {
      return clipViewBounds.origin.y / x;
    }
  }
  return 0.0;
}

- (void)restoreScrollPosition:(CGFloat)position
{
  NSClipView *clipView = [target contentView];
  
  NSRect documentBounds = [[target documentView] frame];
  NSRect clipViewBounds = [clipView visibleRect];
  CGFloat scrollPoint;
  
  if (documentBounds.size.height < clipViewBounds.size.height) {
    scrollPoint = 0.0;
  }
  else if (position == 0.0)
  {
    scrollPoint = 0.0;
  }
  else if (position == 1.0)
  {
    scrollPoint = (documentBounds.origin.y + documentBounds.size.height) - clipViewBounds.size.height;
  }
  else
  {
    scrollPoint = floor(position * ((documentBounds.origin.y + documentBounds.size.height) - clipViewBounds.size.height));
  }

  if (scrollPoint != [clipView visibleRect].origin.y)
  {
    [target scrollClipView:clipView toPoint:NSMakePoint(0.0, scrollPoint)];
    [target reflectScrolledClipView:clipView];
  }
}

@end
