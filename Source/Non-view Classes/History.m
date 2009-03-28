/*
 
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*
* MacIrssi - History.c
* Nils Hjelte, c01nhe@cs.umu.se
*
* A list of strings that can be iterated forward and backward.
*/

#import "History.h"

@implementation History

- (id)init
{
  if (self = [super init])
  {
    commandHistory = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)dealloc
{
  [commandHistory release];
  [super dealloc];
}

- (NSString*)commandBefore:(NSString*)string
{
  if ([commandHistory count] == 0)
  {
    return nil;
  }
  else if (index == -1)
  {
    index = [commandHistory count] - 1;
    return [commandHistory lastObject];
  }
  else if (index == 0)
  {
    return [commandHistory objectAtIndex:0];
  }
  
  index--;
  return [commandHistory objectAtIndex:index];
}

- (NSString*)commandAfter:(NSString*)string
{
  if ([commandHistory count] == 0)
  {
    return nil;
  }
  else if (index == -1)
  {
    return nil;
  }
  else if (index == ([commandHistory count] - 1))
  {
    index = -1;
    return nil;
  }
  
  index++;
  return [commandHistory objectAtIndex:index];
}

- (void)addCommand:(NSString*)string
{
  if (string && ![commandHistory containsObject:string])
  {
    [commandHistory addObject:string];
    index = -1;
  }
}

@end
