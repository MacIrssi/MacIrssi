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
*	MacIrssi - ColorSet.c
*	Nils Hjelte, c01nhe@cs.umu.se
*
*	Maintains all the colors used.
*/

#import "ColorSet.h"


@implementation ColorSet

- (NSMutableArray *)channelFGColors
{
	return channelFGColors;
}

- (NSMutableArray *)channelListFGColors
{
	return channelListFGColors;
}

- (NSMutableArray *)nickListFGColors
{
	return nickListFGColors;
}

- (NSColor *)channelFGDefaultColor
{
	return channelFGDefaultColor;
}

- (void)setChannelFGDefaultColor:(NSColor *)newColor
{
	[newColor retain];
	[channelFGDefaultColor release];
	channelFGDefaultColor = newColor;
}

- (NSColor *)channelBGColor
{
	return channelBGColor;
}

- (void)setChannelBGColor:(NSColor *)newColor
{
	[newColor retain];
	[channelBGColor release];
	channelBGColor = newColor;
}

- (NSColor *)channelListBGColor
{
	return channelListBGColor;
}

- (void)setChannelListBGColor:(NSColor *)newColor
{
	[newColor retain];
	[channelListBGColor release];
	channelListBGColor = newColor;
}

- (NSColor *)channelListFGColorOfLevel:(int)level
{
	return [channelListFGColors objectAtIndex:level];
}

- (void)setChannelListFGColorOfLevel:(int)level toColor:(NSColor *)newColor
{
	[channelListFGColors insertObject:newColor atIndex:level];
}

- (NSColor *)nickListBGColor
{
	return nickListBGColor;
}

- (void)setNickListBGColor:(NSColor *)newColor
{
	[newColor retain];
	[nickListBGColor release];
	nickListBGColor = newColor;
}

- (NSColor *)nickListFGColorOfStatus:(enum nickStatus)status
{
	return [nickListFGColors objectAtIndex:status];
}

- (void)setNickListFGColorOfStatus:(enum nickStatus)status toColor:(NSColor *)newColor
{
	[nickListFGColors insertObject:newColor atIndex:status];
}	

- (NSColor *)inputTextFieldFGColor
{
	return inputTextFieldFGColor;
}

- (void)setInputTextFieldFGColor:(NSColor *)newColor
{
	[newColor retain];
	[inputTextFieldFGColor release];
	inputTextFieldFGColor = newColor;
}	

- (NSColor *)inputTextFieldBGColor
{
	return inputTextFieldBGColor;
}

- (void)setInputTextFieldBGColor:(NSColor *)newColor
{
	[newColor retain];
	[inputTextFieldBGColor release];
	inputTextFieldBGColor = newColor;	
}

- (void)revertToDefaultColors
{
	/* Channel colors */
	[channelFGColors removeAllObjects];
	[channelFGColors addObject:[NSColor blackColor]];
	[channelFGColors addObject:[NSColor blueColor]];
	[channelFGColors addObject:[NSColor greenColor]];
	[channelFGColors addObject:[NSColor cyanColor]];
	[channelFGColors addObject:[NSColor redColor]];
	[channelFGColors addObject:[NSColor magentaColor]];
	[channelFGColors addObject:[NSColor orangeColor]];
	[channelFGColors addObject:[NSColor lightGrayColor]];
	[channelFGColors addObject:[NSColor grayColor]];
	[channelFGColors addObject:[NSColor blueColor]]; //light
	[channelFGColors addObject:[NSColor greenColor]]; //light
	[channelFGColors addObject:[NSColor cyanColor]]; //light
	[channelFGColors addObject:[NSColor redColor]]; //light
	[channelFGColors addObject:[NSColor magentaColor]]; //light
	[channelFGColors addObject:[NSColor yellowColor]];
	[channelFGColors addObject:[NSColor whiteColor]];
	channelFGDefaultColor = [[NSColor  colorWithCalibratedRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0] retain];
	//channelBGColor = [[NSColor  colorWithCalibratedRed:41.0/255 green:41.0/255 blue:41.0/255 alpha:1.0] retain];
	channelBGColor = [[NSColor  colorWithCalibratedRed:5.0/255 green:13.0/255 blue:25.0/255 alpha:0.92] retain];
	
	/* Channel list colors */
	[channelListFGColors removeAllObjects];
	[channelListFGColors addObject:[NSColor whiteColor]];
	[channelListFGColors addObject:[NSColor yellowColor]];
	[channelListFGColors addObject:[NSColor orangeColor]];
	[channelListFGColors addObject:[NSColor redColor]];
	channelListBGColor = [[NSColor  colorWithCalibratedRed:103.0/255 green:103.0/255 blue:103.0/255 alpha:0.82] retain];

	/* Nick list colors */
	[nickListFGColors removeAllObjects];
	[nickListFGColors addObject:[NSColor  colorWithCalibratedRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0]];
	[nickListFGColors addObject:[NSColor yellowColor]];
	[nickListFGColors addObject:[NSColor cyanColor]];
	[nickListFGColors addObject:[NSColor orangeColor]];
	[nickListFGColors addObject:[NSColor redColor]];
	nickListBGColor = [[NSColor  colorWithCalibratedRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:0.82] retain];

	/* Input text field colors */
	inputTextFieldFGColor = [[NSColor blackColor] retain];
	inputTextFieldBGColor = [[NSColor whiteColor] retain];	
}

