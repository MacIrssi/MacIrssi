//
//  UTURLRegex.m
//  MacIrssi
//
//  Created by Matt Wright on 29/08/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "UTURLRegex.h"
#import "NSString+Additions.h"

@implementation UTURLRegex

- (void)testURLRegex
{
  STAssertTrue([[@"http://foo.com.uk/tart is a moo lion (www.sysctl.co.uk/lion#anchor) and we'll have something with brackets in url and one in both (gopher://www.url.co.uk/fart_(foo))" arrayOfURLsDetectedInString] count] == 4,
               @"testURLRegex step 1 did not return 4 urls");
}

@end
