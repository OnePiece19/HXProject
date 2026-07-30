//
//  HXMainContainer.m
//  HXProject
//
//  Created by hx on 2022/4/30.
//

#import "HXMainContainer.h"
#import "HXTabConfigureManager.h"
#import "HXHomeViewController.h"
#import "YYCustomTabBar.h"

#import <Lottie/Lottie.h>
#import <objc/runtime.h>

@interface HXMainContainer () <UITabBarControllerDelegate>

@property (nonatomic, strong) HXTabConfigureManager *tabConfigureManager;

@property (nonatomic, strong) NSMutableArray *tabBarLottieViewArray;

@end

@implementation HXMainContainer

- (void)viewDidLoad {
    [super viewDidLoad];
    object_setClass(self.tabBar, [YYCustomTabBar class]);
    [self setupViewControllers];
    [self customizeTabBarStyle];
    [self customizeTabBarItemsStyle];
    [self customizeTabBarItemsLottie];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.tabBar invalidateIntrinsicContentSize];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [super setSelectedIndex:selectedIndex];
    [self tabItemChangeToIndex:selectedIndex];
    self.lastSelectIdx = selectedIndex;
}

#pragma mark - privateMethods

- (void)setupViewControllers {
    NSArray *tabBarItemModelArray = self.tabConfigureManager.tabBarItemModelArray;

    // 3 个差异化 Tab: 知识 | 算法 | 防护
    NSArray *vcClasses = @[
        @"HXHomeViewController",           // Tab 0: 知识 (所有知识点分组)
        @"HXLeetCode.TouchNum",            // Tab 1: 算法 (HXLeetCode)
        @"HXCrashViewController",           // Tab 2: 防护 (Crash/Defender)
    ];

    NSMutableArray *navigationArr = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < tabBarItemModelArray.count && i < vcClasses.count; i++) {
        Class cls = NSClassFromString(vcClasses[i]);
        UIViewController *tempVC = nil;

        if (cls && [cls isSubclassOfClass:[UIViewController class]]) {
            tempVC = [[cls alloc] init];
        } else {
            // 兜底
            tempVC = [[UIViewController alloc] init];
            tempVC.view.backgroundColor = [UIColor whiteColor];
            tempVC.title = @"Coming Soon";
        }

        UINavigationController *tempNav = [[UINavigationController alloc] initWithRootViewController:tempVC];
        [navigationArr addObject:tempNav];
    }
    [self setViewControllers:navigationArr];
    self.selectedIndex = 0;
    self.delegate = self;
}

- (void)customizeTabBarStyle {
    UIImage *img;
    HXTabBarStyleModel *settingModel = self.tabConfigureManager.tabBarModel;
    if (settingModel.tabBackgroundColor) {
        img = [UIImage imageWithColor:[UIColor colorWithHexString:settingModel.tabBackgroundColor]];
    } else {
        img = [UIImage imageWithColor:[UIColor whiteColor]];
    }
    [self.tabBar setBackgroundImage:img];
    self.tabBar.layer.cornerRadius = 10;
    self.tabBar.barStyle = UIBarStyleDefault;
    if (@available(iOS 15.0, *)) {
        UITabBarAppearance *appearance = [UITabBarAppearance new];
        appearance.backgroundImage = img;
        [UITabBar appearance].standardAppearance = appearance;
        [UITabBar appearance].scrollEdgeAppearance = [UITabBar appearance].standardAppearance;
    }
}

- (void)customizeTabBarItemsStyle {
    NSInteger index = 0;
    for (UITabBarItem *item in [((HXMainContainer *)self).tabBar items]) {
        HXTabBarItemModel *itemModel = [self.tabConfigureManager.tabBarItemModelArray objectAtIndexSafely:index];

        item.tag = 100 + index;
        item.titlePositionAdjustment = UIOffsetMake(0, -20);
        item.imageInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        item.title = itemModel.title;
        // image
        UIImage *imageNormal = [self.tabConfigureManager getSourceImageNormalWithItemModel:itemModel];
        UIImage *imageSelected = [self.tabConfigureManager getSourceImageSelectedWithItemModel:itemModel];
        [item setImage:imageNormal];
        [item setSelectedImage:imageSelected];

        // text
        UIColor *normalColor = [UIColor colorWithHexString:[itemModel textColorNormal]];
        UIColor *selectColor = [UIColor colorWithHexString:[itemModel textColorSelected]];
        UIFont *titleFont = [UIFont boldSystemFontOfSize:11];
        NSDictionary *normalTColor = [NSDictionary dictionaryWithObjectsAndKeys:normalColor, NSForegroundColorAttributeName, titleFont, NSFontAttributeName, nil];
        NSDictionary *selectTColor = [NSDictionary dictionaryWithObjectsAndKeys:selectColor, NSForegroundColorAttributeName, titleFont, NSFontAttributeName, nil];
        [item setTitleTextAttributes:normalTColor forState:UIControlStateNormal];
        [item setTitleTextAttributes:selectTColor forState:UIControlStateSelected];
        self.tabBar.tintColor = selectColor;
        self.tabBar.unselectedItemTintColor = normalColor;
        item.titlePositionAdjustment = UIOffsetMake(0, 0);
        item.imageInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        index++;
    }
}

