/*
 * ITCommandGlue.m
 *
 * /Applications/iTunes.app
 * osaglue 0.4.0
 *
 */

#import "ITCommandGlue.h"

@implementation ITCommand
- (NSString *)AS_formatObject:(id)obj appData:(id)appData{
    return [ITReferenceRenderer formatObject: obj appData: appData];
}
@end

@implementation ITActivateCommand

- (NSString *)AS_commandName {
    return @"activate";
}

@end


@implementation ITAddCommand

- (ITAddCommand *)to:(id)value {
    [AS_event setParameter: value forKeyword: 'insh'];
    return self;
}

- (NSString *)AS_commandName {
    return @"add";
}

- (NSString *)AS_parameterNameForCode:(DescType)code {
    switch (code) {
        case 'insh':
            return @"to";
    }
    return [super AS_parameterNameForCode: code];
}

@end


@implementation ITBackTrackCommand

- (NSString *)AS_commandName {
    return @"backTrack";
}

@end


@implementation ITCloseCommand

- (NSString *)AS_commandName {
    return @"close";
}

@end


@implementation ITConvertCommand

- (NSString *)AS_commandName {
    return @"convert";
}

@end


@implementation ITCountCommand

- (ITCountCommand *)each:(id)value {
    [AS_event setParameter: value forKeyword: 'kocl'];
    return self;
}

- (NSString *)AS_commandName {
    return @"count";
}

- (NSString *)AS_parameterNameForCode:(DescType)code {
    switch (code) {
        case 'kocl':
            return @"each";
    }
    return [super AS_parameterNameForCode: code];
}

@end


@implementation ITDeleteCommand

- (NSString *)AS_commandName {
    return @"delete";
}

@end


@implementation ITDownloadCommand

- (NSString *)AS_commandName {
    return @"download";
}

@end


@implementation ITDuplicateCommand

- (ITDuplicateCommand *)to:(id)value {
    [AS_event setParameter: value forKeyword: 'insh'];
    return self;
}

- (NSString *)AS_commandName {
    return @"duplicate";
}

- (NSString *)AS_parameterNameForCode:(DescType)code {
    switch (code) {
        case 'insh':
            return @"to";
    }
    return [super AS_parameterNameForCode: code];
}

@end


@implementation ITEjectCommand

- (NSString *)AS_commandName {
    return @"eject";
}

@end


@implementation ITExistsCommand

- (NSString *)AS_commandName {
    return @"exists";
}

@end


@implementation ITFastForwardCommand

- (NSString *)AS_commandName {
    return @"fastForward";
}

@end


@implementation ITGetCommand

- (NSString *)AS_commandName {
    return @"get";
}

@end


@implementation ITLaunchCommand

- (NSString *)AS_commandName {
    return @"launch";
}

@end


@implementation ITMakeCommand

- (ITMakeCommand *)at:(id)value {
    [AS_event setParameter: value forKeyword: 'insh'];
    return self;
}

- (ITMakeCommand *)new_:(id)value {
    [AS_event setParameter: value forKeyword: 'kocl'];
    return self;
}

- (ITMakeCommand *)withProperties:(id)value {
    [AS_event setParameter: value forKeyword: 'prdt'];
    return self;
}

- (NSString *)AS_commandName {
    return @"make";
}

- (NSString *)AS_parameterNameForCode:(DescType)code {
    switch (code) {
        case 'insh':
            return @"at";
        case 'kocl':
            return @"new_";
        case 'prdt':
            return @"withProperties";
    }
    return [super AS_parameterNameForCode: code];
}

@end


@implementation ITMoveCommand

- (ITMoveCommand *)to:(id)value {
    [AS_event setParameter: value forKeyword: 'insh'];
    return self;
}

- (NSString *)AS_commandName {
    return @"move";
}

- (NSString *)AS_parameterNameForCode:(DescType)code {
    switch (code) {
        case 'insh':
            return @"to";
    }
    return [super AS_parameterNameForCode: code];
}

@end


@implementation ITNextTrackCommand

