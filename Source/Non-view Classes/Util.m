//
//  Util.m
//  MacIrssi
//
//  Dakota Schneider (dakota@codefromabove.com) 10/6/14.
//
//

#import "Defaults.h"

void playSoundNamed (NSString* soundName)
{
  NSSound *sound = [NSSound soundNamed:soundName];
  if (!sound)
  {
    NSString *soundPath = [[NSBundle mainBundle] resourcePath];
    soundPath = [soundPath stringByAppendingPathComponent:@"Sounds"];
    soundPath = [soundPath stringByAppendingPathComponent:soundName];
    soundPath = [soundPath stringByAppendingPathExtension:@"aiff"];
    sound = [[[NSSound alloc] initWithContentsOfFile:soundPath byReference:YES] autorelease];
  }
  [sound setVolume:[Defaults floatForKey:@"Notifications.playSound.volume"]];
  // Pew pew
  [sound play];
}