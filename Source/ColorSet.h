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
	NSMutableArray *channelFGColors;
	NSColor *channelBGColor;

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

- (NSMutableArray *)channelFGColors;
- (NSMutableArray *)channelListFGColors;
- (NSMutableArray *)nickListFGColors;

- (NSColor *)channelFGDefaultColor;
- (void)setChannelFGDefaultColor:(NSColor *)newColor;

- (NSColor *)channelBGColor;
- (void)setChannelBGColor:(NSColor *)newColor;

- (NSColor *)channelListBGColor;
- (void)setChannelListBGColor:(NSColor *)newColor;

- (NSColor *)channelListFGColorOfLevel:(int)level;
- (void)setChannelListFGColorOfLevel:(int)level toColor:(NSColor *)newColor;

- (NSColor *)nickListBGColor;
- (void)setNickListBGColor:(NSColor *)newColor;

- (NSColor *)nickListFGColorOfStatus:(enum nickStatus)status;
- (void)setNickListFGColorOfStatus:(enum nickStatus)status toColor:(NSColor *)newColor;

- (NSColor *)inputTextFieldFGColor;
- (void)setInputTextFieldFGColor:(NSColor *)newColor;

- (NSColor *)inputTextFieldBGColor;
- (void)setInputTextFieldBGColor:(NSColor *)newColor;

- (void)revertToDefaultColors;
- (void)registerColorDefaults:(BOOL)revert;
- (id)init;
- (void)dealloc;

@end
