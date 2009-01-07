//
//  TextEncodings.m
//  MacIrssi
//
//  Created by Matt Wright on 05/01/2009.
//  Copyright 2009 Matt Wright Consulting. All rights reserved.
//

#import "TextEncodings.h"

#import "IrssiBridge.h"
#import "settings.h"
#import "common.h"

@implementation MITextEncoding

+ (NSArray*)encodings
{
  return [NSArray arrayWithObjects:
          [MITextEncoding textEncodingWithEncoding:kCFStringEncodingUnicode],
          [MITextEncoding textEncodingWithEncoding:kCFStringEncodingUTF8],
          [MITextEncoding textEncodingWithEncoding:kCFStringEncodingMacRoman],
          [MITextEncoding textEncodingWithEncoding:kCFStringEncodingMacJapanese],
          [MITextEncoding textEncodingWithEncoding:kCFStringEncodingMacChineseTrad],
          [MITextEncoding textEncodingWithEncoding:kCFStringEncodingMacKorean],
          [MITextEncoding textEncodingWithEncoding:kCFStringEncodingMacArabic],
          [MITextEncoding textEncodingWithEncoding:kCFStringEncodingMacHebrew],
          [MITextEncoding textEncodingWithEncoding:kCFStringEncodingMacGreek],
          [MITextEncoding textEncodingWithEncoding:kCFStringEncodingMacCyrillic],
          [MITextEncoding textEncodingWithEncoding:kCFStringEncodingMacChineseSimp],
          [MITextEncoding textEncodingWithEncoding:kCFStringEncodingMacCentralEurRoman],
          [MITextEncoding textEncodingWithEncoding:kCFStringEncodingMacTurkish],
          [MITextEncoding textEncodingWithEncoding:kCFStringEncodingMacIcelandic],
          [MITextEncoding textEncodingWithEncoding:kCFStringEncodingISOLatin1],
          [MITextEncoding textEncodingWithEncoding:kCFStringEncodingISOLatin2],
          [MITextEncoding textEncodingWithEncoding:kCFStringEncodingISOLatin3],
          [MITextEncoding textEncodingWithEncoding:kCFStringEncodingISOLatin4],
          [MITextEncoding textEncodingWithEncoding:kCFStringEncodingISOLatinCyrillic],
          [MITextEncoding textEncodingWithEncoding:kCFStringEncodingISOLatinGreek],
          [MITextEncoding textEncodingWithEncoding:kCFStringEncodingISOLatin5],
          [MITextEncoding textEncodingWithEncoding:kCFStringEncodingDOSLatinUS],
          [MITextEncoding textEncodingWithEncoding:kCFStringEncodingWindowsLatin1],
          [MITextEncoding textEncodingWithEncoding:kCFStringEncodingWindowsLatin2],
          [MITextEncoding textEncodingWithEncoding:kCFStringEncodingEUC_JP],
          [MITextEncoding textEncodingWithEncoding:kCFStringEncodingISO_2022_JP],
          [MITextEncoding textEncodingWithEncoding:kCFStringEncodingShiftJIS],
          [MITextEncoding textEncodingWithEncoding:kCFStringEncodingNextStepLatin],
          [MITextEncoding textEncodingWithEncoding:kCFStringEncodingNonLossyASCII],
          [MITextEncoding textEncodingWithEncoding:kCFStringEncodingASCII],
          nil];
}

+ (MITextEncoding*)textEncodingWithEncoding:(NSStringEncoding)encoding
{
  return [[[MITextEncoding alloc] initWithEncoding:encoding] autorelease];
}


+ (MITextEncoding*)irssiEncoding;
{
  return [[[MITextEncoding alloc] initWithIANAString:[NSString stringWithCString:settings_get_str("term_charset") encoding:NSASCIIStringEncoding]] autorelease];
}

+ (void)setIrssiEncoding:(MITextEncoding*)enc;
{
  char *irssiCString = [IrssiBridge irssiCStringWithString:[[enc IANAString] lowercaseString]];
  if (strcmp(irssiCString, settings_get_str("term_charset")) != 0)
  {
    settings_set_str("term_charset", irssiCString);
    signal_emit("setup changed", 0);
  }
}
          
- (id)initWithEncoding:(NSStringEncoding)encoding
{
  if (self = [super init])
  {
    enc = encoding;
  }
  return self;
}

- (id)initWithIANAString:(NSString*)string
{
  if (self = [super init])
  {
    enc = (NSStringEncoding)CFStringConvertIANACharSetNameToEncoding((CFStringRef)string);
  }
  return self;
}

- (NSStringEncoding)encoding
{
  return enc;
}

- (NSString*)IANAString
{
  return (NSString*)CFStringConvertEncodingToIANACharSetName((CFStringEncoding)enc);
}

- (NSString*)description
{
  return (NSString*)CFStringGetNameOfEncoding((CFStringEncoding)enc);
}

@end
