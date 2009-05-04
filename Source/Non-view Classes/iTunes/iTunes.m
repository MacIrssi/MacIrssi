/*
 iTunes.m
 Copyright (c) 2008, 2009 Matt Wright.
 
 MacIrssi is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "iTunes.h"


@implementation iTunes

- (id)init
{
  if (self = [super init])
  {
    iTunesGlue = [[ITApplication alloc] initWithBundleID:@"com.apple.iTunes"];
  }
  return self;
}

- (void)dealloc
{
  [iTunesGlue release];
  [super dealloc];
}

- (BOOL)isRunning
{
  return [iTunesGlue isRunning];
}

- (BOOL)isPlaying
{
  return [[[[iTunesGlue playerState] get] send] isEqualTo:[ITConstant playing]];
}

- (NSString*)currentTitle
{
  return [[[[iTunesGlue currentTrack] name] get] send];
}

- (NSString*)currentArtist
{
  return [[[[iTunesGlue currentTrack] artist] get] send];
}

- (NSString*)currentAlbum
{
  return [[[[iTunesGlue currentTrack] album] get] send];
}

@end
