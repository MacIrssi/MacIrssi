/*
 PreferenceVersionHelper.h
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

#import "PreferenceVersionHelper.h"

#define CURRENT_PREFERENCES_VERSION 1
#define CURRENT_VERSION() ([[NSUserDefaults standardUserDefaults] integerForKey:@"preferencesVersion"])

@interface PreferenceVersionHelper ()

+ (BOOL)checkAndBailIfNewer;
+ (void)lookForOldPreferencesAndMigrate;

@end


@implementation PreferenceVersionHelper

+ (void)checkVersionAndUpgrade
{
  /* Deal with versioning of preferences and their upgrades between versions. */
  
  if (![PreferenceVersionHelper checkAndBailIfNewer])
  {
    return;
  }
  
  if (CURRENT_VERSION() == 0)
  {
    [PreferenceVersionHelper lookForOldPreferencesAndMigrate];
  }
  
  /* And finally, set the preferences version to the current. */
  [[NSUserDefaults standardUserDefaults] setInteger:CURRENT_PREFERENCES_VERSION forKey:@"preferencesVersion"];
}

+ (BOOL)checkAndBailIfNewer
{
  int version = [[NSUserDefaults standardUserDefaults] integerForKey:@"preferencesVersion"];
  
  if (version > CURRENT_PREFERENCES_VERSION) {
    
    return NO;
  }
  return YES;
}

+ (void)lookForOldPreferencesAndMigrate
{
  /* After commit 1ea9ba4 MacIrssi changed bundle identifier, so we need to look for the old
     preferences file (MacIrssi.plist) and copy in the preferences. It's assumed you don't have
     current preferences if you hit this migration. */
  
  NSDictionary *oldSettings = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"MacIrssi"];
  if (oldSettings)
  {
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:oldSettings forName:[[NSBundle mainBundle] bundleIdentifier]];
  }
}

@end
