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
*	MacIrssi - History.h
*	Nils Hjelte, c01nhe@cs.umu.se
*
*	A list of commands that can be iterated forward and backward.
*/

#import <Foundation/Foundation.h>

@interface History : NSObject {
	NSString **commands;
	int size;
	int maxSize;
	int back;
	int front; 
	int indexIterator;
	BOOL hasTemporaryCommand;
}

- (NSString *)previousCommand;
- (NSString *)nextCommand;
- (void)addCommand:(NSString *)command;
- (void)setTemporaryCommand:(NSString *)command;
- (id)initWithCapacity:(int)c;
- (void)dealloc;
- (BOOL)isEmpty;
- (BOOL)iteratorAtFront;

/* PRIVATE */
- (void)addCommand:(NSString *)command isTemporary:(BOOL)isTemp;
- (BOOL)indexIteratorIsValid;
- (NSString *)popCommand;
- (BOOL)pushCommand:(NSString *)command;
- (BOOL)hasTemporaryCommand;
- (void)setHasTemporaryCommand:(BOOL)flag;
- (void)resetIterator;

@end
