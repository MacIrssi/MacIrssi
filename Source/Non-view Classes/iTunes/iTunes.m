/*
 iTunes.m
 Copyright (c) 2008, 2009 Matt Wright.
 
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

#import "iTunes.h"


@implementation iTunes

- (id)init
{
  if (self = [super init])
  {
    iTunesBridge = [[SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"] retain];
  }
  return self;
}

- (void)dealloc
{
  [iTunesBridge release];
  [super dealloc];
}

- (BOOL)isRunning
{
  return [iTunesBridge isRunning];
}

- (BOOL)isPlaying
{
  return [iTunesBridge playerState] == iTunesEPlSPlaying;
}

- (NSString*)currentTitle
{
  return [[iTunesBridge currentTrack] name];
}

- (NSString*)currentArtist
{
  return [[iTunesBridge currentTrack] artist];
}

- (NSString*)currentAlbum
{
  return [[iTunesBridge currentTrack] album];
}

@end
