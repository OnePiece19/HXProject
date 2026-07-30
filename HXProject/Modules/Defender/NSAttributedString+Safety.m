//
//  NSAttributedString+Safety.m
//  homework
//
//  Created by panxiang on 14-10-13.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import "NSAttributedString+Safety.h"
#import "NBSafetyCommon.h"

@implementation NSAttributedString (Safety)

+ (BOOL)isObjectNil:(id)object onFunction:(const char *)function
{
    if (object == nil) {
#if ZDLogEnable
        NSLog(@"function : %s has invalid argument : object can't be nil" ,function);
        NSLog(@"*************error stack****************** \n%@",ThreadCallStackSymbols);
#else
#endif
        
        return YES;
    }
    return NO;
}

- (BOOL)isObjectNil:(id)string onFunction:(const char *)function
{
    return [[self class] isObjectNil:string onFunction:function];
}

+ (void)printRangeError:(NSRange)range forString:(NSAttributedString *)string onFunction:(const char *)function
{
#if ZDLogEnable
    NSLog(@"*************error******************\n %s:\n range.location %d range.length %d beyond string length %d",function ,range.location,range.length ,string.length);
    NSLog(@"string data : \n %@",string);
    NSLog(@"*************error stack****************** \n%@",ThreadCallStackSymbols);
#else
#endif
    
}

- (BOOL)isRightRange:(NSRange)range forString:(NSAttributedString *)string onFunction:(const char *)function
{
    if (string && (range.location + range.length <= string.length)) {
        return YES;
    }
    [[self class] printRangeError:range forString:string onFunction:function];
    return NO;
    
}

- (BOOL)isRightIndexInAttributedString:(NSUInteger)index onFunction:(const char *)function
{
    return index <= self.length;
}

- (id)initWithStringSafely:(NSString *)str
{
    if ([self isObjectNil:str onFunction:__FUNCTION__]) {
        return nil;
    }
    return [self initWithString:str];
}


- (id)initWithString:(NSString *)str attributesSafely:(NSDictionary *)attrs
{
    if ([self isObjectNil:str onFunction:__FUNCTION__]) {
        return nil;
    }
    return [self initWithString:str attributes:attrs];
}

- (id)initWithAttributedStringSafely:(NSAttributedString *)attrStr
{
    if ([self isObjectNil:attrStr onFunction:__FUNCTION__]) {
        return nil;
    }
    return [self initWithAttributedString:attrStr];
}


@end

@implementation NSMutableAttributedString(Safety)

- (void)replaceCharactersInRange:(NSRange)range withStringSafely:(NSString *)str
{
    if ([self isRightRange:range forString:self onFunction:__FUNCTION__]) {
        [self replaceCharactersInRange:range withString:str];
    }
}

- (void)setAttributes:(NSDictionary *)attrs rangeSafely:(NSRange)range
{
    if ([self isRightRange:range forString:self onFunction:__FUNCTION__]) {
        [self setAttributes:attrs range:range];
    }
}

- (void)addAttribute:(NSString *)name value:(id)value rangeSafely:(NSRange)range
{
    if ([self isObjectNil:name onFunction:__FUNCTION__]) {
        return;
    }
    if ([self isObjectNil:value onFunction:__FUNCTION__]) {
        return;
    }

    if ([self isRightRange:range forString:self onFunction:__FUNCTION__]) {

        [self addAttribute:name value:value range:range];
    }
}

- (void)addAttributes:(NSDictionary *)attrs rangeSafely:(NSRange)range
{
    if ([self isObjectNil:attrs onFunction:__FUNCTION__]) {
        return;
    }
    if ([self isRightRange:range forString:self onFunction:__FUNCTION__]) {
        [self addAttributes:attrs range:range];
    }
}

- (void)removeAttribute:(NSString *)name rangeSafely:(NSRange)range
{
    if ([self isRightRange:range forString:self onFunction:__FUNCTION__]) {
        [self removeAttribute:name range:range];
    }
}

- (void)replaceCharactersInRange:(NSRange)range withAttributedStringSafely:(NSAttributedString *)attrString
{
    if ([self isRightRange:range forString:self onFunction:__FUNCTION__]) {
        [self replaceCharactersInRange:range withAttributedString:attrString];
    }
}

- (void)insertAttributedString:(NSAttributedString *)attrString atIndexSafely:(NSUInteger)loc
{
    if ([self isRightIndexInAttributedString:loc onFunction:__FUNCTION__]) {
        [self insertAttributedString:attrString atIndex:loc];
    }
}

- (void)deleteCharactersInRangeSafely:(NSRange)range
{
    if ([self isRightRange:range forString:self onFunction:__FUNCTION__]) {
        [self deleteCharactersInRange:range];
    }
}
@end
