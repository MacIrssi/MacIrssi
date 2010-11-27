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

@implementation NSAttributedString (Additions)

#define FONT_HEIGHT_STRING		@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789()"
+ (float)stringHeightForAttributes:(NSDictionary *)attributes
{
	NSAttributedString	*string = [[[NSAttributedString alloc] initWithString:FONT_HEIGHT_STRING
                                                                attributes:attributes] autorelease];
	return [string heightWithWidth:1e7];
}

+ (NSAttributedString *)stringWithString:(NSString *)inString
{
	return [[[NSAttributedString alloc] initWithString:inString] autorelease];
}

- (float)heightWithWidth:(float)width
{	
  //Setup the layout manager and text container
  NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:self];
  NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(width, 1e7)];
  NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
  
  //Configure
  [textContainer setLineFragmentPadding:0.0];
  [layoutManager addTextContainer:textContainer];
  [textStorage addLayoutManager:layoutManager];
  
  //Force the layout manager to layout its text
  (void)[layoutManager glyphRangeForTextContainer:textContainer];
  
	float height = [layoutManager usedRectForTextContainer:textContainer].size.height;
  
	[textStorage release];
	[textContainer release];
	[layoutManager release];
	
  return height;
}

@end

@implementation NSMutableAttributedString (Additions)

- (void)appendString:(NSString*)text foreground:(int)fg background:(int)bg flags:(int)flags attributes:(NSDictionary*)attributes
{
  if (text) // We could have an invalid string but still need to append a new line.
  {
    NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    
    if (fg < 0 || fg > 15) 
    {
      [mutableAttributes setObject:[ColorSet channelForegroundColor] forKey:NSForegroundColorAttributeName];
    }
    else 
    {
      [mutableAttributes setObject:[ColorSet colourMappedFromIrssiIndex:fg isMircColour:(flags & GUI_PRINT_FLAG_MIRC_COLOR)] forKey:NSForegroundColorAttributeName];
    }
    
    if (bg < 0 || bg > 15)
    {
      [mutableAttributes removeObjectForKey:NSBackgroundColorAttributeName];
    }
    else
    {
      [mutableAttributes setObject:[ColorSet colourMappedFromIrssiIndex:bg isMircColour:(flags & GUI_PRINT_FLAG_MIRC_COLOR)] forKey:NSBackgroundColorAttributeName];
    }
    
    /* Ignored Flags */
    // if (flags & GUI_PRINT_FLAG_REVERSE)
    // if (flags & GUI_PRINT_FLAG_BLINK) 
    // if (flags & GUI_PRINT_FLAG_INDENT) 
    // if (flags & GUI_PRINT_FLAG_CLRTOEOL) 
    
    if (flags & GUI_PRINT_FLAG_BOLD) 
    {
      NSFont *newFont = [[NSFontManager sharedFontManager] convertFont:[mutableAttributes objectForKey:NSFontAttributeName] toHaveTrait:NSBoldFontMask];
      [mutableAttributes setObject:newFont forKey:NSFontAttributeName];
    }
    if (flags & GUI_PRINT_FLAG_UNDERLINE) 
    {
      [mutableAttributes setObject:[NSNumber numberWithInt:NSUnderlineStyleSingle] forKey:NSUnderlineStyleAttributeName];
    }
    
    int l = [self length];
    [self replaceCharactersInRange:NSMakeRange(l, 0) withString:text];
    [self setAttributes:mutableAttributes range:NSMakeRange(l, [text length])];
  }
  
  if (flags & GUI_PRINT_FLAG_NEWLINE)
  {
    [self replaceCharactersInRange:NSMakeRange([self length], 0) withString:@"\n"];
  }
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
