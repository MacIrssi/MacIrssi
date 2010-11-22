/*
 CustomTextView.m
 Copyright (c) 2008, 2009 Matt Wright, 2008 Nils Hjelte.
 
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

//	Overrides link color attributes.

#import "CustomTextView.h"
#import "CustomWindow.h"

@implementation CustomTextView

- (void)awakeFromNib
{
  shouldAntialias = YES;
}

- (id)initWithFrame:(NSRect)frameRect textContainer:(NSTextContainer *)aTextContainer
{
  if (self = [super initWithFrame:frameRect textContainer:aTextContainer])
  {
    shouldAntialias = YES;
  }
  return self;
}

- (BOOL)shouldAntialias
{
  return shouldAntialias;
}

- (void)setShouldAntialias:(BOOL)flag
{
  if (flag != shouldAntialias)
  {
    shouldAntialias = flag;
    [self setNeedsDisplay:YES];
  }
}

- (void)drawRect:(NSRect)rect
{
  if ([[NSGraphicsContext currentContext] shouldAntialias] != shouldAntialias)
  {
    [[NSGraphicsContext currentContext] setShouldAntialias:shouldAntialias];
  }
  [super drawRect:rect];
}

- (NSDictionary *)linkTextAttributes
{
	return [NSDictionary dictionaryWithObjectsAndKeys:[NSCursor pointingHandCursor], NSCursorAttributeName, 
		[NSNumber numberWithInt:1], NSUnderlineStyleAttributeName, nil];
}

@end
