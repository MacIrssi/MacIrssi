/*
 NSString+Additions.m
 Copyright (c) 2009 Matt Wright.
 
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

#import "NSString+Additions.h"
#import <GoogleToolboxForMac/GTMRegex.h>

@implementation NSString (Additions)

+ (NSString*)stringWithUnicodeCharacter:(unichar)character
{
  return [NSString stringWithCharacters:&character length:sizeof(unichar)];
}


- (NSArray*)arrayOfURLsDetectedInString
{
  // grab an array of the URLs we've found in the string
  NSMutableArray *urls = [NSMutableArray array];
  
  // first thing is first, we're gonna have to build a URL regex, handily, here is one I made earlier
  NSString *pattern =  @"(("
                          "([a-zA-Z0-9]+://)" // protocol
                          "(([0-9a-zA-Z_!~*'().&=+$%-]+: )?[0-9a-zA-Z_!~*'().&=+$%-]+@)?" // user@ 
                          "(([0-9]{1,3}\\.){3}[0-9]{1,3}" // IP- 199.194.52.184 
                          "|" // allows either IP or domain 
                          "([0-9a-zA-Z_!~'-]+\\.)*" // tertiary domain(s)- www. 
                          "([0-9a-zA-Z][0-9a-zA-Z-]{0,61})?[0-9a-zA-Z]\\." // second level domain 
                          "[a-zA-Z]{2,6})" // first level domain- .com or .museum 
                        ")|("
                          "([0-9a-zA-Z_!~'-]+\\.)+" // tertiary domain(s)- www. 
                          "([0-9a-zA-Z][0-9a-zA-Z-]{0,61})?[0-9a-zA-Z]\\." // second level domain 
                          "[a-zA-Z]{2,6}" // first level domain- .com or .museum 
                        "))"
                        "(:[0-9]{1,4})?" // port number- :80 
                        "((/?)|" // a slash isn't required if there is no file name 
                        "((/[0-9a-zA-Z_!~*'.;?:@&=+$,%#-]+)|\\(([0-9a-zA-Z_!~*'.;?:@&=+$,%#-]+)\\))+/?)";
  
  GTMRegex *regex = [GTMRegex regexWithPattern:pattern];
  NSEnumerator *matchesEnumerator = [regex matchSegmentEnumeratorForString:self];
  
  GTMRegexStringSegment *match;
  while (match = [matchesEnumerator nextObject])
  {
    [urls addObject:[match string]];
  }

  return urls;
}

@end
