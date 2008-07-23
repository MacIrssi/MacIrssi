/*
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <time.h>
#import "History.h"
#import "common.h"
#import "signals.h"
#import "channels.h"
#import "nicklist.h"
#import "glib.h"
#import "MarkedScroller.h"

#import "fe-windows.h"

#define MAX_LINE 1024
// enough to hold max line (512 bytes according to rfc1459) + some additional space

@class AppController;
@class ColorSet;
//int mircColors[] = { 15, 0, 1, 2, 12, 4, 5, 6, 14, 10, 3, 11, 9, 13, 8, 7 };

enum nickContextMenuTags {
	Query,
	Whois,
	Who,

	Ignore,
	Op,
	Deop,
	Voice,
	Devoice,
	Kick,
	Ban,
	KickBan,

	Ping,
	Finger,
	Version,
	Time,
	Userinfo,
	Clientinfo,

	Send,
	Chat,
	List,
	CopyIP
};

@interface ChannelController : NSObject {
	
	NSString *name;
	NSString *topic_by;
	time_t topic_time;

	NSMutableArray *nicks; /* list of nicks */
	NICK_REC *ownnick; /* our own nick */
	CHANNEL_REC *channel;

	BOOL no_modes; /* channel doesn't support modes */
	NSString *mode;
	int limit; /* user limit */
	NSString *key; /* password key */

	BOOL chanop; /* You're a channel operator */
	BOOL names_got; /* Received /NAMES list */
	BOOL wholist; /* WHO list got */
	BOOL synced; /* Channel synced - all queries done */

	BOOL joined; /* Have we even received JOIN event for this channel? */
	BOOL justLeft; /* You just left the channel */
	BOOL kicked; /* You just got kicked */
	BOOL session_rejoin; /* This channel was joined with /UPGRADE */
	BOOL destroying;
	
	/* Topic window */
	IBOutlet NSWindow *topicWindow;
	IBOutlet NSTextField *topicEditableTextField;
	IBOutlet NSTextField *topicByTextField;
	IBOutlet NSTextField *topicTimeTextField;
	IBOutlet NSButton *inviteCheckBox;
	IBOutlet NSButton *moderatedCheckBox;
	IBOutlet NSButton *privateCheckBox;
	IBOutlet NSButton *secretCheckBox;
	IBOutlet NSButton *noExternalMessagesCheckBox;
	IBOutlet NSButton *onlyOpsCanChangeTopicCheckBox;
	IBOutlet NSTextField *maxUsersTextField;
	IBOutlet NSTextField *keyTextField;
	IBOutlet NSButton *saveButton;
	IBOutlet NSButton *cancelButton;
	IBOutlet NSButton *floaterCheckBox;
	IBOutlet NSPopUpButton *textEncodingPopUpButton;

	/* Reason window */
	IBOutlet NSWindow *reasonWindow;

	/* Main view */
    IBOutlet NSTextView *mainTextView;
    IBOutlet NSScrollView *mainTextScrollView;
	IBOutlet NSTableView *nickTableView;
    IBOutlet NSTextField *topicTextField;
    IBOutlet NSView *wholeView;
	IBOutlet NSSplitView *splitView;
	IBOutlet NSButton *editChannelButton;
    IBOutlet NSScrollView *nickTableScrollView;

	/* Context menus */
	IBOutlet NSMenu *nickViewMenu;
	IBOutlet NSMenu *mainTextViewMenu;

	IBOutlet NSSearchField *searchField;
	MarkedScroller *scroller;
	NSTabViewItem *tabViewItem;
	NSRange endRange;
	NSMutableDictionary *textAttributes;
	NSMutableDictionary *topicAttributes;
	NSMutableDictionary *nickAttributes;
	NSMutableArray *fg_colors;
	NSMutableArray *bg_colors;//TODO
	WINDOW_REC *windowRec;
	BOOL modeChanged;
	NSColor *opColor;
	NSColor *halfOpColor;
	NSColor *voiceColor;
	NSColor *defaultColor;
	NSColor *serverOpColor;
	NSColor *defaultTextColor;

	NSColor *searchColor;
	NSColor *currentSearchMatchColor;
	NSTextStorage *textStorage;
	NSString *searchString;
	NSMutableArray *searchRanges;
	AppController *appController;
	ColorSet *colorSet;
	NSMutableString *commandWithReason;
	char linebuf[MAX_LINE]; 
	int linebufIndex;
	NSRange attrRanges[MAX_LINE];
	int attrRangesIndex;
	bool useFloater;
	bool isChannel;
	bool scrollState;
	CFStringEncoding textEncoding;
	NSMutableAttributedString *line;
	int searchIteratorIndex;
	NSRange oldSearchMatchRange;
	//int currentDataLevel;
	
	History *commandHistory;
	NSString *partialCommand;
}
- (NSString *)mode;
- (NSArray *)nicks;
- (void)saveScrollState;
- (bool)scrollState;
- (void)moveToNextSearchMatch;
- (void)moveToPreviousSearchMatch;
- (void)highlightCurrentSearchMatch;