- (void)customizeTabBarItemsLottie {
    NSMutableArray *tabBarBtnArr = [NSMutableArray new];
    for (UIView *view in self.tabBar.subviews) {
        if ([view isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            [tabBarBtnArr addObjectSafely:view];
        }
    }
    [tabBarBtnArr sortUsingComparator:^NSComparisonResult(UIView *obj1, UIView *obj2) {
        return obj1.left > obj2.left;
    }];

    [self.tabBarLottieViewArray removeAllObjects];
    [tabBarBtnArr enumerateObjectsUsingBlock:^(UIView *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        HXTabBarItemModel *itemModel = [self.tabConfigureManager.tabBarItemModelArray objectAtIndexSafely:idx];
        for (UIImageView *imageView in obj.subviews) {
            if ([imageView isKindOfClass:NSClassFromString(@"UITabBarSwappableImageView")]) {
                NSString *lottieName = itemModel.imageLottie;
                NSBundle *lottieBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:lottieName ofType:@"bundle"]];
                LOTAnimationView *tabLottieView = [LOTAnimationView animationNamed:lottieName inBundle:lottieBundle];
                tabLottieView.backgroundColor = [UIColor clearColor];
                tabLottieView.loopAnimation = NO;
                tabLottieView.userInteractionEnabled = NO;
                [imageView addSubview:tabLottieView];

                CGSize lottieViewSize = CGSizeMake(28.0f, 28.0f);
                [tabLottieView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(lottieViewSize.width);
                    make.height.mas_equalTo(lottieViewSize.height);
                    make.centerX.bottom.equalTo(imageView);
                }];
                [self.tabBarLottieViewArray addObject:tabLottieView];
                if (idx == 0) {
                    tabLottieView.animationProgress = 1.0;
                    tabLottieView.hidden = NO;
                } else {
                    tabLottieView.hidden = YES;
                }
            }
        }
    }];
}

- (void)tabItemChangeToIndex:(NSUInteger)targetIndex {
    if (self.lastSelectIdx == targetIndex) {
        return;
    }
    for (LOTAnimationView *lottieView in self.tabBarLottieViewArray) {
        lottieView.hidden = YES;
        if (lottieView.animationProgress != 0.0) {
            lottieView.animationProgress = 0.0;
        } else {
            continue;
        }
    }
    LOTAnimationView *curLottieView = [self.tabBarLottieViewArray objectAtIndexSafely:targetIndex];
    if (curLottieView) {
        curLottieView.hidden = NO;
        [curLottieView playFromProgress:0.f toProgress:1.f withCompletion:NULL];
    }
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if (tabBarController.selectedIndex == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"tabBarControllerDidSelectViewControllerFirst" object:nil];
    }
    NSInteger newItemIndex = tabBarController.selectedIndex;
    if (newItemIndex != self.lastSelectIdx) {
        [self tabItemChangeToIndex:newItemIndex];
        self.lastSelectIdx = newItemIndex;
    }
}

#pragma mark - lazyload

- (HXTabConfigureManager *)tabConfigureManager {
    if (!_tabConfigureManager) {
        _tabConfigureManager = [[HXTabConfigureManager alloc] init];
    }
    return _tabConfigureManager;
}

- (NSMutableArray *)tabBarLottieViewArray {
    if (!_tabBarLottieViewArray) {
        _tabBarLottieViewArray = [NSMutableArray new];
    }
    return _tabBarLottieViewArray;
}

@end