/*
 ColorSet.m
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

//	Maintains all the colors used.

#import "ColorSet.h"


@implementation ColorSet

/* From gui-printtext.c */
static int mirc_colors[] = { 15, 0, 1, 2, 12, 4, 5, 6, 14, 10, 3, 11, 9, 13, 8, 7 };

+ (NSArray*) mircColours
{
  return [NSArray arrayWithObjects:
          [NSColor blackColor],
          [NSColor blueColor],
          [NSColor greenColor],
          [NSColor cyanColor],
          [NSColor redColor],
          [NSColor magentaColor],
          [NSColor orangeColor],
          [NSColor lightGrayColor],
          [NSColor grayColor],
          [NSColor blueColor], //light
          [NSColor greenColor], //light
          [NSColor cyanColor], //light
          [NSColor redColor], //light
          [NSColor magentaColor], //light
          [NSColor yellowColor],
          [NSColor whiteColor],
          nil];
}

+ (NSColor*)colourMappedFromIrssiIndex:(int)index isMircColour:(BOOL)flag
{
  if (flag)
  {
    index = mirc_colors[index % 16];
  }
  return [[ColorSet mircColours] objectAtIndex:index];
}

+ (void)registerDefaults
{
  NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0]], @"channelFGDefaultColor",
                            [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:5.0/255 green:13.0/255 blue:25.0/255 alpha:0.92]], @"channelBGColor",
                            [NSArchiver archivedDataWithRootObject:[NSColor yellowColor]], @"channelLinkColor",
                            
                            [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:103.0/255 green:103.0/255 blue:103.0/255 alpha:0.82]], @"channelListBGColor",
                            [NSArchiver archivedDataWithRootObject:[NSColor whiteColor]], @"channelListFGNoActivityColor",
                            [NSArchiver archivedDataWithRootObject:[NSColor yellowColor]], @"channelListFGActionColor",
                            [NSArchiver archivedDataWithRootObject:[NSColor orangeColor]], @"channelListFGPublicMessageColor",
                            [NSArchiver archivedDataWithRootObject:[NSColor redColor]], @"channelListFGPrivateMessageColor",
                            
                            [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:0.82]], @"nickListBGColor",
                            [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0]], @"nickListFGNormalColor",
                            [NSArchiver archivedDataWithRootObject:[NSColor yellowColor]], @"nickListFGVoiceColor",
                            [NSArchiver archivedDataWithRootObject:[NSColor cyanColor]], @"nickListFGHalfOpColor",
                            [NSArchiver archivedDataWithRootObject:[NSColor orangeColor]], @"nickListFGOpColor",
                            [NSArchiver archivedDataWithRootObject:[NSColor redColor]], @"nickListFGServerOpColor",
                            
                            nil];
  [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

+ (void)revertToDefaults
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults removeObjectForKey:@"channelFGDefaultColor"];
  [defaults removeObjectForKey:@"channelBGColor"];
  [defaults removeObjectForKey:@"channelLinkColor"];
  
  [defaults removeObjectForKey:@"channelListBGColor"];
  [defaults removeObjectForKey:@"channelListFGNoActivityColor"];
  [defaults removeObjectForKey:@"channelListFGActionColor"];
  [defaults removeObjectForKey:@"channelListFGPublicMessageColor"];
  [defaults removeObjectForKey:@"channelListFGPrivateMessageColor"];
  
  [defaults removeObjectForKey:@"nickListBGColor"];
  [defaults removeObjectForKey:@"nickListFGNormalColor"];
  [defaults removeObjectForKey:@"nickListFGVoiceColor"];
  [defaults removeObjectForKey:@"nickListFGHalfOpColor"];
  [defaults removeObjectForKey:@"nickListFGOpColor"];
  [defaults removeObjectForKey:@"nickListFGServerOpColor"];
  [defaults synchronize];
}

+ (NSArray*)channelListForegroundKeys
{
  return [NSArray arrayWithObjects:
          @"channelListFGNoActivityColor",
          @"channelListFGActionColor",
          @"channelListFGPublicMessageColor",
          @"channelListFGPrivateMessageColor",
          nil];
}

+ (NSArray*)nickListForegroundKeys
{
  return [NSArray arrayWithObjects:
          @"nickListFGNormalColor",
          @"nickListFGVoiceColor",
          @"nickListFGHalfOpColor",
          @"nickListFGOpColor",
          @"nickListFGServerOpColor",
          nil];
}

+ (NSColor*)colorForKey:(NSString*)key
{
  return [NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] valueForKey:key]];
}

+ (void)setColor:(NSColor*)color forKey:(NSString*)key
{
  [[NSUserDefaults standardUserDefaults] setObject:[NSArchiver archivedDataWithRootObject:color] forKey:key];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark Common Colour Accessors

+ (NSColor*)channelForegroundColor
{
  return [ColorSet colorForKey:@"channelFGDefaultColor"];
}

+ (NSColor*)channelBackgroundColor
{
  return [ColorSet colorForKey:@"channelBGColor"];
}

+ (NSColor*)channelLinkColour
{
  return [ColorSet colorForKey:@"channelLinkColor"];
}

// Did these ones by accident, would be surprised if I ever used them
+ (NSColor*)channelListBackgroundColor
{
  return [ColorSet colorForKey:@"channelListBGColor"];
}

+ (NSColor*)channelListForegroundNoActivityColor
{
  return [ColorSet colorForKey:@"channelListFGNoActivityColor"];
}

+ (NSColor*)channelListForegroundActionColor
{
  return [ColorSet colorForKey:@"channelListFGActionColor"];
}

+ (NSColor*)channelListForegroundPublicColor
{
  return [ColorSet colorForKey:@"channelListFGPublicMessageColor"];
}

+ (NSColor*)channelListForegroundPrivateColor
{
  return [ColorSet colorForKey:@"channelListFGPrivateMessageColor"];
}

// These are simply for ease-of-use, the ChannelController doesn't
// actually need to access these colours as an array, makes the code nicer
+ (NSColor*)nickListBackgroundColor
{
  return [ColorSet colorForKey:@"nickListBGColor"];
}

+ (NSColor*)nickListForegroundNormalColor
{
  return [ColorSet colorForKey:@"nickListFGNormalColor"];
}

+ (NSColor*)nickListForegroundVoiceColor
{
  return [ColorSet colorForKey:@"nickListFGVoiceColor"];
}

+ (NSColor*)nickListForegroundHalfOpColor
{
  return [ColorSet colorForKey:@"nickListFGHalfOpColor"];
}

+ (NSColor*)nickListForegroundOpColor
{
  return [ColorSet colorForKey:@"nickListFGOpColor"];
}

+ (NSColor*)nickListForegroundServerOpColor
{
  return [ColorSet colorForKey:@"nickListFGServerOpColor"];
}

+ (NSColor*)inputTextForegroundColor
{
  return [NSColor blackColor];
}

+ (NSColor*)inputTextBackgroundColor
{
  return [NSColor whiteColor];
}

@end
