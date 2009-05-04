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

@end
