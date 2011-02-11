//
//  MIResizingTextView.h
//  MacIrssi
//
//  Created by Matt Wright on 09/12/2009.
//  Copyright 2009 Matt Wright Consulting. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define MIViewDesiredSizeDidChangeNotification		@"MIViewDesiredSizeDidChangeNotification"

@interface MIResizingTextView : NSTextView {
  NSSize _desiredSizeCache;
  NSSize _lastPostedSize;
  BOOL resizing;
}

- (NSSize)desiredSize;
- (void)frameDidChange:(NSNotification*)notification;
- (void)_resetCacheAndPostSizeChanged;
- (void)textDidChange:(NSNotification *)notification;

@end
