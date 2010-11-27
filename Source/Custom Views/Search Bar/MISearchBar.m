/*
 MISearchBar.m
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

#import "MISearchBar.h"
#import "CHLayout.h"

#define DONE_BUTTON_WIDTH 45

@implementation MISearchBar

- (id)initWithFrame:(NSRect)frame
{
  if (self = [super initWithFrame:frame])
  {
    NSFont *smallSystemFont = [NSFont systemFontOfSize:[NSFont smallSystemFontSize]];
    
    doneButton = [[NSButton alloc] initWithFrame:NSMakeRect(frame.size.width - DONE_BUTTON_WIDTH - 10, 1, DONE_BUTTON_WIDTH, 22)];
    [[doneButton cell] setFont:smallSystemFont];
    [doneButton setTitle:@"Done"];
    [doneButton setBezelStyle:NSRoundRectBezelStyle];
    [doneButton setAutoresizingMask:(NSViewMinXMargin|NSViewMaxYMargin)];
    [doneButton setLayoutName:@"doneButton"];
    [self addSubview:doneButton];
          
    searchResultsLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(10, 0, 150, 15)];
    [[searchResultsLabel cell] setControlSize:NSSmallControlSize];
    [searchResultsLabel setEditable:NO];
    [searchResultsLabel setBezeled:NO];
    [searchResultsLabel setSelectable:NO];
    [searchResultsLabel setDrawsBackground:NO];
    [searchResultsLabel setFont:smallSystemFont];
    [searchResultsLabel setAlignment:NSRightTextAlignment];
    [searchResultsLabel setStringValue:@""];
    [searchResultsLabel setLayoutName:@"searchResultsLabel"];
    [self addSubview:searchResultsLabel];
    
    [searchResultsLabel addConstraint:[CHLayoutConstraint constraintWithAttribute:CHLayoutConstraintAttributeMidY relativeTo:@"doneButton" attribute:CHLayoutConstraintAttributeMidY]];
    
    NSImage *smallGoLeftImage = [NSImage imageNamed:NSImageNameGoLeftTemplate];
    [smallGoLeftImage setSize:NSMakeSize(8, 8)];
    NSImage *smallGoRightImage = [NSImage imageNamed:NSImageNameGoRightTemplate];
    [smallGoRightImage setSize:NSMakeSize(8, 8)];
    
    nextBackButton = [[NSSegmentedControl alloc] initWithFrame:NSMakeRect(0, 0, 40, 22)];
    [[nextBackButton cell] setTrackingMode:NSSegmentSwitchTrackingMomentary];
    [nextBackButton setSegmentStyle:NSSegmentStyleRoundRect];
    [nextBackButton setSegmentCount:2];
    [nextBackButton setImageScaling:NSImageScaleProportionallyDown forSegment:0];
    [nextBackButton setImageScaling:NSImageScaleProportionallyDown forSegment:1];
    [nextBackButton setImage:smallGoLeftImage forSegment:0];
    [nextBackButton setImage:smallGoRightImage forSegment:1];
    [nextBackButton setWidth:17 forSegment:0];
    [nextBackButton setWidth:17 forSegment:1];
    [nextBackButton setLayoutName:@"nextBackButton"];
    [self addSubview:nextBackButton];
    
    [nextBackButton addConstraint:[CHLayoutConstraint constraintWithAttribute:CHLayoutConstraintAttributeMinX relativeTo:@"searchResultsLabel" attribute:CHLayoutConstraintAttributeMaxX offset:10]];
    [nextBackButton addConstraint:[CHLayoutConstraint constraintWithAttribute:CHLayoutConstraintAttributeMidY relativeTo:@"searchResultsLabel" attribute:CHLayoutConstraintAttributeMidY]];
    
    CGFloat searchFieldWidth = [doneButton frame].origin.x - ([nextBackButton frame].origin.x + [nextBackButton frame].size.width) - 20;
    searchField = [[NSSearchField alloc] initWithFrame:NSMakeRect(0, 0, searchFieldWidth, 20)];
    [[searchField cell] setControlSize:NSSmallControlSize];
    [[searchField cell] setFont:smallSystemFont];
    [searchField setAutoresizingMask:NSViewWidthSizable];
    [searchField setLayoutName:@"searchField"];
    [self addSubview:searchField];    
                                   
    [searchField addConstraint:[CHLayoutConstraint constraintWithAttribute:CHLayoutConstraintAttributeMaxX relativeTo:@"doneButton" attribute:CHLayoutConstraintAttributeMinX offset:-10]];
    [searchField addConstraint:[CHLayoutConstraint constraintWithAttribute:CHLayoutConstraintAttributeMidY relativeTo:@"doneButton" attribute:CHLayoutConstraintAttributeMidY]];
  }
  return self;
}

- (void)dealloc
{
  [searchResultsLabel removeAllConstraints];
  [searchResultsLabel release];
  [nextBackButton removeAllConstraints];
  [nextBackButton release];
  [searchField removeAllConstraints];
  [searchField release];
  [doneButton removeAllConstraints];
  [doneButton release];
  [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect
{
//  [[NSColor blueColor] set];
//  NSRectFill(dirtyRect);
}

@end
