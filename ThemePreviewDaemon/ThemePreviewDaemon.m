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
 */


#import "ThemePreviewDaemon.h"
#import "NSAttributedStringAdditions.h"
#import "irssi.h"
#import "formats.h"
#import "signals.h"

#define FAKE_IRC_SERVER_PORT 9753

BOOL tpd_quitting;

@implementation ThemePreviewDaemon

/**
 * Starts the deamon
 */
- (void)runIrssiMainLoop:(id)loop
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//[NSThread setThreadPriority:0.1];
	main_loop = [loop pointerValue];
	[self connectToMacIrssi];	
	[pool release];

	tpd_quitting = FALSE;
	while (!tpd_quitting) {
		pool = [[NSAutoreleasePool alloc] init];
		@try {
			g_main_iteration(TRUE);
		}
		@catch (NSException *e) {
			NSLog(@"Exception in irssi loop: %@", e);
		}
		[pool release];
	}
	
	[NSThread exit];
}

#pragma mark Private methods
/**
 * Launches the fake IRC Server on an availible port.
 */
- (void)launchFakeIRCServer
{
	textServerTask = [[NSTask alloc] init];
	NSString *serverDir = @"Fake IRC Server";
	//NSString *serverDir = @"MacIrssi.app/Contents/ThemePreviewDaemon/Fake IRC Server";
	NSString *base = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], serverDir];
	serverPort = [self findAvailiblePort];
	NSString *port = [[NSNumber numberWithInt:serverPort] stringValue];
	NSString *textFile = @"serverlog";
	
	[textServerTask setCurrentDirectoryPath:base];
	[textServerTask setLaunchPath:[base stringByAppendingString:@"/textserver"]];
	[textServerTask setArguments:[NSArray arrayWithObjects:port, textFile, nil]];
	[textServerTask launch];
}

/**
 * Connects to MacIrssi
 */
- (void)connectToMacIrssi
{
	/* Then notify MacIrssi that we are ready */
	prefController = [NSConnection rootProxyForConnectionWithRegisteredName:@"MacIrssi" host:nil];
	
	if (!prefController) {
		NSLog(@"Unable to connect to MacIrssi!");
		return;
	}
	
	[prefController retain];
	[prefController setProtocolForProxy:@protocol(ThemePreviewClientProtocol)];
	[prefController daemonInitiationComplete];
}

/**
 * Registers as a distributed object.
 */
- (void)registerDistributedObject
{
	NSConnection *connection = [NSConnection defaultConnection];
	[connection setRootObject:self];
	
	if (![connection registerName:@"ThemePreviewDaemon"])
		NSLog(@"Unable to register name!");
	
	[connection retain];
	[connection setDelegate:self];	
}

/**
 * Finds an availible TCP port.
 */
- (int)findAvailiblePort
{
	//TODO: dynamic checking
	return FAKE_IRC_SERVER_PORT;
}

#pragma mark Distributed methods

/**
 * Creates an attributed string used as a preview for a irssi theme.
 * @param theme The name of the theme (filename exluding the .theme suffix)
 */
- (void)requestPreviewForThemeNamed:(in NSString *)theme usingColorSet:(in ColorSet *)colors font:(NSFont *)font;
{	
	/* Reset preview */
	[themePreview release];
	themePreview = [[NSMutableAttributedString alloc] init];
	currentLineNumber = 0;
	
	/* Set colors and font */
	[fg_colors release];
	[defaultTextColor release];
	fg_colors = [[colors channelFGColors] retain];
	defaultTextColor = [[colors channelFGDefaultColor] retain];
	[textAttributes setObject:font forKey:NSFontAttributeName];

	/* Load the theme */
	char command[12 + [theme length]];
	sprintf(command, "/set theme %s", [theme lossyCString]);
	signal_emit("send command", 3, command, windowRec->active_server, windowRec->active);

	/* Connect to fake IRC server */
	NSString *connectString = [NSString stringWithFormat:@"/server localhost %d", serverPort];
	signal_emit("send command", 3, [connectString lossyCString], windowRec->active_server, windowRec->active);
}

/**
 * Shuts down the deamon and fake IRC server and releases all resources
 */
- (void)shutDown
{
	[textServerTask terminate];
	[textServerTask release];
	signal_emit("command quit", 1, "ThemePreviewDaemon quitting!");
}

#pragma mark Indirect receivers of irssi signals
- (void)irssiTerminationComplete
{
	NSLog(@"terminating...");
	tpd_quitting = TRUE;
}

- (void)setWindowRec:(WINDOW_REC *)rec
{
	windowRec = rec;
}

- (void)serverConnected:(SERVER_REC *)server
{
}

