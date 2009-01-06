/*
 * ITReferenceRendererGlue.m
 *
 * /Applications/iTunes.app
 * osaglue 0.4.0
 *
 */

#import "ITReferenceRendererGlue.h"

@implementation ITReferenceRenderer

- (NSString *)propertyByCode:(OSType)code {
    switch (code) {
        case 'pEQp': return @"EQ";
        case 'pEQ ': return @"EQEnabled";
        case 'pURL': return @"address";
        case 'pAlb': return @"album";
        case 'pAlA': return @"albumArtist";
        case 'pAlR': return @"albumRating";
        case 'pARk': return @"albumRatingKind";
        case 'pArt': return @"artist";
        case 'pEQ1': return @"band1";
        case 'pEQ0': return @"band10";
        case 'pEQ2': return @"band2";
        case 'pEQ3': return @"band3";
        case 'pEQ4': return @"band4";
        case 'pEQ5': return @"band5";
        case 'pEQ6': return @"band6";
        case 'pEQ7': return @"band7";
        case 'pEQ8': return @"band8";
        case 'pEQ9': return @"band9";
        case 'pBRt': return @"bitRate";
        case 'pBkt': return @"bookmark";
        case 'pBkm': return @"bookmarkable";
        case 'pbnd': return @"bounds";
        case 'pBPM': return @"bpm";
        case 'capa': return @"capacity";
        case 'pCat': return @"category";
        case 'pcls': return @"class_";
        case 'hclb': return @"closeable";
        case 'pWSh': return @"collapseable";
        case 'wshd': return @"collapsed";
        case 'lwcl': return @"collating";
        case 'pCmt': return @"comment";
        case 'pAnt': return @"compilation";
        case 'pCmp': return @"composer";
        case 'ctnr': return @"container";
        case 'lwcp': return @"copies";
        case 'pEQP': return @"currentEQPreset";
        case 'pEnc': return @"currentEncoder";
        case 'pPla': return @"currentPlaylist";
        case 'pStT': return @"currentStreamTitle";
        case 'pStU': return @"currentStreamURL";
        case 'pTrk': return @"currentTrack";
        case 'pVis': return @"currentVisual";
        case 'pPCT': return @"data";
        case 'pDID': return @"databaseID";
        case 'pAdd': return @"dateAdded";
        case 'pDes': return @"description_";
        case 'pDsC': return @"discCount";
        case 'pDsN': return @"discNumber";
        case 'pDlA': return @"downloaded";
        case 'pDur': return @"duration";
        case 'enbl': return @"enabled";
        case 'lwlp': return @"endingPage";
        case 'pEpD': return @"episodeID";
        case 'pEpN': return @"episodeNumber";
        case 'lweh': return @"errorHandling";
        case 'faxn': return @"faxNumber";
        case 'pStp': return @"finish";
        case 'pFix': return @"fixedIndexing";
        case 'pFmt': return @"format";
        case 'frsp': return @"freeSpace";
        case 'pisf': return @"frontmost";
        case 'pFSc': return @"fullScreen";
        case 'pGpl': return @"gapless";
        case 'pGen': return @"genre";
        case 'pGrp': return @"grouping";
        case 'ID  ': return @"id_";
        case 'pidx': return @"index";
        case 'pKnd': return @"kind";
        case 'pLoc': return @"location";
        case 'pLds': return @"longDescription";
        case 'pLyr': return @"lyrics";
        case 'pMin': return @"minimized";
        case 'pMod': return @"modifiable";
        case 'asmo': return @"modificationDate";
        case 'pMut': return @"mute";
        case 'pnam': return @"name";
        case 'lwla': return @"pagesAcross";
        case 'lwld': return @"pagesDown";
        case 'pPlP': return @"parent";
        case 'pPIS': return @"persistentID";
        case 'pPlC': return @"playedCount";
        case 'pPlD': return @"playedDate";
        case 'pPos': return @"playerPosition";
        case 'pPlS': return @"playerState";
        case 'pTPc': return @"podcast";
        case 'ppos': return @"position";
        case 'pEQA': return @"preamp";
        case 'lwpf': return @"printerFeatures";
        case 'pRte': return @"rating";
        case 'pRtk': return @"ratingKind";
        case 'pRaw': return @"rawData";
        case 'lwqt': return @"requestedPrintTime";
        case 'prsz': return @"resizable";
        case 'pSRt': return @"sampleRate";
        case 'pSeN': return @"seasonNumber";
        case 'sele': return @"selection";
        case 'pShr': return @"shared";
        case 'pShw': return @"show";
        case 'pSfa': return @"shufflable";
        case 'pShf': return @"shuffle";
        case 'pSiz': return @"size";
        case 'pSkC': return @"skippedCount";
        case 'pSkD': return @"skippedDate";
        case 'pSmt': return @"smart";
        case 'pRpt': return @"songRepeat";
        case 'pSAl': return @"sortAlbum";
        case 'pSAA': return @"sortAlbumArtist";
        case 'pSAr': return @"sortArtist";
        case 'pSCm': return @"sortComposer";
        case 'pSNm': return @"sortName";
        case 'pSSN': return @"sortShow";
        case 'pVol': return @"soundVolume";
        case 'pSpK': return @"specialKind";
        case 'pStr': return @"start";
        case 'lwfp': return @"startingPage";
        case 'trpr': return @"targetPrinter";
        case 'pTim': return @"time";
        case 'pTrC': return @"trackCount";
        case 'pTrN': return @"trackNumber";
        case 'pUnp': return @"unplayed";
        case 'pUTC': return @"updateTracks";
        case 'vers': return @"version_";
        case 'pVdK': return @"videoKind";
        case 'pPly': return @"view";
        case 'pvis': return @"visible";
        case 'pVSz': return @"visualSize";
        case 'pVsE': return @"visualsEnabled";
        case 'pAdj': return @"volumeAdjustment";
        case 'pYr ': return @"year";
        case 'iszm': return @"zoomable";
        case 'pzum': return @"zoomed";

        default: return nil;
    }
}

- (NSString *)elementByCode:(OSType)code {
    switch (code) {
        case 'cEQP': return @"EQPresets";
        case 'cEQW': return @"EQWindows";
        case 'cURT': return @"URLTracks";
        case 'capp': return @"application";
        case 'cArt': return @"artworks";
        case 'cCDP': return @"audioCDPlaylists";
        case 'cCDT': return @"audioCDTracks";
        case 'cBrW': return @"browserWindows";
        case 'cDvP': return @"devicePlaylists";
        case 'cDvT': return @"deviceTracks";
        case 'cEnc': return @"encoders";
        case 'cFlT': return @"fileTracks";
        case 'cFoP': return @"folderPlaylists";
        case 'cobj': return @"items";
        case 'cLiP': return @"libraryPlaylists";
        case 'cPlW': return @"playlistWindows";
        case 'cPly': return @"playlists";
        case 'pset': return @"printSettings";
        case 'cRTP': return @"radioTunerPlaylists";
        case 'cShT': return @"sharedTracks";
        case 'cSrc': return @"sources";
        case 'cTrk': return @"tracks";
        case 'cUsP': return @"userPlaylists";
        case 'cVis': return @"visuals";
        case 'cwin': return @"windows";

        default: return nil;
    }
}

- (NSString *)prefix {
    return @"IT";
}

@end
