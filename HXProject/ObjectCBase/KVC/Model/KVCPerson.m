//
//  KVCPerson.m
//  HXProject
//
//  Created by HX on 2021/8/12.
//

#import "KVCPerson.h"

@interface KVCPerson ()
{
    @private
    NSString *privateVar;
}

@property (strong, nonatomic) NSString *privateProperty;

@end

@implementation KVCPerson

-(void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"Age"]) {
        [self setValue:value forKey:@"age"];
    }
}

//给某个非对象的属性赋值为 nil 时,会抛出 NSInvalidArgumentException 的异常并崩溃。
-(void)setNilValueForKey:(NSString *)key {
    if ([key isEqualToString:@"sex"]) {
        [self setValue:@1 forKey:@"sex"];
    } else {
        [super setNilValueForKey:key];
    }
}

-(void)setName:(NSString *)name {
    _name = name;
}

- (BOOL)validateValue:(inout id  _Nullable __autoreleasing *)ioValue forKey:(NSString *)inKey error:(out NSError *__autoreleasing  _Nullable *)outError {
    NSNumber *age = *ioValue;
    if (age.integerValue == 10) {
        return NO;
    }
    return YES;
}


// 返回no，则不能通过KVC访问私有变量和属性
+ (BOOL)accessInstanceVariablesDirectly {
    return YES;
}


@end
