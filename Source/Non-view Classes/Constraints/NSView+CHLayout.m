//
//  NSView+CHLayout.m
//  CHLayoutManager
/**
 Copyright (c) 2010 Dave DeLong
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 **/

#import "NSView+CHLayout.h"
#import "CHLayoutManager.h"

#define CHScalarRect(_s) (NSMakeRect((_s), 0, 0, 0))
#define CHPointRect(_x,_y) (NSMakeRect((_x), (_y), 0, 0))

#define CHRectScalar(_r) ((_r).origin.x)
#define CHRectPoint(_r) ((_r).origin)

#define CHSetMinX(_r,_v) ((_r).origin.x = (_v))
#define CHSetMinY(_r,_v) ((_r).origin.y = (_v))
#define CHSetMidX(_r,_v) ((_r).origin.x = (_v) - ((_r).size.width/2))
#define CHSetMidY(_r,_v) ((_r).origin.y = (_v) - ((_r).size.height/2))
#define CHSetMaxX(_r,_v) ((_r).origin.x = (_v) - (_r).size.width)
#define CHSetMaxY(_r,_v) ((_r).origin.y = (_v) - (_r).size.height)

@implementation NSView (CHLayout)

- (void) setLayoutName:(NSString *)newLayoutName {
	[[CHLayoutManager sharedLayoutManager] setLayoutName:newLayoutName forView:self];
}

- (NSString *) layoutName {
	return [[CHLayoutManager sharedLayoutManager] layoutNameForView:self];
}

- (void) addLayoutConstraint:(CHLayoutConstraint *)constraint {
	[[CHLayoutManager sharedLayoutManager] addConstraint:constraint toView:self];
}

- (NSArray *) layoutConstraints {
	return [[CHLayoutManager sharedLayoutManager] constraintsOnView:self];
}

- (void) removeAllLayoutConstraints {
	[[CHLayoutManager sharedLayoutManager] removeConstraintsFromView:self];
}

- (NSRect) valueForLayoutAttribute:(CHLayoutConstraintAttribute)attribute {
	NSRect frame = [self frame];
	NSRect bounds = [self bounds];
	switch (attribute) {
		case CHLayoutConstraintAttributeMinY:
			return CHScalarRect(NSMinY(frame));
		case CHLayoutConstraintAttributeMaxY:
			return CHScalarRect(NSMaxY(frame));
		case CHLayoutConstraintAttributeMinX:
			return CHScalarRect(NSMinX(frame));
		case CHLayoutConstraintAttributeMaxX:
			return CHScalarRect(NSMaxX(frame));
		case CHLayoutConstraintAttributeWidth:
			return CHScalarRect(NSWidth(frame));
		case CHLayoutConstraintAttributeHeight:
			return CHScalarRect(NSHeight(frame));
		case CHLayoutConstraintAttributeMidY:
			return CHScalarRect(NSMidY(frame));
		case CHLayoutConstraintAttributeMidX:
			return CHScalarRect(NSMidX(frame));
		case CHLayoutConstraintAttributeMinXMinY:
			return CHPointRect(NSMinX(frame), NSMinY(frame));
		case CHLayoutConstraintAttributeMinXMidY:
			return CHPointRect(NSMinX(frame), NSMidY(frame));
		case CHLayoutConstraintAttributeMinXMaxY:
			return CHPointRect(NSMinX(frame), NSMaxY(frame));
		case CHLayoutConstraintAttributeMidXMinY:
			return CHPointRect(NSMidX(frame), NSMinY(frame));
		case CHLayoutConstraintAttributeMidXMidY:
			return CHPointRect(NSMidX(frame), NSMidY(frame));
		case CHLayoutConstraintAttributeMidXMaxY:
			return CHPointRect(NSMidX(frame), NSMaxY(frame));
		case CHLayoutConstraintAttributeMaxXMinY:
			return CHPointRect(NSMaxX(frame), NSMinY(frame));
		case CHLayoutConstraintAttributeMaxXMidY:
			return CHPointRect(NSMaxX(frame), NSMidY(frame));
		case CHLayoutConstraintAttributeMaxXMaxY:
			return CHPointRect(NSMaxX(frame), NSMaxY(frame));
		case CHLayoutConstraintAttributeBoundsCenter:
			return CHPointRect(NSMidX(bounds), NSMidY(bounds));
		case CHLayoutConstraintAttributeFrame:
			return frame;
		case CHLayoutConstraintAttributeBounds:
			return bounds;
		default:
			return NSZeroRect;
	}
}

