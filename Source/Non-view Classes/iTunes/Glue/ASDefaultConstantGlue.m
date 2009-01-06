/*
 * ASDefaultConstantGlue.m
 *
 * <default terminology>
 * osaglue 0.4.0
 *
 */

#import "ASDefaultConstantGlue.h"

@implementation ASDefaultConstant

+ (id)constantWithCode:(OSType)code_ {
    switch (code_) {
        case 'apr ': return [self April];
        case 'aug ': return [self August];
        case 'dec ': return [self December];
        case 'EPS ': return [self EPSPicture];
        case 'feb ': return [self February];
        case 'fri ': return [self Friday];
        case 'GIFf': return [self GIFPicture];
        case 'JPEG': return [self JPEGPicture];
        case 'jan ': return [self January];
        case 'jul ': return [self July];
        case 'jun ': return [self June];
        case 'mar ': return [self March];
        case 'may ': return [self May];
        case 'mon ': return [self Monday];
        case 'nov ': return [self November];
        case 'oct ': return [self October];
        case 'PICT': return [self PICTPicture];
        case 'tr16': return [self RGB16Color];
        case 'tr96': return [self RGB96Color];
        case 'cRGB': return [self RGBColor];
        case 'sat ': return [self Saturday];
        case 'sep ': return [self September];
        case 'sun ': return [self Sunday];
        case 'TIFF': return [self TIFFPicture];
        case 'thu ': return [self Thursday];
        case 'tue ': return [self Tuesday];
        case 'wed ': return [self Wednesday];
        case 'alis': return [self alias];
        case '****': return [self anything];
        case 'bund': return [self applicationBundleID];
        case 'rmte': return [self applicationResponses];
        case 'sign': return [self applicationSignature];
        case 'aprl': return [self applicationURL];
        case 'ask ': return [self ask];
        case 'best': return [self best];
        case 'bool': return [self boolean];
        case 'qdrt': return [self boundingRectangle];
        case 'case': return [self case_];
        case 'cmtr': return [self centimeters];
        case 'gcli': return [self classInfo];
        case 'pcls': return [self class_];
        case 'clrt': return [self colorTable];
        case 'ccmt': return [self cubicCentimeters];
        case 'cfet': return [self cubicFeet];
        case 'cuin': return [self cubicInches];
        case 'cmet': return [self cubicMeters];
        case 'cyrd': return [self cubicYards];
        case 'tdas': return [self dashStyle];
        case 'rdat': return [self data];
        case 'ldt ': return [self date];
        case 'decm': return [self decimalStruct];
        case 'degc': return [self degreesCelsius];
        case 'degf': return [self degreesFahrenheit];
        case 'degk': return [self degreesKelvin];
        case 'diac': return [self diacriticals];
        case 'comp': return [self doubleInteger];
        case 'elin': return [self elementInfo];
        case 'encs': return [self encodedString];
        case 'enum': return [self enumerator];
        case 'evin': return [self eventInfo];
        case 'expa': return [self expansion];
        case 'exte': return [self extendedFloat];
        case 'feet': return [self feet];
        case 'fsrf': return [self fileRef];
        case 'fss ': return [self fileSpecification];
        case 'furl': return [self fileURL];
        case 'fixd': return [self fixed];
        case 'fpnt': return [self fixedPoint];
        case 'frct': return [self fixedRectangle];
        case 'ldbl': return [self float128bit];
        case 'doub': return [self float_];
        case 'galn': return [self gallons];
        case 'gram': return [self grams];
        case 'cgtx': return [self graphicText];
        case 'hyph': return [self hyphens];
        case 'ID  ': return [self id_];
        case 'inch': return [self inches];
        case 'long': return [self integer];
        case 'itxt': return [self internationalText];
        case 'intl': return [self internationalWritingCode];
        case 'kpid': return [self kernelProcessID];
        case 'kgrm': return [self kilograms];
        case 'kmtr': return [self kilometers];
        case 'list': return [self list];
        case 'litr': return [self liters];
        case 'insl': return [self locationReference];
        case 'lfxd': return [self longFixed];
        case 'lfpt': return [self longFixedPoint];
        case 'lfrc': return [self longFixedRectangle];
        case 'lpnt': return [self longPoint];
        case 'lrct': return [self longRectangle];
        case 'port': return [self machPort];
        case 'mach': return [self machine];
        case 'mLoc': return [self machineLocation];
        case 'metr': return [self meters];
        case 'mile': return [self miles];
        case 'msng': return [self missingValue];
        case 'no  ': return [self no];
        case 'null': return [self null];
        case 'nume': return [self numericStrings];
        case 'ozs ': return [self ounces];
        case 'pmin': return [self parameterInfo];
        case 'tpmm': return [self pixelMapRecord];
        case 'QDpt': return [self point];
        case 'lbs ': return [self pounds];
        case 'psn ': return [self processSerialNumber];
        case 'prop': return [self property];
        case 'pinf': return [self propertyInfo];
        case 'punc': return [self punctuation];
        case 'qrts': return [self quarts];
        case 'reco': return [self record];
        case 'obj ': return [self reference];
        case 'trot': return [self rotation];
        case 'scpt': return [self script];
        case 'sing': return [self shortFloat];
        case 'shor': return [self shortInteger];
        case 'sqft': return [self squareFeet];
        case 'sqkm': return [self squareKilometers];
        case 'sqrm': return [self squareMeters];
        case 'sqmi': return [self squareMiles];
        case 'sqyd': return [self squareYards];
        case 'TEXT': return [self string];
        case 'styl': return [self styledClipboardText];
        case 'STXT': return [self styledText];
        case 'suin': return [self suiteInfo];
        case 'tsty': return [self textStyleInfo];
        case 'type': return [self typeClass];
        case 'utxt': return [self unicodeText];
        case 'magn': return [self unsignedInteger];
        case 'ut16': return [self utf16Text];
        case 'utf8': return [self utf8Text];
        case 'vers': return [self version];
        case 'whit': return [self whitespace];
        case 'psct': return [self writingCode];
        case 'yard': return [self yards];
        case 'yes ': return [self yes];
        default: return [[self superclass] constantWithCode: code_];
    }
}


