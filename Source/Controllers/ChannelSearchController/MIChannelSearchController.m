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

@end


@implementation MIChannelSearchController

- (id)initWithController:(ChannelController*)aController
{
  if (self = [super init])
  {
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
    default:
      return;
  }
}

- (void)makeSearchBarVisibleAndKey
{
  [controller setSearchBarVisible:YES];
}

- (void)searchBar:(MISearchBar*)bar findInDirection:(MISearchDirection)direction withString:(NSString*)term
{
  
}

- (NSInteger)searchBar:(MISearchBar *)bar numberOfMatchesWithString:(NSString*)term
{
  NSLog(@"%@: %@", bar, term);
  return 0;
}

- (void)searchBarShouldCancel:(MISearchBar*)bar
{
  [controller setSearchBarVisible:NO];
}

@end
