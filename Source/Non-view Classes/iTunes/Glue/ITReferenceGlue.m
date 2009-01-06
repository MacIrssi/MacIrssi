/*
 * ITReferenceGlue.m
 *
 * /Applications/iTunes.app
 * osaglue 0.4.0
 *
 */

#import "ITReferenceGlue.h"

@implementation ITReference

- (NSString *)description {
	return [ITReferenceRenderer formatObject: AS_aemReference appData: AS_appData];
}

/* Commands */

- (ITActivateCommand *)activate {
    return [ITActivateCommand commandWithAppData: AS_appData
                         eventClass: 'misc'
                            eventID: 'actv'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITActivateCommand *)activate:(id)directParameter {
    return [ITActivateCommand commandWithAppData: AS_appData
                         eventClass: 'misc'
                            eventID: 'actv'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITAddCommand *)add {
    return [ITAddCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Add '
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITAddCommand *)add:(id)directParameter {
    return [ITAddCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Add '
                    directParameter: directParameter
                    parentReference: self];
}

- (ITBackTrackCommand *)backTrack {
    return [ITBackTrackCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Back'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITBackTrackCommand *)backTrack:(id)directParameter {
    return [ITBackTrackCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Back'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITCloseCommand *)close {
    return [ITCloseCommand commandWithAppData: AS_appData
                         eventClass: 'core'
                            eventID: 'clos'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITCloseCommand *)close:(id)directParameter {
    return [ITCloseCommand commandWithAppData: AS_appData
                         eventClass: 'core'
                            eventID: 'clos'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITConvertCommand *)convert {
    return [ITConvertCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Conv'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITConvertCommand *)convert:(id)directParameter {
    return [ITConvertCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Conv'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITCountCommand *)count {
    return [ITCountCommand commandWithAppData: AS_appData
                         eventClass: 'core'
                            eventID: 'cnte'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITCountCommand *)count:(id)directParameter {
    return [ITCountCommand commandWithAppData: AS_appData
                         eventClass: 'core'
                            eventID: 'cnte'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITDeleteCommand *)delete {
    return [ITDeleteCommand commandWithAppData: AS_appData
                         eventClass: 'core'
                            eventID: 'delo'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITDeleteCommand *)delete:(id)directParameter {
    return [ITDeleteCommand commandWithAppData: AS_appData
                         eventClass: 'core'
                            eventID: 'delo'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITDownloadCommand *)download {
    return [ITDownloadCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Dwnl'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITDownloadCommand *)download:(id)directParameter {
    return [ITDownloadCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Dwnl'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITDuplicateCommand *)duplicate {
    return [ITDuplicateCommand commandWithAppData: AS_appData
                         eventClass: 'core'
                            eventID: 'clon'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITDuplicateCommand *)duplicate:(id)directParameter {
    return [ITDuplicateCommand commandWithAppData: AS_appData
                         eventClass: 'core'
                            eventID: 'clon'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITEjectCommand *)eject {
    return [ITEjectCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Ejct'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITEjectCommand *)eject:(id)directParameter {
    return [ITEjectCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Ejct'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITExistsCommand *)exists {
    return [ITExistsCommand commandWithAppData: AS_appData
                         eventClass: 'core'
                            eventID: 'doex'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITExistsCommand *)exists:(id)directParameter {
    return [ITExistsCommand commandWithAppData: AS_appData
                         eventClass: 'core'
                            eventID: 'doex'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITFastForwardCommand *)fastForward {
    return [ITFastForwardCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Fast'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITFastForwardCommand *)fastForward:(id)directParameter {
    return [ITFastForwardCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Fast'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITGetCommand *)get {
    return [ITGetCommand commandWithAppData: AS_appData
                         eventClass: 'core'
                            eventID: 'getd'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITGetCommand *)get:(id)directParameter {
    return [ITGetCommand commandWithAppData: AS_appData
                         eventClass: 'core'
                            eventID: 'getd'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITLaunchCommand *)launch {
    return [ITLaunchCommand commandWithAppData: AS_appData
                         eventClass: 'ascr'
                            eventID: 'noop'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITLaunchCommand *)launch:(id)directParameter {
    return [ITLaunchCommand commandWithAppData: AS_appData
                         eventClass: 'ascr'
                            eventID: 'noop'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITMakeCommand *)make {
    return [ITMakeCommand commandWithAppData: AS_appData
                         eventClass: 'core'
                            eventID: 'crel'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITMakeCommand *)make:(id)directParameter {
    return [ITMakeCommand commandWithAppData: AS_appData
                         eventClass: 'core'
                            eventID: 'crel'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITMoveCommand *)move {
    return [ITMoveCommand commandWithAppData: AS_appData
                         eventClass: 'core'
                            eventID: 'move'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITMoveCommand *)move:(id)directParameter {
    return [ITMoveCommand commandWithAppData: AS_appData
                         eventClass: 'core'
                            eventID: 'move'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITNextTrackCommand *)nextTrack {
    return [ITNextTrackCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Next'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITNextTrackCommand *)nextTrack:(id)directParameter {
    return [ITNextTrackCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Next'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITOpenCommand *)open {
    return [ITOpenCommand commandWithAppData: AS_appData
                         eventClass: 'aevt'
                            eventID: 'odoc'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITOpenCommand *)open:(id)directParameter {
    return [ITOpenCommand commandWithAppData: AS_appData
                         eventClass: 'aevt'
                            eventID: 'odoc'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITOpenLocationCommand *)openLocation {
    return [ITOpenLocationCommand commandWithAppData: AS_appData
                         eventClass: 'GURL'
                            eventID: 'GURL'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITOpenLocationCommand *)openLocation:(id)directParameter {
    return [ITOpenLocationCommand commandWithAppData: AS_appData
                         eventClass: 'GURL'
                            eventID: 'GURL'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITPauseCommand *)pause {
    return [ITPauseCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Paus'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITPauseCommand *)pause:(id)directParameter {
    return [ITPauseCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Paus'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITPlayCommand *)play {
    return [ITPlayCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Play'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITPlayCommand *)play:(id)directParameter {
    return [ITPlayCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Play'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITPlaypauseCommand *)playpause {
    return [ITPlaypauseCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'PlPs'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITPlaypauseCommand *)playpause:(id)directParameter {
    return [ITPlaypauseCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'PlPs'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITPreviousTrackCommand *)previousTrack {
    return [ITPreviousTrackCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Prev'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITPreviousTrackCommand *)previousTrack:(id)directParameter {
    return [ITPreviousTrackCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Prev'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITPrintCommand *)print {
    return [ITPrintCommand commandWithAppData: AS_appData
                         eventClass: 'aevt'
                            eventID: 'pdoc'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITPrintCommand *)print:(id)directParameter {
    return [ITPrintCommand commandWithAppData: AS_appData
                         eventClass: 'aevt'
                            eventID: 'pdoc'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITQuitCommand *)quit {
    return [ITQuitCommand commandWithAppData: AS_appData
                         eventClass: 'aevt'
                            eventID: 'quit'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITQuitCommand *)quit:(id)directParameter {
    return [ITQuitCommand commandWithAppData: AS_appData
                         eventClass: 'aevt'
                            eventID: 'quit'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITRefreshCommand *)refresh {
    return [ITRefreshCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Rfrs'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITRefreshCommand *)refresh:(id)directParameter {
    return [ITRefreshCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Rfrs'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITReopenCommand *)reopen {
    return [ITReopenCommand commandWithAppData: AS_appData
                         eventClass: 'aevt'
                            eventID: 'rapp'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITReopenCommand *)reopen:(id)directParameter {
    return [ITReopenCommand commandWithAppData: AS_appData
                         eventClass: 'aevt'
                            eventID: 'rapp'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITResumeCommand *)resume {
    return [ITResumeCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Resu'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITResumeCommand *)resume:(id)directParameter {
    return [ITResumeCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Resu'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITRevealCommand *)reveal {
    return [ITRevealCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Revl'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITRevealCommand *)reveal:(id)directParameter {
    return [ITRevealCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Revl'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITRewindCommand *)rewind {
    return [ITRewindCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Rwnd'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITRewindCommand *)rewind:(id)directParameter {
    return [ITRewindCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Rwnd'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITRunCommand *)run {
    return [ITRunCommand commandWithAppData: AS_appData
                         eventClass: 'aevt'
                            eventID: 'oapp'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITRunCommand *)run:(id)directParameter {
    return [ITRunCommand commandWithAppData: AS_appData
                         eventClass: 'aevt'
                            eventID: 'oapp'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITSearchCommand *)search {
    return [ITSearchCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Srch'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITSearchCommand *)search:(id)directParameter {
    return [ITSearchCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Srch'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITSetCommand *)set {
    return [ITSetCommand commandWithAppData: AS_appData
                         eventClass: 'core'
                            eventID: 'setd'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITSetCommand *)set:(id)directParameter {
    return [ITSetCommand commandWithAppData: AS_appData
                         eventClass: 'core'
                            eventID: 'setd'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITStopCommand *)stop {
    return [ITStopCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Stop'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITStopCommand *)stop:(id)directParameter {
    return [ITStopCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Stop'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITSubscribeCommand *)subscribe {
    return [ITSubscribeCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'pSub'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITSubscribeCommand *)subscribe:(id)directParameter {
    return [ITSubscribeCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'pSub'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITUpdateCommand *)update {
    return [ITUpdateCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Updt'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITUpdateCommand *)update:(id)directParameter {
    return [ITUpdateCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Updt'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITUpdateAllPodcastsCommand *)updateAllPodcasts {
    return [ITUpdateAllPodcastsCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Updp'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITUpdateAllPodcastsCommand *)updateAllPodcasts:(id)directParameter {
    return [ITUpdateAllPodcastsCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Updp'
                    directParameter: directParameter
                    parentReference: self];
}

- (ITUpdatePodcastCommand *)updatePodcast {
    return [ITUpdatePodcastCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Upd1'
                    directParameter: kASNoDirectParameter
                    parentReference: self];
}

- (ITUpdatePodcastCommand *)updatePodcast:(id)directParameter {
    return [ITUpdatePodcastCommand commandWithAppData: AS_appData
                         eventClass: 'hook'
                            eventID: 'Upd1'
                    directParameter: directParameter
                    parentReference: self];
}


/* Elements */

- (ITReference *)EQPresets {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference elements: 'cEQP']];
}

- (ITReference *)EQWindows {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference elements: 'cEQW']];
}

- (ITReference *)URLTracks {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference elements: 'cURT']];
}

- (ITReference *)application {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference elements: 'capp']];
}

- (ITReference *)artworks {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference elements: 'cArt']];
}

- (ITReference *)audioCDPlaylists {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference elements: 'cCDP']];
}

- (ITReference *)audioCDTracks {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference elements: 'cCDT']];
}

- (ITReference *)browserWindows {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference elements: 'cBrW']];
}

- (ITReference *)devicePlaylists {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference elements: 'cDvP']];
}

- (ITReference *)deviceTracks {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference elements: 'cDvT']];
}

- (ITReference *)encoders {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference elements: 'cEnc']];
}

- (ITReference *)fileTracks {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference elements: 'cFlT']];
}

- (ITReference *)folderPlaylists {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference elements: 'cFoP']];
}

- (ITReference *)items {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference elements: 'cobj']];
}

- (ITReference *)libraryPlaylists {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference elements: 'cLiP']];
}

- (ITReference *)playlistWindows {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference elements: 'cPlW']];
}

- (ITReference *)playlists {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference elements: 'cPly']];
}

- (ITReference *)printSettings {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference elements: 'pset']];
}

- (ITReference *)radioTunerPlaylists {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference elements: 'cRTP']];
}

- (ITReference *)sharedTracks {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference elements: 'cShT']];
}

- (ITReference *)sources {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference elements: 'cSrc']];
}

- (ITReference *)tracks {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference elements: 'cTrk']];
}

- (ITReference *)userPlaylists {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference elements: 'cUsP']];
}

- (ITReference *)visuals {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference elements: 'cVis']];
}

- (ITReference *)windows {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference elements: 'cwin']];
}


/* Properties */

- (ITReference *)EQ {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pEQp']];
}

- (ITReference *)EQEnabled {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pEQ ']];
}

- (ITReference *)address {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pURL']];
}

- (ITReference *)album {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pAlb']];
}

- (ITReference *)albumArtist {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pAlA']];
}

- (ITReference *)albumRating {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pAlR']];
}

- (ITReference *)albumRatingKind {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pARk']];
}

- (ITReference *)artist {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pArt']];
}

- (ITReference *)band1 {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pEQ1']];
}

- (ITReference *)band10 {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pEQ0']];
}

- (ITReference *)band2 {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pEQ2']];
}

- (ITReference *)band3 {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pEQ3']];
}

- (ITReference *)band4 {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pEQ4']];
}

- (ITReference *)band5 {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pEQ5']];
}

- (ITReference *)band6 {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pEQ6']];
}

- (ITReference *)band7 {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pEQ7']];
}

- (ITReference *)band8 {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pEQ8']];
}

- (ITReference *)band9 {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pEQ9']];
}

- (ITReference *)bitRate {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pBRt']];
}

- (ITReference *)bookmark {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pBkt']];
}

- (ITReference *)bookmarkable {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pBkm']];
}

- (ITReference *)bounds {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pbnd']];
}

- (ITReference *)bpm {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pBPM']];
}

- (ITReference *)capacity {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'capa']];
}

- (ITReference *)category {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pCat']];
}

- (ITReference *)class_ {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pcls']];
}

- (ITReference *)closeable {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'hclb']];
}

- (ITReference *)collapseable {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pWSh']];
}

- (ITReference *)collapsed {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'wshd']];
}

- (ITReference *)collating {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'lwcl']];
}

- (ITReference *)comment {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pCmt']];
}

- (ITReference *)compilation {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pAnt']];
}

- (ITReference *)composer {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pCmp']];
}

- (ITReference *)container {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'ctnr']];
}

- (ITReference *)copies {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'lwcp']];
}

- (ITReference *)currentEQPreset {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pEQP']];
}

- (ITReference *)currentEncoder {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pEnc']];
}

- (ITReference *)currentPlaylist {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pPla']];
}

- (ITReference *)currentStreamTitle {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pStT']];
}

- (ITReference *)currentStreamURL {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pStU']];
}

- (ITReference *)currentTrack {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pTrk']];
}

- (ITReference *)currentVisual {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pVis']];
}

- (ITReference *)data {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pPCT']];
}

- (ITReference *)databaseID {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pDID']];
}

- (ITReference *)dateAdded {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pAdd']];
}

- (ITReference *)description_ {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pDes']];
}

- (ITReference *)discCount {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pDsC']];
}

- (ITReference *)discNumber {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pDsN']];
}

- (ITReference *)downloaded {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pDlA']];
}

- (ITReference *)duration {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pDur']];
}

- (ITReference *)enabled {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'enbl']];
}

- (ITReference *)endingPage {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'lwlp']];
}

- (ITReference *)episodeID {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pEpD']];
}

- (ITReference *)episodeNumber {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pEpN']];
}

- (ITReference *)errorHandling {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'lweh']];
}

- (ITReference *)faxNumber {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'faxn']];
}

- (ITReference *)finish {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pStp']];
}

- (ITReference *)fixedIndexing {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pFix']];
}

- (ITReference *)format {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pFmt']];
}

- (ITReference *)freeSpace {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'frsp']];
}

