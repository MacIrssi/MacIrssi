//
//  MIChannelSearchController.h
//  MacIrssi
//
//  Created by Matt Wright on 11/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MISearchBar.h"

@class ChannelController;

@interface MIChannelSearchController : NSObject {
  ChannelController *controller;

  NSString *currentSearchTerm;
  NSMutableArray *matches;
}

- (id)initWithController:(ChannelController*)controller;
- (void)dealloc;

- (BOOL)canPerformFindForTag:(int)tag;
- (void)performFind:(id)sender;

- (void)searchBar:(MISearchBar*)bar findInDirection:(MISearchDirection)direction withString:(NSString*)term;
- (NSInteger)searchBar:(MISearchBar *)bar numberOfMatchesWithString:(NSString*)term;
- (void)searchBarShouldCancel:(MISearchBar*)bar;

@end
