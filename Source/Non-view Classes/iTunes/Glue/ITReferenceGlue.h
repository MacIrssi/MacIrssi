/*
 * ITReferenceGlue.h
 *
 * /Applications/iTunes.app
 * osaglue 0.4.0
 *
 */

#import <Foundation/Foundation.h>


#import "Appscript/Appscript.h"
#import "ITCommandGlue.h"
#import "ITReferenceRendererGlue.h"

#define ITApp ((ITReference *)[ITReference referenceWithAppData: nil aemReference: AEMApp])
#define ITCon ((ITReference *)[ITReference referenceWithAppData: nil aemReference: AEMCon])
#define ITIts ((ITReference *)[ITReference referenceWithAppData: nil aemReference: AEMIts])


@interface ITReference : ASReference

/* Commands */

- (ITActivateCommand *)activate;
- (ITActivateCommand *)activate:(id)directParameter;
- (ITAddCommand *)add;
- (ITAddCommand *)add:(id)directParameter;
- (ITBackTrackCommand *)backTrack;
- (ITBackTrackCommand *)backTrack:(id)directParameter;
- (ITCloseCommand *)close;
- (ITCloseCommand *)close:(id)directParameter;
- (ITConvertCommand *)convert;
- (ITConvertCommand *)convert:(id)directParameter;
- (ITCountCommand *)count;
- (ITCountCommand *)count:(id)directParameter;
- (ITDeleteCommand *)delete;
- (ITDeleteCommand *)delete:(id)directParameter;
- (ITDownloadCommand *)download;
- (ITDownloadCommand *)download:(id)directParameter;
- (ITDuplicateCommand *)duplicate;
- (ITDuplicateCommand *)duplicate:(id)directParameter;
- (ITEjectCommand *)eject;
- (ITEjectCommand *)eject:(id)directParameter;
- (ITExistsCommand *)exists;
- (ITExistsCommand *)exists:(id)directParameter;
- (ITFastForwardCommand *)fastForward;
- (ITFastForwardCommand *)fastForward:(id)directParameter;
- (ITGetCommand *)get;
- (ITGetCommand *)get:(id)directParameter;
- (ITLaunchCommand *)launch;
- (ITLaunchCommand *)launch:(id)directParameter;
- (ITMakeCommand *)make;
- (ITMakeCommand *)make:(id)directParameter;
- (ITMoveCommand *)move;
- (ITMoveCommand *)move:(id)directParameter;
- (ITNextTrackCommand *)nextTrack;
- (ITNextTrackCommand *)nextTrack:(id)directParameter;
- (ITOpenCommand *)open;
- (ITOpenCommand *)open:(id)directParameter;
- (ITOpenLocationCommand *)openLocation;
- (ITOpenLocationCommand *)openLocation:(id)directParameter;
- (ITPauseCommand *)pause;
- (ITPauseCommand *)pause:(id)directParameter;
- (ITPlayCommand *)play;
- (ITPlayCommand *)play:(id)directParameter;
- (ITPlaypauseCommand *)playpause;
- (ITPlaypauseCommand *)playpause:(id)directParameter;
- (ITPreviousTrackCommand *)previousTrack;
- (ITPreviousTrackCommand *)previousTrack:(id)directParameter;
- (ITPrintCommand *)print;
- (ITPrintCommand *)print:(id)directParameter;
- (ITQuitCommand *)quit;
- (ITQuitCommand *)quit:(id)directParameter;
- (ITRefreshCommand *)refresh;
- (ITRefreshCommand *)refresh:(id)directParameter;
- (ITReopenCommand *)reopen;
- (ITReopenCommand *)reopen:(id)directParameter;
- (ITResumeCommand *)resume;
- (ITResumeCommand *)resume:(id)directParameter;
- (ITRevealCommand *)reveal;
- (ITRevealCommand *)reveal:(id)directParameter;
- (ITRewindCommand *)rewind;
- (ITRewindCommand *)rewind:(id)directParameter;
- (ITRunCommand *)run;
- (ITRunCommand *)run:(id)directParameter;
- (ITSearchCommand *)search;
- (ITSearchCommand *)search:(id)directParameter;
- (ITSetCommand *)set;
- (ITSetCommand *)set:(id)directParameter;
- (ITStopCommand *)stop;
- (ITStopCommand *)stop:(id)directParameter;
- (ITSubscribeCommand *)subscribe;
- (ITSubscribeCommand *)subscribe:(id)directParameter;
- (ITUpdateCommand *)update;
- (ITUpdateCommand *)update:(id)directParameter;
- (ITUpdateAllPodcastsCommand *)updateAllPodcasts;
- (ITUpdateAllPodcastsCommand *)updateAllPodcasts:(id)directParameter;
- (ITUpdatePodcastCommand *)updatePodcast;
- (ITUpdatePodcastCommand *)updatePodcast:(id)directParameter;

