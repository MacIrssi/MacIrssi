/*
 * ASDefaultAEMConstants.h
 * 
 * <default terminology>
 * osaglue 0.4.0
 *
 */
#import "Appscript/Appscript.h"

// Type/Enum Names
enum {
	kASDefaultApplicationResponses = 'rmte',
	kASDefaultAsk = 'ask ',
	kASDefaultCase_ = 'case',
	kASDefaultDiacriticals = 'diac',
	kASDefaultExpansion = 'expa',
	kASDefaultHyphens = 'hyph',
	kASDefaultNo = 'no  ',
	kASDefaultNumericStrings = 'nume',
	kASDefaultPunctuation = 'punc',
	kASDefaultWhitespace = 'whit',
	kASDefaultYes = 'yes ',
	kASDefaultApril = 'apr ',
	kASDefaultAugust = 'aug ',
	kASDefaultDecember = 'dec ',
	kASDefaultEPSPicture = 'EPS ',
	kASDefaultFebruary = 'feb ',
	kASDefaultFriday = 'fri ',
	kASDefaultGIFPicture = 'GIFf',
	kASDefaultJPEGPicture = 'JPEG',
	kASDefaultJanuary = 'jan ',
	kASDefaultJuly = 'jul ',
	kASDefaultJune = 'jun ',
	kASDefaultMarch = 'mar ',
	kASDefaultMay = 'may ',
	kASDefaultMonday = 'mon ',
	kASDefaultNovember = 'nov ',
	kASDefaultOctober = 'oct ',
	kASDefaultPICTPicture = 'PICT',
	kASDefaultRGB16Color = 'tr16',
	kASDefaultRGB96Color = 'tr96',
	kASDefaultRGBColor = 'cRGB',
	kASDefaultSaturday = 'sat ',
	kASDefaultSeptember = 'sep ',
	kASDefaultSunday = 'sun ',
	kASDefaultTIFFPicture = 'TIFF',
	kASDefaultThursday = 'thu ',
	kASDefaultTuesday = 'tue ',
	kASDefaultWednesday = 'wed ',
	kASDefaultAlias = 'alis',
	kASDefaultAnything = '****',
	kASDefaultApplicationBundleID = 'bund',
	kASDefaultApplicationSignature = 'sign',
	kASDefaultApplicationURL = 'aprl',
	kASDefaultBest = 'best',
	kASDefaultBoolean = 'bool',
	kASDefaultBoundingRectangle = 'qdrt',
	kASDefaultCentimeters = 'cmtr',
	kASDefaultClassInfo = 'gcli',
	kASDefaultClass_ = 'pcls',
	kASDefaultColorTable = 'clrt',
	kASDefaultCubicCentimeters = 'ccmt',
	kASDefaultCubicFeet = 'cfet',
	kASDefaultCubicInches = 'cuin',
	kASDefaultCubicMeters = 'cmet',
	kASDefaultCubicYards = 'cyrd',
	kASDefaultDashStyle = 'tdas',
	kASDefaultData = 'rdat',
	kASDefaultDate = 'ldt ',
	kASDefaultDecimalStruct = 'decm',
	kASDefaultDegreesCelsius = 'degc',
	kASDefaultDegreesFahrenheit = 'degf',
	kASDefaultDegreesKelvin = 'degk',
	kASDefaultDoubleInteger = 'comp',
	kASDefaultElementInfo = 'elin',
	kASDefaultEncodedString = 'encs',
	kASDefaultEnumerator = 'enum',
	kASDefaultEventInfo = 'evin',
	kASDefaultExtendedFloat = 'exte',
	kASDefaultFeet = 'feet',
	kASDefaultFileRef = 'fsrf',
	kASDefaultFileSpecification = 'fss ',
	kASDefaultFileURL = 'furl',
	kASDefaultFixed = 'fixd',
	kASDefaultFixedPoint = 'fpnt',
	kASDefaultFixedRectangle = 'frct',
	kASDefaultFloat128bit = 'ldbl',
	kASDefaultFloat_ = 'doub',
	kASDefaultGallons = 'galn',
	kASDefaultGrams = 'gram',
	kASDefaultGraphicText = 'cgtx',
	kASDefaultId_ = 'ID  ',
	kASDefaultInches = 'inch',
	kASDefaultInteger = 'long',
	kASDefaultInternationalText = 'itxt',
	kASDefaultInternationalWritingCode = 'intl',
	kASDefaultKernelProcessID = 'kpid',
	kASDefaultKilograms = 'kgrm',
	kASDefaultKilometers = 'kmtr',
	kASDefaultList = 'list',
	kASDefaultLiters = 'litr',
	kASDefaultLocationReference = 'insl',
	kASDefaultLongFixed = 'lfxd',
	kASDefaultLongFixedPoint = 'lfpt',
	kASDefaultLongFixedRectangle = 'lfrc',
	kASDefaultLongPoint = 'lpnt',
	kASDefaultLongRectangle = 'lrct',
	kASDefaultMachPort = 'port',
	kASDefaultMachine = 'mach',
	kASDefaultMachineLocation = 'mLoc',
	kASDefaultMeters = 'metr',
	kASDefaultMiles = 'mile',
	kASDefaultMissingValue = 'msng',
	kASDefaultNull = 'null',
	kASDefaultOunces = 'ozs ',
	kASDefaultParameterInfo = 'pmin',
	kASDefaultPixelMapRecord = 'tpmm',
	kASDefaultPoint = 'QDpt',
	kASDefaultPounds = 'lbs ',
	kASDefaultProcessSerialNumber = 'psn ',
	kASDefaultProperty = 'prop',
	kASDefaultPropertyInfo = 'pinf',
	kASDefaultQuarts = 'qrts',
	kASDefaultRecord = 'reco',
	kASDefaultReference = 'obj ',
	kASDefaultRotation = 'trot',
	kASDefaultScript = 'scpt',
	kASDefaultShortFloat = 'sing',
	kASDefaultShortInteger = 'shor',
	kASDefaultSquareFeet = 'sqft',
	kASDefaultSquareKilometers = 'sqkm',
	kASDefaultSquareMeters = 'sqrm',
	kASDefaultSquareMiles = 'sqmi',
	kASDefaultSquareYards = 'sqyd',
	kASDefaultString = 'TEXT',
	kASDefaultStyledClipboardText = 'styl',
	kASDefaultStyledText = 'STXT',
	kASDefaultSuiteInfo = 'suin',
	kASDefaultTextStyleInfo = 'tsty',
	kASDefaultTypeClass = 'type',
	kASDefaultUnicodeText = 'utxt',
	kASDefaultUnsignedInteger = 'magn',
	kASDefaultUtf16Text = 'ut16',
	kASDefaultUtf8Text = 'utf8',
	kASDefaultVersion = 'vers',
	kASDefaultWritingCode = 'psct',
	kASDefaultYards = 'yard',
};

