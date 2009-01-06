/*
 * ASDefaultReferenceGlue.m
 *
 * <default terminology>
 * osaglue 0.4.0
 *
 */

#import "ASDefaultReferenceGlue.h"

@implementation ASDefaultReference

- (NSString *)description {
	return [ASDefaultReferenceRenderer formatObject: AS_aemReference appData: AS_appData];
}

/* Commands */

- (ASDefaultActivateCommand *)activate {
    return [ASDefaultActivateCommand commandWithAppData: AS_appData
                         eventClass: 'misc'
                            eventID: 'actv'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ASDefaultActivateCommand *)activate:(id)directParameter {
    return [ASDefaultActivateCommand commandWithAppData: AS_appData
                         eventClass: 'misc'
                            eventID: 'actv'
                    directParameter: directParameter
                    parentReference: self];
}

- (ASDefaultGetCommand *)get {
    return [ASDefaultGetCommand commandWithAppData: AS_appData
                         eventClass: 'core'
                            eventID: 'getd'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ASDefaultGetCommand *)get:(id)directParameter {
    return [ASDefaultGetCommand commandWithAppData: AS_appData
                         eventClass: 'core'
                            eventID: 'getd'
                    directParameter: directParameter
                    parentReference: self];
}

- (ASDefaultLaunchCommand *)launch {
    return [ASDefaultLaunchCommand commandWithAppData: AS_appData
                         eventClass: 'ascr'
                            eventID: 'noop'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ASDefaultLaunchCommand *)launch:(id)directParameter {
    return [ASDefaultLaunchCommand commandWithAppData: AS_appData
                         eventClass: 'ascr'
                            eventID: 'noop'
                    directParameter: directParameter
                    parentReference: self];
}

- (ASDefaultOpenCommand *)open {
    return [ASDefaultOpenCommand commandWithAppData: AS_appData
                         eventClass: 'aevt'
                            eventID: 'odoc'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ASDefaultOpenCommand *)open:(id)directParameter {
    return [ASDefaultOpenCommand commandWithAppData: AS_appData
                         eventClass: 'aevt'
                            eventID: 'odoc'
                    directParameter: directParameter
                    parentReference: self];
}

- (ASDefaultOpenLocationCommand *)openLocation {
    return [ASDefaultOpenLocationCommand commandWithAppData: AS_appData
                         eventClass: 'GURL'
                            eventID: 'GURL'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ASDefaultOpenLocationCommand *)openLocation:(id)directParameter {
    return [ASDefaultOpenLocationCommand commandWithAppData: AS_appData
                         eventClass: 'GURL'
                            eventID: 'GURL'
                    directParameter: directParameter
                    parentReference: self];
}

- (ASDefaultPrintCommand *)print {
    return [ASDefaultPrintCommand commandWithAppData: AS_appData
                         eventClass: 'aevt'
                            eventID: 'pdoc'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ASDefaultPrintCommand *)print:(id)directParameter {
    return [ASDefaultPrintCommand commandWithAppData: AS_appData
                         eventClass: 'aevt'
                            eventID: 'pdoc'
                    directParameter: directParameter
                    parentReference: self];
}

- (ASDefaultQuitCommand *)quit {
    return [ASDefaultQuitCommand commandWithAppData: AS_appData
                         eventClass: 'aevt'
                            eventID: 'quit'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ASDefaultQuitCommand *)quit:(id)directParameter {
    return [ASDefaultQuitCommand commandWithAppData: AS_appData
                         eventClass: 'aevt'
                            eventID: 'quit'
                    directParameter: directParameter
                    parentReference: self];
}

- (ASDefaultReopenCommand *)reopen {
    return [ASDefaultReopenCommand commandWithAppData: AS_appData
                         eventClass: 'aevt'
                            eventID: 'rapp'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ASDefaultReopenCommand *)reopen:(id)directParameter {
    return [ASDefaultReopenCommand commandWithAppData: AS_appData
                         eventClass: 'aevt'
                            eventID: 'rapp'
                    directParameter: directParameter
                    parentReference: self];
}

- (ASDefaultRunCommand *)run {
    return [ASDefaultRunCommand commandWithAppData: AS_appData
                         eventClass: 'aevt'
                            eventID: 'oapp'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ASDefaultRunCommand *)run:(id)directParameter {
    return [ASDefaultRunCommand commandWithAppData: AS_appData
                         eventClass: 'aevt'
                            eventID: 'oapp'
                    directParameter: directParameter
                    parentReference: self];
}

- (ASDefaultSetCommand *)set {
    return [ASDefaultSetCommand commandWithAppData: AS_appData
                         eventClass: 'core'
                            eventID: 'setd'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ASDefaultSetCommand *)set:(id)directParameter {
    return [ASDefaultSetCommand commandWithAppData: AS_appData
                         eventClass: 'core'
                            eventID: 'setd'
                    directParameter: directParameter
                    parentReference: self];
}


/* Properties */

- (ASDefaultReference *)class_ {
    return [ASDefaultReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pcls']];
}

- (ASDefaultReference *)id_ {
    return [ASDefaultReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'ID  ']];
}


/***********************************/

// ordinal selectors

- (ASDefaultReference *)first {
    return [ASDefaultReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference first]];
}

- (ASDefaultReference *)middle {
    return [ASDefaultReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference middle]];
}

- (ASDefaultReference *)last {
    return [ASDefaultReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference last]];
}

- (ASDefaultReference *)any {
    return [ASDefaultReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference any]];
}

// by-index, by-name, by-id selectors
 
- (ASDefaultReference *)at:(long)index {
    return [ASDefaultReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference at: index]];
}

- (ASDefaultReference *)byIndex:(id)index { // index is normally NSNumber, but may occasionally be other types
    return [ASDefaultReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference byIndex: index]];
}

- (ASDefaultReference *)byName:(id)name {
    return [ASDefaultReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference byName: name]];
}

- (ASDefaultReference *)byID:(id)id_ {
    return [ASDefaultReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference byID: id_]];
}

// by-relative-position selectors

- (ASDefaultReference *)previous:(ASConstant *)class_ {
    return [ASDefaultReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference previous: [class_ AS_code]]];
}

- (ASDefaultReference *)next:(ASConstant *)class_ {
    return [ASDefaultReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference next: [class_ AS_code]]];
}

