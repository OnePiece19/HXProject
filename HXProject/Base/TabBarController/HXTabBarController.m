//
//  HXTabBarController.m
//  HXProject
//
//  Created by hx on 2021/6/29.
//

#import "HXTabBarController.h"
#import "HXHomeViewController.h"
#import "HXUIHomeViewController.h"


@interface HXTabBarController ()

@property (nonatomic,strong) NSMutableArray * VCS;

@end

@implementation HXTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpTabBar];
    [self setUpAllChildViewController];
}


- (void)setUpTabBar {
    [self.tabBar setBackgroundColor:[UIColor whiteColor]];
    [self.tabBar setBackgroundImage:[UIImage new]];
}

-(void)setUpAllChildViewController{
    _VCS = @[].mutableCopy;
    
   
    
    HXHomeViewController * homeVC = [[HXHomeViewController alloc] init];
    [self setupChildViewController:homeVC title:@"首页" imageName:@"tab_homeInfo" seleceImageName:@"tab_homeInfoLight"];
    
    
    HXUIHomeViewController * UIHomeVC = [[HXUIHomeViewController alloc] init];
    [self setupChildViewController:UIHomeVC title:@"UI" imageName:@"tab_homeInfo" seleceImageName:@"tab_homeInfoLight"];
    
    
////    NSString * userid = userManager.curUserInfo.user_id;
////    NSString * url = [NSString stringWithFormat:@"http://party-tools-web.t.eoffcn.com/formlist?user=%@",userid];
////    PBActivityViewController * activityVC = [[PBActivityViewController alloc] initWithUrl:url];
////    [self setupChildViewController:activityVC title:@"活动" imageName:@"tab_activity" seleceImageName:@"tab_activityLight"];
//
//    PBMineViewController * mineVC = [[PBMineViewController alloc] init];
//    [self setupChildViewController:mineVC title:@"我的" imageName:@"tab_mine" seleceImageName:@"tab_mineLight"];
    self.viewControllers = _VCS;
    self.selectedIndex = 0;
    
}

-(void)setupChildViewController:(UIViewController*)controller title:(NSString *)title imageName:(NSString *)imageName seleceImageName:(NSString *)selectImageName{
    controller.title = title;
    controller.tabBarItem.title = title;
    controller.tabBarItem.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    controller.tabBarItem.selectedImage = [[UIImage imageNamed:selectImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    //未选中字体颜色
    [controller.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:CTabFontColor,
                                                    NSFontAttributeName:SYSTEMFONT(10.0f)}
                                         forState:UIControlStateNormal];
    //选中字体颜色
    [controller.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:CTabFontColorLight,
                                                    NSFontAttributeName:SYSTEMFONT(10.0f)}
                                         forState:UIControlStateSelected];
    
    
    PBNavigationController * nav = [[PBNavigationController alloc] initWithRootViewController:controller];
    [_VCS addObject:nav];
}


@end
