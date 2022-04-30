//
//  UIView+Badge.m
//  homeworkFrame
//
//  Created by 汤冉阳 on 2020/5/26.
//  Copyright © 2020 冯天宇. All rights reserved.
//

#import "UIView+Badge.h"
#import <objc/runtime.h>
#import <YYCategories/YYCategoriesMacro.h>

#define KBadgeBGColor [UIColor colorWithRed:251/255.0 green:85/255.0 blue:85/255.0 alpha:1.0]

static char badgeCenterOffsetKey;

@implementation UIView (Badge)

- (void)showBadgePoint {
    [self showBadgePointWithColorStr:@"FB5555"];
}

- (void)showBadgeWithNumber:(NSInteger)showNum {
    [self showBadgeWithNumber:showNum ColorStr:@"FB5555"];
}

- (void)showBadgeWithText:(NSString *)showText {
    [self showBadgeWithText:showText ColorStr:@"FB5555"];
}

- (void)showBadgePointWithColorStr:(NSString*)colorStr {
    [self removeBadgeValue];
    [self bgBadgeViewInit];
    self.badgeTextLabel.hidden = YES;
    CGFloat pointWidth = 5;
    self.bgBadgeView.bounds = CGRectMake(0, 0, pointWidth, pointWidth);
    self.bgBadgeView.layer.cornerRadius = pointWidth*0.5;
    //    self.bgBadgeView.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6].CGColor;
    //    self.bgBadgeView.layer.borderWidth = 1;
    self.bgBadgeView.backgroundColor = [UIColor colorWithHexString:colorStr];
    CGPoint point = CGPointMake(CGRectGetWidth(self.bounds) + 2 + self.badgeCenterOffset.x, self.badgeCenterOffset.y);
    self.bgBadgeView.center = point;
    
}

- (void)showBadgeWithNumber:(NSInteger)showNum ColorStr:(NSString*)colorStr {
    [self removeBadgeValue];
    if (showNum <= 0) {
        return;
    }
    CGFloat pointWidth = 14;
    
    [self bgBadgeViewInit];
    self.badgeTextLabel.hidden = NO;
    NSString *showText = [NSString stringWithFormat:@"%zd",showNum];
    if (showText.length > 2) {
        showText = @"...";
        self.badgeTextLabel.width = 14;
    } else if (showText.length > 1) {
        showText = [NSString stringWithFormat:@"%zd",showNum];
        self.badgeTextLabel.width = 20;
    } else {
        showText = [NSString stringWithFormat:@"%zd",showNum];
        self.badgeTextLabel.width = 14;
    }
    self.badgeTextLabel.height = 14;
    self.badgeTextLabel.text = showText;
    self.badgeTextLabel.backgroundColor = [UIColor colorWithHexString:colorStr];
    self.bgBadgeView.bounds = CGRectMake(0, 0, self.badgeTextLabel.width, pointWidth);
    if (showText.length > 2) {
        self.badgeTextLabel.frame = CGRectMake(0, -3, self.badgeTextLabel.width, pointWidth);
    } else {
        self.badgeTextLabel.frame = self.bgBadgeView.bounds;
    }
    self.bgBadgeView.layer.cornerRadius = pointWidth*0.5;
    self.bgBadgeView.layer.masksToBounds = YES;
    self.bgBadgeView.backgroundColor = [UIColor colorWithHexString:colorStr];;
    [self.bgBadgeView.layer.mask removeFromSuperlayer];
    CGPoint point = CGPointMake(CGRectGetWidth(self.bounds) + 2 + self.badgeCenterOffset.x, self.badgeCenterOffset.y);
    self.bgBadgeView.center = point;
    NSLog(@"%@",NSStringFromCGRect(self.bgBadgeView.frame));
    
}

