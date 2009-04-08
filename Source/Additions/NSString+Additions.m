//
//  NSString+Additions.m
//  MacIrssi
//
//  Created by Matt Wright on 08/04/2009.
//  Copyright 2009 Matt Wright Consulting. All rights reserved.
//

#import "NSString+Additions.h"


@implementation NSString (Additions)

+ (NSString*)stringWithUnicodeCharacter:(unichar)character
{
  return [NSString stringWithCharacters:&character length:sizeof(unichar)];
}

@end