/* Enumerators */

+ (ASDefaultConstant *)applicationResponses {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"applicationResponses" type: typeEnumerated code: 'rmte'];
    return constantObj;
}

+ (ASDefaultConstant *)ask {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"ask" type: typeEnumerated code: 'ask '];
    return constantObj;
}

+ (ASDefaultConstant *)case_ {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"case_" type: typeEnumerated code: 'case'];
    return constantObj;
}

+ (ASDefaultConstant *)diacriticals {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"diacriticals" type: typeEnumerated code: 'diac'];
    return constantObj;
}

+ (ASDefaultConstant *)expansion {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"expansion" type: typeEnumerated code: 'expa'];
    return constantObj;
}

+ (ASDefaultConstant *)hyphens {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"hyphens" type: typeEnumerated code: 'hyph'];
    return constantObj;
}

+ (ASDefaultConstant *)no {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"no" type: typeEnumerated code: 'no  '];
    return constantObj;
}

+ (ASDefaultConstant *)numericStrings {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"numericStrings" type: typeEnumerated code: 'nume'];
    return constantObj;
}

+ (ASDefaultConstant *)punctuation {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"punctuation" type: typeEnumerated code: 'punc'];
    return constantObj;
}

+ (ASDefaultConstant *)whitespace {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"whitespace" type: typeEnumerated code: 'whit'];
    return constantObj;
}

+ (ASDefaultConstant *)yes {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"yes" type: typeEnumerated code: 'yes '];
    return constantObj;
}


/* Types and properties */

+ (ASDefaultConstant *)April {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"April" type: typeType code: 'apr '];
    return constantObj;
}

+ (ASDefaultConstant *)August {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"August" type: typeType code: 'aug '];
    return constantObj;
}

