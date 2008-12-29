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
*	MacIrssi - ColorSet.h
*	Nils Hjelte, c01nhe@cs.umu.se
*
*	Maintains all the colors used.
*/

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

enum nickStatus {
	normalStatus,
	voiceStatus,
	halfOpStatus,
	opStatus,
	serverOpStatus
};
	
@interface ColorSet : NSObject {
	/* Channel colors */
	NSColor *channelFGDefaultColor;
	NSColor *channelBGColor;
  NSColor *channelLinkColor;

	/* Channel list colors */
	NSMutableArray *channelListFGColors;
	NSColor *channelListBGColor;

	/* Nick list colors */
	NSMutableArray *nickListFGColors;
	NSColor *nickListBGColor;

	/* Input text field colors */
	NSColor *inputTextFieldFGColor;
	NSColor *inputTextFieldBGColor;
}

+ (NSArray*)mircColours;

+ (void)registerDefaults;
+ (void)revertToDefaults;

+ (NSArray*)channelListForegroundKeys;
+ (NSArray*)nickListForegroundKeys;

+ (NSColor*)colorForKey:(NSString*)key;
+ (void)setColor:(NSColor*)color forKey:(NSString*)key;

#pragma mark Common Colour Accessors

+ (NSColor*)channelForegroundColor;
+ (NSColor*)channelBackgroundColor;
+ (NSColor*)channelLinkColour;

+ (NSColor*)channelListBackgroundColor;
+ (NSColor*)channelListForegroundNoActivityColor;
+ (NSColor*)channelListForegroundActionColor;
+ (NSColor*)channelListForegroundPublicColor;
+ (NSColor*)channelListForegroundPrivateColor;

// These are simply for ease-of-use, the ChannelController doesn't
// actually need to access these colours as an array, makes the code nicer
+ (NSColor*)nickListBackgroundColor;
+ (NSColor*)nickListForegroundNormalColor;
+ (NSColor*)nickListForegroundVoiceColor;
+ (NSColor*)nickListForegroundHalfOpColor;
+ (NSColor*)nickListForegroundOpColor;
+ (NSColor*)nickListForegroundServerOpColor;

+ (NSColor*)inputTextForegroundColor;
+ (NSColor*)inputTextBackgroundColor;

@end