// by-range selector

- (ASDefaultReference *)at:(long)fromIndex to:(long)toIndex {
    return [ASDefaultReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference at: fromIndex to: toIndex]];
}

- (ASDefaultReference *)byRange:(id)fromObject to:(id)toObject {
    // takes two con-based references, with other values being expanded as necessary
    if ([fromObject isKindOfClass: [ASDefaultReference class]])
        fromObject = [fromObject AS_aemReference];
    if ([toObject isKindOfClass: [ASDefaultReference class]])
        toObject = [toObject AS_aemReference];
    return [ASDefaultReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference byRange: fromObject to: toObject]];
}

// by-test selector

- (ASDefaultReference *)byTest:(ASDefaultReference *)testReference {
    // note: getting AS_aemReference won't work for ASDynamicReference
    return [ASDefaultReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference byTest: [testReference AS_aemReference]]];
}

// insertion location selectors

- (ASDefaultReference *)beginning {
    return [ASDefaultReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference beginning]];
}

- (ASDefaultReference *)end {
    return [ASDefaultReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference end]];
}

- (ASDefaultReference *)before {
    return [ASDefaultReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference before]];
}

- (ASDefaultReference *)after {
    return [ASDefaultReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference after]];
}

// Comparison and logic tests

- (ASDefaultReference *)greaterThan:(id)object {
    return [ASDefaultReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference greaterThan: object]];
}

- (ASDefaultReference *)greaterOrEquals:(id)object {
    return [ASDefaultReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference greaterOrEquals: object]];
}

- (ASDefaultReference *)equals:(id)object {
    return [ASDefaultReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference equals: object]];
}

- (ASDefaultReference *)notEquals:(id)object {
    return [ASDefaultReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference notEquals: object]];
}

- (ASDefaultReference *)lessThan:(id)object {
    return [ASDefaultReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference lessThan: object]];
}

- (ASDefaultReference *)lessOrEquals:(id)object {
    return [ASDefaultReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference lessOrEquals: object]];
}

- (ASDefaultReference *)beginsWith:(id)object {
    return [ASDefaultReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference beginsWith: object]];
}

- (ASDefaultReference *)endsWith:(id)object {
    return [ASDefaultReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference endsWith: object]];
}

- (ASDefaultReference *)contains:(id)object {
    return [ASDefaultReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference contains: object]];
}

- (ASDefaultReference *)isIn:(id)object {
    return [ASDefaultReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference isIn: object]];
}

- (ASDefaultReference *)AND:(id)remainingOperands {
    return [ASDefaultReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference AND: remainingOperands]];
}

- (ASDefaultReference *)OR:(id)remainingOperands {
    return [ASDefaultReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference OR: remainingOperands]];
}

- (ASDefaultReference *)NOT {
    return [ASDefaultReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference NOT]];
}

@end