- (void)serverDisconnected:(SERVER_REC *)server
{
	/* EOF from fake IRC server -> Return result to MacIrssi */
	[themePreview detectURLs:[NSColor yellowColor]];
	
	@try {
		[prefController returnPreview:themePreview];
	}
	@catch (NSException *e) {
		NSLog(@"Unable to return preview!");
	}
}

/* From gui-printtext.c */
int mirc_colors[] = { 15, 0, 1, 2, 12, 4, 5, 6, 14, 10, 3, 11, 9, 13, 8, 7 };

//-------------------------------------------------------------------
// printText:forground:background:flags:
// Adds a text section to the linebuffer. Called for each new
// text-color-section. Currenlty ignores flags <-- FIX =)
//
// "text" - The text to print
// "fg" - The foreground color
// "bg" - The background color
// "flags" - Flags
//-------------------------------------------------------------------
- (void)printText:(char *)text forground:(int)fg background:(int)bg flags:(int)flags
{
	if (!themePreview)
		return;
	
	NSString *decodedString = (NSString *)CFStringCreateWithCStringNoCopy(NULL, text, kCFStringEncodingISOLatin1, kCFAllocatorNull);
	
	if (decodedString == NULL) {
		NSLog(@"[ThemePreviewDaemon printText] decodedString is NULL.");
		return; //TODO: handle?
	}
	
	/* Handle colors */
	if (flags & GUI_PRINT_FLAG_MIRC_COLOR) {
		/* mirc colors - real range is 0..15, but after 16
		colors wrap to 0, 1, ... */
		if (bg >= 0) bg = mirc_colors[bg % 16];
		if (fg >= 0) fg = mirc_colors[fg % 16];
	}
	
	
	if (fg < 0 || fg > 15)
		[textAttributes setObject:defaultTextColor forKey:NSForegroundColorAttributeName];
	else
		[textAttributes setObject:[fg_colors objectAtIndex:fg] forKey:NSForegroundColorAttributeName];
	
#if 0
	//TODO
	if (bg < 0 || bg > 15)
		[textAttributes removeObjectForKey:NSBackgroundColorAttributeName];
	else
		[textAttributes setObject:bg_colors[bg] forKey:NSBackgroundColorAttributeName];
#endif
	
	/* Handle flags */ //TODO
	if (flags & GUI_PRINT_FLAG_REVERSE) {
	}
	if (flags & GUI_PRINT_FLAG_BOLD) {
	}
	if (flags & GUI_PRINT_FLAG_UNDERLINE) {
	}
	if (flags & GUI_PRINT_FLAG_BLINK) {
		/* Ignore */
	} 
	if (flags & GUI_PRINT_FLAG_NEWLINE) {
		NSLog(@"GUI_PRINT_FLAG_NEWLINE for text \'%@\'", decodedString);
		[themePreview appendAttributedString:[[[NSMutableAttributedString alloc] initWithString:@"\n"] autorelease]];
	}
	if (flags & GUI_PRINT_FLAG_INDENT_FUNC) {
		NSLog(@"GUI_PRINT_FLAG_INDENT_FUNC for text \'%@\'", decodedString);
	}
	if (flags & GUI_PRINT_FLAG_INDENT) {
		//NSLog(@"GUI_PRINT_FLAG_INDENT for text \'%@\'", decodedString);
	}
	if (flags & GUI_PRINT_FLAG_CLRTOEOL) {
		NSLog(@"GUI_PRINT_FLAG_CLRTOEOL for text \'%@\'", decodedString);
	}
	
	NSAttributedString *tmp = [[NSAttributedString alloc] initWithString:decodedString attributes:textAttributes];
	[themePreview appendAttributedString:tmp];
	[decodedString release];
	[tmp release];
}

/**
 * EOL signal from irssi.
 */
- (void)finishLine
{	
	if (!themePreview)
		return;

	/* Remove first 7 lines, they inform of the theme change and the connection to
	localhost */
	if (++currentLineNumber < 7) {
		[themePreview release];
		themePreview = [[NSMutableAttributedString alloc] init];
		return;
	}
		
	[themePreview appendAttributedString:newLine];
}

/**
 * Connection with MacIrssi died. Shut down daemon.
 */
- (void)connectionDidDie:(NSNotification *)notification
{
	NSLog(@"Connection with MacIrssi lost!");
	[self shutDown];
}

#pragma mark init/dealloc

- (void)dealloc
{
	g_main_destroy(main_loop);
	[newLine release];
	[themePreview release];
	[textAttributes release];
	[super dealloc];
}

- (id)init
{
	NSLog(@"initializing...");
		
	if (![super init])
		return nil;
	
	newLine = [[NSAttributedString alloc] initWithString:@"\n"];
	themePreview = nil;
	textAttributes = [[NSMutableDictionary alloc] init];

	[self launchFakeIRCServer];
	[self registerDistributedObject];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionDidDie:) name:@"NSConnectionDidDieNotification" object:nil];

	return self;
}

@end
