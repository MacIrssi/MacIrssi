//
//  iTunes.h
//  MacIrssi
//
//  Created by Matt Wright on 06/01/2009.
//  Copyright 2009 Matt Wright Consulting. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ITGlue.h"

@interface iTunes : NSObject {
  ITApplication *iTunesGlue;
}

- (id)init;
- (void)dealloc;

- (BOOL)isRunning;
- (BOOL)isPlaying;

- (NSString*)currentTitle;
- (NSString*)currentArtist;
- (NSString*)currentAlbum;

@end