- (ITReference *)frontmost {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pisf']];
}

- (ITReference *)fullScreen {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pFSc']];
}

- (ITReference *)gapless {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pGpl']];
}

- (ITReference *)genre {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pGen']];
}

- (ITReference *)grouping {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pGrp']];
}

- (ITReference *)id_ {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'ID  ']];
}

- (ITReference *)index {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pidx']];
}

- (ITReference *)kind {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pKnd']];
}

- (ITReference *)location {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pLoc']];
}

- (ITReference *)longDescription {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pLds']];
}

- (ITReference *)lyrics {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pLyr']];
}

- (ITReference *)minimized {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pMin']];
}

- (ITReference *)modifiable {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pMod']];
}

- (ITReference *)modificationDate {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'asmo']];
}

- (ITReference *)mute {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pMut']];
}

- (ITReference *)name {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pnam']];
}

- (ITReference *)pagesAcross {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'lwla']];
}

- (ITReference *)pagesDown {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'lwld']];
}

- (ITReference *)parent {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pPlP']];
}

- (ITReference *)persistentID {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pPIS']];
}

- (ITReference *)playedCount {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pPlC']];
}

- (ITReference *)playedDate {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pPlD']];
}

- (ITReference *)playerPosition {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pPos']];
}

- (ITReference *)playerState {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pPlS']];
}

