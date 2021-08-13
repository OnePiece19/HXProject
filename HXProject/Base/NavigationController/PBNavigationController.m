//
//  PBNavigationController.m
//  PartyBuild
//
//  Created by HX on 2019/6/26.
//  Copyright © 2019 非公党建. All rights reserved.
//

#import "PBNavigationController.h"

@interface PBNavigationController ()<UINavigationControllerDelegate,UIGestureRecognizerDelegate>

@end

@implementation PBNavigationController

/**
+initialize方法和其他类一样，如果某个类未实现它，而其超类实现了，那么就会运行超类的实现代码。
 如果本身和超类都没有实现，超类的分类实现了，就会去调用分类的initialize方法。如果本身没有实现，超类和父类的分类实现了就会去调分类的initialize方法。
 不管是在超类中还是分类中实现initialize方法都会被调多次，调用顺序是SuperClass -->SubClass。
 APP生命周期中 只会执行一次
 */
+ (void)initialize {
    
    UINavigationBar *navBar = [UINavigationBar appearance];

    [navBar setBarTintColor:CNavBgColor];
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName :CNavBgFontColor,
                                     NSFontAttributeName : [UIFont systemFontOfSize:18]}];
    
    [navBar setBackgroundImage:[UIImage imageWithColor:CNavBgColor] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    //去掉阴影线
    [navBar setShadowImage:[UIImage new]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    //默认开启系统右划返回
    self.interactivePopGestureRecognizer.enabled = YES;
    self.interactivePopGestureRecognizer.delegate = self;
}

/** 根视图禁用右划返回 */
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return self.childViewControllers.count == 1 ? NO : YES;
}

/** push时隐藏tabbar */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count > 0) {
#warning 如何增加专场动画？
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}

/**
 * 判断是否隐藏导航栏
 *
 * UINavigationControllerDelegate Method
 */
-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController isKindOfClass:[PBViewController class]]) {
        PBViewController * vc = (PBViewController *)viewController;
        if (vc.isHidenNavBar) {
            [vc.navigationController setNavigationBarHidden:YES animated:animated];
        }else{
            [vc.navigationController setNavigationBarHidden:NO animated:animated];
        }
    }
}

/**
 *  返回到指定的类视图
 *
 *  @param ClassName 类名
 *  @param animated  是否动画
 */
-(BOOL)popToAppointViewController:(NSString *)ClassName animated:(BOOL)animated {
    id vc = [self getCurrentViewControllerClass:ClassName];
    if(vc != nil && [vc isKindOfClass:[UIViewController class]]) {
        [self popToViewController:vc animated:animated];
        return YES;
    }
    return NO;
}

/**
 *  获得当前导航器显示的视图
 *
 *  @param ClassName 要获取的视图的名称
 *
 *  @return 成功返回对应的对象，失败返回nil;
 */
-(instancetype)getCurrentViewControllerClass:(NSString *)ClassName {
    Class classObj = NSClassFromString(ClassName);
    NSArray * szArray = self.viewControllers;
    for (id vc in szArray) {
        if([vc isMemberOfClass:classObj]) {
            return vc;
        }
    }
    return nil;
}

@end
