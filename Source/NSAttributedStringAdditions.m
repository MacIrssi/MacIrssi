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


static NSURL* findURL(NSString* string);

@implementation NSMutableAttributedString (Additions)

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