- (void)showBadgeWithText:(NSString *)showText ColorStr:(NSString*)colorStr {
    [self removeBadgeValue];
    if (showText && showText.length > 0) {
        CGFloat pointWidth = 14;
        
        [self bgBadgeViewInit];
        self.badgeTextLabel.hidden = NO;
        self.badgeTextLabel.text = showText;
        [self.badgeTextLabel sizeToFit];
        if (self.badgeTextLabel.width < 29) {
            self.badgeTextLabel.width = 29;
        } else {
            self.badgeTextLabel.width = self.badgeTextLabel.width + 10;
        }
        self.badgeTextLabel.height = 14;
        self.badgeTextLabel.backgroundColor = [UIColor colorWithHexString:colorStr];
        self.bgBadgeView.bounds = CGRectMake(0, 0, self.badgeTextLabel.width, pointWidth);
        self.badgeTextLabel.frame = self.bgBadgeView.bounds;
        self.bgBadgeView.layer.cornerRadius = 0;
        self.bgBadgeView.layer.masksToBounds = YES;
        self.bgBadgeView.backgroundColor = [UIColor colorWithHexString:colorStr];
        [self setPartRoundWithView:self.bgBadgeView];
        CGPoint point = CGPointMake(CGRectGetWidth(self.bounds) + 2 + self.badgeCenterOffset.x, self.badgeCenterOffset.y);
        self.bgBadgeView.center = point;
    }
}

- (void)bgBadgeViewInit {
    if (!self.bgBadgeView) {
        self.bgBadgeView = [[UIView alloc] init];
        
        [self badgeTextLabelInit];
        [self.bgBadgeView addSubview:self.badgeTextLabel];
        self.badgeTextLabel.hidden = YES;
        
        [self addSubview:self.bgBadgeView];
    }
}

- (void)badgeTextLabelInit {
    UIColor *badgeTextColor = [UIColor whiteColor];
    UIColor *badgeBgColor = [UIColor colorWithRed:254/255.0 green:59/255.0 blue:48/255.0 alpha:1];
    
    if (self.badgeTextLabel == nil) {
        CGFloat redotWidth = 6;
        CGRect frm = CGRectMake(CGRectGetWidth(self.bounds), -redotWidth, redotWidth, redotWidth);
        self.badgeTextLabel = [[UILabel alloc] initWithFrame:frm];
        self.badgeTextLabel.textAlignment = NSTextAlignmentCenter;
        self.badgeTextLabel.backgroundColor = badgeBgColor;
        self.badgeTextLabel.textColor = badgeTextColor;
        self.badgeTextLabel.text = @"";
        self.badgeTextLabel.font = [UIFont systemFontOfSize:10];
        self.badgeTextLabel.layer.cornerRadius = CGRectGetWidth(self.badgeTextLabel.frame) / 2;
        self.badgeTextLabel.layer.masksToBounds = YES;//very important
        self.badgeTextLabel.hidden = NO;
    }
}

- (void)removeBadgeValue {
    if (self.bgBadgeView) {
        [self.bgBadgeView removeFromSuperview];
        self.bgBadgeView = nil;
    }
}

YYSYNTH_DYNAMIC_PROPERTY_OBJECT(bgBadgeView, setBgBadgeView, RETAIN_NONATOMIC, UIView *)
YYSYNTH_DYNAMIC_PROPERTY_OBJECT(badgeTextLabel, setBadgeTextLabel, RETAIN_NONATOMIC, UILabel *)
- (CGPoint)badgeCenterOffset {
    id obj = objc_getAssociatedObject(self, &badgeCenterOffsetKey);
    if (obj != nil && [obj isKindOfClass:[NSDictionary class]] && [obj count] == 2) {
        CGFloat x = [obj[@"x"] floatValue];
        CGFloat y = [obj[@"y"] floatValue];
        return CGPointMake(x, y);
    } else
        return CGPointZero;
}

- (void)setBadgeCenterOffset:(CGPoint)badgeCenterOff {
    NSDictionary *cenerInfo = @{@"x" : @(badgeCenterOff.x), @"y" : @(badgeCenterOff.y)};
    objc_setAssociatedObject(self, &badgeCenterOffsetKey, cenerInfo, OBJC_ASSOCIATION_RETAIN);
}

- (void)setPartRoundWithView:(UIView *)view {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight |UIRectCornerBottomRight cornerRadii:CGSizeMake(7, 7)].CGPath;
    view.layer.mask = shapeLayer;
}
@end
