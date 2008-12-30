//
//  AppcastVersionComparator.h
//  MacIrssi
//
//  Created by Matt Wright on 14/10/2008.
//  Copyright 2008 Matt Wright Consulting. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Sparkle/Sparkle.h>

@interface AppcastVersionComparator : NSObject <SUVersionComparison> {
  
}

+ (AppcastVersionComparator*)defaultComparator;
- (NSComparisonResult)compareVersion:(NSString *)versionA toVersion:(NSString *)versionB;

@end