//
//  MISplitView.m
//  MacIrssi
//
//  Created by Matt Wright on 27/12/2008.
//  Copyright 2008 Matt Wright Consulting. All rights reserved.
//

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
