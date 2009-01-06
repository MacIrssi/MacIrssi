/*
 * ITCommandGlue.h
 *
 * /Applications/iTunes.app
 * osaglue 0.4.0
 *
 */

#import <Foundation/Foundation.h>


#import "Appscript/Appscript.h"
#import "ITReferenceRendererGlue.h"


@interface ITCommand : ASCommand
@end

@interface ITActivateCommand : ITCommand
@end


@interface ITAddCommand : ITCommand
- (ITAddCommand *)to:(id)value;
@end


@interface ITBackTrackCommand : ITCommand
@end


@interface ITCloseCommand : ITCommand
@end


@interface ITConvertCommand : ITCommand
@end


@interface ITCountCommand : ITCommand
- (ITCountCommand *)each:(id)value;
@end


@interface ITDeleteCommand : ITCommand
@end


@interface ITDownloadCommand : ITCommand
@end


@interface ITDuplicateCommand : ITCommand
- (ITDuplicateCommand *)to:(id)value;
@end


@interface ITEjectCommand : ITCommand
@end


@interface ITExistsCommand : ITCommand
@end


@interface ITFastForwardCommand : ITCommand
@end


@interface ITGetCommand : ITCommand
@end


@interface ITLaunchCommand : ITCommand
@end


@interface ITMakeCommand : ITCommand
- (ITMakeCommand *)at:(id)value;
- (ITMakeCommand *)new_:(id)value;
- (ITMakeCommand *)withProperties:(id)value;
@end


@interface ITMoveCommand : ITCommand
- (ITMoveCommand *)to:(id)value;
@end


@interface ITNextTrackCommand : ITCommand
@end


@interface ITOpenCommand : ITCommand
@end


@interface ITOpenLocationCommand : ITCommand
@end


@interface ITPauseCommand : ITCommand
@end


@interface ITPlayCommand : ITCommand
- (ITPlayCommand *)once:(id)value;
@end


@interface ITPlaypauseCommand : ITCommand
@end


@interface ITPreviousTrackCommand : ITCommand
@end


@interface ITPrintCommand : ITCommand
- (ITPrintCommand *)kind:(id)value;
- (ITPrintCommand *)printDialog:(id)value;
- (ITPrintCommand *)theme:(id)value;
- (ITPrintCommand *)withProperties:(id)value;
@end


@interface ITQuitCommand : ITCommand
@end


@interface ITRefreshCommand : ITCommand
@end


@interface ITReopenCommand : ITCommand
@end


@interface ITResumeCommand : ITCommand
@end


@interface ITRevealCommand : ITCommand
@end


@interface ITRewindCommand : ITCommand
@end


@interface ITRunCommand : ITCommand
@end


@interface ITSearchCommand : ITCommand
- (ITSearchCommand *)for_:(id)value;
- (ITSearchCommand *)only:(id)value;
@end


@interface ITSetCommand : ITCommand
- (ITSetCommand *)to:(id)value;
@end


@interface ITStopCommand : ITCommand
@end


@interface ITSubscribeCommand : ITCommand
@end


@interface ITUpdateCommand : ITCommand
@end


@interface ITUpdateAllPodcastsCommand : ITCommand
@end


@interface ITUpdatePodcastCommand : ITCommand
@end


