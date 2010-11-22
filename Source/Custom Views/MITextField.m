/*
 MITextField.m
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

#import "MITextField.h"


@implementation MITextField

- (void)awakeFromNib
{
  shouldAntialias = YES;
}

- (id)initWithFrame:(NSRect)frameRect
{
  if (self = [super initWithFrame:frameRect])
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
  if (shouldAntialias != flag)
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

@end
