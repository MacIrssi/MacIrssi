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
*	MacIrssi - CustomTableView.h
*	Nils Hjelte, c01nhe@cs.umu.se
*
*	Custom table view to select items when right-clicked on.
*/

#import "CustomTableView.h"

@implementation CustomTableView

/***
*	Name: rightMouseDown
*	Purpose: Overrides method from NSResponder to recieve right-click events.
*			 When the user right-clicks in the table view the item clicked is
*			 selected and thereafter the context-menu is brought up.
*	Param: theEvent - The mouse event.
*	Return: -
*/
- (void)rightMouseDown:(NSEvent *)theEvent
{
	NSIndexSet *indexSet = [self selectedRowIndexes];
	int row = [self rowAtPoint:[self convertPoint: [theEvent locationInWindow] fromView: nil]];

	if (row == -1)
		return;

	if (![indexSet containsIndex:row])
		[self selectRow:row byExtendingSelection:FALSE];
	
	/* Continue with right-click to bring up context-menu */
	[super rightMouseDown:theEvent];
}
@end
