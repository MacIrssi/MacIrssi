/*
 * NSAttributedStringAdditions.m
 * Fire
 *
 * Created by Eric Peyton on Thu Apr 22 1999.
 * Copyright (c) 1999-2003 Fire Development Team and/or epicware, Inc.
 * All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#import "NSAttributedStringAdditions.h"
#import "ColorSet.h"

#import "common.h"
#import "formats.h"

#import "NSString+Additions.h"

/* From gui-printtext.c */
static int mirc_colors[] = { 15, 0, 1, 2, 12, 4, 5, 6, 14, 10, 3, 11, 9, 13, 8, 7 };

@implementation NSMutableAttributedString (Additions)

- (NSMutableAttributedString*)attributedStringByAppendingString:(NSString*)text foreground:(int)fg background:(int)bg flags:(int)flags attributes:(NSDictionary*)attributes;
{
  NSMutableAttributedString *buffer = [[NSMutableAttributedString alloc] initWithAttributedString:self];
  NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
  
  /* Handle colors */
  if (flags & GUI_PRINT_FLAG_MIRC_COLOR) {
    /* mirc colors - real range is 0..15, but after 16
     colors wrap to 0, 1, ... */
    if (bg >= 0)
    {
      bg = mirc_colors[bg % 16];
    }
    
    if (fg >= 0)
    {
      fg = mirc_colors[fg % 16];
    }
  }
  
  if (fg < 0 || fg > 15) 
  {
    [mutableAttributes setObject:[ColorSet channelForegroundColor] forKey:NSForegroundColorAttributeName];
  }
  else 
  {
    [mutableAttributes setObject:[[ColorSet mircColours] objectAtIndex:fg] forKey:NSForegroundColorAttributeName];
  }
  
#if 0
  //TODO
  if (bg < 0 || bg > 15)
    [attributes removeObjectForKey:NSBackgroundColorAttributeName];
  else
    [attributes setObject:[bg_colors objectAtIndex:bg] forKey:NSBackgroundColorAttributeName];
#endif
  
  /* Handle flags */ //TODO
  if (flags & GUI_PRINT_FLAG_REVERSE) 
  {
    
  }
  if (flags & GUI_PRINT_FLAG_BOLD) 
  {
    
  }
  if (flags & GUI_PRINT_FLAG_UNDERLINE) 
  {
    
  }
  if (flags & GUI_PRINT_FLAG_BLINK) 
  {
    /* Ignore */
  } 
  if (flags & GUI_PRINT_FLAG_NEWLINE) 
  {
    NSLog(@"GUI_PRINT_FLAG_NEWLINE for text \'%@\'", text);
    [buffer appendAttributedString:[[[NSMutableAttributedString alloc] initWithString:@"\n"] autorelease]];
  }
  if (flags & GUI_PRINT_FLAG_INDENT) 
  {
    //NSLog(@"GUI_PRINT_FLAG_INDENT for text \'%@\'", text);
  }
  if (flags & GUI_PRINT_FLAG_CLRTOEOL) 
  {
    NSLog(@"GUI_PRINT_FLAG_CLRTOEOL for text \'%@\'", text);
  }
  
  if (text)
  {
    NSAttributedString *tmp = [[NSAttributedString alloc] initWithString:text attributes:mutableAttributes];
    [buffer appendAttributedString:tmp];
    [tmp release];
  }
  
  return buffer;
}

- (void)detectURLs:(NSColor*)linkColor
{
  NSArray *urls = [[self string] arrayOfURLsDetectedInString];
  
  int i = 0;
  for (i=0; i < [urls count]; i++)
  {
    NSString *link = [urls objectAtIndex:i];
    
    NSRange range = [[self string] rangeOfString:link];
    
    NSDictionary *linkAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    link, NSLinkAttributeName,
                                    [NSNumber numberWithInt:NSSingleUnderlineStyle], NSUnderlineStyleAttributeName,
                                    linkColor, NSForegroundColorAttributeName,
                                    nil];
    [self addAttributes:linkAttributes range:range];
  }
}

@end
