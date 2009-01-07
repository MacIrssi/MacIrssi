//
//  iTunes.m
//  MacIrssi
//
//  Created by Matt Wright on 06/01/2009.
//  Copyright 2009 Matt Wright Consulting. All rights reserved.
//

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
