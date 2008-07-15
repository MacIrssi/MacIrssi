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

#import <Foundation/Foundation.h>
#import "ThemePreviewDaemon.h"
#import "IrssiBridge.h"
#import "irssi.h"

NSArray *getThemeLocations(void) {
	NSMutableArray *tmp = [[NSMutableArray alloc] init];
	if (get_irssi_dir()) {
		[tmp addObject:[NSString stringWithCString:get_irssi_dir()]];
		[tmp addObject:[NSString stringWithFormat:@"%s/%@", get_irssi_dir(), @"themes"]];
	}

	[tmp addObject:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], @"../Resources/Themes"]];
	return [tmp autorelease];
}

int main (int argc, const char * argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
 	ThemePreviewDaemon *daemon = [[ThemePreviewDaemon alloc] init];
	irssi_bridge_set_current_theme_preview_daemon(daemon);

	/* Must initialize irssi after irssi_bridge_set_current_theme_preview_daemon, otherwise
		we won't get a window created signal */
	char *irssi_argv[] = {"irssi", "--config=/tmp/irssi_dummy_config", "--noconnect", NULL};
	//char *argv[] = {"irssi", "--connect=localhost", "--port=9753", NULL};
	int irssi_argc = 3;
	
	irssi_main(irssi_argc, irssi_argv);	
	GMainLoop *main_loop = g_main_new(TRUE);
	
	/* Init theme dirs */
	const char *tmp;
	
	NSArray *dirs = getThemeLocations();
	num_theme_dirs = [dirs count];
	theme_dirs = (char **)malloc(num_theme_dirs * sizeof(char *));
	int i;
	for (i = 0; i < [dirs count]; i++) {
		tmp = [[dirs objectAtIndex:i] lossyCString];
		theme_dirs[i] = (char *)malloc(strlen(tmp)+1);
		strcpy(theme_dirs[i], tmp);
	}	
	
	[NSThread detachNewThreadSelector:@selector(runIrssiMainLoop:) toTarget:daemon withObject:[NSValue valueWithPointer:main_loop]];
	//[daemon requestPreviewForThemeNamed:@"lime" usingColorSet:nil andFont:nil];
	//[daemon runIrssiMainLoop:main_loop];
	[pool release];

	while (!tpd_quitting) {		
		pool = [[NSAutoreleasePool alloc] init];
		[[NSRunLoop currentRunLoop] runMode:NSConnectionReplyMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
		[pool release];
	}

    return 0;
}
