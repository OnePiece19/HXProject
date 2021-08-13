//
//  PBFrameMacros.h
//  PartyBuild
//
//  Created by HX on 2019/7/2.
//  Copyright © 2019 非公党建. All rights reserved.
//

#ifndef PBFrameMacros_h
#define PBFrameMacros_h


/// 屏幕信息
#define KScreenBounds           [UIScreen mainScreen].bounds
#define KScreenWidth            [[UIScreen mainScreen] bounds].size.width
#define KScreenHeight           [[UIScreen mainScreen] bounds].size.height
#define kSystemStatusBarHeight  [[UIApplication sharedApplication] statusBarFrame].size.height


/** 导航栏高度 */
#define kNavBarHeight                       (44.0)
/** 状态栏的高度 */
#define kStatusBarHeight                    (CGFloat)(IPHONE_X ? (44.0):(20.0))
/** 状态栏和导航栏总高度 */
#define kNavBarAndStatusBarHeight           (CGFloat)(IPHONE_X ? (88.0):(64.0))
/** TabBar高度 */
#define kTabBarHeight                       (CGFloat)(IPHONE_X ? (49.0 + 34.0):(49.0))
/** 顶部安全区域远离高度 */
#define kTopBarSafeHeight                   (CGFloat)(IPHONE_X ? (44.0):(0))
/** 底部安全区域远离高度 */
#define kBottomSafeHeight                   (CGFloat)(IPHONE_X ? (34.0):(0))
/** 导航条和Tabbar总高度 */
#define kNavAndTabHeight                    (kNavBarAndStatusBarHeight + kTabBarHeight)


#endif /* PBFrameMacros_h */
