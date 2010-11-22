//
//  SRHacks.h
//  ShortcutRecorder
//
//  Copyright 2006-2007 Contributors. All rights reserved.
//
//  License: BSD
//
//  Contributors:
//      David Dauer
//      Jesper
//      Jamie Kirkpatrick

#import "SRHacks.h"

NSString *SRFunctionKeyToString(NSInteger keyCode)
{
  unichar key;
  
  switch (keyCode)
  {
    case kSRKeysF1:
      key = NSF1FunctionKey;
      break;
    case kSRKeysF2:
      key = NSF2FunctionKey;
      break;
    case kSRKeysF3:
      key = NSF3FunctionKey;
      break;
    case kSRKeysF4:
      key = NSF4FunctionKey;
      break;
    case kSRKeysF5:
      key = NSF5FunctionKey;
      break;
    case kSRKeysF6:
      key = NSF6FunctionKey;
      break;
    case kSRKeysF7:
      key = NSF7FunctionKey;
      break;
    case kSRKeysF8:
      key = NSF8FunctionKey;
      break;
    case kSRKeysF9:
      key = NSF9FunctionKey;
      break;
    case kSRKeysF10:
      key = NSF10FunctionKey;
      break;
    case kSRKeysF11:
      key = NSF11FunctionKey;
      break;
    case kSRKeysF12:
      key = NSF12FunctionKey;
      break;
    case kSRKeysF13:
      key = NSF13FunctionKey;
      break;
    case kSRKeysF14:
      key = NSF14FunctionKey;
      break;
    case kSRKeysF15:
      key = NSF15FunctionKey;
      break;
    case kSRKeysF16:
      key = NSF16FunctionKey;
      break;
    case kSRKeysF17:
      key = NSF17FunctionKey;
      break;
    case kSRKeysF18:
      key = NSF18FunctionKey;
      break;
    case kSRKeysF19:
      key = NSF19FunctionKey;
      break;
    default:
      return nil;
  }
  
  return [NSString stringWithCharacters:&key length:1];
}