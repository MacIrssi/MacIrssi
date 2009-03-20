//
//  formatter.m
//  appscript
//
//   Copyright (C) 2007-2008 HAS
//


@interface AEMObjectRenderer : NSObject

+(NSString *)formatOSType:(OSType)code;

+(void)formatObject:(id)obj indent:(NSString *)indent result:(NSMutableString *)result;

+(NSString *)formatObject:(id)obj;

@end