enum {
	pASDefaultClass_ = 'pcls',
	pASDefaultId_ = 'ID  ',
};

enum {
	ecASDefaultActivate = 'misc',
	eiASDefaultActivate = 'actv',
};

enum {
	ecASDefaultGet = 'core',
	eiASDefaultGet = 'getd',
};

enum {
	ecASDefaultLaunch = 'ascr',
	eiASDefaultLaunch = 'noop',
};

enum {
	ecASDefaultOpen = 'aevt',
	eiASDefaultOpen = 'odoc',
};

enum {
	ecASDefaultOpenLocation = 'GURL',
	eiASDefaultOpenLocation = 'GURL',
	epASDefaultWindow = 'WIND',
};

enum {
	ecASDefaultPrint = 'aevt',
	eiASDefaultPrint = 'pdoc',
};

enum {
	ecASDefaultQuit = 'aevt',
	eiASDefaultQuit = 'quit',
	epASDefaultSaving = 'savo',
};

enum {
	ecASDefaultReopen = 'aevt',
	eiASDefaultReopen = 'rapp',
};

enum {
	ecASDefaultRun = 'aevt',
	eiASDefaultRun = 'oapp',
};

enum {
	ecASDefaultSet = 'core',
	eiASDefaultSet = 'setd',
	epASDefaultTo = 'data',
};

