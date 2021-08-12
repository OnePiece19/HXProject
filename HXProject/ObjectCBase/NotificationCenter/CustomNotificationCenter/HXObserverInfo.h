//
//  HXObserverInfo.h
//  HXProject
//
//  Created by HX on 2021/8/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXObserverInfo : NSObject

@property (nonatomic, weak) id observer;                        // 观察者

@property (nonatomic, assign) SEL aSelector;                    // 方法

@property (nonatomic, copy, nonnull) NSNotificationName name;   // 通知名称

@property (nonatomic, strong) id object;                        // 对象

@property (nonatomic, strong) NSDictionary *userInfo;           // 消息


@property (nonatomic, strong) NSOperationQueue *queue;

@property (nonatomic, copy) void (^block)(HXObserverInfo *info);


- (instancetype)initWithObserver:(id)observer selector:(SEL)aSelector name:(nullable NSNotificationName)aName object:(nullable id)anObject;

- (instancetype)initWithObserver:(id)observer name:(nullable NSNotificationName)aName queue:(nullable NSOperationQueue *)queue block:(void (^)(HXObserverInfo *info))block;

@end

NS_ASSUME_NONNULL_END
