//
//  CHLayoutConstraint.m
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

#import "CHLayout.h"

#pragma mark Value Transformers

@interface CHLayoutValueTransformer : NSValueTransformer
{
	CGFloat offset;
	CGFloat scale;
}

+ (id) transformerWithOffset:(CGFloat)anOffset scale:(CGFloat)aScale;
- (id) initWithOffset:(CGFloat)anOffset scale:(CGFloat)aScale;

@end

@implementation CHLayoutValueTransformer

+ (id) transformerWithOffset:(CGFloat)anOffset scale:(CGFloat)aScale {
	return [[[self alloc] initWithOffset:anOffset scale:aScale] autorelease];
}

- (id) initWithOffset:(CGFloat)anOffset scale:(CGFloat)aScale {
	self = [super init];
	if (self) {
		offset = anOffset;
		scale = aScale;
	}
	return self;
}

- (id) transformedValue:(id)value {
	if ([value respondsToSelector:@selector(floatValue)] == NO) { return [NSNumber numberWithInt:0]; }
	
	CGFloat source = [value floatValue];
	CGFloat transformed = (source * scale) + offset;
	return [NSNumber numberWithFloat:transformed];
}

@end

#if NS_BLOCKS_AVAILABLE
@interface CHLayoutBlockValueTransformer : NSValueTransformer
{
	CHLayoutTransformer transformer;
}

+ (id) transformerWithBlock:(CHLayoutTransformer)block;
- (id) initWithBlock:(CHLayoutTransformer)block;

@end

@implementation CHLayoutBlockValueTransformer

+ (id) transformerWithBlock:(CHLayoutTransformer)block {
	return [[[self alloc] initWithBlock:block] autorelease];
}

- (id) initWithBlock:(CHLayoutTransformer)block {
	self = [super init];
	if (self) {
		transformer = Block_copy(block);
	}
	return self;
}

- (void) dealloc {
	Block_release(transformer);
	[super dealloc];
}

- (id) transformedValue:(id)value {
	if ([value respondsToSelector:@selector(floatValue)] == NO) { return [NSNumber numberWithInt:0]; }
	
	CGFloat source = [value floatValue];
	CGFloat transformed = transformer(source);
	return [NSNumber numberWithFloat:transformed];
}

@end
#endif


#pragma mark -
#pragma mark CHLayoutConstraint

@implementation CHLayoutConstraint
@synthesize attribute, sourceAttribute, sourceName;

#pragma mark Basic Initializers

+ (id)constraintWithAttribute:(CHLayoutConstraintAttribute)attr relativeTo:(NSString *)srcLayer attribute:(CHLayoutConstraintAttribute)srcAttr {
	return [self constraintWithAttribute:attr relativeTo:srcLayer attribute:srcAttr scale:1.0 offset:0.0];
}

+ (id)constraintWithAttribute:(CHLayoutConstraintAttribute)attr relativeTo:(NSString *)srcLayer attribute:(CHLayoutConstraintAttribute)srcAttr offset:(CGFloat)offset {
	return [self constraintWithAttribute:attr relativeTo:srcLayer attribute:srcAttr scale:1.0 offset:offset];
}

+ (id)constraintWithAttribute:(CHLayoutConstraintAttribute)attr relativeTo:(NSString *)srcLayer attribute:(CHLayoutConstraintAttribute)srcAttr scale:(CGFloat)scale offset:(CGFloat)offset {
	CHLayoutValueTransformer * t = [CHLayoutValueTransformer transformerWithOffset:offset scale:scale];
	return [self constraintWithAttribute:attr relativeTo:srcLayer attribute:srcAttr valueTransformer:t];
}

#if NS_BLOCKS_AVAILABLE
+ (id) constraintWithAttribute:(CHLayoutConstraintAttribute)attr relativeTo:(NSString *)srcLayer attribute:(CHLayoutConstraintAttribute)srcAttr blockTransformer:(CHLayoutTransformer)transformer {
	CHLayoutBlockValueTransformer * t = [CHLayoutBlockValueTransformer transformerWithBlock:transformer];
	return [self constraintWithAttribute:attr relativeTo:srcLayer attribute:srcAttr valueTransformer:t];
}
#endif

+ (id) constraintWithAttribute:(CHLayoutConstraintAttribute)attr relativeTo:(NSString *)srcLayer attribute:(CHLayoutConstraintAttribute)srcAttr valueTransformer:(NSValueTransformer *)transformer {
	return [[[self alloc] initWithAttribute:attr relativeTo:srcLayer attribute:srcAttr valueTransformer:transformer] autorelease];
}

- (id)initWithAttribute:(CHLayoutConstraintAttribute)attr relativeTo:(NSString *)srcLayer attribute:(CHLayoutConstraintAttribute)srcAttr valueTransformer:(NSValueTransformer *)transformer {
	double attributeRange = floorf(log10(attr));
	double sourceAttributeRange = floorf(log10(srcAttr));
	
	if (attributeRange != sourceAttributeRange) {
		[super dealloc];
		[NSException raise:NSInvalidArgumentException format:@"Invalid source and target attributes"];
		return nil;
	}
	
	self = [super init];
	if (self) {
		attribute = attr;
		sourceAttribute = srcAttr;
				
		sourceName = [srcLayer copy];
		valueTransformer = [transformer retain];
	}
	return self;
}

- (void) dealloc {
	[valueTransformer release];
	[sourceName release];
	[super dealloc];
}

- (CGFloat) transformValue:(CGFloat)original {
	id transformed = [valueTransformer transformedValue:[NSNumber numberWithFloat:original]];
	if ([transformed respondsToSelector:@selector(floatValue)] == NO) { return 0; }
	return [transformed floatValue];
}

- (void) applyToTargetView:(NSView *)target {
	NSView * source = [target relativeViewForName:[self sourceName]];
	[self applyToTargetView:target sourceView:source];
}

- (void) applyToTargetView:(NSView *)target sourceView:(NSView *)source {
	if (source == target) { return; }
	if (source == nil) { return; }
	if ([self sourceAttribute] == 0) { return; }
	
	NSRect sourceValue = [source valueForLayoutAttribute:[self sourceAttribute]];
	
	NSRect targetValue = sourceValue;
	if (attribute >= CHLayoutConstraintAttributeMinY && attribute <= CHLayoutConstraintAttributeMidX) {
		targetValue.origin.x = [self transformValue:sourceValue.origin.x];
	}
	
	[target setValue:targetValue forLayoutAttribute:[self attribute]];
}

@end
