//
//  ClickPushViewController.m
//  UIViewController的生命周期
//
//  Created by 蒲悦蓉 on 2019/9/24.
//  Copyright © 2019 蒲悦蓉. All rights reserved.
//

#import "ClickPushViewController.h"
#import "ClickPopViewController.h"
@interface ClickPushViewController ()

@end

@implementation ClickPushViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"clickPush";
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake(100, 150, 75, 40)];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button setTitle:@"clickPush" forState:UIControlStateNormal];
    button.layer.borderWidth = 1;
    button.layer.cornerRadius = 10;
    button.layer.borderColor = [UIColor blackColor].CGColor;
    [button addTarget:self action:@selector(ClickPush:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    // Do any additional setup after loading the view.
}
- (void)ClickPush:(UIButton*)btn {
    ClickPopViewController *popVC = [[ClickPopViewController alloc] init];
    [self.navigationController pushViewController:popVC animated:YES];
}
- (void)loadView {
    NSLog(@"\n\n点击Push界面  loadView");
    [super loadView];
}

/*x出现*/
- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"\n\n点击Push界面  viewWillAppear");
}
/*布局*/
- (void)viewWillLayoutSubviews {
    NSLog(@"\n\n点击Push界面  viewWillLayoutSubviews");
    [super viewWillLayoutSubviews];
}

// view 已经布局其 Subviews
- (void)viewDidLayoutSubviews {
    NSLog(@"\n\n点击Push界面  viewDidLayoutSubviews");
    [super viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"\n\n点击Push界面  viewDidAppear");
}
/*消失*/
- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"\n\n点击Push界面  viewWillDisappear");
}
- (void)viewDidDisappear:(BOOL)animated {
    NSLog(@"\n\n点击Push界面  viewDidDisappear");
}

- (void)didReceiveMemoryWarning {
    NSLog(@"%s", __FUNCTION__);
    [super didReceiveMemoryWarning];
}
- (void)dealloc {
    NSLog(@"\n\n点击Push界面  dealloc");
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
