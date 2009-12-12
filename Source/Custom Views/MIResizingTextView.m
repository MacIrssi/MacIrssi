//
//  MIResizingTextView.m
//  MacIrssi
//
//  Created by Matt Wright on 09/12/2009.
//  Copyright 2009 Matt Wright Consulting. All rights reserved.
//

#import "MIResizingTextView.h"

@interface MIResizingTextView ()
- (void)_init;
- (void)_resetCacheAndPostSizeChanged;
@end

@implementation MIResizingTextView

- (void)_init
{
  _desiredSizeCache = NSZeroSize;
  _lastPostedSize = NSZeroSize;
  resizing = NO;
  
  // Notifications
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(frameDidChange:) name:NSViewFrameDidChangeNotification object:self];
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

- (id)initWithFrame:(NSRect)frameRect
{
  if (self = [super initWithFrame:frameRect])
  {
    [self _init];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  if (self = [super initWithCoder:aDecoder])
  {
    [self _init];
  }
  return self;
}

#pragma mark Resizing

// These resizing functions are pretty much nabbed from Adium's source. Sorry.
- (NSSize)desiredSize
{
  if (_desiredSizeCache.width == 0)
  {
    float textHeight;
    if ([[self textStorage] length] != 0)
    {
      [[self layoutManager] glyphRangeForTextContainer:[self textContainer]];
      textHeight = [[self layoutManager] usedRectForTextContainer:[self textContainer]].size.height;
    }
    else
    {
      NSAttributedString *string = [[[NSAttributedString alloc] initWithString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789()" attributes:attributes] autorelease];
      textHeight = [string heightWithWidth:1e7];
    }
    
    if (_desiredSizeCache.width == 0)
    {
      _desiredSizeCache = NSMakeSize([self frame].size.width, textHeight + 6.0);
    }
  }
  return _desiredSizeCache;
}

- (void)frameDidChange:(NSNotification*)notification
{
  if (!resizing)
  {
    resizing = YES;
    [self _resetCacheAndPostSizeChanged];
    resizing = NO;
  }
}

- (void)_resetCacheAndPostSizeChanged
{
  _desiredSizeCache = NSMakeSize(0,0);
  
  if (!NSEqualSizes([self desiredSize], _lastPostedSize))
  {
    _lastPostedSize = [self desiredSize];
    [[NSNotificationCenter defaultCenter] postNotificationName:MIViewDesiredSizeDidChangeNotification object:self];
  }
}

@end
