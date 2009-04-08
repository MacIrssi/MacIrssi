//*****************************************************************
// MacIrssi - IrssiBridge
// Nils Hjelte, c01nhe@cs.umu.se
//
// Bridge between irssi engine and cocoa GUI
//*****************************************************************

#import "IrssiBridge.h"
#import "AppController.h"
#import "ChannelController.h"

//#define	G_LOG_DOMAIN "MacIrssi"
#define printf(...)
#ifndef MACIRSSI_DEBUG
# define NSLog(...)
#endif

@implementation IrssiBridge
//-------------------------------------------------------------------
// irssiCStringWithString:
// Converts an NSString to irssi encoding/format.
//
// "string" - The string to be converted
// "encoding" - The encoding to use
//
// Returns: A C-string representation of the string, which the sender
// is responsible to release.
//-------------------------------------------------------------------
+ (char *)irssiCStringWithString:(NSString *)string encoding:(CFStringEncoding)encoding
{
	NSData *data = [string dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(encoding) allowLossyConversion:TRUE];
	
	int length = [data length];
	char *str = malloc(length + 1);
	[data getBytes:str];
	
	/* Manually add string termination */
	str[length] = '\0';
	
	return str;
}

/* Wrapper TODO: this should never be used (fix callers of this method) */
+ (char *)irssiCStringWithString:(NSString *)string
{
	return [self irssiCStringWithString:string encoding:kCFStringEncodingISOLatin1];
}

//-------------------------------------------------------------------
// stringWithIrssiCString:
// Converts an irssi string to an NSString.
//
// "string" - The string to be converted
//
// Returns: An NSString representaion of the string
//-------------------------------------------------------------------
+ (NSString *)stringWithIrssiCString:(char *)string
{
	if (!string)
		return @"";
	
	return [(NSString *)CFStringCreateWithCString(NULL, string, kCFStringEncodingISOLatin1) autorelease];
}

//-------------------------------------------------------------------
// stringWithIrssiCStringNoCopy:
// Same as stringWithIrssiCString but shares char buffer with string
//-------------------------------------------------------------------
+ (NSString *)stringWithIrssiCStringNoCopy:(char *)string
{
	return [(NSString *)CFStringCreateWithCStringNoCopy(NULL, string, kCFStringEncodingISOLatin1, kCFAllocatorNull) autorelease];
}

+ (NSString *)stringWithIrssiCStringNoCopy:(char *)string encoding:(CFStringEncoding)encoding
{
  return [(NSString *)CFStringCreateWithCStringNoCopy(NULL, string, encoding, kCFAllocatorNull) autorelease];
}

@end

/****************************************************************
 * Below are receivers of various irssi signals to drive the GUI *
 ****************************************************************/
void textui_deinit(void);
AppController *appController;
ChannelController *windowController;

// Nasty nasty define, but it makes things look prettier
#define CHANNEL_SILENCE_NSSTRING(server, channel) [NSString stringWithFormat:@"%@ - %@", [IrssiBridge stringWithIrssiCString:(char*)server->tag], [IrssiBridge stringWithIrssiCString:(char*)channel]]

void irssibridge_server_setup_read(IRC_SERVER_SETUP_REC *rec, CONFIG_NODE *node)
{	
	//printf("Value: %s\n", rec->chatnet);
}

void irssibridge_channel_mode_changed(CHANNEL_REC *channel, char *setby)
{
	printf("(Channel)Mode change in %s to %s\n", channel->name, channel->mode);
	WINDOW_REC *wind = window_item_window((WI_ITEM_REC *) channel);
  [(ChannelController *)(wind->gui_data) channelModeChanged:channel setBy:setby];
}