- (ITReference *)podcast {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pTPc']];
}

- (ITReference *)position {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'ppos']];
}

- (ITReference *)preamp {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pEQA']];
}

- (ITReference *)printerFeatures {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'lwpf']];
}

- (ITReference *)rating {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pRte']];
}

- (ITReference *)ratingKind {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pRtk']];
}

- (ITReference *)rawData {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pRaw']];
}

- (ITReference *)requestedPrintTime {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'lwqt']];
}

- (ITReference *)resizable {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'prsz']];
}

- (ITReference *)sampleRate {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pSRt']];
}

- (ITReference *)seasonNumber {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pSeN']];
}

- (ITReference *)selection {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'sele']];
}

- (ITReference *)shared {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pShr']];
}

- (ITReference *)show {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pShw']];
}

- (ITReference *)shufflable {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pSfa']];
}

- (ITReference *)shuffle {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pShf']];
}

- (ITReference *)size {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pSiz']];
}

- (ITReference *)skippedCount {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pSkC']];
}

- (ITReference *)skippedDate {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pSkD']];
}

- (ITReference *)smart {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pSmt']];
}

- (ITReference *)songRepeat {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pRpt']];
}

- (ITReference *)sortAlbum {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pSAl']];
}

- (ITReference *)sortAlbumArtist {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pSAA']];
}