- (BOOL)isChannel;
- (id)init;
- (id)initWithWindowRec:(WINDOW_REC *)rec;
- (void)dealloc;
- (BOOL)hasActiveSearch;

- (NSView *)view;
- (WINDOW_REC *)windowRec;
- (NSString *)name;
- (void)setName:(NSString *)newName;

- (History *)commandHistory;
- (NSString *)partialCommand;
- (void)setPartialCommand:(NSString*)cmd;

- (void)channelModeChanged:(CHANNEL_REC *)rec setBy:(char *)setter;
- (void)setTabViewItem:(NSTabViewItem *)newTabViewItem colors:(ColorSet *)colors appController:(AppController *)ref;
- (NSTabViewItem *)tabViewItem;
- (NSTextView *)mainTextView;

/* Nicklist */
- (void)addNickRec:(NICK_REC *)nick;
- (void)removeNickRec:(NICK_REC *)nick;
- (void)changeNickForNickRec:(NICK_REC *)rec fromNick:(char *)oldNick;
- (void)changeServerOpForNickRec:(NICK_REC *)rec;
- (void)setMode:(char *)mode type:(char *)type forNickRec:(NICK_REC *)nick;
- (void)sortNicks;
- (void)sortNicksWithLeftBound:(int)left rightBound:(int)right;
- (int)findNick:(NICK_REC *)nick;
- (int)findNickLinear:(NICK_REC *)nick;
- (int)findInsertionPositionForNick:(NICK_REC *)nick;
- (NSAttributedString *)parseTopic:(char *)str;
- (void)initTextEncodingPopUpButton;
- (void)updateTextEncodingPopUpButton;
- (CFStringEncoding)textEncoding;

/* GUI actions */
- (IBAction)raiseTopicWindow:(id)sender;
- (IBAction)endTopicWindow:(id)sender;
- (IBAction)endReasonWindow:(id)sender;
- (IBAction)modeChanged:(id)sender;
- (IBAction)nickViewMenuClicked:(id)sender;
- (IBAction)mainTextViewMenuClicked:(id)sender;
- (IBAction)performSearch:(id)sender;

- (void)setFont:(NSFont *)font;
- (float)yPositionInTextView:(NSRange)r;
- (void)makeSearchFieldFirstResponder;

- (void)clearTextView;
- (void)setTopic:(char *)newTopic setBy:(char *)setter atTime:(time_t)time;
- (NSString *)topic;
- (void)printText:(char *)text forground:(int)fg background:(int)bg flags:(int)flags;
- (void)finishLine;
- (void)channelColorChanged:(NSNotification *)note;
- (void)nickListColorChanged:(NSNotification *)note;
- (void)awakeFromNib;
- (void)channelJoined:(CHANNEL_REC *)rec;
- (void)clearNickView;
- (void)queryCreated:(QUERY_REC *)rec;
//- (void)setCurrentDataLevel:(int)level;
- (void)searchForString:(NSString *)string;

- (void)nickListRowDoubleClicked:(id)sender;
- (void)setTextEncoding:(CFStringEncoding)encoding;

/* Text Field delegate */
- (void)controlTextDidChange:(NSNotification *)aNotification;

/* Context menu delegate */
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem;

/* for NSTableView's dataSource outlet */
- (int)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
@end

void setController(ChannelController *tmp);
void personFromNickRec(gpointer key, NICK_REC *rec, NSMutableArray *nicks);
