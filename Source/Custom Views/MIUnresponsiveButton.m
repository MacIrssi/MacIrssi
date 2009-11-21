//
//  MIUnresponsiveButton.m
//  MacIrssi
//
//  Created by Matt Wright on 21/11/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MIUnresponsiveButton.h"


@implementation MIUnresponsiveButton

- (NSView *)hitTest:(NSPoint)aPoint
{
  NSView *realHit = [super hitTest:aPoint];
  if ([realHit isEqual:self])
  {
    return [self superview];
  }
  return realHit;
}

@end
