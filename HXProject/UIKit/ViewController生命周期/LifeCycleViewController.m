//
//  ViewController.m
//  UIViewController的生命周期
//
//  Created by 蒲悦蓉 on 2019/9/22.
//  Copyright © 2019 蒲悦蓉. All rights reserved.
//

#import "LifeCycleViewController.h"
#import "TesTViewController.h"
#import "ClickPushViewController.h"
#import "ClickPopViewController.h"
@interface LifeCycleViewController ()

@end

@implementation LifeCycleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor cyanColor];
    NSLog(@"\n\n界面   开始viewDidLoad");
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake(100, 150, 75, 40)];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button setTitle:@"present" forState:UIControlStateNormal];
    button.layer.borderWidth = 1;
    button.layer.cornerRadius = 10;
    button.layer.borderColor = [UIColor blackColor].CGColor;
    [button addTarget:self action:@selector(ClickPresent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    UIButton *button0 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button0 setFrame:CGRectMake(250, 150, 75, 40)];
    button0.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button0 setTitle:@"ClickPush" forState:UIControlStateNormal];
    button0.layer.borderWidth = 1;
    button0.layer.cornerRadius = 10;
    button0.layer.borderColor = [UIColor blackColor].CGColor;
    [button0 addTarget:self action:@selector(ClickPush:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button0];
    NSLog(@"\n\n界面2  viewDidLoad结束");
    NSLog(@"\n\n界面   结束viewDidLoad");
}
- (void)ClickPresent:(UIButton*)btn {
    TesTViewController *VC = [[TesTViewController alloc] init];
    [self presentViewController:VC animated:YES completion:nil];
}
- (void)ClickPush:(UIButton*)btn {
    ClickPushViewController *pushVC = [[ClickPushViewController alloc] init];
    UINavigationController *pushNav = [[UINavigationController alloc] initWithRootViewController:pushVC];
    ClickPopViewController *popVC = [[ClickPopViewController alloc] init];
    UINavigationController *popNav = [[UINavigationController alloc] initWithRootViewController:popVC];
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = [NSMutableArray arrayWithObjects:pushNav, popNav, nil];
    self.view.window.rootViewController = tabBarController;
    
    [self.view.window makeKeyAndVisible];
    [self removeFromParentViewController];
}
- (void)loadView {
    NSLog(@"\n\n界面1  loadView");
    [super loadView];
}

/*x出现*/
- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"\n\n界面1  viewWillAppear");
}
/*布局*/
- (void)viewWillLayoutSubviews {
    NSLog(@"\n\n界面1  viewWillLayoutSubviews");
    [super viewWillLayoutSubviews];
}

// view 已经布局其 Subviews
- (void)viewDidLayoutSubviews {
    NSLog(@"\n\n界面1  viewDidLayoutSubviews");
    [super viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"\n\n界面1  viewDidAppear");
}
/*消失*/
- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"\n\n界面1  viewWillDisappear");
}
- (void)viewDidDisappear:(BOOL)animated {
    NSLog(@"\n\n界面1  viewDidDisappear");
}

- (void)didReceiveMemoryWarning {
    NSLog(@"%s", __FUNCTION__);
    [super didReceiveMemoryWarning];
}
- (void)dealloc {
    NSLog(@"\n\n界面1  dealloc");
}
@end