void irssibridge_nick_mode_changed(CHANNEL_REC *channel, NICK_REC *nick, char *setby, char *mode, char *type)
{
	NSLog(@"(Nick)Mode change in %s. Nick %s gets mode %s (type:%s)\n", channel->name, nick->nick, mode, type);
  
	WINDOW_REC *wind = window_item_window((WI_ITEM_REC *) channel);
  ChannelController *windowController = wind->gui_data;
  [windowController setMode:mode type:type forNickRec:nick];
  
  if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"eventSilences"] valueForKey:CHANNEL_SILENCE_NSSTRING(channel->server, channel->name)] ||
      ![[[[NSUserDefaults standardUserDefaults] valueForKey:@"eventSilences"] valueForKey:CHANNEL_SILENCE_NSSTRING(channel->server, channel->name)] boolValue])
  {
    NSString *message = @"";
    NSString *event = @"";
    
    switch (*mode)
    {
      case '@':
        if (*type == '+')
        {
          message = [NSString stringWithFormat:@"%s was promoted to operator in %s by %s.", nick->nick, channel->name, setby];
          event = @"IRSSI_ROOM_OP";
        }
        else
        {
          message = [NSString stringWithFormat:@"%s was demoted from operator in %s by %s.", nick->nick, channel->name, setby];
          event = @"IRSSI_ROOM_DEOP";
        }
        break;
      case '%':
        if (*type == '+')
        {
          message = [NSString stringWithFormat:@"%s was promoted to half-operator in %s by %s.", nick->nick, channel->name, setby];
          event = @"IRSSI_ROOM_HALFOP";
        }
        else
        {
          message = [NSString stringWithFormat:@"%s was demoted from half-operator in %s by %s.", nick->nick, channel->name, setby];
          event = @"IRSSI_ROOM_DEHALFOP";
        }      
        break;
      case '+':
        if (*type == '+')
        {
          message = [NSString stringWithFormat:@"%s was given voice in %s by %s.", nick->nick, channel->name, setby];
          event = @"IRSSI_ROOM_VOICE";
        }
        else
        {
          message = [NSString stringWithFormat:@"%s was de-voiced in %s by %s.", nick->nick, channel->name, setby];
          event = @"IRSSI_ROOM_DEVOICE";
        }      
        break;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:event object:windowController userInfo:[NSDictionary dictionaryWithObject:message forKey:@"Description"]];
  }  
}

void irssibridge_user_mode_changed(SERVER_REC *server, char *old)
{
	NSLog(@"(User)Mode change (old: %s)", old);
}

void irssibridge_away_mode_changed(SERVER_REC *server)
{
	printf("(Away)Mode change: %s\n", server->away_reason);
}

void irssibridge_server_disconnected(SERVER_REC *server)
{
	NSLog(@"Server disconnected");
}

void irssibridge_server_connected(SERVER_REC *server)
{
	NSLog(@"Server connected");
}

void irssibridge_event_connected(void)
{
  NSLog(@"Event connected");
  [[NSNotificationCenter defaultCenter] postNotificationName:@"IRSSI_SERVER_CONNECTED" object:nil];
}

void setRefToAppController(AppController *a)
{
	appController = a;
}

void irssibridge_channel_joined(CHANNEL_REC *channel)
{
	WINDOW_REC *wind = window_item_window((WI_ITEM_REC *) channel);
	[(ChannelController *)(wind->gui_data) channelJoined:channel];
	[appController channelJoined:wind];
}

void irssibridge_channel_wholist(CHANNEL_REC *channel)
{
	//WINDOW_REC *wind = window_item_window((WI_ITEM_REC *) channel);
	//[(ChannelController *)(wind->gui_data) whoListReceived];
}

void irssibridge_channel_destroyed(CHANNEL_REC *channel)
{
	NSLog(@"destroyed channel %p",[NSThread currentThread]);
  
	WINDOW_REC *wind = window_item_window((WI_ITEM_REC *) channel);
	
	if (wind) {
		[(ChannelController *)(wind->gui_data) clearNickView];
		//[appController removeTabWithWindowRec:wind];
	}
}

void irssibridge_print_text(WINDOW_REC *wind, int fg, int bg, int flags, char *text, TEXT_DEST_REC *dest_rect) {
  [(ChannelController *)(wind->gui_data) printText:text forground:fg background:bg flags:flags];
}

void irssibridge_print_text_finished(WINDOW_REC *wind) {
  //[(ChannelController *)(wind->gui_data) finishLine];
	[(ChannelController *)(wind->gui_data) performSelectorOnMainThread:@selector(finishLine) withObject:nil waitUntilDone:TRUE];
}

void irssibridge_window_created(WINDOW_REC *wind) {
  [appController newTabWithWindowRec:wind];
}

void irssibridge_window_changed(WINDOW_REC *wind, WINDOW_REC *oldwind) {
  [appController windowChanged:wind withOldWind:oldwind];
}

void irssibridge_window_changed_automatic(WINDOW_REC *wind) {
	printf("change auto\n");
}

void irssibridge_window_history_changed(WINDOW_REC *wind, char *oldname) {
	printf("history change\n");
}

void irssibridge_window_refnum_changed(WINDOW_REC *wind, int old) {
	[appController refnumChanged:wind old:old];
}

void irssibridge_window_destroyed(WINDOW_REC *wind) {
	NSLog(@"destroyed window %p",[NSThread currentThread]);
  
	[(ChannelController *)(wind->gui_data) clearNickView];
  [appController removeTabWithWindowRec:wind];
  
}

void irssibridge_window_item_new(WINDOW_REC *wind, WI_ITEM_REC *wir) {
	printf("irssibridge_window_item_new\n");
}

void irssibridge_window_item_changed(WINDOW_REC *wind, WI_ITEM_REC *wir) {
	printf("irssibridge_window_item_changed\n");
}