- (void) setValue:(NSRect)newValue forLayoutAttribute:(CHLayoutConstraintAttribute)attribute {
	NSRect frame = [self frame];
	NSRect bounds = [self bounds];
	
	CGFloat scalarValue = CHRectScalar(newValue);
	NSPoint pointValue = CHRectPoint(newValue);
	NSRect rectValue = newValue;
	
	switch (attribute) {
		case CHLayoutConstraintAttributeMinY:
			CHSetMinY(frame, scalarValue);
			break;
		case CHLayoutConstraintAttributeMaxY:
			CHSetMaxY(frame, scalarValue);
			break;
		case CHLayoutConstraintAttributeMinX:
			CHSetMinX(frame, scalarValue);
			break;
		case CHLayoutConstraintAttributeMaxX:
			CHSetMaxX(frame, scalarValue);
			break;
		case CHLayoutConstraintAttributeWidth:
			frame.size.width = scalarValue;
			break;
		case CHLayoutConstraintAttributeHeight:
			frame.size.height = scalarValue;
			break;
		case CHLayoutConstraintAttributeMidY:
			CHSetMidY(frame, scalarValue);
			break;
		case CHLayoutConstraintAttributeMidX:
			CHSetMidX(frame, scalarValue);
			break;
		case CHLayoutConstraintAttributeMinXMinY:
			CHSetMinX(frame, pointValue.x);
			CHSetMinY(frame, pointValue.y);
			break;
		case CHLayoutConstraintAttributeMinXMidY:
			CHSetMinX(frame, pointValue.x);
			CHSetMidY(frame, pointValue.y);
			break;
		case CHLayoutConstraintAttributeMinXMaxY:
			CHSetMinX(frame, pointValue.x);
			CHSetMaxY(frame, pointValue.y);
			break;
		case CHLayoutConstraintAttributeMidXMinY:
			CHSetMidX(frame, pointValue.x);
			CHSetMinY(frame, pointValue.y);
			break;
		case CHLayoutConstraintAttributeMidXMidY:
			CHSetMidX(frame, pointValue.x);
			CHSetMidY(frame, pointValue.y);
			break;
		case CHLayoutConstraintAttributeBoundsCenter:
			CHSetMidX(bounds, pointValue.x);
			CHSetMidY(bounds, pointValue.y);
			break;
		case CHLayoutConstraintAttributeMidXMaxY:
			CHSetMidX(frame, pointValue.x);
			CHSetMaxY(frame, pointValue.y);
			break;
		case CHLayoutConstraintAttributeMaxXMinY:
			CHSetMaxX(frame, pointValue.x);
			CHSetMinY(frame, pointValue.y);
			break;
		case CHLayoutConstraintAttributeMaxXMidY:
			CHSetMaxX(frame, pointValue.x);
			CHSetMidY(frame, pointValue.y);
			break;
		case CHLayoutConstraintAttributeMaxXMaxY:
			CHSetMaxX(frame, pointValue.x);
			CHSetMaxY(frame, pointValue.y);
			break;
		case CHLayoutConstraintAttributeFrame:
			frame = rectValue;
			break;
		case CHLayoutConstraintAttributeBounds:
			bounds = rectValue;
			break;
	}
	
	if (attribute != CHLayoutConstraintAttributeBounds && attribute != CHLayoutConstraintAttributeBoundsCenter) {
		[self setFrame:frame];
	} else {
		[self setBounds:bounds];
	}
}

- (NSView *) relativeViewForName:(NSString *)name {
	if ([name isEqual:@"superview"]) {
		return [self superview];
	}
	
	NSArray * superSubviews = [[self superview] subviews];
	for (NSView *view in superSubviews) {
		if ([[view layoutName] isEqual:name]) {
			return (view == self ? nil : view);
		}
	}
	return nil;
}

@end