- (ITReference *)sortArtist {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pSAr']];
}

- (ITReference *)sortComposer {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pSCm']];
}

- (ITReference *)sortName {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pSNm']];
}

- (ITReference *)sortShow {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pSSN']];
}

- (ITReference *)soundVolume {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pVol']];
}

- (ITReference *)specialKind {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pSpK']];
}

- (ITReference *)start {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pStr']];
}

- (ITReference *)startingPage {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'lwfp']];
}

- (ITReference *)targetPrinter {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'trpr']];
}

- (ITReference *)time {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pTim']];
}

- (ITReference *)trackCount {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pTrC']];
}

- (ITReference *)trackNumber {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pTrN']];
}

- (ITReference *)unplayed {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pUnp']];
}

- (ITReference *)updateTracks {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pUTC']];
}

- (ITReference *)version_ {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'vers']];
}

- (ITReference *)videoKind {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pVdK']];
}

- (ITReference *)view {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pPly']];
}

- (ITReference *)visible {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pvis']];
}

- (ITReference *)visualSize {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pVSz']];
}

- (ITReference *)visualsEnabled {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pVsE']];
}

- (ITReference *)volumeAdjustment {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pAdj']];
}

- (ITReference *)year {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pYr ']];
}

- (ITReference *)zoomable {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'iszm']];
}