void irssibridge_window_name_changed(WINDOW_REC *wind) {
	printf("irssibridge_window_name_changed\n");
}

void irssibridge_channel_topic_changed(CHANNEL_REC * chan) {
	//printf("Topic changed in channel:%s\n", chan->name);
  WINDOW_REC *wind = window_item_window((WI_ITEM_REC *) chan);
  [(ChannelController *)(wind->gui_data) setTopic:chan->topic setBy:chan->topic_by atTime:chan->topic_time];
}

void irssibridge_query_created(QUERY_REC *qr, int automatic) {
	//printf("Auto: %s\n", automatic ? "YES":"NO");
	[appController queryCreated:qr automatically:automatic];
}

void irssibridge_window_server_changed(WINDOW_REC *wind, SERVER_REC *serv) {
	if (!serv || !serv->tag)
		return;
	[appController setServer:[NSString stringWithCString:serv->tag]];
}

void irssibridge_window_level_changed(WINDOW_REC *wind) {
	printf("irssibridge_window_level_changed\n");
}

void irssibridge_window_activity(WINDOW_REC *wind, int old_level) {
	[appController windowActivity:wind oldLevel:old_level];
}

void irssibridge_window_hilight(WINDOW_REC *wind)
{
  [appController highlightChanged:wind];
}

void irssibridge_gui_exit(void) {
	[appController irssiQuit];
}

void irssibridge_nicklist_new(CHANNEL_REC *channel, NICK_REC *nick)
{
	NSLog(@"irssibridge_nicklist_new: %s", nick->nick);
	WINDOW_REC *wind;
	/* Only use after initial names list is recieved */
	if (!channel->names_got)
		return;
	wind = window_item_window((WI_ITEM_REC *) channel);
	[(ChannelController *)(wind->gui_data) addNickRec:nick];
}

void irssibridge_nicklist_remove(CHANNEL_REC *channel, NICK_REC *nick)
{
	NSLog(@"irssibridge_nicklist_remove: %s", nick->nick);
  
	WINDOW_REC *wind;
	if (channel->destroying)
		return;
	wind = window_item_window((WI_ITEM_REC *) channel);
	[(ChannelController *)(wind->gui_data) removeNickRec:nick];
}

void irssibridge_nicklist_changed(CHANNEL_REC *channel, NICK_REC *nick, char *old_nick)
{
	NSLog(@"irssibridge_nicklist_changed");
  
	WINDOW_REC *wind;
	wind = window_item_window((WI_ITEM_REC *) channel);
	[(ChannelController *)(wind->gui_data) changeNickForNickRec:nick fromNick:old_nick];
}

void irssibridge_nicklist_host_changed(CHANNEL_REC *channel, NICK_REC *nick)
{
	/* Only use after initial names list is recieved */
	if (!channel->wholist)
		return;
	
	printf("[nicklist host changed] nick:%s\n", nick->nick);
  
}

void irssibridge_nicklist_gone_changed(CHANNEL_REC *channel, NICK_REC *nick)
{
	/* Only use after initial names list is recieved */
	if (!channel->wholist)
		return;
	
	printf("[nicklist gone changed] nick:%s\n", nick->nick);
  
}

void irssibridge_nicklist_serverop_changed(CHANNEL_REC *channel, NICK_REC *nick)
{
	//printf("[nicklist serverop changed] nick:%s\tserverop: %d\n", nick->nick, nick->serverop);
	WINDOW_REC *wind;
	wind = window_item_window((WI_ITEM_REC *) channel);
	[(ChannelController *)(wind->gui_data) changeServerOpForNickRec:nick];
}


void irssibridge_message_join(SERVER_REC *server, const char *channel, const char *nick, const char *address)
{
	NSLog(@"[Join event] channel:%s nick:%s\n", channel, nick);
  
  if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"eventSilences"] valueForKey:CHANNEL_SILENCE_NSSTRING(server, channel)] ||
      ![[[[NSUserDefaults standardUserDefaults] valueForKey:@"eventSilences"] valueForKey:CHANNEL_SILENCE_NSSTRING(server, channel)] boolValue])
  {
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%s joined the chat room %s.", nick, channel], @"Description", 
                          [NSString stringWithFormat:@"%s", server->tag], @"Server", 
                          [NSString stringWithFormat:@"%s", channel], @"Channel", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"IRSSI_ROOM_JOIN" object:nil userInfo:info];
  }
}

