/*
 IrssiInternal.m
 Copyright (c) 2008, 2009, 2010 Matt Wright.
 
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

#include <signal.h>
#include <locale.h>
#include <dlfcn.h>

// We need visibility default here, nothing links to macirssi_find_module directly,
// because we load it using dlopen in the irssi code. So this forces the compiler/linker
// not to remove/unexport the symbol.
char* macirssi_find_module(char *module) __attribute__((visibility("default")));
char* macirssi_find_module(char *module)
{
	// I'm taking a leap of faith here that the /System/Library/Perl/lib directory contains
	// working versions and that if they're specified as major, minor and no third revision
	// then that means they're binary compatible across increments.

	// All of the perl dylibs we've built link against /S/L/P/l with the exception of the
	// Panther one, I think, which I'm going to exclude from the shipping binary anyway. So,
	// we can litmus test each library by dlopening it and seeing if it sticks.
	
	if (!strcmp(module, "perl_core") || !strcmp(module, "fe_perl"))
	{
		for (NSString *dylib in [[NSBundle mainBundle] pathsForResourcesOfType:@"dylib" inDirectory:@"Perl"])
		{
			// Check to see if this is a libmodule.foo.dylib
			if ([dylib length] < strlen(module)+3)
			{
				continue;
			}
			
			NSString *stem = [[dylib lastPathComponent] substringWithRange:NSMakeRange(3, strlen(module))];
			if (!strcmp([stem UTF8String], module))
			{
				void *handle = dlopen([dylib UTF8String], 0);
				if (handle)
				{
					// We've managed to load, rejoice!
					dlclose(handle);
					
					// We need to copy the C string version of the path out to a pointer
					// we can malloc and hand off back to the irssi core.
					char *ret = strdup([dylib UTF8String]);
					return ret;
				}
			}
		}		
	}
	
  return NULL;
}
