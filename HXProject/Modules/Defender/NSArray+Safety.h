//
//  NSArray+Safety.h
//  homework
//
//  Created by panxiang on 14-6-24.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSArray (Safety)
- (id)valueForKeySafely:(id)aKey;
- (id)objectAtIndexSafely:(NSUInteger)index;

- (NSArray *)subarrayWithRangeSafely:(NSRange)range;

+ (instancetype)arrayWithObjectSafely:(id)anObject;
@end


@interface NSMutableArray (Safety)

@property (readonly, getter=reverse) NSMutableArray *reversed;

- (NSMutableArray *) reverse;
- (NSMutableArray *) randomObject;
- (void)insertObject:(id)anObject atIndexSafely:(NSUInteger)index;

- (void)replaceObjectAtIndex:(NSUInteger)index withObjectSafely:(id)anObject;

- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndexSafely:(NSUInteger)idx2;

- (void)removeObjectAtIndexSafely:(NSUInteger)index;



- (void)removeObjectsInRangeSafely:(NSRange)range;
- (void)removeObjectSafely:(id)anyObject;

- (void)addObjectSafely:(id)object;
- (void)addObjectsFromArraySafely:(id)object;

@end


@interface NSArray (PSLib)

/*
 * Checks to see if the array is empty
 */
@property(nonatomic,readonly,getter=isEmpty) BOOL empty;

@end

