//
//  CHLayoutConstraint.h
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

#import <Cocoa/Cocoa.h>

typedef enum {
	CHLayoutConstraintAttributeMinY = 1, //the left edge
	CHLayoutConstraintAttributeMaxY = 2, //the right edge
	CHLayoutConstraintAttributeMinX = 3, //the bottom edge
	CHLayoutConstraintAttributeMaxX = 4, //the top edge
	CHLayoutConstraintAttributeWidth = 5, //the width
	CHLayoutConstraintAttributeHeight = 6, //the height
	CHLayoutConstraintAttributeMidY = 7, //the vertical center
	CHLayoutConstraintAttributeMidX = 8, //the horizontal center
	
	CHLayoutConstraintAttributeMinXMinY = 101,
	CHLayoutConstraintAttributeMinXMidY = 102,
	CHLayoutConstraintAttributeMinXMaxY = 103,
	
	CHLayoutConstraintAttributeMidXMinY = 104,
	CHLayoutConstraintAttributeMidXMidY = 105,
	CHLayoutConstraintAttributeMidXMaxY = 106,
	
	CHLayoutConstraintAttributeMaxXMinY = 107,
	CHLayoutConstraintAttributeMaxXMidY = 108,
	CHLayoutConstraintAttributeMaxXMaxY = 109,
	
	CHLayoutConstraintAttributeBoundsCenter = 110,
	
	CHLayoutConstraintAttributeFrame = 1000,
	CHLayoutConstraintAttributeBounds = 1001
} CHLayoutConstraintAttribute;

#if NS_BLOCKS_AVAILABLE
typedef CGFloat (^CHLayoutTransformer)(CGFloat);
#endif

@interface CHLayoutConstraint : NSObject {
	CHLayoutConstraintAttribute attribute;
	
	NSString * sourceName;
	CHLayoutConstraintAttribute sourceAttribute;
	
	NSValueTransformer * valueTransformer;
}

@property (readonly) CHLayoutConstraintAttribute attribute;
@property (readonly) CHLayoutConstraintAttribute sourceAttribute;
@property (readonly) NSString * sourceName;

+ (id) constraintWithAttribute:(CHLayoutConstraintAttribute)attr relativeTo:(NSString *)srcLayer attribute:(CHLayoutConstraintAttribute)srcAttr;
+ (id) constraintWithAttribute:(CHLayoutConstraintAttribute)attr relativeTo:(NSString *)srcLayer attribute:(CHLayoutConstraintAttribute)srcAttr offset:(CGFloat)offset;
+ (id) constraintWithAttribute:(CHLayoutConstraintAttribute)attr relativeTo:(NSString *)srcLayer attribute:(CHLayoutConstraintAttribute)srcAttr scale:(CGFloat)scale offset:(CGFloat)offset;

#if NS_BLOCKS_AVAILABLE
+ (id) constraintWithAttribute:(CHLayoutConstraintAttribute)attr relativeTo:(NSString *)srcLayer attribute:(CHLayoutConstraintAttribute)srcAttr blockTransformer:(CHLayoutTransformer)transformer;
#endif

+ (id) constraintWithAttribute:(CHLayoutConstraintAttribute)attr relativeTo:(NSString *)srcLayer attribute:(CHLayoutConstraintAttribute)srcAttr valueTransformer:(NSValueTransformer *)transformer;
- (id) initWithAttribute:(CHLayoutConstraintAttribute)attr relativeTo:(NSString *)srcLayer attribute:(CHLayoutConstraintAttribute)srcAttr valueTransformer:(NSValueTransformer *)transformer;

- (CGFloat) transformValue:(CGFloat)original;
- (void) applyToTargetView:(NSView *)target;
- (void) applyToTargetView:(NSView *)target sourceView:(NSView *)source;

@end
