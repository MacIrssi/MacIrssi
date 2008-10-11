//
//  ServerBridgeController.m
//  MacIrssi
//
//  Created by Matt Wright on 11/10/2008.
//  Copyright 2008 Matt Wright Consulting. All rights reserved.
//

#import "ServerBridgeController.h"
#import "IrssiBridge.h"

@implementation ServerBridgeController

- (id)initWithServerSetupRec:(SERVER_SETUP_REC*)serverrec
{
  if (self = [super init])
  {
    rec = serverrec;
  }
  return self;
}

- (NSString*)address
{
  return [IrssiBridge stringWithIrssiCString:rec->address];
}

- (NSString*)chatnet
{
  return [IrssiBridge stringWithIrssiCString:rec->chatnet];
}

@end