+ (ASDefaultConstant *)December {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"December" type: typeType code: 'dec '];
    return constantObj;
}

+ (ASDefaultConstant *)EPSPicture {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"EPSPicture" type: typeType code: 'EPS '];
    return constantObj;
}

+ (ASDefaultConstant *)February {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"February" type: typeType code: 'feb '];
    return constantObj;
}

+ (ASDefaultConstant *)Friday {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"Friday" type: typeType code: 'fri '];
    return constantObj;
}

+ (ASDefaultConstant *)GIFPicture {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"GIFPicture" type: typeType code: 'GIFf'];
    return constantObj;
}

+ (ASDefaultConstant *)JPEGPicture {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"JPEGPicture" type: typeType code: 'JPEG'];
    return constantObj;
}

+ (ASDefaultConstant *)January {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"January" type: typeType code: 'jan '];
    return constantObj;
}

+ (ASDefaultConstant *)July {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"July" type: typeType code: 'jul '];
    return constantObj;
}

+ (ASDefaultConstant *)June {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"June" type: typeType code: 'jun '];
    return constantObj;
}

+ (ASDefaultConstant *)March {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"March" type: typeType code: 'mar '];
    return constantObj;
}

+ (ASDefaultConstant *)May {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"May" type: typeType code: 'may '];
    return constantObj;
}

+ (ASDefaultConstant *)Monday {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"Monday" type: typeType code: 'mon '];
    return constantObj;
}

+ (ASDefaultConstant *)November {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"November" type: typeType code: 'nov '];
    return constantObj;
}

+ (ASDefaultConstant *)October {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"October" type: typeType code: 'oct '];
    return constantObj;
}

+ (ASDefaultConstant *)PICTPicture {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"PICTPicture" type: typeType code: 'PICT'];
    return constantObj;
}

+ (ASDefaultConstant *)RGB16Color {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"RGB16Color" type: typeType code: 'tr16'];
    return constantObj;
}

+ (ASDefaultConstant *)RGB96Color {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"RGB96Color" type: typeType code: 'tr96'];
    return constantObj;
}

+ (ASDefaultConstant *)RGBColor {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"RGBColor" type: typeType code: 'cRGB'];
    return constantObj;
}

+ (ASDefaultConstant *)Saturday {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"Saturday" type: typeType code: 'sat '];
    return constantObj;
}

+ (ASDefaultConstant *)September {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"September" type: typeType code: 'sep '];
    return constantObj;
}

+ (ASDefaultConstant *)Sunday {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"Sunday" type: typeType code: 'sun '];
    return constantObj;
}

+ (ASDefaultConstant *)TIFFPicture {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"TIFFPicture" type: typeType code: 'TIFF'];
    return constantObj;
}

+ (ASDefaultConstant *)Thursday {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"Thursday" type: typeType code: 'thu '];
    return constantObj;
}

+ (ASDefaultConstant *)Tuesday {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"Tuesday" type: typeType code: 'tue '];
    return constantObj;
}

+ (ASDefaultConstant *)Wednesday {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"Wednesday" type: typeType code: 'wed '];
    return constantObj;
}

+ (ASDefaultConstant *)alias {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"alias" type: typeType code: 'alis'];
    return constantObj;
}

+ (ASDefaultConstant *)anything {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"anything" type: typeType code: '****'];
    return constantObj;
}

+ (ASDefaultConstant *)applicationBundleID {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"applicationBundleID" type: typeType code: 'bund'];
    return constantObj;
}

+ (ASDefaultConstant *)applicationSignature {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"applicationSignature" type: typeType code: 'sign'];
    return constantObj;
}

+ (ASDefaultConstant *)applicationURL {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"applicationURL" type: typeType code: 'aprl'];
    return constantObj;
}

+ (ASDefaultConstant *)best {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"best" type: typeType code: 'best'];
    return constantObj;
}

+ (ASDefaultConstant *)boolean {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"boolean" type: typeType code: 'bool'];
    return constantObj;
}