- (NSString *)AS_commandName {
    return @"nextTrack";
}

@end


@implementation ITOpenCommand

- (NSString *)AS_commandName {
    return @"open";
}

@end


@implementation ITOpenLocationCommand

- (NSString *)AS_commandName {
    return @"openLocation";
}

@end


@implementation ITPauseCommand

- (NSString *)AS_commandName {
    return @"pause";
}

@end


@implementation ITPlayCommand

- (ITPlayCommand *)once:(id)value {
    [AS_event setParameter: value forKeyword: 'POne'];
    return self;
}

- (NSString *)AS_commandName {
    return @"play";
}

- (NSString *)AS_parameterNameForCode:(DescType)code {
    switch (code) {
        case 'POne':
            return @"once";
    }
    return [super AS_parameterNameForCode: code];
}

@end


@implementation ITPlaypauseCommand

- (NSString *)AS_commandName {
    return @"playpause";
}

@end


@implementation ITPreviousTrackCommand

- (NSString *)AS_commandName {
    return @"previousTrack";
}

@end


@implementation ITPrintCommand

- (ITPrintCommand *)kind:(id)value {
    [AS_event setParameter: value forKeyword: 'pKnd'];
    return self;
}

- (ITPrintCommand *)printDialog:(id)value {
    [AS_event setParameter: value forKeyword: 'pdlg'];
    return self;
}

- (ITPrintCommand *)theme:(id)value {
    [AS_event setParameter: value forKeyword: 'pThm'];
    return self;
}

- (ITPrintCommand *)withProperties:(id)value {
    [AS_event setParameter: value forKeyword: 'prdt'];
    return self;
}

- (NSString *)AS_commandName {
    return @"print";
}

- (NSString *)AS_parameterNameForCode:(DescType)code {
    switch (code) {
        case 'pKnd':
            return @"kind";
        case 'pdlg':
            return @"printDialog";
        case 'pThm':
            return @"theme";
        case 'prdt':
            return @"withProperties";
    }
    return [super AS_parameterNameForCode: code];
}

@end


@implementation ITQuitCommand

- (NSString *)AS_commandName {
    return @"quit";
}

@end


@implementation ITRefreshCommand

- (NSString *)AS_commandName {
    return @"refresh";
}

@end


@implementation ITReopenCommand

- (NSString *)AS_commandName {
    return @"reopen";
}

@end


@implementation ITResumeCommand

- (NSString *)AS_commandName {
    return @"resume";
}

@end


@implementation ITRevealCommand

- (NSString *)AS_commandName {
    return @"reveal";
}

@end


@implementation ITRewindCommand

- (NSString *)AS_commandName {
    return @"rewind";
}

@end


@implementation ITRunCommand

- (NSString *)AS_commandName {
    return @"run";
}

@end


@implementation ITSearchCommand

- (ITSearchCommand *)for_:(id)value {
    [AS_event setParameter: value forKeyword: 'pTrm'];
    return self;
}

- (ITSearchCommand *)only:(id)value {
    [AS_event setParameter: value forKeyword: 'pAre'];
    return self;
}

- (NSString *)AS_commandName {
    return @"search";
}

- (NSString *)AS_parameterNameForCode:(DescType)code {
    switch (code) {
        case 'pTrm':
            return @"for_";
        case 'pAre':
            return @"only";
    }
    return [super AS_parameterNameForCode: code];
}

@end


@implementation ITSetCommand

- (ITSetCommand *)to:(id)value {
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


@implementation ITStopCommand

- (NSString *)AS_commandName {
    return @"stop";
}

@end


@implementation ITSubscribeCommand

- (NSString *)AS_commandName {
    return @"subscribe";
}

@end


@implementation ITUpdateCommand

- (NSString *)AS_commandName {
    return @"update";
}

@end


@implementation ITUpdateAllPodcastsCommand

- (NSString *)AS_commandName {
    return @"updateAllPodcasts";
}

@end


@implementation ITUpdatePodcastCommand

- (NSString *)AS_commandName {
    return @"updatePodcast";
}

@end


