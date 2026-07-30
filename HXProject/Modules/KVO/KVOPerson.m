//
//  KVOPerson.m
//  HXProject
//
//  Created by HX on 2021/8/14.
//

#import "KVOPerson.h"

@interface KVOPerson ()

{
    NSString *privateVar;
}
@property (strong, nonatomic) NSString *privateProperty;

@end

@implementation KVOPerson

-(NSMutableArray *)mArray {
    if (!_mArray) {
        _mArray = [NSMutableArray array];
    }
    return _mArray;
}
/*
 可以在被观察对象的类中重写+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key方法来控制KVO的自动触发。
   如果我们只允许外界观察 person 的 name 属性，可以在 Person 类如下操作。这样外界就只能观察 name 属性，即使外界注册了对 person 对象其它属性的监听，那么在属性发生改变时也不会触发KVO。
 注意：

 第一个方法的优先级高于第二个方法。如果实现了automaticallyNotifiesObserversForKey:方法，并对<Key>做了处理，则系统就不会再调用该<Key>的automaticallyNotifiesObserversOf<Key>方法。
 options指定的NSKeyValueObservingOptionInitial触发的KVO通知，是无法被automaticallyNotifiesObserversForKey:阻止的。
 */

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    BOOL automatic = NO;
    if ([key isEqualToString:@"sex"] || [key isEqualToString:@"address"]) {
        automatic = NO;
    } else {
        automatic = [super automaticallyNotifiesObserversForKey:key];
    }
    return automatic;
}

+ (BOOL)automaticallyNotifiesObserversOfSex{
    return NO;
}

/*
 有时候我们可能会有这样的需求，KVO监听的属性值修改前后相等的时候，不触发KVO的监听方法，可以结合KVO的自动触发控制和手动触发来实现。
 */
- (void)setAddress:(NSString *)address {
    if (![_address isEqualToString:address]) {
        [self willChangeValueForKey:@"address"];
        _address = address;
        [self didChangeValueForKey:@"address"];
    }
}

@end
