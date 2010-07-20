/*
 TextEncodings.h
 Copyright (c) 2009 Matt Wright.
 
 MacIrssi is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 2 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#define MICurrentTextEncoding ([[MITextEncoding irssiEncoding] encoding])

@interface MITextEncoding : NSObject
{
  CFStringEncoding enc;
}

+ (NSArray*)encodings;
+ (MITextEncoding*)textEncodingWithEncoding:(NSStringEncoding)encoding;

+ (MITextEncoding*)irssiEncoding;
+ (void)setIrssiEncoding:(MITextEncoding*)enc;

- (id)initWithEncoding:(NSStringEncoding)encoding;
- (id)initWithCFStringEncoding:(CFStringEncoding)encoding;
- (id)initWithIANAString:(NSString*)string;

- (CFStringEncoding)CFStringEncoding;
- (NSStringEncoding)encoding;
- (NSString*)IANAString;
- (NSString*)name;

@end
