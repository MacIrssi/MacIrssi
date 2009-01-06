/*
 * ASDefaultCommandGlue.m
 *
 * <default terminology>
 * osaglue 0.4.0
 *
 */

#import "ASDefaultCommandGlue.h"

@implementation ASDefaultCommand
- (NSString *)AS_formatObject:(id)obj appData:(id)appData{
    return [ASDefaultReferenceRenderer formatObject: obj appData: appData];
}
@end

@implementation ASDefaultActivateCommand

- (NSString *)AS_commandName {
    return @"activate";
}

@end


@implementation ASDefaultGetCommand

- (NSString *)AS_commandName {
    return @"get";
}

@end


@implementation ASDefaultLaunchCommand

- (NSString *)AS_commandName {
    return @"launch";
}

@end


@implementation ASDefaultOpenCommand

- (NSString *)AS_commandName {
    return @"open";
}

@end


@implementation ASDefaultOpenLocationCommand

- (ASDefaultOpenLocationCommand *)window:(id)value {
    [AS_event setParameter: value forKeyword: 'WIND'];
    return self;
}

- (NSString *)AS_commandName {
    return @"openLocation";
}

- (NSString *)AS_parameterNameForCode:(DescType)code {
    switch (code) {
        case 'WIND':
            return @"window";
    }
    return [super AS_parameterNameForCode: code];
}

@end


@implementation ASDefaultPrintCommand

- (NSString *)AS_commandName {
    return @"print";
}

@end


@implementation ASDefaultQuitCommand

- (ASDefaultQuitCommand *)saving:(id)value {
    [AS_event setParameter: value forKeyword: 'savo'];
    return self;
}

- (NSString *)AS_commandName {
    return @"quit";
}

- (NSString *)AS_parameterNameForCode:(DescType)code {
    switch (code) {
        case 'savo':
            return @"saving";
    }
    return [super AS_parameterNameForCode: code];
}

@end


@implementation ASDefaultReopenCommand

- (NSString *)AS_commandName {
    return @"reopen";
}

@end


@implementation ASDefaultRunCommand

- (NSString *)AS_commandName {
    return @"run";
}

@end


@implementation ASDefaultSetCommand

- (ASDefaultSetCommand *)to:(id)value {
    [AS_event setParameter: value forKeyword: 'data'];
    return self;
}

- (NSString *)AS_commandName {
    return @"set";
}

- (NSString *)AS_parameterNameForCode:(DescType)code {
    switch (code) {
        case 'data':
            return @"to";
    }
    return [super AS_parameterNameForCode: code];
}

@end


