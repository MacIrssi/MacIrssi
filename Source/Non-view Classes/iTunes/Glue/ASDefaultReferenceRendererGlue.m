/*
 * ASDefaultReferenceRendererGlue.m
 *
 * <default terminology>
 * osaglue 0.4.0
 *
 */

#import "ASDefaultReferenceRendererGlue.h"

@implementation ASDefaultReferenceRenderer

- (NSString *)propertyByCode:(OSType)code {
    switch (code) {
        case 'pcls': return @"class_";
        case 'ID  ': return @"id_";

        default: return nil;
    }
}

- (NSString *)elementByCode:(OSType)code {
    switch (code) {

        default: return nil;
    }
}

- (NSString *)prefix {
    return @"ASDefault";
}

@end