- (ITReference *)zoomed {
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference property: 'pzum']];
}


/***********************************/

// ordinal selectors

- (ITReference *)first {
    return [ITReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference first]];
}

- (ITReference *)middle {
    return [ITReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference middle]];
}

- (ITReference *)last {
    return [ITReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference last]];
}

- (ITReference *)any {
    return [ITReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference any]];
}

// by-index, by-name, by-id selectors
 
- (ITReference *)at:(long)index {
    return [ITReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference at: index]];
}

- (ITReference *)byIndex:(id)index { // index is normally NSNumber, but may occasionally be other types
    return [ITReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference byIndex: index]];
}

- (ITReference *)byName:(id)name {
    return [ITReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference byName: name]];
}

- (ITReference *)byID:(id)id_ {
    return [ITReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference byID: id_]];
}

// by-relative-position selectors

- (ITReference *)previous:(ASConstant *)class_ {
    return [ITReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference previous: [class_ AS_code]]];
}

- (ITReference *)next:(ASConstant *)class_ {
    return [ITReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference next: [class_ AS_code]]];
}

// by-range selector

- (ITReference *)at:(long)fromIndex to:(long)toIndex {
    return [ITReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference at: fromIndex to: toIndex]];
}

