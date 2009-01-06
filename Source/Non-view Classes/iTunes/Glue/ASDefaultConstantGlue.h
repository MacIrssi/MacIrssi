/*
 * ASDefaultConstantGlue.h
 *
 * <default terminology>
 * osaglue 0.4.0
 *
 */

#import <Foundation/Foundation.h>


#import "Appscript/Appscript.h"


@interface ASDefaultConstant : ASConstant
+ (id)constantWithCode:(OSType)code_;

/* Enumerators */

+ (ASDefaultConstant *)applicationResponses;
+ (ASDefaultConstant *)ask;
+ (ASDefaultConstant *)case_;
+ (ASDefaultConstant *)diacriticals;
+ (ASDefaultConstant *)expansion;
+ (ASDefaultConstant *)hyphens;
+ (ASDefaultConstant *)no;
+ (ASDefaultConstant *)numericStrings;
+ (ASDefaultConstant *)punctuation;
+ (ASDefaultConstant *)whitespace;
+ (ASDefaultConstant *)yes;

/* Types and properties */

+ (ASDefaultConstant *)April;
+ (ASDefaultConstant *)August;
+ (ASDefaultConstant *)December;
+ (ASDefaultConstant *)EPSPicture;
+ (ASDefaultConstant *)February;
+ (ASDefaultConstant *)Friday;
+ (ASDefaultConstant *)GIFPicture;
+ (ASDefaultConstant *)JPEGPicture;
+ (ASDefaultConstant *)January;
+ (ASDefaultConstant *)July;
+ (ASDefaultConstant *)June;
+ (ASDefaultConstant *)March;
+ (ASDefaultConstant *)May;
+ (ASDefaultConstant *)Monday;
+ (ASDefaultConstant *)November;
+ (ASDefaultConstant *)October;
+ (ASDefaultConstant *)PICTPicture;
+ (ASDefaultConstant *)RGB16Color;
+ (ASDefaultConstant *)RGB96Color;
+ (ASDefaultConstant *)RGBColor;
+ (ASDefaultConstant *)Saturday;
+ (ASDefaultConstant *)September;
+ (ASDefaultConstant *)Sunday;
+ (ASDefaultConstant *)TIFFPicture;
+ (ASDefaultConstant *)Thursday;
+ (ASDefaultConstant *)Tuesday;
+ (ASDefaultConstant *)Wednesday;
+ (ASDefaultConstant *)alias;
+ (ASDefaultConstant *)anything;
+ (ASDefaultConstant *)applicationBundleID;
+ (ASDefaultConstant *)applicationSignature;
+ (ASDefaultConstant *)applicationURL;
+ (ASDefaultConstant *)best;
+ (ASDefaultConstant *)boolean;
+ (ASDefaultConstant *)boundingRectangle;
+ (ASDefaultConstant *)centimeters;
+ (ASDefaultConstant *)classInfo;
+ (ASDefaultConstant *)class_;
+ (ASDefaultConstant *)colorTable;
+ (ASDefaultConstant *)cubicCentimeters;
+ (ASDefaultConstant *)cubicFeet;
+ (ASDefaultConstant *)cubicInches;
+ (ASDefaultConstant *)cubicMeters;
+ (ASDefaultConstant *)cubicYards;
+ (ASDefaultConstant *)dashStyle;
+ (ASDefaultConstant *)data;
+ (ASDefaultConstant *)date;
+ (ASDefaultConstant *)decimalStruct;
+ (ASDefaultConstant *)degreesCelsius;
+ (ASDefaultConstant *)degreesFahrenheit;
+ (ASDefaultConstant *)degreesKelvin;
+ (ASDefaultConstant *)doubleInteger;
+ (ASDefaultConstant *)elementInfo;
+ (ASDefaultConstant *)encodedString;
+ (ASDefaultConstant *)enumerator;
+ (ASDefaultConstant *)eventInfo;
+ (ASDefaultConstant *)extendedFloat;
+ (ASDefaultConstant *)feet;
+ (ASDefaultConstant *)fileRef;
+ (ASDefaultConstant *)fileSpecification;
+ (ASDefaultConstant *)fileURL;
+ (ASDefaultConstant *)fixed;
+ (ASDefaultConstant *)fixedPoint;
+ (ASDefaultConstant *)fixedRectangle;
+ (ASDefaultConstant *)float128bit;
+ (ASDefaultConstant *)float_;
+ (ASDefaultConstant *)gallons;
+ (ASDefaultConstant *)grams;
+ (ASDefaultConstant *)graphicText;
+ (ASDefaultConstant *)id_;
+ (ASDefaultConstant *)inches;
+ (ASDefaultConstant *)integer;
+ (ASDefaultConstant *)internationalText;
+ (ASDefaultConstant *)internationalWritingCode;
+ (ASDefaultConstant *)kernelProcessID;
+ (ASDefaultConstant *)kilograms;
+ (ASDefaultConstant *)kilometers;
+ (ASDefaultConstant *)list;
+ (ASDefaultConstant *)liters;
+ (ASDefaultConstant *)locationReference;
+ (ASDefaultConstant *)longFixed;
+ (ASDefaultConstant *)longFixedPoint;
+ (ASDefaultConstant *)longFixedRectangle;
+ (ASDefaultConstant *)longPoint;
+ (ASDefaultConstant *)longRectangle;
+ (ASDefaultConstant *)machPort;
+ (ASDefaultConstant *)machine;
+ (ASDefaultConstant *)machineLocation;
+ (ASDefaultConstant *)meters;
+ (ASDefaultConstant *)miles;
+ (ASDefaultConstant *)missingValue;
+ (ASDefaultConstant *)null;
+ (ASDefaultConstant *)ounces;
+ (ASDefaultConstant *)parameterInfo;
+ (ASDefaultConstant *)pixelMapRecord;
+ (ASDefaultConstant *)point;
+ (ASDefaultConstant *)pounds;
+ (ASDefaultConstant *)processSerialNumber;
+ (ASDefaultConstant *)property;
+ (ASDefaultConstant *)propertyInfo;
+ (ASDefaultConstant *)quarts;
+ (ASDefaultConstant *)record;
+ (ASDefaultConstant *)reference;
+ (ASDefaultConstant *)rotation;
+ (ASDefaultConstant *)script;
+ (ASDefaultConstant *)shortFloat;
+ (ASDefaultConstant *)shortInteger;
+ (ASDefaultConstant *)squareFeet;
+ (ASDefaultConstant *)squareKilometers;
+ (ASDefaultConstant *)squareMeters;
+ (ASDefaultConstant *)squareMiles;
+ (ASDefaultConstant *)squareYards;
+ (ASDefaultConstant *)string;
+ (ASDefaultConstant *)styledClipboardText;
+ (ASDefaultConstant *)styledText;
+ (ASDefaultConstant *)suiteInfo;
+ (ASDefaultConstant *)textStyleInfo;
+ (ASDefaultConstant *)typeClass;
+ (ASDefaultConstant *)unicodeText;
+ (ASDefaultConstant *)unsignedInteger;
+ (ASDefaultConstant *)utf16Text;
+ (ASDefaultConstant *)utf8Text;
+ (ASDefaultConstant *)version;
+ (ASDefaultConstant *)writingCode;
+ (ASDefaultConstant *)yards;
@end