+ (ASDefaultConstant *)boundingRectangle {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"boundingRectangle" type: typeType code: 'qdrt'];
    return constantObj;
}

+ (ASDefaultConstant *)centimeters {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"centimeters" type: typeType code: 'cmtr'];
    return constantObj;
}

+ (ASDefaultConstant *)classInfo {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"classInfo" type: typeType code: 'gcli'];
    return constantObj;
}

+ (ASDefaultConstant *)class_ {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"class_" type: typeType code: 'pcls'];
    return constantObj;
}

+ (ASDefaultConstant *)colorTable {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"colorTable" type: typeType code: 'clrt'];
    return constantObj;
}

+ (ASDefaultConstant *)cubicCentimeters {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"cubicCentimeters" type: typeType code: 'ccmt'];
    return constantObj;
}

+ (ASDefaultConstant *)cubicFeet {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"cubicFeet" type: typeType code: 'cfet'];
    return constantObj;
}

+ (ASDefaultConstant *)cubicInches {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"cubicInches" type: typeType code: 'cuin'];
    return constantObj;
}

+ (ASDefaultConstant *)cubicMeters {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"cubicMeters" type: typeType code: 'cmet'];
    return constantObj;
}

+ (ASDefaultConstant *)cubicYards {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"cubicYards" type: typeType code: 'cyrd'];
    return constantObj;
}

+ (ASDefaultConstant *)dashStyle {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"dashStyle" type: typeType code: 'tdas'];
    return constantObj;
}

+ (ASDefaultConstant *)data {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"data" type: typeType code: 'rdat'];
    return constantObj;
}

+ (ASDefaultConstant *)date {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"date" type: typeType code: 'ldt '];
    return constantObj;
}

+ (ASDefaultConstant *)decimalStruct {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"decimalStruct" type: typeType code: 'decm'];
    return constantObj;
}

+ (ASDefaultConstant *)degreesCelsius {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"degreesCelsius" type: typeType code: 'degc'];
    return constantObj;
}

+ (ASDefaultConstant *)degreesFahrenheit {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"degreesFahrenheit" type: typeType code: 'degf'];
    return constantObj;
}

+ (ASDefaultConstant *)degreesKelvin {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"degreesKelvin" type: typeType code: 'degk'];
    return constantObj;
}

+ (ASDefaultConstant *)doubleInteger {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"doubleInteger" type: typeType code: 'comp'];
    return constantObj;
}

+ (ASDefaultConstant *)elementInfo {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"elementInfo" type: typeType code: 'elin'];
    return constantObj;
}

+ (ASDefaultConstant *)encodedString {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"encodedString" type: typeType code: 'encs'];
    return constantObj;
}

+ (ASDefaultConstant *)enumerator {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"enumerator" type: typeType code: 'enum'];
    return constantObj;
}

+ (ASDefaultConstant *)eventInfo {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"eventInfo" type: typeType code: 'evin'];
    return constantObj;
}

+ (ASDefaultConstant *)extendedFloat {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"extendedFloat" type: typeType code: 'exte'];
    return constantObj;
}

+ (ASDefaultConstant *)feet {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"feet" type: typeType code: 'feet'];
    return constantObj;
}

+ (ASDefaultConstant *)fileRef {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"fileRef" type: typeType code: 'fsrf'];
    return constantObj;
}

+ (ASDefaultConstant *)fileSpecification {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"fileSpecification" type: typeType code: 'fss '];
    return constantObj;
}

+ (ASDefaultConstant *)fileURL {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"fileURL" type: typeType code: 'furl'];
    return constantObj;
}

+ (ASDefaultConstant *)fixed {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"fixed" type: typeType code: 'fixd'];
    return constantObj;
}

+ (ASDefaultConstant *)fixedPoint {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"fixedPoint" type: typeType code: 'fpnt'];
    return constantObj;
}

+ (ASDefaultConstant *)fixedRectangle {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"fixedRectangle" type: typeType code: 'frct'];
    return constantObj;
}

