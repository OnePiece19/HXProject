//
//  UITabBarItem+Badge.m
//  homeworkFrame
//
//  Created by 汤冉阳 on 2020/5/26.
//  Copyright © 2020 冯天宇. All rights reserved.
//

#import "UITabBarItem+Badge.h"
#import "UIView+Badge.h"

@implementation UITabBarItem (Badge)
- (void)showBadgePoint {
    [[self getActualTabBarBadgeSuperView] showBadgePoint];
}

- (void)showBadgeWithNumber:(NSInteger)showNum {
    [[self getActualTabBarBadgeSuperView] showBadgeWithNumber:showNum];
}

- (void)showBadgeWithText:(NSString *)showText {
    [[self getActualTabBarBadgeSuperView] showBadgeWithText:showText];
}

- (void)removeBadgeValue {
    [[self getActualTabBarBadgeSuperView] removeBadgeValue];
}

- (void)showBadgePointWithColorStr:(NSString*)colorStr {
    [[self getActualTabBarBadgeSuperView] showBadgePointWithColorStr:colorStr];
}

- (void)showBadgeWithNumber:(NSInteger)showNum ColorStr:(NSString*)colorStr {
    [[self getActualTabBarBadgeSuperView] showBadgeWithNumber:showNum ColorStr:colorStr];
}

- (void)showBadgeWithText:(NSString *)showText ColorStr:(NSString*)colorStr {
    [[self getActualTabBarBadgeSuperView] showBadgeWithText:showText ColorStr:colorStr];
}

- (UIView *)getActualTabBarBadgeSuperView {
    UIView *tabbarButton = [self valueForKeyPath:@"_view"];
//    id superView = tabbarButton.superview;
    UIView *badgeView = [tabbarButton.superview viewWithTag:999 + self.tag];
    if (!badgeView) {
        badgeView = [[UIView alloc] initWithFrame:tabbarButton.frame];
        badgeView.backgroundColor = [UIColor clearColor];
        badgeView.tag = 999 + self.tag;
        badgeView.userInteractionEnabled = NO;
        [tabbarButton.superview addSubview:badgeView];
    }
    CGFloat pWith = (tabbarButton.width - self.image.size.width)*0.5;
    badgeView.badgeCenterOffset = CGPointMake(-pWith, 7);
    return badgeView;
}


@end
