//
//  NSAttributedString+Safety.h
//  homework
//
//  Created by panxiang on 14-10-13.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (Safety)

- (id)initWithStringSafely:(NSString *)str;
- (id)initWithString:(NSString *)str attributesSafely:(NSDictionary *)attrs;
- (id)initWithAttributedStringSafely:(NSAttributedString *)attrStr;

@end


@interface NSMutableAttributedString(Safety)
- (void)replaceCharactersInRange:(NSRange)range withStringSafely:(NSString *)str;
- (void)replaceCharactersInRange:(NSRange)range withAttributedStringSafely:(NSAttributedString *)attrString;
- (void)setAttributes:(NSDictionary *)attrs rangeSafely:(NSRange)range;
- (void)addAttributes:(NSDictionary *)attrs rangeSafely:(NSRange)range;
- (void)addAttribute:(NSString *)name value:(id)value rangeSafely:(NSRange)range;
- (void)removeAttribute:(NSString *)name rangeSafely:(NSRange)range;
- (void)insertAttributedString:(NSAttributedString *)attrString atIndexSafely:(NSUInteger)loc;
- (void)deleteCharactersInRangeSafely:(NSRange)range;
@end