+ (ASDefaultConstant *)float128bit {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"float128bit" type: typeType code: 'ldbl'];
    return constantObj;
}

+ (ASDefaultConstant *)float_ {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"float_" type: typeType code: 'doub'];
    return constantObj;
}

+ (ASDefaultConstant *)gallons {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"gallons" type: typeType code: 'galn'];
    return constantObj;
}

+ (ASDefaultConstant *)grams {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"grams" type: typeType code: 'gram'];
    return constantObj;
}

+ (ASDefaultConstant *)graphicText {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"graphicText" type: typeType code: 'cgtx'];
    return constantObj;
}

+ (ASDefaultConstant *)id_ {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"id_" type: typeType code: 'ID  '];
    return constantObj;
}

+ (ASDefaultConstant *)inches {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"inches" type: typeType code: 'inch'];
    return constantObj;
}

+ (ASDefaultConstant *)integer {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"integer" type: typeType code: 'long'];
    return constantObj;
}

+ (ASDefaultConstant *)internationalText {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"internationalText" type: typeType code: 'itxt'];
    return constantObj;
}

+ (ASDefaultConstant *)internationalWritingCode {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"internationalWritingCode" type: typeType code: 'intl'];
    return constantObj;
}

+ (ASDefaultConstant *)kernelProcessID {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"kernelProcessID" type: typeType code: 'kpid'];
    return constantObj;
}

+ (ASDefaultConstant *)kilograms {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"kilograms" type: typeType code: 'kgrm'];
    return constantObj;
}

+ (ASDefaultConstant *)kilometers {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"kilometers" type: typeType code: 'kmtr'];
    return constantObj;
}

+ (ASDefaultConstant *)list {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"list" type: typeType code: 'list'];
    return constantObj;
}

+ (ASDefaultConstant *)liters {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"liters" type: typeType code: 'litr'];
    return constantObj;
}

+ (ASDefaultConstant *)locationReference {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"locationReference" type: typeType code: 'insl'];
    return constantObj;
}

+ (ASDefaultConstant *)longFixed {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"longFixed" type: typeType code: 'lfxd'];
    return constantObj;
}

+ (ASDefaultConstant *)longFixedPoint {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"longFixedPoint" type: typeType code: 'lfpt'];
    return constantObj;
}

+ (ASDefaultConstant *)longFixedRectangle {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"longFixedRectangle" type: typeType code: 'lfrc'];
    return constantObj;
}

+ (ASDefaultConstant *)longPoint {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"longPoint" type: typeType code: 'lpnt'];
    return constantObj;
}

+ (ASDefaultConstant *)longRectangle {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"longRectangle" type: typeType code: 'lrct'];
    return constantObj;
}

+ (ASDefaultConstant *)machPort {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"machPort" type: typeType code: 'port'];
    return constantObj;
}

+ (ASDefaultConstant *)machine {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"machine" type: typeType code: 'mach'];
    return constantObj;
}

+ (ASDefaultConstant *)machineLocation {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"machineLocation" type: typeType code: 'mLoc'];
    return constantObj;
}

+ (ASDefaultConstant *)meters {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"meters" type: typeType code: 'metr'];
    return constantObj;
}

+ (ASDefaultConstant *)miles {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"miles" type: typeType code: 'mile'];
    return constantObj;
}

+ (ASDefaultConstant *)missingValue {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"missingValue" type: typeType code: 'msng'];
    return constantObj;
}

+ (ASDefaultConstant *)null {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"null" type: typeType code: 'null'];
    return constantObj;
}

+ (ASDefaultConstant *)ounces {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"ounces" type: typeType code: 'ozs '];
    return constantObj;
}

+ (ASDefaultConstant *)parameterInfo {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"parameterInfo" type: typeType code: 'pmin'];
    return constantObj;
}

+ (ASDefaultConstant *)pixelMapRecord {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"pixelMapRecord" type: typeType code: 'tpmm'];
    return constantObj;
}