- (void)registerColorDefaults:(BOOL)revert
{
	NSData *colorAsData;
	NSColor *color;
	id defaultValues = revert ? [NSUserDefaults standardUserDefaults] : [NSMutableDictionary dictionary];

	color = channelFGDefaultColor;
	colorAsData = [NSArchiver archivedDataWithRootObject:color];
	[defaultValues setObject:colorAsData forKey:@"channelFGDefaultColor"];

	color = channelBGColor;
	colorAsData = [NSArchiver archivedDataWithRootObject:color];
	[defaultValues setObject:colorAsData forKey:@"channelBGColor"];

	color = channelListBGColor;
	colorAsData = [NSArchiver archivedDataWithRootObject:color];
	[defaultValues setObject:colorAsData forKey:@"channelListBGColor"];

	color = [channelListFGColors objectAtIndex:0];
	colorAsData = [NSArchiver archivedDataWithRootObject:color];
	[defaultValues setObject:colorAsData forKey:@"channelListFGNoActivityColor"];

	color = [channelListFGColors objectAtIndex:1];
	colorAsData = [NSArchiver archivedDataWithRootObject:color];
	[defaultValues setObject:colorAsData forKey:@"channelListFGActionColor"];

	color = [channelListFGColors objectAtIndex:2];
	colorAsData = [NSArchiver archivedDataWithRootObject:color];
	[defaultValues setObject:colorAsData forKey:@"channelListFGPublicMessageColor"];

	color = [channelListFGColors objectAtIndex:3];
	colorAsData = [NSArchiver archivedDataWithRootObject:color];
	[defaultValues setObject:colorAsData forKey:@"channelListFGPrivateMessageColor"];

	color = nickListBGColor;
	colorAsData = [NSArchiver archivedDataWithRootObject:color];
	[defaultValues setObject:colorAsData forKey:@"nickListBGColor"];

	color = [nickListFGColors objectAtIndex:normalStatus];
	colorAsData = [NSArchiver archivedDataWithRootObject:color];
	[defaultValues setObject:colorAsData forKey:@"nickListFGNormalColor"];

	color = [nickListFGColors objectAtIndex:voiceStatus];
	colorAsData = [NSArchiver archivedDataWithRootObject:color];
	[defaultValues setObject:colorAsData forKey:@"nickListFGVoiceColor"];

	color = [nickListFGColors objectAtIndex:halfOpStatus];
	colorAsData = [NSArchiver archivedDataWithRootObject:color];
	[defaultValues setObject:colorAsData forKey:@"nickListFGHalfOpColor"];

	color = [nickListFGColors objectAtIndex:opStatus];
	colorAsData = [NSArchiver archivedDataWithRootObject:color];
	[defaultValues setObject:colorAsData forKey:@"nickListFGOpColor"];

	color = [nickListFGColors objectAtIndex:serverOpStatus];
	colorAsData = [NSArchiver archivedDataWithRootObject:color];
	[defaultValues setObject:colorAsData forKey:@"nickListFGServerOpColor"];

	color = inputTextFieldFGColor;
	colorAsData = [NSArchiver archivedDataWithRootObject:color];
	[defaultValues setObject:colorAsData forKey:@"inputTextFieldFGColor"];

	color = inputTextFieldBGColor;
	colorAsData = [NSArchiver archivedDataWithRootObject:color];
	[defaultValues setObject:colorAsData forKey:@"inputTextFieldBGColor"];

	if (!revert)
		[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];	
}

