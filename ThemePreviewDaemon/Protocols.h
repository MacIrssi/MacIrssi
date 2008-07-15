#import "Cocoa/Cocoa.h"

@protocol ThemePreviewDaemonProtocol

- (void)requestPreviewForThemeNamed:(in NSString *)theme usingColorSet:(in ColorSet *)set font:(NSFont *)font;
- (void)shutDown;

@end

@protocol ThemePreviewClientProtocol

- (void)daemonInitiationComplete;
- (void)returnPreview:(NSAttributedString *)result;

@end
