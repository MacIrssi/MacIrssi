/*
 MISearchBar.h
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

#import <Cocoa/Cocoa.h>

typedef enum {
  MISearchPreviousDirection = 0,
  MISearchNextDirection,
} MISearchDirection;

@interface MISearchBar : NSView <NSTextFieldDelegate> {
  NSTextField *searchResultsLabel;
  NSSegmentedControl *nextBackButton;
  NSSearchField *searchField;
  NSButton *doneButton;
  id delegate;
}

- (id)initWithFrame:(NSRect)frame;
- (void)dealloc;

- (id)delegate;
- (void)setDelegate:(id)aDelegate;

- (BOOL)becomeFirstResponder;
- (void)update;

@end

@interface NSObject (MISearchBarDelegates)

- (NSString*)searchBarWantsExistingSearchTerm:(MISearchBar*)bar;
- (void)searchBar:(MISearchBar*)bar findInDirection:(MISearchDirection)direction withString:(NSString*)term;
- (NSInteger)searchBar:(MISearchBar *)bar numberOfMatchesWithString:(NSString*)term;
- (void)searchBarShouldCancel:(MISearchBar*)bar;

@end
