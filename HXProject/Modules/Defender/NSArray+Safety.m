//
//  NSArray+Safety.m
//  homework
//
//  Created by panxiang on 14-6-24.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import "NSArray+Safety.h"
#import <objc/runtime.h>
#import "NBSafetyCommon.h"
#import "NSString+Safety.h"


#define kError_index_beyond_arrayCount  @"index beyond array count"
#define kError_range_beyond_arrayCount  @"range beyond array count"


@implementation NSArray (Safety)

- (BOOL)isIndexSet:(NSIndexSet *)indexSet hasValueBeyondNumber:(NSInteger)number wrongIndex:(NSInteger *)index
{
    __block BOOL has = NO;
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        has = idx > number;
        if (has) {
            *stop = YES;
        }
        *index = idx;
    }];
    return has;
}

- (BOOL)isNotNilObject:(id)object forArray:(NSArray *)array onFunction:(const char *)function
{
    return [[self class] isNotNilObject:object forArray:array onFunction:function];
}

+ (void)printNilObjectError:(NSArray *)array onFunction:(const char *)function
{
#if ZDLogEnable
    NSLog(@"*************error******************\n %s:\n%@",function ,kError_nil_object);
    NSLog(@"array data : \n %@",array);
    NSLog(@"*************error stack****************** \n%@",ThreadCallStackSymbols);
#else
#endif

}

+ (BOOL)isNotNilObject:(id)object forArray:(NSArray *)array onFunction:(const char *)function
{
    BOOL notNil = object != nil;
    if (!notNil) {
        [self printNilObjectError:array onFunction:function];
    }
    return notNil;
}

+ (void)printIndexError:(NSInteger)index forArray:(NSArray *)array onFunction:(const char *)function
{
#if ZDLogEnable
    NSLog(@"*************error******************\n %s:\n index %d beyond array count %d",function ,index ,array.count);
    NSLog(@"array data : \n %@",array);
    NSLog(@"*************error stack****************** \n%@",ThreadCallStackSymbols);
#else
#endif

}

- (BOOL)isRightWithInsertIndex:(NSInteger)index forArray:(NSArray *)array onFunction:(const char *)function
{
    BOOL isRight = array.count >= index;
    if (!isRight) {
        [[self class] printIndexError:index forArray:array onFunction:function];
    }
    return isRight;
}

- (BOOL)isRightWithIndex:(NSInteger)index forArray:(NSArray *)array onFunction:(const char *)function
{
    BOOL isRight = array.count > index;
    if (!isRight) {
        [[self class] printIndexError:index forArray:array onFunction:function];
    }
    return isRight;
}

+ (void)printRangeError:(NSRange)range forArray:(NSArray *)array onFunction:(const char *)function
{
#if ZDLogEnable
    NSLog(@"*************error******************\n %s:\n range.location %d range.length %d beyond array count %d",function ,range.location,range.length ,array.count);
    NSLog(@"array data : \n %@",array);
    NSLog(@"*************error stack****************** \n%@",ThreadCallStackSymbols);
#else
#endif

}

- (BOOL)isRightWithRange:(NSRange)range forArray:(NSArray *)array onFunction:(const char *)function
{
    BOOL isRight = array.count >= range.location + range.length;
    if (!isRight) {
        [[self class] printRangeError:range forArray:array onFunction:function];
    }
    return isRight;
}


+ (void)printRangeNotEqualError:(NSRange)range1 otherRange:(NSRange)range2 forArray:(NSArray *)array onFunction:(const char *)function
{
#if ZDLogEnable
    NSLog(@"*************error******************\n %s:\n range1.length (%d) != range2.length (%d)",function ,range1.length,range2.length);
    NSLog(@"array data : \n %@",array);
    NSLog(@"*************error stack****************** \n%@",ThreadCallStackSymbols);
#else
#endif

}

- (void)printNilKeyError:(const char *)fuction
{
    [[self class] printNilKeyError:fuction];
}

+ (void)printNilKeyError:(const char *)fuction
{
#if ZDLogEnable
    NSLog(@"%s \n key is nil \n Dictionary:%@",fuction ,self);
#else
#endif

}

- (BOOL)isRangeLength:(NSRange)range1 isEqualRangeLength:(NSRange)range2 forArray:(NSArray *)array onFunction:(const char *)function
{
    BOOL isRight = (range1.length == range2.length);
    if (!isRight) {
        [[self class] printRangeNotEqualError:range1 otherRange:range2 forArray:array onFunction:function];
    }
    return isRight;
}

+ (void)printIndexSetError:(NSIndexSet *)set forArray:(NSArray *)array onFunction:(const char *)function
{
#if ZDLogEnable
    NSLog(@"*************error******************\n %s:\n NSSet count %d is not equanl to NSArray count %d ",function ,set.count,array.count);
    NSLog(@"array data : \n %@",array);
    NSLog(@"set data : \n %@",set);
    NSLog(@"*************error stack****************** \n%@",ThreadCallStackSymbols);
#else
#endif
}

