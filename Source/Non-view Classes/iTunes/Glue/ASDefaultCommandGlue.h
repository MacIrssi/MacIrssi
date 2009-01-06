/*
 * ASDefaultCommandGlue.h
 *
 * <default terminology>
 * osaglue 0.4.0
 *
 */

#import <Foundation/Foundation.h>


#import "Appscript/Appscript.h"
#import "ASDefaultReferenceRendererGlue.h"


@interface ASDefaultCommand : ASCommand
@end

@interface ASDefaultActivateCommand : ASDefaultCommand
@end


@interface ASDefaultGetCommand : ASDefaultCommand
@end


@interface ASDefaultLaunchCommand : ASDefaultCommand
@end


@interface ASDefaultOpenCommand : ASDefaultCommand
@end


@interface ASDefaultOpenLocationCommand : ASDefaultCommand
- (ASDefaultOpenLocationCommand *)window:(id)value;
@end


@interface ASDefaultPrintCommand : ASDefaultCommand
@end


@interface ASDefaultQuitCommand : ASDefaultCommand
- (ASDefaultQuitCommand *)saving:(id)value;
@end


@interface ASDefaultReopenCommand : ASDefaultCommand
@end


@interface ASDefaultRunCommand : ASDefaultCommand
@end


@interface ASDefaultSetCommand : ASDefaultCommand
- (ASDefaultSetCommand *)to:(id)value;
@end