- (id)init
{
	NSData *colorAsData;
	[super init];
	
	channelListFGColors = [[NSMutableArray alloc] init];
	nickListFGColors = [[NSMutableArray alloc] init];
	channelFGColors = [[NSMutableArray alloc] initWithCapacity:20];
	[self revertToDefaultColors];
	[self registerColorDefaults:FALSE];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	colorAsData = [defaults objectForKey:@"channelFGDefaultColor"];
	channelFGDefaultColor = [[NSUnarchiver unarchiveObjectWithData:colorAsData] retain];
	
	colorAsData = [defaults objectForKey:@"channelBGColor"];
	channelBGColor = [[NSUnarchiver unarchiveObjectWithData:colorAsData] retain];

	colorAsData = [defaults objectForKey:@"channelListBGColor"];
	channelListBGColor = [[NSUnarchiver unarchiveObjectWithData:colorAsData] retain];

	colorAsData = [defaults objectForKey:@"channelListFGNoActivityColor"];
	[channelListFGColors addObject:[NSUnarchiver unarchiveObjectWithData:colorAsData]];

	colorAsData = [defaults objectForKey:@"channelListFGActionColor"];
	[channelListFGColors addObject:[NSUnarchiver unarchiveObjectWithData:colorAsData]];

	colorAsData = [defaults objectForKey:@"channelListFGPublicMessageColor"];
	[channelListFGColors addObject:[NSUnarchiver unarchiveObjectWithData:colorAsData]];

	colorAsData = [defaults objectForKey:@"channelListFGPrivateMessageColor"];
	[channelListFGColors addObject:[NSUnarchiver unarchiveObjectWithData:colorAsData]];

	colorAsData = [defaults objectForKey:@"nickListBGColor"];
	nickListBGColor = [[NSUnarchiver unarchiveObjectWithData:colorAsData] retain];

	colorAsData = [defaults objectForKey:@"nickListFGNormalColor"];
	[nickListFGColors addObject:[NSUnarchiver unarchiveObjectWithData:colorAsData]];

	colorAsData = [defaults objectForKey:@"nickListFGVoiceColor"];
	[nickListFGColors addObject:[NSUnarchiver unarchiveObjectWithData:colorAsData]];

	colorAsData = [defaults objectForKey:@"nickListFGHalfOpColor"];
	[nickListFGColors addObject:[NSUnarchiver unarchiveObjectWithData:colorAsData]];

	colorAsData = [defaults objectForKey:@"nickListFGOpColor"];
	[nickListFGColors addObject:[NSUnarchiver unarchiveObjectWithData:colorAsData]];

	colorAsData = [defaults objectForKey:@"nickListFGServerOpColor"];
	[nickListFGColors addObject:[NSUnarchiver unarchiveObjectWithData:colorAsData]];

	colorAsData = [defaults objectForKey:@"inputTextFieldFGColor"];
	inputTextFieldFGColor = [[NSUnarchiver unarchiveObjectWithData:colorAsData] retain];

	colorAsData = [defaults objectForKey:@"inputTextFieldBGColor"];
	inputTextFieldBGColor = [[NSUnarchiver unarchiveObjectWithData:colorAsData] retain];

	return self;
}

- (void)dealloc
{
	/* Channel colors */
	[channelFGDefaultColor release];
	[channelBGColor release];
	[channelFGColors release];

	/* Channel list colors */
	[channelListBGColor release];
	[channelListFGColors release];

	/* Nick list colors */
	[nickListBGColor release];
	[nickListFGColors release];


	/* Input text field colors */
	[inputTextFieldFGColor release];
	[inputTextFieldBGColor release];

	[super dealloc];
}

@end