void irssibridge_message_part(SERVER_REC *server, const char *channel, const char *nick, const char *address, const char *reason)
{
	NSLog(@"[Part event] channel:%s nick:%s\n", channel, nick);
  
  if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"eventSilences"] valueForKey:CHANNEL_SILENCE_NSSTRING(server, channel)] ||
      ![[[[NSUserDefaults standardUserDefaults] valueForKey:@"eventSilences"] valueForKey:CHANNEL_SILENCE_NSSTRING(server, channel)] boolValue])
  {
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%s has left the chat room %s.", nick, channel], @"Description", 
                      [NSString stringWithFormat:@"%s", server->tag], @"Server",
                      [NSString stringWithFormat:@"%s", channel], @"Channel", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"IRSSI_ROOM_PART" object:nil userInfo:info];
  }
}

void irssibridge_message_quit(SERVER_REC *server, const char *nick, const char *address, const char *reason)
{
	NSLog(@"[Quit event] nick:%s\n", nick);
}

void irssibridge_message_kick(SERVER_REC *server, const char *channel, const char *nick, const char *kicker, const char *address, const char *reason)
{
	NSLog(@"[Kick event] channel:%s nick:%s\n", channel, nick);
  
  if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"eventSilences"] valueForKey:CHANNEL_SILENCE_NSSTRING(server, channel)] ||
      ![[[[NSUserDefaults standardUserDefaults] valueForKey:@"eventSilences"] valueForKey:CHANNEL_SILENCE_NSSTRING(server, channel)] boolValue])
  {
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%s was kicked from %s by %s.", nick, channel, kicker], @"Description",
                          [NSString stringWithFormat:@"%s", server->tag], @"Server",
                          [NSString stringWithFormat:@"%s", channel], @"Channel", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"IRSSI_ROOM_KICK" object:nil userInfo:info];
  }
}

void irssibridge_message_notice(SERVER_REC *server, const char *msg, const char *nick, const char *address, const char *target)
{
  NSLog(@"[Notice event] nick: %s target: %s msg: %s", nick, target, msg);
  
  NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%s", msg], @"Description", [NSString stringWithFormat:@"Notice message from %s.", nick], @"Title", nil];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"IRSSI_NOTICE" object:nil userInfo:info];
}

void irssibridge_message_private(SERVER_REC *server, char *msg, char *nick, char *address)
{
  NSLog(@"[Private event] nick: %s msg: %s", nick, msg);
  
  QUERY_REC *rec = query_find(server, nick);
  
  // existing PM
  if (rec) 
  {
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:[IrssiBridge stringWithIrssiCString:msg], @"Description",
                          [NSString stringWithFormat:@"Private Message from %s.", nick], @"Title", 
                          [NSString stringWithFormat:@"%s", server->tag], @"Server",
                          [NSString stringWithFormat:@"%s", nick], @"Channel", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"IRSSI_QUERY_OLD" object:nil userInfo:info];  
  }
  else
  {
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:[IrssiBridge stringWithIrssiCString:msg], @"Description",
                          [NSString stringWithFormat:@"New Private Message from %s.", nick], @"Title", 
                          [NSString stringWithFormat:@"%s", server->tag], @"Server",
                          [NSString stringWithFormat:@"%s", nick], @"Channel", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"IRSSI_QUERY_NEW" object:nil userInfo:info];
  }
}

void irssibridge_message_channel(SERVER_REC *server, char *msg, char *nick, char *address, char *target)
{
  NSLog(@"[Public event] nick: %s target: %s address: %s msg: %s", nick, target, address, msg);
  // find the channel
  CHANNEL_REC *channel = channel_find(server, target);
  if (!channel)
  {
    NSLog(@"[Public event] Could not infer CHANNEL_REC from SERVER_REC + %s", target);
    return;
  }
  WINDOW_REC *window = window_item_window((WI_ITEM_REC*)channel);
  ChannelController *controller = (ChannelController*)window->gui_data;
    
  [controller setWaitingEvents:[controller waitingEvents]+1];
  [controller setLastEventOwner:[IrssiBridge stringWithIrssiCString:nick]];
  
  if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"eventSilences"] valueForKey:CHANNEL_SILENCE_NSSTRING(server, channel->name)] ||
      ![[[[NSUserDefaults standardUserDefaults] valueForKey:@"eventSilences"] valueForKey:CHANNEL_SILENCE_NSSTRING(server, channel->name)] boolValue])
  {
    NSString *eventDescription;
    
    if ([controller waitingEvents] == 1)
    {
      eventDescription = [NSString stringWithFormat:@"%@ has a message waiting from %@.", [controller name], [controller lastEventOwner]];
    }
    else
    {
      eventDescription = [NSString stringWithFormat:@"%@ has %d messages waiting. Last from %@.", [controller name], [controller waitingEvents], [controller lastEventOwner]];
    }
    
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:eventDescription, @"Description", 
                          [NSString stringWithFormat:@"Activity in %@", [controller name]], @"Title", 
                          [NSNumber numberWithBool:YES], @"Coalesce",
                          nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"IRSSI_ROOM_ACTIVITY" object:controller userInfo:info];
  }  
}