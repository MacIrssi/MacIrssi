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

static NSUserDefaults *standardDefaults;

@implementation Defaults

+ (void)initialize {
    standardDefaults = [NSUserDefaults standardUserDefaults];
}

+ (void)registerDefaults {
  [standardDefaults registerDefaults:@{
                                       @"ChatView.padding.horizontal": @2,
                                       @"ChatView.padding.vertical": @5
                                       }];
}



#pragma mark Default getters

+ (NSInteger)integerForKey:(NSString *)defaultName {
    return [standardDefaults integerForKey:defaultName];
}

+ (BOOL)boolForKey:(NSString *)defaultName {
    return [standardDefaults boolForKey:defaultName];
}



#pragma mark Default setters

+ (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName {
    [standardDefaults setInteger:value forKey:defaultName];
}


@end
