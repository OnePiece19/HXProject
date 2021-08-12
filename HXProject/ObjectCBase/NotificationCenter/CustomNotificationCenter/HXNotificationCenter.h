//
//  HXNotificationCenter.h
//  HXProject
//
//  Created by HX on 2021/8/12.
//

#import <Foundation/Foundation.h>
#import "HXObserverInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXNotificationCenter : NSObject

+ (instancetype)defaultCenter;

/* 添加观察者 */
- (void)addObserver:(id)observer selector:(SEL)aSelector name:(nullable NSNotificationName)aName object:(nullable id)anObject;

- (void)addObserverForName:(nullable NSNotificationName)name observer:(nullable id)observer queue:(nullable NSOperationQueue *)queue usingBlock:(void (^)(HXObserverInfo *info))block;

/* 发送通知 */
- (void)postNotification:(NSNotification *)notification;

- (void)postNotificationName:(NSNotificationName)aName;

- (void)postNotificationName:(NSNotificationName)aName object:(nullable id)anObject;

- (void)postNotificationName:(NSNotificationName)aName object:(nullable id)anObject userInfo:(nullable NSDictionary *)aUserInfo;

/* 移除观察者 */
- (void)removeObserver:(id)observer;

- (void)removeObserver:(id)observer name:(nullable NSNotificationName)aName object:(nullable id)anObject;


@end

NS_ASSUME_NONNULL_END
