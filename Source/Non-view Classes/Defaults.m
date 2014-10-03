/*
 * Copyright (c) 2014 Lucas Jenß
 *
 * MacIrssi is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <Foundation/NSUserDefaults.h>
#import "Defaults.h"

@implementation Defaults

+ (void)registerDefaults {
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults registerDefaults:@{
                                         @"ChatView.padding.horizontal": @2,
                                         @"ChatView.padding.vertical": @5,
                                         @"Notifications.playSound.volume": @1.00
                                         }];
}

+ (NSInteger)integerForKey:(NSString *)defaultName {
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    return [standardDefaults integerForKey:defaultName];
}

+ (float)floatForKey:(NSString *)defaultName {
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    return [standardDefaults floatForKey:defaultName];
}


+ (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName {
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults setInteger:value forKey:defaultName];
}

+ (BOOL)boolForKey:(NSString *)defaultName {
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    return [standardDefaults boolForKey:defaultName];
}


@end
