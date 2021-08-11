//
//  NSString+Safety.m
//  homework
//
//  Created by panxiang on 14-6-27.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import "NSString+Safety.h"
#import "NBSafetyCommon.h"
#define kZeroRange NSMakeRange(0, 0)
#define kNotFoundRange NSMakeRange(NSNotFound, 0)
@implementation NSString (Safety)

+ (BOOL)isObjectNil:(NSString *)string onFunction:(const char *)function
{
    if (string == nil) {
#if ZDLogEnable
        NSLog(@"function : %s has invalid argument : object can't be nil" ,function);
        NSLog(@"*************error stack****************** \n%@",ThreadCallStackSymbols);
#else
#endif

        return YES;
    }
    return NO;
}

- (BOOL)isObjectNil:(NSString *)string onFunction:(const char *)function
{
    return [[self class] isObjectNil:string onFunction:function];
}

+ (void)printNilError:(NSRange)range forString:(NSString *)string onFunction:(const char *)function
{
#if ZDLogEnable
    NSLog(@"*************error******************\n %s:\n range.location %d range.length %d beyond string length %d",function ,range.location,range.length ,string.length);
    NSLog(@"string data : \n %@",string);
    NSLog(@"*************error stack****************** \n%@",ThreadCallStackSymbols);
#else
#endif

}

- (BOOL)isRightRange:(NSRange)range forString:(NSString *)string onFunction:(const char *)function
{
    if (string && (range.location + range.length <= string.length)) {
        return YES;
    }
    [[self class] printRangeError:range forString:string onFunction:function];
    return NO;
    
}

+ (void)printRangeError:(NSRange)range forString:(NSString *)string onFunction:(const char *)function
{
#if ZDLogEnable
    NSLog(@"*************error******************\n %s:\n range.location %d range.length %d beyond string length %d",function ,range.location,range.length ,string.length);
    NSLog(@"string data : \n %@",string);
    NSLog(@"*************error stack****************** \n%@",ThreadCallStackSymbols);
#else
#endif

}

- (NSString *)substringWithRangeSafely:(NSRange)range
{
    if (![self isRightRange:range forString:self onFunction:__FUNCTION__]) {
        return nil;
    }
    return [self substringWithRange:range];
}

- (NSRange)rangeOfCharacterFromSet:(NSCharacterSet *)aSet options:(NSStringCompareOptions)mask rangeSafely:(NSRange)searchRange
{
    if (![self isRightRange:searchRange forString:self onFunction:__FUNCTION__]) {
        return kNotFoundRange;
    }
    return [self rangeOfCharacterFromSet:aSet options:mask range:searchRange];
}

+ (instancetype)stringWithStringSafely:(NSString *)string
{
    if ([[self class] isObjectNil:string onFunction:__FUNCTION__]) {
        return [[self alloc] init];
    }
    return [self stringWithString:string];
}

- (NSString *)stringByAppendingStringSafely:(NSString *)aString
{
    if ([[self class] isObjectNil:aString onFunction:__FUNCTION__]) {
        return self;
    }
    return [self stringByAppendingString:aString];
}

- (instancetype)initWithStringSafely:(NSString *)aString
{
    if ([[self class] isObjectNil:aString onFunction:__FUNCTION__]) {
        aString = @"";
    }
    return [self initWithString:aString];
}

- (NSRange)rangeOfStringSafely:(NSString *)aString
{
    if ([self isObjectNil:aString onFunction:__FUNCTION__]) {
        return kNotFoundRange;
    }
    return [self rangeOfString:aString];
}

- (NSRange)rangeOfString:(NSString *)aString optionsSafely:(NSStringCompareOptions)mask
{
    if ([self isObjectNil:aString onFunction:__FUNCTION__]) {
        return kNotFoundRange;
    }
    return [self rangeOfString:aString options:mask];
}

- (NSRange)rangeOfString:(NSString *)aString options:(NSStringCompareOptions)mask rangeSafely:(NSRange)searchRange
{
    if ([self isObjectNil:aString onFunction:__FUNCTION__]) {
        return kNotFoundRange;
    }
    
    if (![self isRightRange:searchRange forString:self onFunction:__FUNCTION__]) {
        return kNotFoundRange;
    }
    return [self rangeOfString:aString options:mask range:searchRange];
}

- (NSString *)stringByReplacingCharactersInRange:(NSRange)range withStringSafely:(NSString *)replacement
{
    if (![self isRightRange:range forString:self onFunction:__FUNCTION__]) {
        return nil;
    }
    if ([self isObjectNil:replacement onFunction:__FUNCTION__]) {
        return nil;
    }
    return [self stringByReplacingCharactersInRange:range withString:replacement];
}

- (NSString *)stringByReplacingOccurrencesOfString:(NSString *)target withStringSafely:(NSString *)replacement
{
    if ([[self class] isObjectNil:target onFunction:__FUNCTION__]) {
        return nil;
    }
    if ([[self class] isObjectNil:replacement onFunction:__FUNCTION__]) {
        return nil;
    }
    return [self stringByReplacingOccurrencesOfString:target withString:replacement];
}

- (NSString *)substringToIndexSafely:(NSUInteger)anIndex
{
    if (self.length >= anIndex) {
        return [self substringToIndex:anIndex];
    }
    return nil;
}

- (NSString *)substringFromIndexSafely:(NSUInteger)anIndex
{
    if (self.length >= anIndex) {
        return [self substringFromIndex:anIndex];
    }
    return nil;
}

- (unichar)characterAtIndexSafely:(NSUInteger)index
{
    if (self.length > index) {
        return [self characterAtIndex:index];
    }
    return 0;
}

@end


@implementation NSMutableString (Safety)

- (BOOL)isRightIndexInString:(NSUInteger)index onFunction:(const char *)function
{
    return index <= self.length;
}

- (void)insertString:(NSString *)aString atIndexSafely:(NSUInteger)loc
{
    if ([self isRightIndexInString:loc onFunction:__func__]) {
        [self insertString:aString atIndex:loc];
    }
}

//- (void)appendFormat:(NSString *)format, ...
//{
//    if ([self isObjectNil:format onFunction:__FUNCTION__])
//    {
//        format = @"";
//    }
//    va_list argumentList;
//    va_start(argumentList,format);
//    [self appendFormat:format, argumentList];
//    va_end(argumentList);
//}

- (void)replaceCharactersInRange:(NSRange)range withStringSafely:(NSString *)aString
{
    if (![self isRightRange:range forString:self onFunction:__FUNCTION__]) {
        return;
    }
    [self replaceCharactersInRange:range withString:aString];
}

- (void)deleteCharactersInRangeSafely:(NSRange)range
{
    if (![self isRightRange:range forString:self onFunction:__FUNCTION__]) {
        return;
    }
    [self deleteCharactersInRange:range];
}

- (NSUInteger)replaceOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options rangeSafely:(NSRange)searchRange
{
    if (![self isRightRange:searchRange forString:self onFunction:__FUNCTION__]) {
        return 0;
    }
    if ([self isObjectNil:target onFunction:__FUNCTION__]) {
        return 0;
    }
    if ([self isObjectNil:replacement onFunction:__FUNCTION__]) {
        return 0;
    }
    return [self replaceOccurrencesOfString:target withString:replacement options:options range:searchRange];
}
@end