- (ITReference *)byRange:(id)fromObject to:(id)toObject {
    // takes two con-based references, with other values being expanded as necessary
    if ([fromObject isKindOfClass: [ITReference class]])
        fromObject = [fromObject AS_aemReference];
    if ([toObject isKindOfClass: [ITReference class]])
        toObject = [toObject AS_aemReference];
    return [ITReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference byRange: fromObject to: toObject]];
}

// by-test selector

- (ITReference *)byTest:(ITReference *)testReference {
    // note: getting AS_aemReference won't work for ASDynamicReference
    return [ITReference referenceWithAppData: AS_appData
                    aemReference: [AS_aemReference byTest: [testReference AS_aemReference]]];
}

// insertion location selectors

- (ITReference *)beginning {
    return [ITReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference beginning]];
}

- (ITReference *)end {
    return [ITReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference end]];
}

- (ITReference *)before {
    return [ITReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference before]];
}

- (ITReference *)after {
    return [ITReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference after]];
}

// Comparison and logic tests

- (ITReference *)greaterThan:(id)object {
    return [ITReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference greaterThan: object]];
}

- (ITReference *)greaterOrEquals:(id)object {
    return [ITReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference greaterOrEquals: object]];
}

- (ITReference *)equals:(id)object {
    return [ITReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference equals: object]];
}

- (ITReference *)notEquals:(id)object {
    return [ITReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference notEquals: object]];
}

- (ITReference *)lessThan:(id)object {
    return [ITReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference lessThan: object]];
}

- (ITReference *)lessOrEquals:(id)object {
    return [ITReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference lessOrEquals: object]];
}

- (ITReference *)beginsWith:(id)object {
    return [ITReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference beginsWith: object]];
}

- (ITReference *)endsWith:(id)object {
    return [ITReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference endsWith: object]];
}

- (ITReference *)contains:(id)object {
    return [ITReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference contains: object]];
}

- (ITReference *)isIn:(id)object {
    return [ITReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference isIn: object]];
}

- (ITReference *)AND:(id)remainingOperands {
    return [ITReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference AND: remainingOperands]];
}

- (ITReference *)OR:(id)remainingOperands {
    return [ITReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference OR: remainingOperands]];
}

- (ITReference *)NOT {
    return [ITReference referenceWithAppData: AS_appData
                                 aemReference: [AS_aemReference NOT]];
}

@end


