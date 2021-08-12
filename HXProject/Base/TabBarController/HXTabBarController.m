//
//  HXTabBarController.m
//  HXProject
//
//  Created by hx on 2021/6/29.
//

#import "HXTabBarController.h"

#import "ViewController.h"

@interface HXTabBarController ()

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
    
    
    /** 测试代码
    PBLoginViewController * loginVC = [[PBLoginViewController alloc] initWithNibName:@"PBLoginViewController" bundle:[NSBundle mainBundle]];
    [self setupChildViewController:loginVC title:@"登录" imageName:@"home_page" seleceImageName:@"home_page"];

    PBTestViewController * homeVC2 = [[PBTestViewController alloc] init];
    [self setupChildViewController:homeVC2 title:@"测试" imageName:@"home_page" seleceImageName:@"home_page"];
     */
    
    ViewController * temp = [[ViewController alloc] init];
    temp.view.backgroundColor = [UIColor grayColor];
    temp.title = @"基础OC";
    temp.tabBarItem.title = @"基础OC";
    
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:temp];
    
    self.viewControllers = @[nav];
    self.selectedIndex = 0;
}



@end
