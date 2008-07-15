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
*	MacIrssi - CustomWindow.h
*	Nils Hjelte, c01nhe@cs.umu.se
*
*	Redirects all keyboard events to input text field.
*/

#import <Cocoa/Cocoa.h>
#import "AppController.h"

@interface CustomWindow : NSWindow
{
	IBOutlet NSTextField *inputTextField;
	IBOutlet NSSearchField *searchField;
	IBOutlet AppController *controller;
	NSTextView *currentChannelTextView;
	NSRange endRange;
	BOOL interceptKeys;
}

- (void)setCurrentChannelTextView:(NSTextView *)ref;
- (void)sendEvent:(NSEvent *)theEvent;
- (bool)handleSpecialKey:(unichar)uchar withModifierFlags:(unsigned int)flags;
- (IBAction)changeServer:(id)sender;
- (SERVER_REC *)getNextServer:(SERVER_REC *)current;
- (void)makeInputTextFieldFirstResponder;
- (void)paste:(id)sender;


@end