- (BOOL)isRightIndexSetError:(NSIndexSet *)set forArray:(NSArray *)array onFunction:(const char *)function
{
    BOOL isRight = set.count == array.count;
    if (!isRight) {
        [[self class] printIndexSetError:set forArray:array onFunction:function];
    }
    return isRight;
}

- (id)valueForKeySafely:(id)aKey
{
    if (!aKey) {
        [self printNilKeyError:__FUNCTION__];
        return nil;
    }
    return [self valueForKey:aKey];
}

- (void)setValue:(id)value forKeySafely:(NSString *)key
{
    if (!key) {
        [self printNilKeyError:__FUNCTION__];
        return;
    }
    return [self setValue:value forKey:key];
}

- (id)objectAtIndexSafely:(NSUInteger)index
{
    if ([self isRightWithIndex:index forArray:self onFunction:__FUNCTION__]) {
        return [self objectAtIndex:index];
    }
    return nil;
}

- (NSArray *)subarrayWithRangeSafely:(NSRange)range
{
    if (![self isRightWithRange:range forArray:self onFunction:__FUNCTION__]){
        return nil;
    }
    return [self subarrayWithRange:range];
}

+ (instancetype)arrayWithObjectSafely:(id)anObject
{
    if (anObject) {
        return [self arrayWithObject:anObject];
    }
    [[self class] printNilObjectError:nil onFunction:__FUNCTION__];
    return [NSArray array];
}

@end


@implementation NSMutableArray (Safety)


+ (instancetype)arrayWithObjectSafely:(id)anObject
{
    if (anObject) {
        return [self arrayWithObject:anObject];
    }
    [[self class] printNilObjectError:nil onFunction:__FUNCTION__];
    return [NSMutableArray array];
}

- (void)insertObjects:(NSArray *)objects atIndexesSafely:(NSIndexSet *)indexes
{
    if (![self isRightIndexSetError:indexes forArray:objects onFunction:__FUNCTION__]) {
        return;
    }
    
    NSInteger wrongIndex = 0;
    
    BOOL hasWrongNumber = [self isIndexSet:indexes hasValueBeyondNumber:objects.count + self.count - 1 wrongIndex:&wrongIndex];
    
    if (hasWrongNumber)
    {
        [[self class] printIndexError:hasWrongNumber forArray:objects onFunction:__FUNCTION__];
    }
    else
    {
        [self insertObjects:objects atIndexes:indexes];
    }
}


- (void)removeObjectsInRangeSafely:(NSRange)range
{
    if (![self isRightWithRange:range forArray:self onFunction:__FUNCTION__]){
        return;
    }
    [self removeObjectsInRange:range];
}

- (void)removeObjectSafely:(id)anyObject{
    if (![self containsObject:anyObject]) {
        return;
    }
    [self removeObject:anyObject];
}


- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndexSafely:(NSUInteger)idx2
{
    if( MAX(idx1, idx2) >= [self count] ) {
        return;
    }
    [self exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObjectSafely:(id)anObject
{
    if( index >= [self count] ) {
        return;
    }
    if (!anObject) {
        [[self class] printNilObjectError:nil onFunction:__FUNCTION__];
        return;
    }
    [self replaceObjectAtIndex:index withObject:anObject];
}

- (void)removeObjectAtIndexSafely:(NSUInteger)index
{
	if( index >= [self count] )
		return;
	
    [self removeObjectAtIndex:index];
}

- (void)insertObject:(id)anObject atIndexSafely:(NSUInteger)index
{
    if (anObject && self.count >= index) {
        [self insertObject:anObject atIndex:index];
    }
}

- (void)addObjectSafely:(id)object
{
	if (object == nil)
	{
		return;
	}
	
	[self addObject:object];
}
- (void)addObjectsFromArraySafely:(id)object{
    if (object == nil) {
        return;
    }
    [self addObjectsFromArray:object];
}

- (NSMutableArray *) reverse
{
	for (int i=0; i<(floor([self count]/2.0)); i++)
		[self exchangeObjectAtIndex:i withObjectAtIndex:([self count]-(i+1))];
	return self;
}

// Make sure to run srandom([[NSDate date] timeIntervalSince1970]); or similar somewhere in your program
- (NSMutableArray *) randomObject
{
	for (int i=0; i<([self count]-2); i++)
		[self exchangeObjectAtIndex:i withObjectAtIndex:(i+(random()%([self count]-i)))];
	return self;
}

@end


@implementation NSArray (PSLib)

- (BOOL)isEmpty
{
	return [self count] == 0 ? YES : NO;
}

@end