/* Elements */

- (ITReference *)EQPresets;
- (ITReference *)EQWindows;
- (ITReference *)URLTracks;
- (ITReference *)application;
- (ITReference *)artworks;
- (ITReference *)audioCDPlaylists;
- (ITReference *)audioCDTracks;
- (ITReference *)browserWindows;
- (ITReference *)devicePlaylists;
- (ITReference *)deviceTracks;
- (ITReference *)encoders;
- (ITReference *)fileTracks;
- (ITReference *)folderPlaylists;
- (ITReference *)items;
- (ITReference *)libraryPlaylists;
- (ITReference *)playlistWindows;
- (ITReference *)playlists;
- (ITReference *)printSettings;
- (ITReference *)radioTunerPlaylists;
- (ITReference *)sharedTracks;
- (ITReference *)sources;
- (ITReference *)tracks;
- (ITReference *)userPlaylists;
- (ITReference *)visuals;
- (ITReference *)windows;

/* Properties */

- (ITReference *)EQ;
- (ITReference *)EQEnabled;
- (ITReference *)address;
- (ITReference *)album;
- (ITReference *)albumArtist;
- (ITReference *)albumRating;
- (ITReference *)albumRatingKind;
- (ITReference *)artist;
- (ITReference *)band1;
- (ITReference *)band10;
- (ITReference *)band2;
- (ITReference *)band3;
- (ITReference *)band4;
- (ITReference *)band5;
- (ITReference *)band6;
- (ITReference *)band7;
- (ITReference *)band8;
- (ITReference *)band9;
- (ITReference *)bitRate;
- (ITReference *)bookmark;
- (ITReference *)bookmarkable;
- (ITReference *)bounds;
- (ITReference *)bpm;
- (ITReference *)capacity;
- (ITReference *)category;
- (ITReference *)class_;
- (ITReference *)closeable;
- (ITReference *)collapseable;
- (ITReference *)collapsed;
- (ITReference *)collating;
- (ITReference *)comment;
- (ITReference *)compilation;
- (ITReference *)composer;
- (ITReference *)container;
- (ITReference *)copies;
- (ITReference *)currentEQPreset;
- (ITReference *)currentEncoder;
- (ITReference *)currentPlaylist;
- (ITReference *)currentStreamTitle;
- (ITReference *)currentStreamURL;
- (ITReference *)currentTrack;
- (ITReference *)currentVisual;
- (ITReference *)data;
- (ITReference *)databaseID;
- (ITReference *)dateAdded;
- (ITReference *)description_;
- (ITReference *)discCount;
- (ITReference *)discNumber;
- (ITReference *)downloaded;
- (ITReference *)duration;
- (ITReference *)enabled;
- (ITReference *)endingPage;
- (ITReference *)episodeID;
- (ITReference *)episodeNumber;
- (ITReference *)errorHandling;
- (ITReference *)faxNumber;
- (ITReference *)finish;
- (ITReference *)fixedIndexing;
- (ITReference *)format;
- (ITReference *)freeSpace;
- (ITReference *)frontmost;
- (ITReference *)fullScreen;
- (ITReference *)gapless;
- (ITReference *)genre;
- (ITReference *)grouping;
- (ITReference *)id_;
- (ITReference *)index;
- (ITReference *)kind;
- (ITReference *)location;
- (ITReference *)longDescription;
- (ITReference *)lyrics;
- (ITReference *)minimized;
- (ITReference *)modifiable;
- (ITReference *)modificationDate;
- (ITReference *)mute;
- (ITReference *)name;
- (ITReference *)pagesAcross;
- (ITReference *)pagesDown;
- (ITReference *)parent;
- (ITReference *)persistentID;
- (ITReference *)playedCount;
- (ITReference *)playedDate;
- (ITReference *)playerPosition;
- (ITReference *)playerState;
- (ITReference *)podcast;
- (ITReference *)position;
- (ITReference *)preamp;
- (ITReference *)printerFeatures;
- (ITReference *)rating;
- (ITReference *)ratingKind;
- (ITReference *)rawData;
- (ITReference *)requestedPrintTime;
- (ITReference *)resizable;
- (ITReference *)sampleRate;
- (ITReference *)seasonNumber;
- (ITReference *)selection;
- (ITReference *)shared;
- (ITReference *)show;
- (ITReference *)shufflable;
- (ITReference *)shuffle;
- (ITReference *)size;
- (ITReference *)skippedCount;
- (ITReference *)skippedDate;
- (ITReference *)smart;
- (ITReference *)songRepeat;
- (ITReference *)sortAlbum;
- (ITReference *)sortAlbumArtist;
- (ITReference *)sortArtist;
- (ITReference *)sortComposer;
- (ITReference *)sortName;
- (ITReference *)sortShow;
- (ITReference *)soundVolume;
- (ITReference *)specialKind;
- (ITReference *)start;
- (ITReference *)startingPage;
- (ITReference *)targetPrinter;
- (ITReference *)time;
- (ITReference *)trackCount;
- (ITReference *)trackNumber;
- (ITReference *)unplayed;
- (ITReference *)updateTracks;
- (ITReference *)version_;
- (ITReference *)videoKind;
- (ITReference *)view;
- (ITReference *)visible;
- (ITReference *)visualSize;
- (ITReference *)visualsEnabled;
- (ITReference *)volumeAdjustment;
- (ITReference *)year;
- (ITReference *)zoomable;
- (ITReference *)zoomed;
- (ITReference *)first;
- (ITReference *)middle;
- (ITReference *)last;
- (ITReference *)any;
- (ITReference *)at:(long)index;
- (ITReference *)byIndex:(id)index;
- (ITReference *)byName:(id)name;
- (ITReference *)byID:(id)id_;
- (ITReference *)previous:(ASConstant *)class_;
- (ITReference *)next:(ASConstant *)class_;
- (ITReference *)at:(long)fromIndex to:(long)toIndex;
- (ITReference *)byRange:(id)fromObject to:(id)toObject;
- (ITReference *)byTest:(ITReference *)testReference;
- (ITReference *)beginning;
- (ITReference *)end;
- (ITReference *)before;
- (ITReference *)after;
- (ITReference *)greaterThan:(id)object;
- (ITReference *)greaterOrEquals:(id)object;
- (ITReference *)equals:(id)object;
- (ITReference *)notEquals:(id)object;
- (ITReference *)lessThan:(id)object;
- (ITReference *)lessOrEquals:(id)object;
- (ITReference *)beginsWith:(id)object;
- (ITReference *)endsWith:(id)object;
- (ITReference *)contains:(id)object;
- (ITReference *)isIn:(id)object;
- (ITReference *)AND:(id)remainingOperands;
- (ITReference *)OR:(id)remainingOperands;
- (ITReference *)NOT;
@end