+ (ASDefaultConstant *)point {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"point" type: typeType code: 'QDpt'];
    return constantObj;
}

+ (ASDefaultConstant *)pounds {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"pounds" type: typeType code: 'lbs '];
    return constantObj;
}

+ (ASDefaultConstant *)processSerialNumber {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"processSerialNumber" type: typeType code: 'psn '];
    return constantObj;
}

+ (ASDefaultConstant *)property {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"property" type: typeType code: 'prop'];
    return constantObj;
}

+ (ASDefaultConstant *)propertyInfo {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"propertyInfo" type: typeType code: 'pinf'];
    return constantObj;
}

+ (ASDefaultConstant *)quarts {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"quarts" type: typeType code: 'qrts'];
    return constantObj;
}

+ (ASDefaultConstant *)record {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"record" type: typeType code: 'reco'];
    return constantObj;
}

+ (ASDefaultConstant *)reference {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"reference" type: typeType code: 'obj '];
    return constantObj;
}

+ (ASDefaultConstant *)rotation {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"rotation" type: typeType code: 'trot'];
    return constantObj;
}

+ (ASDefaultConstant *)script {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"script" type: typeType code: 'scpt'];
    return constantObj;
}

+ (ASDefaultConstant *)shortFloat {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"shortFloat" type: typeType code: 'sing'];
    return constantObj;
}

+ (ASDefaultConstant *)shortInteger {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"shortInteger" type: typeType code: 'shor'];
    return constantObj;
}

+ (ASDefaultConstant *)squareFeet {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"squareFeet" type: typeType code: 'sqft'];
    return constantObj;
}

+ (ASDefaultConstant *)squareKilometers {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"squareKilometers" type: typeType code: 'sqkm'];
    return constantObj;
}

+ (ASDefaultConstant *)squareMeters {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"squareMeters" type: typeType code: 'sqrm'];
    return constantObj;
}

+ (ASDefaultConstant *)squareMiles {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"squareMiles" type: typeType code: 'sqmi'];
    return constantObj;
}

+ (ASDefaultConstant *)squareYards {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"squareYards" type: typeType code: 'sqyd'];
    return constantObj;
}

+ (ASDefaultConstant *)string {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"string" type: typeType code: 'TEXT'];
    return constantObj;
}

+ (ASDefaultConstant *)styledClipboardText {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"styledClipboardText" type: typeType code: 'styl'];
    return constantObj;
}

+ (ASDefaultConstant *)styledText {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"styledText" type: typeType code: 'STXT'];
    return constantObj;
}

+ (ASDefaultConstant *)suiteInfo {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"suiteInfo" type: typeType code: 'suin'];
    return constantObj;
}

+ (ASDefaultConstant *)textStyleInfo {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"textStyleInfo" type: typeType code: 'tsty'];
    return constantObj;
}

+ (ASDefaultConstant *)typeClass {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"typeClass" type: typeType code: 'type'];
    return constantObj;
}

+ (ASDefaultConstant *)unicodeText {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"unicodeText" type: typeType code: 'utxt'];
    return constantObj;
}

+ (ASDefaultConstant *)unsignedInteger {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"unsignedInteger" type: typeType code: 'magn'];
    return constantObj;
}

+ (ASDefaultConstant *)utf16Text {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"utf16Text" type: typeType code: 'ut16'];
    return constantObj;
}

+ (ASDefaultConstant *)utf8Text {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"utf8Text" type: typeType code: 'utf8'];
    return constantObj;
}

+ (ASDefaultConstant *)version {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"version" type: typeType code: 'vers'];
    return constantObj;
}

+ (ASDefaultConstant *)writingCode {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"writingCode" type: typeType code: 'psct'];
    return constantObj;
}

+ (ASDefaultConstant *)yards {
    static ASDefaultConstant *constantObj;
    if (!constantObj)
        constantObj = [ASDefaultConstant constantWithName: @"yards" type: typeType code: 'yard'];
    return constantObj;
}

@end


