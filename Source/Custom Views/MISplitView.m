/*
 MISplitView.m
 Copyright (c) 2008, 2009 Matt Wright.
 
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

#import "MISplitView.h"


@implementation MISplitView

- (id)initWithFrame:(NSRect)frameRect
{
  if (self = [super initWithFrame:frameRect])
  {
    thickness = [super dividerThickness];
  }
  return self;
}

- (void)awakeFromNib
{
//  thickness = [super dividerThickness];
}

#pragma mark Pre-10.5 layout support

- (void)saveLayoutUsingName:(NSString*)name
{
  // So we'll save the layouts of the subviews, just iterate the subviews of the view and turn them into
  // an array of rectstrings using NSStringFromRect
  NSEnumerator *subviewEnumerator = [[self subviews] objectEnumerator];
  NSView *subview;
  
  NSMutableArray *subviewRegions = [NSMutableArray array];
  
  while (subview = [subviewEnumerator nextObject])
  {
    [subviewRegions addObject:NSStringFromRect([subview frame])];
  }
  [[NSUserDefaults standardUserDefaults] setValue:subviewRegions forKey:[NSString stringWithFormat:@"MISplitView %@ Frame", name]];
}

- (void)restoreLayoutUsingName:(NSString*)name
{
  NSArray *subviewRegions = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"MISplitView %@ Frame", name]];
  
  // Right, go through each subview and see if we have a region for it, if so resize!
  NSEnumerator *subviewRegionEnumerator = [subviewRegions objectEnumerator];
  NSString *region;
  
  while (region = [subviewRegionEnumerator nextObject])
  {
    int index = [subviewRegions indexOfObject:region];
    if (index < [[self subviews] count])
    {
      [[[self subviews] objectAtIndex:index] setFrame:NSRectFromString(region)];
    }
  }
  [self adjustSubviews];
}

#pragma mark Non-standard Divider support

- (void)setDividerThickness:(CGFloat)newThickness
{
  thickness = newThickness;
  [self adjustSubviews];
  [self setNeedsDisplay:YES];
}

- (CGFloat)dividerThickness
{
  return thickness;
}

- (void)setDrawLowerBorder:(BOOL)flag
{
  drawLowerBorder = flag;
  [self adjustSubviews];
  [self setNeedsDisplay:YES];
}

- (BOOL)drawLowerBorder
{
  return drawLowerBorder;
}

- (void)drawDividerInRect:(NSRect)aRect
{ 
  if (thickness > 4.0)
  {
    [super drawDividerInRect:aRect];
  }
  
  if (drawLowerBorder)
  {
    NSRect line;
    if ([self isVertical]) 
    {
      line = NSMakeRect(aRect.origin.x + aRect.size.width, aRect.origin.y, 1, aRect.size.height);
    }
    else
    {
      // Gah can't work out how to draw a line
      line = NSMakeRect(aRect.origin.x, aRect.origin.y, aRect.size.width, 1);
      if ([self isFlipped])
      {
        line.origin.y += aRect.size.height;
      }
    }
    
    [[NSColor grayColor] set];
    NSRectFill(line);
  }
}

@end
