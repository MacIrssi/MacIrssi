//
//  TextEncodings.h
//  MacIrssi
//
//  Created by Matt Wright on 05/01/2009.
//  Copyright 2009 Matt Wright Consulting. All rights reserved.
//

@interface MITextEncoding : NSObject
{
  NSStringEncoding enc;
}

+ (NSArray*)encodings;
+ (MITextEncoding*)textEncodingWithEncoding:(NSStringEncoding)encoding;

+ (MITextEncoding*)irssiEncoding;
+ (void)setIrssiEncoding:(MITextEncoding*)enc;

- (id)initWithEncoding:(NSStringEncoding)encoding;
- (id)initWithIANAString:(NSString*)string;

- (NSStringEncoding)encoding;
- (NSString*)IANAString;

@end
