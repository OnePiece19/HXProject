//
//  NSString+Safety.h
//  homework
//
//  Created by panxiang on 14-6-27.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Safety)

- (NSString *)substringWithRangeSafely:(NSRange)range;
- (NSRange)rangeOfCharacterFromSet:(NSCharacterSet *)aSet options:(NSStringCompareOptions)mask rangeSafely:(NSRange)searchRange;

+ (instancetype)stringWithStringSafely:(NSString *)string;
- (NSString *)stringByAppendingStringSafely:(NSString *)aString;
- (instancetype)initWithStringSafely:(NSString *)aString;
- (NSRange)rangeOfStringSafely:(NSString *)aString;
- (NSRange)rangeOfString:(NSString *)aString optionsSafely:(NSStringCompareOptions)mask;
- (NSRange)rangeOfString:(NSString *)aString options:(NSStringCompareOptions)mask rangeSafely:(NSRange)searchRange;

- (NSString *)stringByReplacingCharactersInRange:(NSRange)range withStringSafely:(NSString *)replacement;
- (NSString *)stringByReplacingOccurrencesOfString:(NSString *)target withStringSafely:(NSString *)replacement;

- (NSString *)substringToIndexSafely:(NSUInteger)anIndex;
- (NSString *)substringFromIndexSafely:(NSUInteger)anIndex;
- (unichar)characterAtIndexSafely:(NSUInteger)index;
@end


@interface NSMutableString (Safety)
//- (void)appendFormat:(NSString *)format, ...;
- (void)insertString:(NSString *)aString atIndexSafely:(NSUInteger)loc;
- (void)replaceCharactersInRange:(NSRange)range withStringSafely:(NSString *)aString;
- (void)deleteCharactersInRangeSafely:(NSRange)range;
- (NSUInteger)replaceOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options rangeSafely:(NSRange)searchRange;
@end
