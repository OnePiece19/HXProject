//
//  PBUtilsMacros.h
//  PartyBuild
//
//  Created by HX on 2019/6/25.
//  Copyright © 2019 非公党建. All rights reserved.
//

#ifndef PBUtilsMacros_h
#define PBUtilsMacros_h

/// 系统信息
#define kApplication          [UIApplication sharedApplication]
#define kAppWindow            [UIApplication sharedApplication].delegate.window
#define kAppDelegate          [AppDelegate shareAppDelegate]
#define kRootViewController   [UIApplication sharedApplication].delegate.window.rootViewController
#define kCurrentAPPVersion    [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define kBundleID             [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]
#define kCurrentSystemVersion [[UIDevice currentDevice].systemVersion doubleValue]
#define kCurrentLanguage      ([NSLocale preferredLanguages] objectAtIndex:0])

/// 判断iPhone系列
#define IPHONE_X \
({BOOL isPhoneX = NO;\
if (@available(iOS1.0, *)) {\
isPhoneX = kAppWindow.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})
#define IPHONE_5S   (kScreenHeight == 568.0)

/// 通知、用户偏好设置
#define kUserDefaults                            [NSUserDefaults standardUserDefaults]
#define kNotificationCenter                      [NSNotificationCenter defaultCenter]
#define kPostNotification(name,obj)              [[NSNotificationCenter defaultCenter] postNotificationName:name object:obj];
#define kPostNotificationInfo(name,obj,dict)     [[NSNotificationCenter defaultCenter] postNotificationName:name object:obj userInfo:dict]

/// 数据验证
#define StrValid(f) (f!=nil && [f isKindOfClass:[NSString class]] && ![f isEqualToString:@""])
#define SafeStr(f) (StrValid(f) ? f:@"")
#define HasString(str,key) ([str rangeOfString:key].location!=NSNotFound)

#define ValidStr(f) StrValid(f)
#define ValidDict(f) (f!=nil && [f isKindOfClass:[NSDictionary class]])
#define ValidArray(f) (f!=nil && [f isKindOfClass:[NSArray class]] && [f count]>0)
#define ValidNum(f) (f!=nil && [f isKindOfClass:[NSNumber class]])
#define ValidClass(f,cls) (f!=nil && [f isKindOfClass:[cls class]])
#define ValidData(f) (f!=nil && [f isKindOfClass:[NSData class]])

#define WeakSelf(type)  __weak typeof(type) weak##type = type;
#define StrongSelf(type)  __strong typeof(type) type = weak##type;

/// 定义UIImage对象
#define ImageWithFile(_pointer) [UIImage imageWithContentsOfFile:([[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@@%dx", _pointer, (int)[UIScreen mainScreen].nativeScale] ofType:@"png"])]
#define IMAGE_NAMED(name) [UIImage imageNamed:name]

/// View圆角、
#define ViewRadius(View, Radius)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES]

#define ViewBorderRadius(View, Radius, Width, Color)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES];\
[View.layer setBorderWidth:(Width)];\
[View.layer setBorderColor:[Color CGColor]]


/// 单例化一个类
#define SINGLETON_FOR_HEADER(className) \
\
+ (className *)shared##className;

#define SINGLETON_FOR_CLASS(className) \
\
+ (className *)shared##className { \
static className *shared##className = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
shared##className = [[self alloc] init]; \
}); \
return shared##className; \
}

/// 打印日志
#ifdef DEBUG
#define PBLog(...) printf("[%s] %s [第%d行]: %s\n", __TIME__ ,__PRETTY_FUNCTION__ ,__LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String])
#else
#define PBLog(...)
#endif

#endif /* PBUtilsMacros_h */
