//
//  HXObserverInfo.m
//  HXProject
//
//  Created by HX on 2021/8/12.
//

#import "HXObserverInfo.h"

@implementation HXObserverInfo

- (instancetype)initWithObserver:(id)observer selector:(SEL)aSelector name:(nullable NSNotificationName)aName object:(nullable id)anObject {
    if (!aName || !aName.length) {
        return nil;
    }
    self = [super init];
    if (self) {
        self.observer = observer;
        self.aSelector = aSelector;
        self.name = aName;
        self.object = anObject;
    }
    return self;
}

- (instancetype)initWithObserver:(id)observer name:(nullable NSNotificationName)aName queue:(nullable NSOperationQueue *)queue block:(void (^)(HXObserverInfo *info))block {
    if (!aName || !aName.length) {
        return nil;
    }
    self = [super init];
    if (self) {
        self.observer = observer;
        self.name = aName;
        self.block = block;
        self.queue = queue;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (!object || ![object isKindOfClass:[HXObserverInfo class]]) {
        return NO;
    }
    HXObserverInfo *newInfo = (HXObserverInfo *)object;
    if (self.observer == newInfo.observer && self.object == newInfo.object && self.aSelector == newInfo.aSelector && self.queue == newInfo.queue && self.block == newInfo.block) {
        return YES;
    }
    return NO;
}

@end
