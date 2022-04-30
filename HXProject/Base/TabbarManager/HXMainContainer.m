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
    // intrinsicContentSize的属性来获取内置大小,通过invalidateIntrinsicContentSize方法来在下次UI规划事件中重新计算intrinsicContentSize。
    // 如果直接创建一个原始的UIView对象，显然它的内置大小为0
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
    NSArray * tabBarItemModelArray = self.tabConfigureManager.tabBarItemModelArray;
    
    NSMutableArray *navigationArr = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < tabBarItemModelArray.count; i++) {
        /*
        HXTabBarItemModel *ItemModel = [tabBarItemModelArray objectAtIndex:i];
        YYTabCommonVC *tempVC = [[YYTabCommonVC alloc] init];
        YYBaseNavViewController *tempNav = [[YYBaseNavViewController alloc] initWithRootViewController:tempVC];
        tempVC.currentTabModel = ItemModel;
         */
        HXHomeViewController *tempVC = [[HXHomeViewController alloc] init];
        UINavigationController *tempNav = [[UINavigationController alloc] initWithRootViewController:tempVC];

        [navigationArr addObject:tempNav];
    }
    [self setViewControllers:navigationArr];
    self.selectedIndex = KTabBarSelectIndexCourse;
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
    if (@available(iOS 15.0, *)) { /*在ios15，有变透明的坑*/
        UITabBarAppearance * appearance = [UITabBarAppearance new];
        appearance.backgroundImage = img;
        [UITabBar appearance].standardAppearance = appearance;
        [UITabBar appearance].scrollEdgeAppearance = [UITabBar appearance].standardAppearance ;
    }
}

- (void)customizeTabBarItemsStyle {

    NSInteger index = 0;
    for (UITabBarItem *item in [((HXMainContainer *)self).tabBar items]) {
        HXTabBarItemModel * itemModel = [self.tabConfigureManager.tabBarItemModelArray objectAtIndexSafely:index];
        
        item.tag = 100 + index;
        item.titlePositionAdjustment = UIOffsetMake(0, -20);
        item.imageInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        item.title = itemModel.title;
        // image
        UIImage *imageNormal = [self.tabConfigureManager getSourceImageNormalWithItemModel:itemModel];
        UIImage *imageSelected = [self.tabConfigureManager getSourceImageSelectedWithItemModel:itemModel];
        [item setImage:imageNormal];
        [item setSelectedImage:imageSelected];
//        [item setSelectedImage:[[UIImage imageWithColor:[UIColor whiteColor]size:imageSelected.size] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        
        // text
        UIColor *notmalColor = [UIColor colorWithHexString:[itemModel textColorNormal]];
        UIColor *selectColor = [UIColor colorWithHexString:[itemModel textColorSelected]];
        UIFont *titleFont = [UIFont boldSystemFontOfSize:11];
        NSDictionary *normalTColor = [NSDictionary dictionaryWithObjectsAndKeys:notmalColor, NSForegroundColorAttributeName, titleFont, NSFontAttributeName, nil];
        NSDictionary *selectTColor = [NSDictionary dictionaryWithObjectsAndKeys:selectColor, NSForegroundColorAttributeName, titleFont, NSFontAttributeName, nil];
        [item setTitleTextAttributes:normalTColor forState:UIControlStateNormal];
        [item setTitleTextAttributes:selectTColor forState:UIControlStateSelected];
        self.tabBar.tintColor = selectColor;
        self.tabBar.unselectedItemTintColor = notmalColor;
        item.titlePositionAdjustment = UIOffsetMake(0, 0);
        item.imageInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        index++;
    }
}

- (void)customizeTabBarItemsLottie {

    // https://blog.csdn.net/jeffasd/article/details/50801873
    
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
    [tabBarBtnArr enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HXTabBarItemModel * itemModel = [self.tabConfigureManager.tabBarItemModelArray objectAtIndexSafely:idx];
        for (UIImageView *imageView in obj.subviews) {
            if ([imageView isKindOfClass:NSClassFromString(@"UITabBarSwappableImageView")]) {
                NSString *lottieName = itemModel.imageLottie;
                NSBundle *lottieBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:lottieName ofType:@"bundle"]];
                LOTAnimationView *tabLottieView = [LOTAnimationView animationNamed:lottieName inBundle:lottieBundle];
                tabLottieView.backgroundColor = [UIColor clearColor];
                tabLottieView.loopAnimation = NO;
                tabLottieView.userInteractionEnabled = NO;
                [imageView addSubview:tabLottieView];
                
                CGSize lottieViewSize = CGSizeMake(28.0f,28.0f);
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
        }else{
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
    if(tabBarController.selectedIndex == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"tabBarControllerDidSelectViewControllerFirst" object:nil];
    }
    NSInteger newItemIndex= tabBarController.selectedIndex;
    if (newItemIndex == self.lastSelectIdx) {
        //发送一些通知，比如说，点击选中的按钮控制器tableview滚动到起始位置
    } else {
        // 隐藏上次选中的tabItem的Lottie视图
        [self tabItemChangeToIndex:newItemIndex];
        self.lastSelectIdx = newItemIndex;
    }
    if (tabBarController.selectedIndex == 1) {
//        [ZYBTabBarTipsViewPlugin hide];
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


