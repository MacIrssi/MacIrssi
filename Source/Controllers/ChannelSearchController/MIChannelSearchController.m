//
//  MIChannelSearchController.m
//  MacIrssi
//
//  Created by Matt Wright on 11/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MIChannelSearchController.h"
#import "ChannelController.h"

@interface MIChannelSearchController ()

- (void)makeSearchBarVisibleAndKey;
- (void)clearResultsAndSearchWithTerm:(NSString*)term;
- (void)jumpToNextResultInDirection:(MISearchDirection)direction;

@end


@implementation MIChannelSearchController

- (id)initWithController:(ChannelController*)aController
{
  if (self = [super init])
  {
    matches = [[NSMutableArray alloc] init];
    currentMatch = -1;
    currentSearchTerm = nil;
    controller = aController;
  }
  return self;
}

- (void)dealloc
{
  [super dealloc];
}

- (BOOL)canPerformFindForTag:(int)tag
{
  switch (tag)
  {
    case 1: // "Find.."
      return YES;
    case 2: // "Find Next"
    case 3: // "Find Previous"
      return ([matches count] != 0);
    case 7: // "Use Selection for Find"
    default:
      return NO;
  }
}

- (void)performFind:(id)sender
{
  switch ([sender tag])
  {
    case 1:
      [self makeSearchBarVisibleAndKey];
      break;
    case 2:
      [self jumpToNextResultInDirection:MISearchNextDirection];
      break;
    case 3:
      [self jumpToNextResultInDirection:MISearchPreviousDirection];
      break;
    default:
      return;
  }
}

- (void)makeSearchBarVisibleAndKey
{
  [controller setSearchBarVisible:YES];
}

- (void)clearResultsAndSearchWithTerm:(NSString*)term
{
  [matches removeAllObjects];
  currentMatch = -1;

  [currentSearchTerm autorelease];
  currentSearchTerm = nil;
  
  if (![term isEqual:@""])
  {
    currentSearchTerm = [term copy];
    
    NSString *text = [[controller textView] string];
    NSRange range = NSMakeRange(0, [text length]);
    
    while (range.location + range.length <= [text length])
    {
      NSRange found = [text rangeOfString:term options:NSCaseInsensitiveSearch range:range];
      if (found.location != NSNotFound)
      {
        NSValue *loc = [NSValue valueWithRange:found];
        [matches addObject:loc];
        range.location = found.location + found.length;
        range.length = [text length] - range.location;
      }
      else
      {
        break;
      }
    }
  }
}

- (void)jumpToNextResultInDirection:(MISearchDirection)direction
{
  if ([matches count] == 0)
  {
    /* Just make sure we can't do this */
    return;
  }
  
  if (currentMatch == -1)
  {
    currentMatch = (direction == MISearchNextDirection ? 0 : [matches count] - 1);
  }
  else if (direction == MISearchNextDirection)
  {
    currentMatch = (currentMatch+1) % [matches count];
  }
  else if ((direction == MISearchPreviousDirection) && (currentMatch == 0))
  {
    currentMatch = ([matches count] - 1);
  }
  else
  {
    currentMatch = (currentMatch-1) % [matches count];
  }

  NSValue *val = [matches objectAtIndex:currentMatch];
  NSRange range = [val rangeValue];
  
  if (range.location != NSNotFound)
  {
    [[controller textView] scrollRangeToVisible:range];
    [[controller textView] showFindIndicatorForRange:range];
  }
}

- (void)searchBar:(MISearchBar*)bar findInDirection:(MISearchDirection)direction withString:(NSString*)term
{
  if (![term isEqual:currentSearchTerm])
  {
    [self clearResultsAndSearchWithTerm:term];
  }
  [self jumpToNextResultInDirection:direction];
}

- (NSInteger)searchBar:(MISearchBar *)bar numberOfMatchesWithString:(NSString*)term
{
  if (![term isEqual:currentSearchTerm])
  {
    /* Reset the search and re-search the text view */
    [self clearResultsAndSearchWithTerm:term];
  }
  return [matches count];
}

- (void)searchBarShouldCancel:(MISearchBar*)bar
{
  [controller setSearchBarVisible:NO];
}

@end
