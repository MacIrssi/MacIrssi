/*
 ServerBridgeController.h
 Copyright (c) 2008, 2009 Matt Wright.
 
 MacIrssi is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <Cocoa/Cocoa.h>

/* Irssi Headers */
#import "common.h"
#import "servers-setup.h"

@interface ServerBridgeController : NSObject {
  SERVER_SETUP_REC *rec;
}

- (id)initWithServerSetupRec:(SERVER_SETUP_REC*)rec;

- (SERVER_SETUP_REC*)rec;

- (NSString*)address;
- (void)setAddress:(NSString*)value;

- (NSString*)chatnet;
- (void)setChatnet:(NSString*)value;

- (int)port;
- (void)setPort:(int)port;

- (BOOL)autoconnect;
- (void)setAutoconnect:(BOOL)flag;

@end
