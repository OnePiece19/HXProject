//
//  UITabBarItem+Badge.h
//  homeworkFrame
//
//  Created by 汤冉阳 on 2020/5/26.
//  Copyright © 2020 冯天宇. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    YYTabBarBadgeStyleRedDot,
    YYTabBarBadgeStyleNumber,
    YYTabBarBadgeStyleString,
} YYTabBarBadgeStyle;



@interface UITabBarItem (Badge)
- (void)showBadgePoint;
- (void)showBadgeWithNumber:(NSInteger)showNum;
- (void)showBadgeWithText:(NSString *)showText;
- (void)showBadgePointWithColorStr:(NSString*)colorStr;
- (void)showBadgeWithNumber:(NSInteger)showNum ColorStr:(NSString*)colorStr;
- (void)showBadgeWithText:(NSString *)showText ColorStr:(NSString*)colorStr;
- (void)removeBadgeValue;
@end

NS_ASSUME_NONNULL_END
