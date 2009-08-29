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

static NSURL* findURL(NSString* string);

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
  NSScanner*					scanner;
  NSRange						scanRange;
  NSString*					scanString;
  NSCharacterSet*				whitespaceSet;
  NSURL*						foundURL;
  NSDictionary*				linkAttr;
  
  // Create our scanner and supporting delimiting character set
  scanner = [NSScanner scannerWithString:[self string]];
  whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  
  // Start Scan
  while( ![scanner isAtEnd] )
  {
    // Pull out a token delimited by whitespace or new line
    [scanner scanUpToCharactersFromSet:whitespaceSet intoString:&scanString];
    scanRange.length = [scanString length];
    scanRange.location = [scanner scanLocation] - scanRange.length;
    
    // If we find a url modify the string attributes
    if(( foundURL = findURL(scanString) ))
    {
      // Apply underline style and link color
      linkAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                  foundURL, NSLinkAttributeName,
                  [NSNumber numberWithInt:NSSingleUnderlineStyle], NSUnderlineStyleAttributeName,
                  linkColor, NSForegroundColorAttributeName, 
                  NULL ];
      [self addAttributes:linkAttr range:scanRange];
    }
  }
}

@end


NSURL* findURL(NSString* string)
{
  NSRange		theRange;
  
  // We can't assume they're gonna be NSURL compatible urls. So escape them first. If they are escaped, remove them first
  // so we don't end up double escaping.
  string = [string stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
  string = CFURLCreateStringByAddingPercentEscapes(NULL, string, CFSTR("#"), NULL, kCFStringEncodingUTF8);
  NSLog(@"%@", string);
  // Look for ://
  theRange = [string rangeOfString:@"://"];
  
  if( theRange.location != NSNotFound && theRange.length != 0 )
  {
    return [NSURL URLWithString:string];
  }
  
  // Look for www. at start
  if( [string hasPrefix:@"www."] )
  {
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", string]];
  }
  
  // Look for ftp. at start
  if( [string hasPrefix:@"ftp."] )
  {
    return [NSURL URLWithString:[NSString stringWithFormat:@"ftp://%@", string]];
  }
  
	// Look for mailto: at start
  if( [string hasPrefix:@"mailto:"] )
  {
    return [NSURL URLWithString:string];
  }
  
#if 0
  // Look for gopher. at start
  if( [string hasPrefix:@"gopher."] )
  {
    return [NSURL URLWithString:[NSString stringWithFormat:@"gopher://%@", string]];
  }
  
  // Look for nap: at start
  if( [string hasPrefix:@"nap:"] )
  {
    return [NSURL URLWithString:string];
  }
#endif   
	
#if 0
	/* DISABLED - IRC who-entries get f**ked up (Nils Hjelte) */
  // Look for @ - minimum of a@a.a
  theRange = [string rangeOfString:@"@"];
  if( theRange.location != NSNotFound && theRange.length != 0
     && theRange.location > 0 && theRange.location < [string length] - 3 
     && [string rangeOfString:@"." options:0 range:NSMakeRange(theRange.location+1, [string length] - theRange.location-1)].location != NSNotFound)        return [NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@",string]];
#endif
	
  return nil;
}
